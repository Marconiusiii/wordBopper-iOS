import SwiftUI

struct BubbleGridView: View {
	@Environment(GameViewModel.self) private var vm
	let cellSize: CGFloat

	var body: some View {
		VStack(spacing: 0) {
			ForEach(0..<5, id: \.self) { row in
				HStack(spacing: 0) {
					ForEach(0..<5, id: \.self) { col in
						let bubble = vm.bubbles[row * 5 + col]
						let selected = vm.isSelected(bubble)
						BubbleButton(
							bubble: bubble,
							isSelected: selected,
							size: cellSize,
							speakLetterPositions: vm.speakLetterPositions,
							textColorOption: vm.bubbleTextColorOption
						) {
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
	let speakLetterPositions: Bool
	let textColorOption: BubbleTextColorOption
	let action: () -> Void

	private var fillColor: Color {
		let palette = Color.bubbleFill(for: textColorOption)
		guard bubble.colorIndex < palette.count else { return palette[0] }
		return palette[bubble.colorIndex]
	}

	private var textColor: Color {
		Color.bubbleText(for: textColorOption)
	}

	private var selectedFillColor: Color {
		Color.selectedBubbleFill(for: textColorOption)
	}

	private var selectedTextColor: Color {
		Color.selectedBubbleText(for: textColorOption)
	}

	private var selectedRingColor: Color {
		Color.selectedBubbleRing(for: textColorOption)
	}

	var body: some View {
		Button(action: action) {
			ZStack {
				Circle()
					.fill(isSelected ? selectedFillColor : fillColor)
					.overlay {
						Circle()
							.stroke(isSelected ? selectedRingColor : Color.clear, lineWidth: isSelected ? 4 : 0)
					}
					.frame(width: bubbleSize, height: bubbleSize)
					.shadow(color: .black.opacity(isSelected ? 0 : 0.3), radius: 4, y: 3)
					.scaleEffect(reduceMotion ? 1.0 : (isSelected ? 0.88 : 1.0))

				Text(bubble.letter.lowercased())
					.font(.system(.title2, design: .monospaced).weight(.bold))
					.foregroundStyle(isSelected ? selectedTextColor : textColor)
					.minimumScaleFactor(0.6)
					.lineLimit(1)
			}
			.frame(width: size, height: size)
			.contentShape(Rectangle())
			.animation(reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.6), value: isSelected)
		}
		.buttonStyle(.plain)
		.accessibilityLabel(bubble.letter.lowercased())
		.accessibilityValue(speakLetterPositions ? "\(bubble.col + 1) \(bubble.row + 1)" : "")
		.accessibilityAddTraits(isSelected ? [.isSelected] : [])
		.id(bubble.id)
		.transition(reduceMotion ? .identity : .scale(scale: 0.0).combined(with: .opacity))
		.animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6), value: bubble.id)
	}

	private var bubbleSize: CGFloat {
		size * 0.92
	}
}
