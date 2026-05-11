import AVFoundation

final class AudioEngine {

	private let engine = AVAudioEngine()
	private let sampleRate: Double = 44100
	private let playerCount = 18
	private var voices: [AudioVoice] = []
	private var nextPlayerIndex = 0
	private var selectNoteIndex = 0
	private var powerUpTimer: Timer?
	private var powerUpStartedAt: Date?
	private var powerUpDuration: Double = 15
	private var powerUpChimeStep = 0

	// MARK: - Init

	init() {
		setupSession()
		setupEngine()
	}

	private func setupSession() {
		do {
			try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
			try AVAudioSession.sharedInstance().setActive(true)
		} catch {}
	}

	private func setupEngine() {
		let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false)
		for _ in 0..<playerCount {
			let player = AVAudioPlayerNode()
			engine.attach(player)
			engine.connect(player, to: engine.mainMixerNode, format: format)
			voices.append(AudioVoice(player: player))
		}
		engine.mainMixerNode.outputVolume = 0.82
	}

	// MARK: - Public sound interface

	func resetSelectSound() {
		selectNoteIndex = 0
	}

	func stepSelectSoundBack() {
		selectNoteIndex = max(0, selectNoteIndex - 1)
	}

	func playSelectSound() {
		let selectNotes: [Double] = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88,
									 523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77, 1046.50]
		let step = selectNoteIndex
		selectNoteIndex += 1
		let freq = selectNotes[min(step, selectNotes.count - 1)]
		let duration = step >= 3 ? 0.64 : 0.44

		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		// Marimba: 3 harmonics
		let harmonics: [(Double, Double)] = [(1, 0.58), (2, 0.2), (3, 0.08)]
		for (mult, amp) in harmonics {
			ctx.addOsc(type: .sine, freq: freq * mult, start: 0, attackTime: 0.006,
					   peakAmp: amp * 0.58, releaseTime: 0.38, settleRatio: 0.35, settleTime: 0.05)
		}
		// Bright click attack
		ctx.addNoise(start: 0, duration: 0.01, amplitude: 0.18, highpass: true)
		// Sparkle for 4th letter onward
		if step >= 3 {
			addSparkle(to: &ctx, step: step, masterGain: 1.0)
		}
		play(ctx.toBuffer(), priority: .transient)
	}

	func playDeselectSound() {
		let duration = 0.28
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		ctx.addOscWithFreqSlide(freq: 523.25, endFreq: 392.0, start: 0, duration: 0.18, peakAmp: 0.11)
		ctx.addOsc(type: .sine, freq: 261.63, start: 0.035, attackTime: 0.01,
				   peakAmp: 0.07, releaseTime: 0.22, settleRatio: 0.35, settleTime: 0.06)
		ctx.addOsc(type: .triangle, freq: 784.0, start: 0.01, attackTime: 0.004,
				   peakAmp: 0.025, releaseTime: 0.12, filter: FilterSpec(kind: .lowpass, frequency: 1800, q: 0.7))
		play(ctx.toBuffer(), priority: .transient)
	}

	func playWordSound(wordLength: Int) {
		let baseNotes: [Double] = [261.63, 329.63, 392.00, 493.88, 523.25, 659.25, 783.99]
		let noteCount = wordLength >= 7 ? 7 : wordLength >= 5 ? 5 : 3
		let masterVol = wordLength >= 7 ? 1.0 : wordLength >= 5 ? 0.82 : 0.65
		let spacing = wordLength >= 7 ? 0.055 : wordLength >= 5 ? 0.065 : 0.075
		let notes = Array(baseNotes.prefix(noteCount))
		let duration = spacing * Double(notes.count) + 0.9

		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		for (i, freq) in notes.enumerated() {
			let nd = Double(i) * spacing
			ctx.addOsc(type: .sine,     freq: freq,       start: nd, attackTime: 0.012, peakAmp: 0.38 * masterVol, releaseTime: 0.85, settleRatio: 0.45, settleTime: 0.1)
			ctx.addOsc(type: .triangle, freq: freq * 2,   start: nd, attackTime: 0.012, peakAmp: 0.12 * masterVol, releaseTime: 0.85, settleRatio: 0.45, settleTime: 0.1)
			ctx.addOsc(type: .sine,     freq: freq * 0.5, start: nd, attackTime: 0.012, peakAmp: 0.18 * masterVol, releaseTime: 0.85, settleRatio: 0.45, settleTime: 0.1)
		}
		// Sub thump
		let subFreq = wordLength >= 5 ? 130.0 : 110.0
		let subVol = wordLength >= 7 ? 0.34 : wordLength >= 5 ? 0.26 : 0.18
		ctx.addOscWithFreqSlide(freq: subFreq, endFreq: subFreq / 2, start: 0, duration: 0.22, peakAmp: subVol)
		// Sparkle noise for medium/long words
		if wordLength >= 5 {
			ctx.addNoise(start: 0, duration: 0.045, amplitude: wordLength >= 7 ? 0.4 : 0.22, highpass: false, bandpass: true)
		}
		play(ctx.toBuffer(), priority: .score)
	}

	func playInvalidSound() {
		let duration = 0.3
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		ctx.addOscWithFreqSlide(freq: 280, endFreq: 80, start: 0, duration: 0.25, peakAmp: 0.34)
		ctx.addNoise(start: 0, duration: 0.07, amplitude: 0.32, highpass: false)
		play(ctx.toBuffer(), priority: .transient)
	}

	func playBonusSound() {
		let pairs: [(Double, Double)] = [(784.0, 0), (1046.5, 0.14)]
		let duration = 0.45
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		for (freq, delay) in pairs {
			ctx.addOsc(type: .sine,     freq: freq,     start: delay, attackTime: 0.01, peakAmp: 0.42, releaseTime: 0.28)
			ctx.addOsc(type: .triangle, freq: freq * 2, start: delay, attackTime: 0.001, peakAmp: 0.12, releaseTime: 0.2)
		}
		play(ctx.toBuffer(), priority: .score)
	}

	func playConnectedWordSound(wordLength: Int) {
		let noteCount = wordLength >= 7 ? 8 : wordLength >= 5 ? 6 : 4
		let shimmerVol = wordLength >= 7 ? 0.26 : wordLength >= 5 ? 0.2 : 0.14
		let allNotes: [Double] = [1046.5, 1318.51, 1567.98, 2093.0, 2637.02, 3135.96, 4186.01, 5274.04]
		let notes = Array(allNotes.prefix(noteCount))
		let duration = Double(noteCount) * 0.045 + 0.55

		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		for (i, freq) in notes.enumerated() {
			let t = Double(i) * 0.045
			let type: OscType = i % 2 == 0 ? .sine : .triangle
			ctx.addOsc(type: type, freq: freq, start: t, attackTime: 0.01, peakAmp: shimmerVol,
					   releaseTime: 0.5, filter: FilterSpec(kind: .bandpass, frequency: freq, q: 8))
		}
		play(ctx.toBuffer(), priority: .connected)
	}

	func playChainStreakSound(streak: Int) {
		let fifthRoots: [Double] = [523.25, 587.33, 659.25]
		let root = fifthRoots[min(streak - 1, fifthRoots.count - 1)]
		let fifth = root * 1.5
		let duration = 0.46
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		ctx.addOsc(type: .sine,     freq: root,  start: 0, attackTime: 0.012, peakAmp: 0.1, releaseTime: 0.42)
		ctx.addOsc(type: .triangle, freq: fifth, start: 0, attackTime: 0.012, peakAmp: 0.08, releaseTime: 0.42)
		play(ctx.toBuffer(), priority: .connected)
	}

	func playChainMultiplierScoreSound(wordLength: Int) {
		let duration = 1.36
		let masterVol = wordLength >= 7 ? 1.0 : wordLength >= 5 ? 0.88 : 0.76
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)

		let glissStart = wordLength >= 7 ? 987.77 : 880.0
		let glissEnd = wordLength >= 7 ? 3951.07 : 3135.96
		ctx.addOscWithFreqSlide(freq: glissStart, endFreq: glissEnd, start: 0.02, duration: 0.32, peakAmp: 0.18 * masterVol)
		ctx.addOscWithFreqSlide(freq: glissStart * 1.5, endFreq: glissEnd * 1.25, start: 0.055, duration: 0.28, peakAmp: 0.08 * masterVol)

		let sparkleNotes: [Double] = [1318.51, 1567.98, 2093.0, 2637.02, 3135.96, 4186.01]
		for (i, freq) in sparkleNotes.enumerated() {
			let delay = 0.045 + Double(i) * 0.038
			let amp = (i == sparkleNotes.count - 1 ? 0.13 : 0.075) * masterVol
			ctx.addOsc(type: i % 2 == 0 ? .sine : .triangle,
					   freq: freq,
					   start: delay,
					   attackTime: 0.006,
					   peakAmp: amp,
					   releaseTime: 0.34,
					   filter: FilterSpec(kind: .bandpass, frequency: freq, q: 9))
		}

		let preChimeNotes: [Double] = [783.99, 1046.5, 1318.51]
		for (i, freq) in preChimeNotes.enumerated() {
			let delay = 0.255 + Double(i) * 0.04
			ctx.addOsc(type: .sine, freq: freq, start: delay, attackTime: 0.004,
					   peakAmp: 0.105 * masterVol, releaseTime: 0.26,
					   filter: FilterSpec(kind: .bandpass, frequency: freq, q: 8))
		}

		let finishStart = 0.39
		let finishNotes: [Double] = [261.63, 392.0, 523.25, 659.25, 1046.5, 1318.51, 1567.98, 2093.0]
		for freq in finishNotes {
			ctx.addOscWithVibrato(type: .sine, freq: freq, start: finishStart, attackTime: 0.014,
								  peakAmp: 0.115 * masterVol, releaseTime: 0.92,
								  vibratoRate: 5.2, vibratoDepthCents: 7.0, vibratoDelay: 0.12,
								  settleRatio: 0.42, settleTime: 0.14)
			ctx.addOscWithVibrato(type: .triangle, freq: freq * 2, start: finishStart, attackTime: 0.008,
								  peakAmp: 0.026 * masterVol, releaseTime: 0.78,
								  vibratoRate: 5.2, vibratoDepthCents: 4.0, vibratoDelay: 0.14,
								  settleRatio: 0.28, settleTime: 0.12)
		}
		ctx.addNoise(start: 0.03, duration: 0.18, amplitude: 0.16 * masterVol, highpass: true)
		ctx.addNoise(start: finishStart, duration: 0.09, amplitude: 0.09 * masterVol, highpass: false, bandpass: true)

		play(ctx.toBuffer(), priority: .connected)
	}

	func playRoundStartSound() {
		let chordNotes: [Double] = [261.63, 329.63, 392.00, 523.25, 659.25, 783.99]
		let shapes = [[0,1,2,3],[2,1,3,0],[1,3,2,4],[3,2,4,5],[4,2,3,1]]
		let shape = shapes[Int.random(in: 0..<shapes.count)]
		let notes = shape.map { chordNotes[$0] }
		let duration = Double(notes.count) * 0.07 + 0.5
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		for (i, freq) in notes.enumerated() {
			let nd = Double(i) * 0.07
			ctx.addOsc(type: .sine,     freq: freq,     start: nd, attackTime: 0.012, peakAmp: 0.27, releaseTime: 0.46)
			ctx.addOsc(type: .triangle, freq: freq * 2, start: nd, attackTime: 0.012, peakAmp: 0.072, releaseTime: 0.46)
		}
		play(ctx.toBuffer(), priority: .score)
	}

	func playRoundEndSound() {
		let chordTones: [Double] = [261.63, 329.63, 392.00, 523.25, 659.25, 783.99, 1046.50, 1318.51, 1567.98]
		var noteIndex = Int.random(in: 0...4)
		var notes: [Double] = []
		for _ in 0..<6 {
			notes.append(chordTones[noteIndex])
			let turn = [-2, -1, 1, 2, 3].randomElement() ?? 1
			noteIndex = min(max(noteIndex + turn, 0), chordTones.count - 1)
		}
		notes.append(2093.00)
		let duration = Double(notes.count) * 0.085 + 0.75
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		for (i, freq) in notes.enumerated() {
			let nd = Double(i) * 0.085
			ctx.addOsc(type: .sine,     freq: freq,       start: nd, attackTime: 0.01, peakAmp: 0.3, releaseTime: 0.7)
			ctx.addOsc(type: .triangle, freq: freq * 2,   start: nd, attackTime: 0.01, peakAmp: 0.088, releaseTime: 0.7)
			ctx.addOsc(type: .sine,     freq: freq * 0.5, start: nd, attackTime: 0.01, peakAmp: 0.106, releaseTime: 0.7)
		}
		play(ctx.toBuffer(), priority: .score)
	}

	func playTickSound(secondsLeft: Int) {
		let freq = 600.0 + Double(10 - secondsLeft) * 66.0
		let amplitude = secondsLeft <= 3 ? 0.34 : 0.24
		let duration = 0.15
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		ctx.addOsc(type: .sine, freq: freq, start: 0, attackTime: 0.008, peakAmp: amplitude, releaseTime: 0.12)
		if secondsLeft <= 3 {
			ctx.addOsc(type: .sine, freq: freq * 2, start: 0, attackTime: 0.001, peakAmp: 0.1, releaseTime: 0.1)
		}
		play(ctx.toBuffer(), priority: .transient)
	}

	func startPowerUpChimes(duration: Double) {
		stopPowerUpChimes()
		powerUpStartedAt = Date()
		powerUpDuration = duration
		powerUpChimeStep = 0
		playPowerUpChime(step: powerUpChimeStep, progress: 0)
		powerUpChimeStep += 1
		let chimeInterval = duration / Double(powerUpChimeGroups.count)
		powerUpTimer = Timer.scheduledTimer(withTimeInterval: chimeInterval, repeats: true) { [weak self] _ in
			guard let self, let start = self.powerUpStartedAt else { return }
			let elapsed = Date().timeIntervalSince(start)
			if elapsed >= self.powerUpDuration || self.powerUpChimeStep >= self.powerUpChimeGroups.count {
				self.stopPowerUpChimes()
				return
			}
			self.playPowerUpChime(step: self.powerUpChimeStep, progress: elapsed / self.powerUpDuration)
			self.powerUpChimeStep += 1
		}
	}

	func stopPowerUpChimes() {
		powerUpTimer?.invalidate()
		powerUpTimer = nil
		powerUpStartedAt = nil
		powerUpChimeStep = 0
	}

	// MARK: - Private helpers

	private func addSparkle(to ctx: inout SynthContext, step: Int, masterGain: Double) {
		let sparkleNotes: [Double] = [659.25, 698.46, 783.99, 880.00, 987.77, 1046.50,
									  1174.66, 1318.51, 1396.91, 1567.98]
		let sparkleCount = min(4, max(3, step - 1))
		let sparkleGain = min(0.07, 0.024 + Double(step - 3) * 0.007) * masterGain
		let rootIndex = min(step - 3, sparkleNotes.count - 4)
		var phrase = Array(sparkleNotes[rootIndex..<min(rootIndex + sparkleCount, sparkleNotes.count)])
		if step >= 7, phrase.count > 1 {
			let last = phrase.removeLast()
			phrase.shuffle()
			phrase.append(last)
		}

		for (i, freq) in phrase.enumerated() {
			let delay = 0.055 + Double(i) * 0.06
			ctx.addOsc(type: .sine, freq: freq, start: delay, attackTime: 0.018, peakAmp: sparkleGain,
					   releaseTime: 0.36, filter: FilterSpec(kind: .lowpass, frequency: 2400, q: 0.7))
		}
	}

	private var powerUpChimeGroups: [[Double]] {
		[
			[2093.00, 1975.53, 1760.00],
			[1975.53, 1760.00, 1567.98],
			[1760.00, 1567.98, 1396.91],
			[1567.98, 1396.91, 1318.51],
			[1396.91, 1318.51, 1174.66],
			[1318.51, 1174.66, 1046.50],
			[1174.66, 1046.50, 987.77],
			[1046.50, 987.77, 880.00],
			[987.77, 880.00, 783.99],
			[880.00, 783.99, 698.46],
			[783.99, 698.46, 659.25],
			[698.46, 659.25, 587.33],
			[659.25, 587.33, 523.25]
		]
	}

	private func playPowerUpChime(step: Int, progress: Double) {
		let notes = powerUpChimeGroups[min(step, powerUpChimeGroups.count - 1)]
		let level = max(0.012, 0.032 * (1 - progress))
		let duration = Double(notes.count) * 0.115 + 0.6
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		for (i, freq) in notes.enumerated() {
			let delay = Double(i) * 0.08 + Double.random(in: 0..<0.035)
			ctx.addOsc(type: .sine, freq: freq, start: delay,
					   attackTime: 0.02, peakAmp: level, releaseTime: 0.55,
					   filter: FilterSpec(kind: .lowpass, frequency: 2600, q: 0.7))
		}
		play(ctx.toBuffer(), priority: .ambient)
	}

	private func play(_ buffer: AVAudioPCMBuffer?, priority: SoundPriority) {
		guard let buffer else { return }
		guard !voices.isEmpty else { return }
		let duration = Double(buffer.frameLength) / sampleRate
		guard let voiceIndex = nextVoiceIndex(for: priority) else { return }
		let player = voices[voiceIndex].player
		player.stop()
		voices[voiceIndex].priority = priority
		voices[voiceIndex].reservedUntil = Date().addingTimeInterval(duration + 0.035)
		if !engine.isRunning { try? engine.start() }
		player.scheduleBuffer(buffer, completionHandler: nil)
		player.play()
	}

	private func nextVoiceIndex(for priority: SoundPriority) -> Int? {
		let now = Date()
		let count = voices.count

		for offset in 0..<count {
			let index = (nextPlayerIndex + offset) % count
			let voice = voices[index]
			if !voice.player.isPlaying || voice.reservedUntil <= now {
				nextPlayerIndex = (index + 1) % count
				return index
			}
		}

		let replaceable = voices.indices
			.filter { voices[$0].priority.rawValue < priority.rawValue }
			.min { voices[$0].reservedUntil < voices[$1].reservedUntil }

		if let replaceable {
			nextPlayerIndex = (replaceable + 1) % count
			return replaceable
		}

		return nil
	}
}

// MARK: - Synthesis primitives

private enum OscType { case sine, triangle, sawtooth }
private enum SoundPriority: Int { case transient, ambient, score, connected }
private enum FilterKind { case lowpass, highpass, bandpass }

private struct AudioVoice {
	let player: AVAudioPlayerNode
	var priority: SoundPriority = .transient
	var reservedUntil: Date = .distantPast
}

private struct FilterSpec {
	let kind: FilterKind
	let frequency: Double
	let q: Double
}

private struct SynthContext {
	let sampleRate: Double
	var samples: [Float]

	init(duration: Double, sampleRate: Double) {
		self.sampleRate = sampleRate
		self.samples = [Float](repeating: 0, count: Int(ceil(duration * sampleRate)))
	}

	mutating func addOsc(
		type: OscType,
		freq: Double,
		start: Double,
		attackTime: Double,
		peakAmp: Double,
		releaseTime: Double,
		settleRatio: Double = 1.0,
		settleTime: Double? = nil,
		filter: FilterSpec? = nil
	) {
		let startSample = Int(start * sampleRate)
		let attackSamples = max(1, Int(attackTime * sampleRate))
		let releaseSamples = max(attackSamples + 1, Int(releaseTime * sampleRate))
		let settleSamples = settleTime.map { max(attackSamples + 1, Int($0 * sampleRate)) }
		let count = samples.count
		var rendered = [Float](repeating: 0, count: count)

		for i in startSample..<min(count, startSample + releaseSamples) {
			let t = Double(i) / sampleRate
			let raw: Double
			switch type {
			case .sine:
				raw = sin(2.0 * .pi * freq * t)
			case .triangle:
				let p = t * freq
				raw = 2.0 * abs(2.0 * (p - floor(p + 0.5))) - 1.0
			case .sawtooth:
				let p = t * freq
				raw = 2.0 * (p - floor(p + 0.5))
			}

			let elapsed = i - startSample
			let gain: Double
			if elapsed < attackSamples {
				gain = peakAmp * Double(elapsed) / Double(attackSamples)
			} else if let settleSamples, elapsed < settleSamples {
				let progress = Double(elapsed - attackSamples) / Double(max(1, settleSamples - attackSamples))
				gain = exponentialRamp(from: peakAmp, to: peakAmp * settleRatio, progress: progress)
			} else {
				let releaseStart = settleSamples ?? attackSamples
				let startGain = peakAmp * settleRatio
				let progress = Double(elapsed - releaseStart) / Double(max(1, releaseSamples - releaseStart))
				gain = exponentialRamp(from: startGain, to: 0.001, progress: progress)
			}
			rendered[i] = Float(raw * gain)
		}

		if let filter {
			applyBiquad(filter, to: &rendered)
		}

		for i in rendered.indices {
			samples[i] += rendered[i]
		}
	}

	mutating func addOscWithFreqSlide(freq: Double, endFreq: Double, start: Double, duration: Double, peakAmp: Double) {
		let startSample = Int(start * sampleRate)
		let endSample = min(samples.count, Int((start + duration) * sampleRate))
		var phase = 0.0
		let durationSamples = max(1, endSample - startSample)

		for i in startSample..<endSample {
			let progress = Double(i - startSample) / Double(durationSamples)
			let currentFreq = freq * pow(endFreq / freq, progress)
			phase += 2.0 * .pi * currentFreq / sampleRate
			let decayProgress = progress
			let gain = peakAmp * exp(-decayProgress * 3.5)
			samples[i] += Float(sin(phase) * gain)
		}
	}

	mutating func addOscWithVibrato(
		type: OscType,
		freq: Double,
		start: Double,
		attackTime: Double,
		peakAmp: Double,
		releaseTime: Double,
		vibratoRate: Double,
		vibratoDepthCents: Double,
		vibratoDelay: Double,
		settleRatio: Double = 1.0,
		settleTime: Double? = nil
	) {
		let startSample = Int(start * sampleRate)
		let attackSamples = max(1, Int(attackTime * sampleRate))
		let releaseSamples = max(attackSamples + 1, Int(releaseTime * sampleRate))
		let settleSamples = settleTime.map { max(attackSamples + 1, Int($0 * sampleRate)) }
		let count = samples.count
		var phase = 0.0

		for i in startSample..<min(count, startSample + releaseSamples) {
			let elapsed = i - startSample
			let elapsedTime = Double(elapsed) / sampleRate
			let vibratoProgress = min(max((elapsedTime - vibratoDelay) / 0.18, 0), 1)
			let vibratoCents = sin(2.0 * .pi * vibratoRate * elapsedTime) * vibratoDepthCents * vibratoProgress
			let currentFreq = freq * pow(2.0, vibratoCents / 1200.0)
			phase += 2.0 * .pi * currentFreq / sampleRate

			let raw: Double
			switch type {
			case .sine:
				raw = sin(phase)
			case .triangle:
				let p = phase / (2.0 * .pi)
				raw = 2.0 * abs(2.0 * (p - floor(p + 0.5))) - 1.0
			case .sawtooth:
				let p = phase / (2.0 * .pi)
				raw = 2.0 * (p - floor(p + 0.5))
			}

			let gain: Double
			if elapsed < attackSamples {
				gain = peakAmp * Double(elapsed) / Double(attackSamples)
			} else if let settleSamples, elapsed < settleSamples {
				let progress = Double(elapsed - attackSamples) / Double(max(1, settleSamples - attackSamples))
				gain = exponentialRamp(from: peakAmp, to: peakAmp * settleRatio, progress: progress)
			} else {
				let releaseStart = settleSamples ?? attackSamples
				let startGain = peakAmp * settleRatio
				let progress = Double(elapsed - releaseStart) / Double(max(1, releaseSamples - releaseStart))
				gain = exponentialRamp(from: startGain, to: 0.001, progress: progress)
			}
			samples[i] += Float(raw * gain)
		}
	}

	mutating func addNoise(start: Double, duration: Double, amplitude: Double, highpass: Bool, bandpass: Bool = false) {
		let startSample = Int(start * sampleRate)
		let noiseSamples = Int(duration * sampleRate)
		let endSample = min(samples.count, startSample + noiseSamples)

		// Simple one-pole filter state
		var filterState: Double = 0
		let cutoff = highpass ? 0.85 : (bandpass ? 0.6 : 0.15)

		for i in startSample..<endSample {
			let raw = Double.random(in: -1.0...1.0)
			filterState = filterState * (1 - cutoff) + raw * cutoff
			let filtered = highpass ? raw - filterState : filterState
			let progress = Double(i - startSample) / Double(max(noiseSamples, 1))
			let gain = amplitude * exp(-progress * 5.0)
			samples[i] += Float(filtered * gain)
		}
	}

	private func exponentialRamp(from start: Double, to end: Double, progress: Double) -> Double {
		let clamped = min(max(progress, 0), 1)
		let safeStart = max(start, 0.0001)
		let safeEnd = max(end, 0.0001)
		return safeStart * pow(safeEnd / safeStart, clamped)
	}

	private func applyBiquad(_ spec: FilterSpec, to rendered: inout [Float]) {
		let cutoff = min(max(spec.frequency, 20), sampleRate * 0.45)
		let omega = 2.0 * .pi * cutoff / sampleRate
		let alpha = sin(omega) / (2.0 * max(spec.q, 0.001))
		let cosOmega = cos(omega)

		let b0: Double
		let b1: Double
		let b2: Double
		let a0: Double
		let a1: Double
		let a2: Double

		switch spec.kind {
		case .lowpass:
			b0 = (1 - cosOmega) / 2
			b1 = 1 - cosOmega
			b2 = (1 - cosOmega) / 2
			a0 = 1 + alpha
			a1 = -2 * cosOmega
			a2 = 1 - alpha
		case .highpass:
			b0 = (1 + cosOmega) / 2
			b1 = -(1 + cosOmega)
			b2 = (1 + cosOmega) / 2
			a0 = 1 + alpha
			a1 = -2 * cosOmega
			a2 = 1 - alpha
		case .bandpass:
			b0 = alpha
			b1 = 0
			b2 = -alpha
			a0 = 1 + alpha
			a1 = -2 * cosOmega
			a2 = 1 - alpha
		}

		var x1 = 0.0
		var x2 = 0.0
		var y1 = 0.0
		var y2 = 0.0

		for i in rendered.indices {
			let x0 = Double(rendered[i])
			let y0 = (b0 / a0) * x0 + (b1 / a0) * x1 + (b2 / a0) * x2 - (a1 / a0) * y1 - (a2 / a0) * y2
			rendered[i] = Float(y0)
			x2 = x1
			x1 = x0
			y2 = y1
			y1 = y0
		}
	}

	func toBuffer() -> AVAudioPCMBuffer? {
		guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false) else { return nil }
		var rendered = samples
		applyOutputPolish(to: &rendered)
		let frameCount = UInt32(rendered.count)
		guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
		buffer.frameLength = frameCount
		guard let channelData = buffer.floatChannelData?[0] else { return nil }
		rendered.withUnsafeBufferPointer { ptr in
			guard let baseAddress = ptr.baseAddress else { return }
			channelData.update(from: baseAddress, count: rendered.count)
		}
		return buffer
	}

	private func applyOutputPolish(to rendered: inout [Float]) {
		guard !rendered.isEmpty else { return }

		let fadeSamples = min(rendered.count, Int(sampleRate * 0.014))
		if fadeSamples > 1 {
			let start = rendered.count - fadeSamples
			for i in 0..<fadeSamples {
				let progress = Float(i) / Float(fadeSamples - 1)
				rendered[start + i] *= 1 - progress
			}
		}

		for i in rendered.indices {
			rendered[i] = Float(tanh(Double(rendered[i]) * 0.82))
		}
	}
}
