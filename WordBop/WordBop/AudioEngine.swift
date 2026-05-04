import AVFoundation

final class AudioEngine {

	private let engine = AVAudioEngine()
	private let sampleRate: Double = 44100
	private var selectNoteIndex = 0
	private var powerUpTimer: Timer?
	private var powerUpStartedAt: Date?
	private var powerUpDuration: Double = 15
	private var bufferCache: [SoundKey: AVAudioPCMBuffer] = [:]

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
		engine.prepare()
	}

	// MARK: - Public sound interface

	func resetSelectSound() {
		selectNoteIndex = 0
	}

	func playSelectSound() {
		let selectNotes: [Double] = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88,
									 523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77, 1046.50]
		let step = selectNoteIndex
		selectNoteIndex += 1
		let noteIndex = min(step, selectNotes.count - 1)
		let sparkleLevel = min(max(step - 3, 0), 8)
		play(buffer(for: .select(noteIndex: noteIndex, sparkleLevel: sparkleLevel)) {
			makeSelectBuffer(freq: selectNotes[noteIndex], step: step)
		})
	}

	private func makeSelectBuffer(freq: Double, step: Int) -> AVAudioPCMBuffer? {
		let duration = step >= 3 ? 0.7 : 0.45
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		// Marimba: 3 harmonics
		let harmonics: [(Double, Double)] = [(1, 0.58), (2, 0.2), (3, 0.08)]
		for (mult, amp) in harmonics {
			ctx.addOsc(type: .sine, freq: freq * mult, start: 0, attackTime: 0.006,
					   peakAmp: amp * 0.78, decayHalf: 0.06)
		}
		// Bright click attack
		ctx.addNoise(start: 0, duration: 0.012, amplitude: 0.35 * 0.78, highpass: true)
		// Sparkle for 4th letter onward
		if step >= 3 {
			addSparkle(to: &ctx, step: step, masterGain: 1.0)
		}
		return ctx.toBuffer()
	}

	func playWordSound(wordLength: Int) {
		let wordSoundSize = wordLength >= 7 ? 7 : wordLength >= 5 ? 5 : 3
		play(buffer(for: .word(size: wordSoundSize)) {
			makeWordBuffer(wordLength: wordLength)
		})
	}

	private func makeWordBuffer(wordLength: Int) -> AVAudioPCMBuffer? {
		let baseNotes: [Double] = [261.63, 329.63, 392.00, 493.88, 523.25, 659.25, 783.99]
		let noteCount = wordLength >= 7 ? 7 : wordLength >= 5 ? 5 : 3
		let masterVol = wordLength >= 7 ? 1.0 : wordLength >= 5 ? 0.82 : 0.65
		let spacing = wordLength >= 7 ? 0.055 : wordLength >= 5 ? 0.065 : 0.075
		let notes = Array(baseNotes.prefix(noteCount))
		let duration = spacing * Double(notes.count) + 0.9

		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		for (i, freq) in notes.enumerated() {
			let nd = Double(i) * spacing
			ctx.addOsc(type: .sine,     freq: freq,       start: nd, attackTime: 0.012, peakAmp: 0.38 * masterVol, decayHalf: 0.2)
			ctx.addOsc(type: .triangle, freq: freq * 2,   start: nd, attackTime: 0.012, peakAmp: 0.12 * masterVol, decayHalf: 0.2)
			ctx.addOsc(type: .sine,     freq: freq * 0.5, start: nd, attackTime: 0.012, peakAmp: 0.18 * masterVol, decayHalf: 0.2)
		}
		// Sub thump
		let subFreq = wordLength >= 5 ? 130.0 : 110.0
		let subVol = wordLength >= 7 ? 0.55 : wordLength >= 5 ? 0.42 : 0.3
		ctx.addOscWithFreqSlide(freq: subFreq, endFreq: subFreq / 2, start: 0, duration: 0.22, peakAmp: subVol)
		// Sparkle noise for medium/long words
		if wordLength >= 5 {
			ctx.addNoise(start: 0, duration: 0.045, amplitude: wordLength >= 7 ? 0.4 : 0.22, highpass: false, bandpass: true)
		}
		return ctx.toBuffer()
	}

	func playInvalidSound() {
		play(buffer(for: .invalid) {
			makeInvalidBuffer()
		})
	}

	private func makeInvalidBuffer() -> AVAudioPCMBuffer? {
		let duration = 0.3
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		ctx.addOscWithFreqSlide(freq: 280, endFreq: 80, start: 0, duration: 0.25, peakAmp: 0.5 * 0.8)
		ctx.addNoise(start: 0, duration: 0.07, amplitude: 0.7 * 0.8, highpass: false)
		return ctx.toBuffer()
	}

	func playBonusSound() {
		play(buffer(for: .bonus) {
			makeBonusBuffer()
		})
	}

	private func makeBonusBuffer() -> AVAudioPCMBuffer? {
		let pairs: [(Double, Double)] = [(784.0, 0), (1046.5, 0.14)]
		let duration = 0.45
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		for (freq, delay) in pairs {
			ctx.addOsc(type: .sine,     freq: freq,     start: delay, attackTime: 0.01, peakAmp: 0.42, decayHalf: 0.1)
			ctx.addOsc(type: .triangle, freq: freq * 2, start: delay, attackTime: 0.001, peakAmp: 0.12, decayHalf: 0.07)
		}
		return ctx.toBuffer()
	}

	func playConnectedWordSound(wordLength: Int) {
		let noteCount = wordLength >= 7 ? 8 : wordLength >= 5 ? 6 : 4
		play(buffer(for: .connected(noteCount: noteCount)) {
			makeConnectedWordBuffer(wordLength: wordLength)
		})
	}

	private func makeConnectedWordBuffer(wordLength: Int) -> AVAudioPCMBuffer? {
		let noteCount = wordLength >= 7 ? 8 : wordLength >= 5 ? 6 : 4
		let shimmerVol = wordLength >= 7 ? 0.26 : wordLength >= 5 ? 0.2 : 0.14
		let allNotes: [Double] = [1046.5, 1318.51, 1567.98, 2093.0, 2637.02, 3135.96, 4186.01, 5274.04]
		let notes = Array(allNotes.prefix(noteCount))
		let duration = Double(noteCount) * 0.045 + 0.55

		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		for (i, freq) in notes.enumerated() {
			let t = Double(i) * 0.045
			let type: OscType = i % 2 == 0 ? .sine : .triangle
			ctx.addOsc(type: type, freq: freq, start: t, attackTime: 0.01, peakAmp: shimmerVol, decayHalf: 0.18)
		}
		return ctx.toBuffer()
	}

	func playChainStreakSound(streak: Int) {
		play(buffer(for: .chain(streak: min(streak, 3))) {
			makeChainStreakBuffer(streak: streak)
		})
	}

	private func makeChainStreakBuffer(streak: Int) -> AVAudioPCMBuffer? {
		let fifthRoots: [Double] = [523.25, 587.33, 659.25]
		let root = fifthRoots[min(streak - 1, fifthRoots.count - 1)]
		let fifth = root * 1.5
		let duration = 0.46
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		ctx.addOsc(type: .sine,     freq: root,  start: 0, attackTime: 0.012, peakAmp: 0.24 * 0.42, decayHalf: 0.15)
		ctx.addOsc(type: .triangle, freq: fifth, start: 0, attackTime: 0.012, peakAmp: 0.18 * 0.42, decayHalf: 0.15)
		return ctx.toBuffer()
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
			ctx.addOsc(type: .sine,     freq: freq,     start: nd, attackTime: 0.012, peakAmp: 0.34 * 0.8, decayHalf: 0.18)
			ctx.addOsc(type: .triangle, freq: freq * 2, start: nd, attackTime: 0.012, peakAmp: 0.09 * 0.8, decayHalf: 0.18)
		}
		play(buffer(for: .roundStart(shape: shape.map(String.init).joined())) { ctx.toBuffer() })
	}

	func playRoundEndSound() {
		let notes: [Double] = [392.00, 523.25, 659.25, 783.99, 1046.50]
		let duration = Double(notes.count) * 0.085 + 0.75
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		for (i, freq) in notes.enumerated() {
			let nd = Double(i) * 0.085
			ctx.addOsc(type: .sine,     freq: freq,       start: nd, attackTime: 0.01, peakAmp: 0.34 * 0.88, decayHalf: 0.25)
			ctx.addOsc(type: .triangle, freq: freq * 2,   start: nd, attackTime: 0.01, peakAmp: 0.10 * 0.88, decayHalf: 0.25)
			ctx.addOsc(type: .sine,     freq: freq * 0.5, start: nd, attackTime: 0.01, peakAmp: 0.12 * 0.88, decayHalf: 0.25)
		}
		play(buffer(for: .roundEnd) { ctx.toBuffer() })
	}

	func playTickSound(secondsLeft: Int) {
		play(buffer(for: .tick(secondsLeft: secondsLeft)) {
			makeTickBuffer(secondsLeft: secondsLeft)
		})
	}

	private func makeTickBuffer(secondsLeft: Int) -> AVAudioPCMBuffer? {
		let freq = 600.0 + Double(10 - secondsLeft) * 66.0
		let amplitude = secondsLeft <= 3 ? 0.55 : 0.38
		let duration = 0.15
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		ctx.addOsc(type: .sine, freq: freq, start: 0, attackTime: 0.008, peakAmp: amplitude, decayHalf: 0.04)
		if secondsLeft <= 3 {
			ctx.addOsc(type: .sine, freq: freq * 2, start: 0, attackTime: 0.001, peakAmp: 0.18, decayHalf: 0.035)
		}
		return ctx.toBuffer()
	}

	func startPowerUpChimes(duration: Double) {
		stopPowerUpChimes()
		powerUpStartedAt = Date()
		powerUpDuration = duration
		playPowerUpChime(progress: 0)
		powerUpTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { [weak self] _ in
			guard let self, let start = self.powerUpStartedAt else { return }
			let elapsed = Date().timeIntervalSince(start)
			if elapsed >= self.powerUpDuration {
				self.stopPowerUpChimes()
				return
			}
			self.playPowerUpChime(progress: elapsed / self.powerUpDuration)
		}
	}

	func stopPowerUpChimes() {
		powerUpTimer?.invalidate()
		powerUpTimer = nil
		powerUpStartedAt = nil
	}

	// MARK: - Private helpers

	private func addSparkle(to ctx: inout SynthContext, step: Int, masterGain: Double) {
		let sparkleNotes: [Double] = [659.25, 698.46, 783.99, 880.00, 987.77, 1046.50,
									  1174.66, 1318.51, 1396.91, 1567.98]
		let sparkleCount = min(4, max(3, step - 1))
		let sparkleGain = min(0.105, 0.035 + Double(step - 3) * 0.01) * masterGain
		let rootIndex = min(step - 3, sparkleNotes.count - 4)
		var phrase = Array(sparkleNotes[rootIndex..<min(rootIndex + sparkleCount, sparkleNotes.count)])
		if step >= 7, phrase.count > 1 {
			let last = phrase.removeLast()
			phrase.shuffle()
			phrase.append(last)
		}

		for (i, freq) in phrase.enumerated() {
			let delay = 0.055 + Double(i) * 0.06
			ctx.addOsc(type: .sine, freq: freq, start: delay, attackTime: 0.018, peakAmp: sparkleGain, decayHalf: 0.12)
		}
	}

	private func playPowerUpChime(progress: Double) {
		let powerUpNotes: [Double] = [1046.50, 987.77, 880.00, 783.99, 698.46, 659.25, 587.33, 523.25]
		let startIndex = min(Int(progress * 4), powerUpNotes.count - 3)
		let level = max(0.018, 0.05 * (1 - progress))

		var indices = [startIndex, startIndex + 1, startIndex + 2]
		indices = indices.map { min($0, powerUpNotes.count - 1) }

		let duration = Double(indices.count) * 0.115 + 0.6
		var ctx = SynthContext(duration: duration, sampleRate: sampleRate)
		for (i, idx) in indices.enumerated() {
			let delay = Double(i) * 0.08 + Double.random(in: 0..<0.035)
			ctx.addOsc(type: .sine, freq: powerUpNotes[idx], start: delay,
					   attackTime: 0.02, peakAmp: level, decayHalf: 0.2)
		}
		play(ctx.toBuffer())
	}

	private func play(_ buffer: AVAudioPCMBuffer?) {
		guard let buffer else { return }
		let player = AVAudioPlayerNode()
		engine.attach(player)
		engine.connect(player, to: engine.mainMixerNode, format: buffer.format)
		if !engine.isRunning { try? engine.start() }
		player.scheduleBuffer(buffer) { [weak self] in
			DispatchQueue.main.async { self?.engine.detach(player) }
		}
		player.play()
	}

	private func buffer(for key: SoundKey, make: () -> AVAudioPCMBuffer?) -> AVAudioPCMBuffer? {
		if let cached = bufferCache[key] { return cached }
		let rendered = make()
		bufferCache[key] = rendered
		return rendered
	}
}

private enum SoundKey: Hashable {
	case select(noteIndex: Int, sparkleLevel: Int)
	case word(size: Int)
	case invalid
	case bonus
	case connected(noteCount: Int)
	case chain(streak: Int)
	case roundStart(shape: String)
	case roundEnd
	case tick(secondsLeft: Int)
}

// MARK: - Synthesis primitives

private enum OscType { case sine, triangle, sawtooth }

private struct SynthContext {
	let sampleRate: Double
	var samples: [Float]

	init(duration: Double, sampleRate: Double) {
		self.sampleRate = sampleRate
		self.samples = [Float](repeating: 0, count: Int(ceil(duration * sampleRate)))
	}

	mutating func addOsc(type: OscType, freq: Double, start: Double, attackTime: Double, peakAmp: Double, decayHalf: Double) {
		let startSample = Int(start * sampleRate)
		let attackSamples = max(1, Int(attackTime * sampleRate))
		let count = samples.count

		for i in startSample..<count {
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
			} else {
				let decayElapsed = Double(elapsed - attackSamples) / sampleRate
				let halfLife = max(decayHalf, 0.001)
				gain = peakAmp * exp(-decayElapsed * 0.693 / halfLife)
			}
			samples[i] += Float(raw * gain)
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
		let fadeSamples = min(rendered.count, Int(sampleRate * 0.012))
		if fadeSamples > 1 {
			let start = rendered.count - fadeSamples
			for i in 0..<fadeSamples {
				let gain = Float(fadeSamples - i) / Float(fadeSamples)
				rendered[start + i] *= gain
			}
		}
		for i in rendered.indices {
			rendered[i] = Float(tanh(Double(rendered[i] * 0.9)))
		}
	}
}
