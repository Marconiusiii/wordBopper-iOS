import SwiftUI

struct BubbleGridView: View {
	@Environment(GameViewModel.self) private var vm
	let cellSize: CGFloat

	var body: some View {
		VStack(spacing: 6) {
			ForEach(0..<5, id: \.self) { row in
				HStack(spacing: 6) {
					ForEach(0..<5, id: \.self) { col in
						let bubble = vm.bubbles[row * 5 + col]
						let selected = vm.isSelected(bubble)
						BubbleButton(bubble: bubble, isSelected: selected, size: cellSize) {
							vm.tapBubble(bubble)
						}
					}
				}
			}
		}
	}
}

struct BubbleButton: View {
	@Environment(\.accessibilityReduceMotion) private var reduceMotion
	let bubble: Bubble
	let isSelected: Bool
	let size: CGFloat
	let action: () -> Void

	private var fillColor: Color {
		guard bubble.colorIndex < Color.bubbleFill.count else { return .wbAccent4 }
		return Color.bubbleFill[bubble.colorIndex]
	}

	private var textColor: Color {
		guard bubble.colorIndex < Color.bubbleText.count else { return .black }
		return Color.bubbleText[bubble.colorIndex]
	}

	var body: some View {
		Button(action: action) {
			Text(bubble.letter.uppercased())
				.font(.system(.title2, design: .monospaced).weight(.bold))
				.foregroundStyle(isSelected ? Color.wbSelectedText : textColor)
				.minimumScaleFactor(0.6)
				.lineLimit(1)
				.frame(width: size, height: size)
				.background(
					Circle()
						.fill(isSelected ? Color.wbSelectedBubble : fillColor)
				)
				.shadow(color: .black.opacity(isSelected ? 0 : 0.3), radius: 4, y: 3)
				.scaleEffect(reduceMotion ? 1.0 : (isSelected ? 0.88 : 1.0))
				.animation(reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.6), value: isSelected)
		}
		.buttonStyle(.plain)
		.accessibilityLabel(bubble.letter.uppercased())
		.accessibilityAddTraits(isSelected ? [.isSelected] : [])
		.id(bubble.id)
		.transition(reduceMotion ? .identity : .scale(scale: 0.0).combined(with: .opacity))
		.animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6), value: bubble.id)
	}
}
