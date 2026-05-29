import UIKit

@MainActor
final class HapticsEngine {
	var isEnabled = true

	func selectLetter() {
		guard shouldPlayInteractionHaptic else { return }
		UISelectionFeedbackGenerator().selectionChanged()
	}

	func deselectLetter() {
		guard shouldPlayInteractionHaptic else { return }
		UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.45)
	}

	func clearLetters() {
		guard isEnabled else { return }
		pulse(.medium, intensity: 0.65)
		pulse(.light, intensity: 0.45, after: 0.06)
	}

	func invalidWord() {
		guard isEnabled else { return }
		UINotificationFeedbackGenerator().notificationOccurred(.warning)
		pulse(.rigid, intensity: 0.7, after: 0.05)
	}

	func wordScored(wordLength: Int) {
		guard isEnabled else { return }
		let noteCount = wordLength >= 7 ? 7 : wordLength >= 5 ? 5 : 3
		let spacing = wordLength >= 7 ? 0.055 : wordLength >= 5 ? 0.065 : 0.075
		let finishTime = spacing * Double(noteCount) + 0.52

		pulse(.medium, intensity: wordLength >= 7 ? 0.82 : 0.64)
		for index in 0..<noteCount {
			let intensity = min(0.38 + CGFloat(index) * 0.07, 0.82)
			pulse(.light, intensity: intensity, after: Double(index) * spacing)
		}
		pulse(.soft, intensity: 0.42, after: finishTime)
		pulse(.soft, intensity: 0.28, after: finishTime + 0.26)
	}

	func chainWord() {
		guard isEnabled else { return }
		for index in 0..<4 {
			pulse(.light, intensity: 0.36 + CGFloat(index) * 0.08, after: Double(index) * 0.045)
		}
		pulse(.medium, intensity: 0.82, after: 0.2)
		pulse(.soft, intensity: 0.34, after: 0.46)
	}

	func powerUpActivated() {
		guard isEnabled else { return }
		pulse(.light, intensity: 0.35)
		pulse(.light, intensity: 0.48, after: 0.07)
		pulse(.medium, intensity: 0.64, after: 0.14)
		pulse(.heavy, intensity: 0.88, after: 0.24)
		pulse(.soft, intensity: 0.36, after: 0.42)
	}

	func powerUpScored() {
		guard isEnabled else { return }
		let glissandoTimes = [0.02, 0.085, 0.15, 0.215, 0.28, 0.34]
		for (index, time) in glissandoTimes.enumerated() {
			pulse(.light, intensity: 0.36 + CGFloat(index) * 0.08, after: time)
		}

		pulse(.medium, intensity: 0.62, after: 0.255)
		pulse(.medium, intensity: 0.72, after: 0.295)
		pulse(.medium, intensity: 0.82, after: 0.335)
		pulse(.heavy, intensity: 1.0, after: 0.39)
		pulse(.soft, intensity: 0.62, after: 0.68)
		pulse(.soft, intensity: 0.42, after: 0.95)
		pulse(.soft, intensity: 0.26, after: 1.2)
	}

	func roundStarted() {
		guard isEnabled else { return }
		UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
	}

	func roundEnded() {
		guard isEnabled else { return }
		for index in 0..<7 {
			let style: UIImpactFeedbackGenerator.FeedbackStyle = index == 6 ? .heavy : .light
			let intensity = index == 6 ? 0.95 : min(0.36 + CGFloat(index) * 0.07, 0.76)
			pulse(style, intensity: intensity, after: Double(index) * 0.085)
		}
		pulse(.soft, intensity: 0.42, after: 0.92)
		pulse(.soft, intensity: 0.28, after: 1.2)
	}

	private var shouldPlayInteractionHaptic: Bool {
		isEnabled && !UIAccessibility.isVoiceOverRunning
	}

	private func pulse(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat, after delay: TimeInterval = 0) {
		let play: @MainActor @Sendable () -> Void = {
			UIImpactFeedbackGenerator(style: style).impactOccurred(intensity: intensity)
		}
		if delay == 0 {
			play()
		} else {
			DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: play)
		}
	}
}
