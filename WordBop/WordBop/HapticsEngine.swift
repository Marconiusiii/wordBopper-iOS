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

	func wordScored() {
		guard isEnabled else { return }
		pulse(.light, intensity: 0.45)
		pulse(.medium, intensity: 0.65, after: 0.05)
		UINotificationFeedbackGenerator().notificationOccurred(.success)
	}

	func chainWord() {
		guard isEnabled else { return }
		pulse(.medium, intensity: 0.75)
		pulse(.heavy, intensity: 0.8, after: 0.07)
	}

	func powerUpActivated() {
		guard isEnabled else { return }
		pulse(.light, intensity: 0.45)
		pulse(.medium, intensity: 0.7, after: 0.06)
		pulse(.heavy, intensity: 0.95, after: 0.13)
		UINotificationFeedbackGenerator().notificationOccurred(.success)
	}

	func powerUpScored() {
		guard isEnabled else { return }
		pulse(.medium, intensity: 0.8)
		pulse(.heavy, intensity: 1.0, after: 0.06)
		pulse(.soft, intensity: 0.75, after: 0.14)
		UINotificationFeedbackGenerator().notificationOccurred(.success)
	}

	func roundStarted() {
		guard isEnabled else { return }
		UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
	}

	func roundEnded() {
		guard isEnabled else { return }
		pulse(.medium, intensity: 0.65)
		pulse(.heavy, intensity: 0.9, after: 0.09)
		UINotificationFeedbackGenerator().notificationOccurred(.success)
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
