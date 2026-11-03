import AVFoundation
import OSLog

// Playback state is owned by the main queue; synthesis never touches the graph.
final class AudioEngine {
    private var engine = AVAudioEngine()
    private var soundMixer = AVAudioMixerNode()
    private var musicMixer = AVAudioMixerNode()
    private var anthemPlayer = AVAudioPlayerNode()
    private var soundPreviewPlayer = AVAudioPlayerNode()
    private var musicPreviewPlayer = AVAudioPlayerNode()
    private var voices: [AudioVoice] = []
    private let library: SoundLibrary
    private let logger = Logger(subsystem: "com.marconius.WordBop", category: "Audio")
    private var observers: [NSObjectProtocol] = []
    private var sessionActive = false
    private var interrupted = false
    private var interruptedAnthem: (() -> TimeInterval)?
    private var interruptedChimes: PowerUpPlayback?
    private var suspended = false
    private(set) var gameplayActive = false
    private(set) var selectNoteIndex = 0
    private(set) var engineStartCount = 0
    private(set) var scheduledSoundCount = 0
    private(set) var staleSoundCount = 0
    private(set) var lastSchedulingDelay: TimeInterval = 0
    private var graphGeneration = 0
    private var generation = 0
    private var requestSequence = 0
    private var lastSoundRequest = 0
    private var lastMusicRequest = 0
    private var idleWorkItem: DispatchWorkItem?
    private var powerUpTimer: Timer?
    private var powerUpStartedAt: TimeInterval = 0
    private var powerUpDuration: Double = 15
    private var powerUpChimeStep = 0
    private var powerUpGeneration = 0
    private let anthemQueue = DispatchQueue(label: "com.wordbopper.anthem", qos: .utility)
    private var anthemBuffer: AVAudioPCMBuffer?
    private var preparingAnthem = false
    private var anthemElapsed: (() -> TimeInterval)?
    private var anthemGeneration = 0
    private var anthemPlaying = false
    private(set) var previewPlayCount = 0
    private var previewGeneration = 0
    private var previewWorkItem: DispatchWorkItem?
    private var previewEndsAt: TimeInterval = 0
    private var lastPreviewAt: TimeInterval = -.infinity

    var soundVolume: Float = 0.82 {
        didSet { soundMixer.outputVolume = Self.clamp(soundVolume) }
    }
    var musicVolume: Float = 0.82 {
        didSet { musicMixer.outputVolume = Self.clamp(musicVolume) }
    }

    init(library: SoundLibrary = .shared) {
        self.library = library
        setupEngine()
        observeAudioChanges()
    }

    deinit {
        observers.forEach(NotificationCenter.default.removeObserver)
        idleWorkItem?.cancel()
        previewWorkItem?.cancel()
        powerUpTimer?.invalidate()
        engine.stop()
    }

    private static func clamp(_ value: Float) -> Float {
        value.isFinite ? min(max(value, 0), 1) : 0
    }

    var isRunning: Bool { engine.isRunning }
    var activeSoundVoiceCount: Int { voices.filter { $0.isSound && $0.busy }.count }
    var activeMusicVoiceCount: Int { voices.filter { !$0.isSound && $0.busy }.count }

    private func setupEngine() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        engine.attach(soundMixer)
        engine.attach(musicMixer)
        engine.connect(soundMixer, to: engine.mainMixerNode, format: format)
        engine.connect(musicMixer, to: engine.mainMixerNode, format: format)
        for (player, mixer) in [(anthemPlayer, musicMixer), (soundPreviewPlayer, soundMixer), (musicPreviewPlayer, musicMixer)] {
            engine.attach(player)
            engine.connect(player, to: mixer, format: format)
        }
        // Six voices are reserved for immediate feedback; music cannot occupy them.
        for index in 0..<18 {
            let player = AVAudioPlayerNode()
            engine.attach(player)
            engine.connect(player, to: index < 6 ? soundMixer : musicMixer, format: format)
            voices.append(AudioVoice(player: player, isSound: index < 6))
        }
        soundMixer.outputVolume = Self.clamp(soundVolume)
        musicMixer.outputVolume = Self.clamp(musicVolume)
    }

    @discardableResult
    private func startEngine() -> Bool {
        guard !suspended, !interrupted else { return false }
        if engine.isRunning { return true }
        do {
            let session = AVAudioSession.sharedInstance()
            if !sessionActive {
                try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try session.setActive(true)
                sessionActive = true
            }
            engine.prepare()
            try engine.start()
            engineStartCount += 1
            logger.debug("Audio started: buffer \(session.ioBufferDuration), output latency \(session.outputLatency), sample rate \(session.sampleRate)")
            return true
        } catch {
            logger.error("Audio startup failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    func setGameplayActive(_ active: Bool) {
        gameplayActive = active
        if active {
            suspended = false
            idleWorkItem?.cancel()
            startEngine()
        } else {
            generation += 1 // Discard cold requests from the round that just paused or ended.
            scheduleIdlePause()
        }
    }

    func resetSelectSound() { selectNoteIndex = 0 }
    func stepSelectSoundBack() { selectNoteIndex = max(0, selectNoteIndex - 1) }
    func playSelectSound() {
        request(.select(min(selectNoteIndex, 21)))
        selectNoteIndex += 1
    }
    func playDeselectSound() { request(.deselect) }
    func playInvalidSound() { request(.invalid) }
    func playBonusSound() { request(.bonus) }
    private func tier(_ count: Int) -> Int { count >= 7 ? 7 : count >= 5 ? 5 : 3 }
    func playWordSound(wordLength: Int) { request(.word(tier(wordLength))) }
    func playBopQuestWordSound(wordLength: Int) { request(.quest(tier(wordLength))) }
    func playConnectedWordSound(wordLength: Int) { request(.connected(tier(wordLength))) }
    func playChainStreakSound(streak: Int) { request(.streak(min(max(streak, 1), 3))) }
    func playChainMultiplierScoreSound(wordLength: Int) { request(.multiplier(tier(wordLength))) }
    func playDailyBopIntroSound() { request(.dailyIntro) }
    func playRoundStartSound() { playRoundStartSound(for: .timed) }
    func playRoundStartSound(for mode: GameMode) {
        switch mode {
        case .timed: request(.timedStart)
        case .bopple: request(.boppleStart)
        case .nonStop: request(.nonStopStart)
        }
    }
    func playPauseSound() { request(.pause) }
    func playResumeSound() { request(.resume) }
    func playRoundEndSound() { request(.roundEnd) }
    func playTickSound(secondsLeft: Int) { request(.tick(min(max(secondsLeft, 1), 10))) }

    private func request(_ cue: SoundCue, gain: Float = 1) {
        guard !suspended, !interrupted, (cue.isSound ? soundVolume : musicVolume) > 0 else { return }
        requestSequence += 1
        let sequence = requestSequence
        let requestedAt = ProcessInfo.processInfo.systemUptime
        let token = generation
        let chimeToken = powerUpGeneration
        library.buffer(for: cue) { [weak self] buffer in
            guard let self, token == self.generation, !self.suspended, !self.interrupted else { return }
            if case .powerUp = cue, chimeToken != self.powerUpGeneration { return }
            let delay = ProcessInfo.processInfo.systemUptime - requestedAt
            // Never replay a backlog of obsolete interactions after cold preparation.
            guard delay < 0.25, sequence > (cue.isSound ? self.lastSoundRequest : self.lastMusicRequest) else {
                self.staleSoundCount += 1
                self.logger.debug("Discarded late audio request after \(delay) seconds")
                return
            }
            guard let buffer else { self.logger.error("Sound preparation failed"); return }
            if cue.isSound { self.lastSoundRequest = sequence } else { self.lastMusicRequest = sequence }
            self.play(buffer, cue: cue, gain: gain, requestedAt: requestedAt)
        }
    }

    private func play(_ buffer: AVAudioPCMBuffer, cue: SoundCue, gain: Float, requestedAt: TimeInterval) {
        guard startEngine() else { return }
        let candidates = voices.indices.filter {
            voices[$0].isSound == cue.isSound && (!voices[$0].busy || voices[$0].cue.priority <= cue.priority)
        }
        guard let index = candidates.first(where: { !voices[$0].busy }) ??
                candidates.min(by: { voices[$0].startedAt < voices[$1].startedAt }) else { return }
        let wasBusy = voices[index].busy
        voices[index].token += 1
        let token = voices[index].token
        let graphToken = graphGeneration
        voices[index].busy = true
        voices[index].cue = cue
        voices[index].startedAt = ProcessInfo.processInfo.systemUptime
        let player = voices[index].player
        let schedule = { [weak self] in
            guard let self, self.graphGeneration == graphToken, self.voices[index].token == token, !self.suspended, !self.interrupted else { return }
            if wasBusy { player.stop() }
            player.volume = gain
            player.scheduleBuffer(buffer, completionCallbackType: .dataPlayedBack) { [weak self] _ in
                DispatchQueue.main.async {
                    guard let self, self.graphGeneration == graphToken, self.voices[index].token == token else { return }
                    self.voices[index].busy = false
                    self.scheduleIdlePause()
                }
            }
            if !player.isPlaying { player.play() }
            self.lastSchedulingDelay = ProcessInfo.processInfo.systemUptime - requestedAt
            self.scheduledSoundCount += 1
        }
        idleWorkItem?.cancel()
        if wasBusy {
            // A bounded 6 ms fade avoids a hard cut when the reserved pool is full.
            let initialVolume = player.volume
            for step in 1...3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * 0.002) { [weak self] in
                    guard let self, self.graphGeneration == graphToken, self.voices[index].token == token else { return }
                    player.volume = initialVolume * Float(3 - step) / 3
                    if step == 3 { schedule() }
                }
            }
        } else { schedule() }
    }

    func previewSoundVolume() { preview(.select(0)) }
    func previewMusicVolume() { preview(.musicPreview) }

    private func preview(_ cue: SoundCue) {
        suspended = false
        previewGeneration += 1
        let token = previewGeneration
        previewWorkItem?.cancel()
        let now = ProcessInfo.processInfo.systemUptime
        let wait = max(0, lastPreviewAt + 0.12 - now)
        let item = DispatchWorkItem { [weak self] in
            guard let self, self.previewGeneration == token, !self.interrupted, !self.suspended else { return }
            self.library.buffer(for: cue) { [weak self] buffer in
                guard let self, self.previewGeneration == token, !self.suspended, !self.interrupted,
                      let buffer, (cue.isSound ? self.soundVolume : self.musicVolume) > 0,
                      self.startEngine() else { return }
                self.lastPreviewAt = ProcessInfo.processInfo.systemUptime
                let player = cue.isSound ? self.soundPreviewPlayer : self.musicPreviewPlayer
                let schedule = { [weak self] in
                    guard let self, self.previewGeneration == token, !self.suspended, !self.interrupted else { return }
                    self.soundPreviewPlayer.stop()
                    self.musicPreviewPlayer.stop()
                    self.soundPreviewPlayer.volume = 1
                    self.musicPreviewPlayer.volume = 1
                    self.previewEndsAt = ProcessInfo.processInfo.systemUptime + Double(buffer.frameLength) / buffer.format.sampleRate
                    player.scheduleBuffer(buffer)
                    player.play()
                    self.previewPlayCount += 1
                    self.scheduleIdlePause()
                }
                if self.soundPreviewPlayer.isPlaying || self.musicPreviewPlayer.isPlaying {
                    let soundLevel = self.soundPreviewPlayer.volume
                    let musicLevel = self.musicPreviewPlayer.volume
                    for step in 1...3 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * 0.002) { [weak self] in
                            guard let self, self.previewGeneration == token else { return }
                            self.soundPreviewPlayer.volume = soundLevel * Float(3 - step) / 3
                            self.musicPreviewPlayer.volume = musicLevel * Float(3 - step) / 3
                            if step == 3 { schedule() }
                        }
                    }
                } else { schedule() }
            }
        }
        previewWorkItem = item
        if wait == 0 { item.perform() }
        else { DispatchQueue.main.asyncAfter(deadline: .now() + wait, execute: item) }
    }

    func stopVolumePreviews() {
        previewGeneration += 1
        previewWorkItem?.cancel()
        soundPreviewPlayer.stop()
        musicPreviewPlayer.stop()
        previewEndsAt = 0
        scheduleIdlePause()
    }

    func startPowerUpChimes(duration: Double) {
        stopPowerUpChimes()
        guard duration > 0 else { return }
        powerUpStartedAt = ProcessInfo.processInfo.systemUptime
        powerUpDuration = duration
        powerUpChimeStep = 0
        playNextPowerUpChime()
        powerUpTimer = Timer.scheduledTimer(withTimeInterval: duration / 13, repeats: true) { [weak self] _ in
            self?.playNextPowerUpChime()
        }
    }

    private func playNextPowerUpChime() {
        let elapsed = ProcessInfo.processInfo.systemUptime - powerUpStartedAt
        guard elapsed < powerUpDuration, powerUpChimeStep < 13 else { stopPowerUpChimes(); return }
        request(.powerUp(powerUpChimeStep), gain: Float(max(0.012 / 0.032, 1 - elapsed / powerUpDuration)))
        powerUpChimeStep += 1
    }

    func stopPowerUpChimes() {
        powerUpGeneration += 1
        powerUpTimer?.invalidate()
        powerUpTimer = nil
        for index in voices.indices {
            if case .powerUp = voices[index].cue {
                voices[index].token += 1
                voices[index].player.stop()
                voices[index].busy = false
            }
        }
        scheduleIdlePause()
    }

    func prepareDailyBopAnthemPreview() {
        guard anthemBuffer == nil, !preparingAnthem else { return }
        preparingAnthem = true
        anthemQueue.async { [weak self] in
            let buffer = SoundRenderer().makeDailyBopAnthemBuffer()
            DispatchQueue.main.async {
                guard let self else { return }
                self.anthemBuffer = buffer
                self.preparingAnthem = false
                self.playPreparedAnthem()
            }
        }
    }

    func playDailyBopAnthemPreview() { playDailyBopAnthem(elapsed: { 0 }) }
    func playDailyBopAnthem(elapsed: @escaping () -> TimeInterval) {
        anthemElapsed = elapsed
        if anthemBuffer != nil { playPreparedAnthem() }
        else { prepareDailyBopAnthemPreview() }
    }
    func stopDailyBopAnthem() {
        anthemGeneration += 1
        anthemElapsed = nil
        anthemPlaying = false
        anthemPlayer.stop()
        scheduleIdlePause()
    }

    private func playPreparedAnthem() {
        guard let buffer = anthemBuffer, let elapsed = anthemElapsed, !suspended, !interrupted else { return }
        anthemGeneration += 1
        let token = anthemGeneration
        let startOffset = elapsed()
        let requestedAt = ProcessInfo.processInfo.systemUptime
        // Copy the resume segment off the main thread; the cached anthem stays immutable.
        anthemQueue.async { [weak self] in
            let offset = AVAudioFrameCount(min(Double(buffer.frameLength), max(0, startOffset * buffer.format.sampleRate)))
            let length = buffer.frameLength - offset
            guard length > 0, let remaining = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: length) else { return }
            remaining.frameLength = length
            remaining.floatChannelData![0].update(from: buffer.floatChannelData![0].advanced(by: Int(offset)), count: Int(length))
            DispatchQueue.main.async {
                guard let self, token == self.anthemGeneration, self.anthemElapsed != nil,
                      !self.suspended, !self.interrupted, self.startEngine() else { return }
                self.anthemPlayer.stop()
                self.anthemPlaying = true
                self.idleWorkItem?.cancel()
                // Bound copy time diagnostically; this is not a measurement of audible latency.
                self.logger.debug("Anthem segment prepared in \(ProcessInfo.processInfo.systemUptime - requestedAt) seconds")
                self.anthemPlayer.scheduleBuffer(remaining, completionCallbackType: .dataPlayedBack) { [weak self] _ in
                    DispatchQueue.main.async {
                        guard let self, self.anthemGeneration == token else { return }
                        self.anthemPlaying = false
                        self.scheduleIdlePause()
                    }
                }
                self.anthemPlayer.play()
            }
        }
    }

    private func scheduleIdlePause() {
        idleWorkItem?.cancel()
        guard !gameplayActive, !anthemPlaying, !voices.contains(where: { $0.busy }) else { return }
        let item = DispatchWorkItem { [weak self] in
            guard let self, !self.gameplayActive, !self.anthemPlaying,
                  !self.voices.contains(where: { $0.busy }) else { return }
            self.engine.pause()
            self.deactivateSession()
        }
        idleWorkItem = item
        let delay = max(0, previewEndsAt - ProcessInfo.processInfo.systemUptime) + 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }

    private func deactivateSession() {
        guard sessionActive else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            sessionActive = false
        } catch { logger.error("Audio deactivation failed: \(error.localizedDescription, privacy: .public)") }
    }

    func resumeForeground() {
        suspended = false
    }

    func suspend() {
        interruptedAnthem = nil
        interruptedChimes = nil
        gameplayActive = false
        suspended = true
        stopPlayback()
        deactivateSession()
    }

    private func stopPlayback() {
        generation += 1
        stopVolumePreviews()
        stopDailyBopAnthem()
        stopPowerUpChimes()
        for index in voices.indices {
            voices[index].token += 1
            voices[index].player.stop()
            voices[index].busy = false
        }
        idleWorkItem?.cancel()
        engine.pause()
    }

    private func observeAudioChanges() {
        let center = NotificationCenter.default
        observers.append(center.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] note in
            guard let self, let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
            if type == .began {
                self.interrupted = true
                self.interruptedAnthem = self.anthemElapsed
                self.interruptedChimes = self.powerUpPlayback
                self.stopPlayback()
                self.sessionActive = false
            } else {
                let options = AVAudioSession.InterruptionOptions(rawValue: note.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0)
                self.interrupted = false
                if options.contains(.shouldResume), self.gameplayActive, self.startEngine() {
                    self.restoreMusic(anthem: self.interruptedAnthem, chimes: self.interruptedChimes)
                }
                self.interruptedAnthem = nil
                self.interruptedChimes = nil
            }
        })
        for name in [AVAudioSession.routeChangeNotification, .AVAudioEngineConfigurationChange] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] note in
                if name == .AVAudioEngineConfigurationChange, let sender = note.object as? AVAudioEngine, sender !== self?.engine { return }
                // Configuration notifications can originate on an audio thread. All graph
                // work is deferred to our owning queue, never performed in that callback.
                DispatchQueue.main.async { self?.recoverConfiguration() }
            })
        }
        observers.append(center.addObserver(forName: AVAudioSession.mediaServicesWereResetNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            let anthem = self.anthemElapsed
            let chimes = self.powerUpPlayback
            self.stopPlayback()
            self.sessionActive = false
            self.graphGeneration += 1
            self.engine = AVAudioEngine()
            self.soundMixer = AVAudioMixerNode()
            self.musicMixer = AVAudioMixerNode()
            self.anthemPlayer = AVAudioPlayerNode()
            self.soundPreviewPlayer = AVAudioPlayerNode()
            self.musicPreviewPlayer = AVAudioPlayerNode()
            self.voices = []
            self.setupEngine()
            if self.gameplayActive, self.startEngine() { self.restoreMusic(anthem: anthem, chimes: chimes) }
        })
    }

    private func recoverConfiguration() {
        guard !engine.isRunning else { return }
        let anthem = anthemElapsed
        let chimes = powerUpPlayback
        stopPlayback()
        if gameplayActive, startEngine() { restoreMusic(anthem: anthem, chimes: chimes) }
    }

    private var powerUpPlayback: PowerUpPlayback? {
        guard powerUpTimer != nil else { return nil }
        return PowerUpPlayback(startedAt: powerUpStartedAt, duration: powerUpDuration, step: powerUpChimeStep)
    }

    private func restoreMusic(anthem: (() -> TimeInterval)?, chimes: PowerUpPlayback?) {
        if let anthem { playDailyBopAnthem(elapsed: anthem) }
        if let chimes {
            let elapsed = ProcessInfo.processInfo.systemUptime - chimes.startedAt
            guard elapsed < chimes.duration else { return }
            powerUpStartedAt = chimes.startedAt
            powerUpDuration = chimes.duration
            powerUpChimeStep = max(chimes.step, Int(elapsed / chimes.duration * 13))
            playNextPowerUpChime()
            powerUpTimer = Timer.scheduledTimer(withTimeInterval: chimes.duration / 13, repeats: true) { [weak self] _ in
                self?.playNextPowerUpChime()
            }
        }
    }
}

private struct AudioVoice {
    let player: AVAudioPlayerNode
    let isSound: Bool
    var busy = false
    var cue: SoundCue = .invalid
    var startedAt: TimeInterval = 0
    var token = 0
}

private struct PowerUpPlayback {
    let startedAt: TimeInterval
    let duration: TimeInterval
    let step: Int
}
