import AVFoundation
import Foundation
import Testing
@testable import WordBop

@Suite(.serialized)
struct AudioEngineTests {
    @Test func volumeMigrationPreservesMuteAndIndependentValues() throws {
        let name = "WordBopperAudioTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        #expect(AudioVolumeSettings.load(from: defaults).sound == 0.82)
        defaults.removeObject(forKey: AudioVolumeSettings.soundKey)
        defaults.removeObject(forKey: AudioVolumeSettings.musicKey)
        defaults.set(0, forKey: "wordBopGameVolume")
        let muted = AudioVolumeSettings.load(from: defaults)
        #expect(muted.sound == 0 && muted.music == 0)
        defaults.set(0.37, forKey: AudioVolumeSettings.soundKey)
        defaults.set(0.91, forKey: AudioVolumeSettings.musicKey)
        let independent = AudioVolumeSettings.load(from: defaults)
        #expect(independent.sound == 0.37 && independent.music == 0.91)
        defaults.removeObject(forKey: AudioVolumeSettings.musicKey)
        defaults.set(0.64, forKey: "wordBopGameVolume")
        let partial = AudioVolumeSettings.load(from: defaults)
        #expect(partial.sound == 0.37 && partial.music == 0.64)
        defaults.set("0.4", forKey: AudioVolumeSettings.soundKey)
        #expect(AudioVolumeSettings.load(from: defaults).sound == 0.4)
        #expect(AudioVolumeSettings.clamp(-1) == 0)
        #expect(AudioVolumeSettings.clamp(2) == 1)
        #expect(AudioVolumeSettings.clamp(.nan) == 0.82)
    }

    @Test func renderedCuesHaveFiniteSamplesAndSmoothEnds() throws {
        let renderer = SoundRenderer()
        for cue in SoundCue.preparedCues {
            let buffer = try #require(renderer.render(cue))
            let samples = try #require(buffer.floatChannelData?[0])
            let count = Int(buffer.frameLength)
            #expect(count > 0)
            #expect((0..<count).allSatisfy { samples[$0].isFinite && abs(samples[$0]) < 1 })
            #expect(abs(samples[count - 1]) < 0.00001)
            #expect((0..<count).contains { abs(samples[$0]) > 0.001 })
        }
        let preview = try #require(renderer.render(.musicPreview))
        #expect(Double(preview.frameLength) / preview.format.sampleRate <= 0.25)
    }

    @MainActor
    @Test func cachedPlaybackAvoidsSynthesisAndKeepsBoundedMemory() async throws {
        let library = SoundLibrary(prewarm: false)
        for cue in SoundCue.preparedCues { _ = await prepared(cue, in: library) }
        let renders = library.renderCount
        let bytes = library.cachedByteCount
        #expect(bytes < 32 * 1024 * 1024)
        let start = ProcessInfo.processInfo.systemUptime
        for _ in 0..<1000 {
            var delivered = false
            library.buffer(for: .select(10)) { buffer in delivered = buffer != nil }
            #expect(delivered)
        }
        let cacheTime = ProcessInfo.processInfo.systemUptime - start
        #expect(library.renderCount == renders)
        #expect(library.cachedByteCount == bytes)
        let synthesisStart = ProcessInfo.processInfo.systemUptime
        for _ in 0..<50 { _ = SoundRenderer().render(.select(10)) }
        let synthesisTime = ProcessInfo.processInfo.systemUptime - synthesisStart
        print("AUDIO METRICS: cached lookup average \(cacheTime / 1000 * 1000) ms; synthesis average \(synthesisTime / 50 * 1000) ms; cache \(bytes) bytes, \(renders) buffers")
    }

    @MainActor
    @Test func rapidPlaybackProtectsInteractionAndDoesNotRestartAfterSilence() async throws {
        let library = SoundLibrary(prewarm: false)
        for cue in [SoundCue.select(0), .select(1), .word(7)] { _ = await prepared(cue, in: library) }
        let audio = AudioEngine(library: library)
        defer { audio.suspend() }
        audio.setGameplayActive(true)
        #expect(audio.isRunning)
        let starts = audio.engineStartCount
        for _ in 0..<18 { audio.playWordSound(wordLength: 7) }
        audio.playSelectSound()
        #expect(audio.activeMusicVoiceCount == 12)
        #expect(audio.activeSoundVoiceCount == 1)
        try await Task.sleep(for: .milliseconds(1900))
        #expect(audio.isRunning)
        audio.playSelectSound()
        #expect(audio.engineStartCount == starts)
        #expect(audio.staleSoundCount == 0)
        print("AUDIO METRICS: warm request-to-schedule \(audio.lastSchedulingDelay * 1000) ms; engine starts during round \(audio.engineStartCount)")
        audio.suspend()
        #expect(!audio.isRunning)
        #expect(audio.activeSoundVoiceCount == 0 && audio.activeMusicVoiceCount == 0)
    }

    @MainActor
    @Test func volumePreviewsAreThrottledSilentAtZeroAndDoNotChangeSelection() async throws {
        let library = SoundLibrary(prewarm: false)
        for cue in [SoundCue.select(0), .musicPreview] { _ = await prepared(cue, in: library) }
        let audio = AudioEngine(library: library)
        defer { audio.suspend() }
        audio.previewSoundVolume()
        #expect(audio.selectNoteIndex == 0)
        for _ in 0..<20 { audio.previewMusicVolume() }
        try await Task.sleep(for: .milliseconds(200))
        #expect(audio.previewPlayCount <= 2)
        #expect(audio.previewPlayCount > 0)
        audio.soundVolume = 0
        audio.musicVolume = 0
        let count = audio.previewPlayCount
        audio.previewSoundVolume()
        audio.previewMusicVolume()
        try await Task.sleep(for: .milliseconds(200))
        #expect(audio.previewPlayCount == count)
        #expect(audio.selectNoteIndex == 0)
        audio.musicVolume = 0.6
        audio.previewMusicVolume()
        audio.stopVolumePreviews()
        let stopped = audio.previewPlayCount
        try await Task.sleep(for: .milliseconds(200))
        #expect(audio.previewPlayCount == stopped)
    }

    @MainActor
    @Test func interruptionsDoNotReplayOldRequestsAndResumeOnlyWhenPermitted() async throws {
        let library = SoundLibrary(prewarm: false)
        _ = await prepared(.select(0), in: library)
        let audio = AudioEngine(library: library)
        defer { audio.suspend() }
        audio.setGameplayActive(true)
        let center = NotificationCenter.default
        center.post(name: AVAudioSession.interruptionNotification, object: nil,
                    userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue])
        #expect(!audio.isRunning)
        let count = audio.scheduledSoundCount
        audio.playSelectSound()
        #expect(audio.scheduledSoundCount == count)
        center.post(name: AVAudioSession.interruptionNotification, object: nil,
                    userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.ended.rawValue,
                               AVAudioSessionInterruptionOptionKey: AVAudioSession.InterruptionOptions.shouldResume.rawValue])
        #expect(audio.isRunning)
        audio.suspend()
        center.post(name: AVAudioSession.interruptionNotification, object: nil,
                    userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.ended.rawValue,
                               AVAudioSessionInterruptionOptionKey: AVAudioSession.InterruptionOptions.shouldResume.rawValue])
        #expect(!audio.isRunning)
    }

    @MainActor
    @Test func resetAndPauseRecoverWithoutReplayingCancelledSounds() async throws {
        let library = SoundLibrary(prewarm: false)
        _ = await prepared(.select(0), in: library)
        let audio = AudioEngine(library: library)
        defer { audio.suspend() }
        audio.setGameplayActive(true)
        audio.playSelectSound()
        NotificationCenter.default.post(name: AVAudioSession.mediaServicesWereResetNotification, object: nil)
        #expect(audio.isRunning)
        #expect(audio.activeSoundVoiceCount == 0)
        audio.resetSelectSound()
        audio.playSelectSound()
        #expect(audio.activeSoundVoiceCount == 1)
        audio.setGameplayActive(false)
        try await Task.sleep(for: .milliseconds(900))
        #expect(!audio.isRunning)
        audio.setGameplayActive(true)
        #expect(audio.isRunning)
        audio.musicVolume = 0
        let count = audio.scheduledSoundCount
        audio.playWordSound(wordLength: 7)
        #expect(audio.scheduledSoundCount == count)
        audio.playChainMultiplierScoreSound(wordLength: 7)
        audio.suspend()
        try await Task.sleep(for: .milliseconds(100))
        #expect(audio.scheduledSoundCount == count)
    }

    @Test func exportVolumeReferenceSamples() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("WordBopperAudioSamples", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for (name, cue) in [("sound", SoundCue.select(0)), ("music", SoundCue.musicPreview)] {
            let original = try #require(SoundRenderer().render(cue))
            for percent in [0, 25, 50, 100] {
                let copy = try #require(AVAudioPCMBuffer(pcmFormat: original.format, frameCapacity: original.frameLength))
                copy.frameLength = original.frameLength
                let source = try #require(original.floatChannelData?[0])
                let destination = try #require(copy.floatChannelData?[0])
                for index in 0..<Int(copy.frameLength) { destination[index] = source[index] * Float(percent) / 100 }
                let url = directory.appendingPathComponent("\(name)-\(percent).wav")
                let file = try AVAudioFile(forWriting: url, settings: copy.format.settings)
                try file.write(from: copy)
            }
        }
        print("AUDIO SAMPLES: \(directory.path)")
    }

    @MainActor
    private func prepared(_ cue: SoundCue, in library: SoundLibrary) async -> AVAudioPCMBuffer? {
        await withCheckedContinuation { continuation in
            library.buffer(for: cue) { continuation.resume(returning: $0) }
        }
    }
}
