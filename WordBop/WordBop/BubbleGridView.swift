import SwiftUI

let phonetics = [
	"Alpha",
	"Bravo",
	"Charlie",
	"Delta",
	"Echo",
	"Foxtrot",
	"Golf",
	"Hotel",
	"India",
	"Juliet",
	"Kilo",
	"Lima",
	"Mike",
	"November",
	"Oscar",
	"Papa",
	"Quebec",
	"Romeo",
	"Sierra",
	"Tango",
	"Uniform",
	"Victor",
	"Whiskey",
	"XRay",
	"Yankee",
	"Zulu"
]
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
							bopAwayIsActive: vm.bopAwayIsActive,
							size: cellSize,
							speakLetterPositions: vm.speakLetterPositions,
							speakLetterPhonetics: vm.speakLetterPhonetics,
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
	@Environment(\.legibilityWeight) private var legibilityWeight
	let bubble: Bubble
	let isSelected: Bool
	let bopAwayIsActive: Bool
	let size: CGFloat
	let speakLetterPositions: Bool
	let speakLetterPhonetics: Bool
	let textColorOption: BubbleTextColorOption
	let action: () -> Void
	@State private var bopAwayPulse = false

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

	private var accessibilityLetterLabel: String {
		let letter = bubble.letter.lowercased()
		guard speakLetterPhonetics else { return letter }
		guard let scalar = letter.unicodeScalars.first else { return letter }
		let index = Int(scalar.value) - Int(UnicodeScalar("a").value)
		guard phonetics.indices.contains(index) else { return letter }
		return "\(letter), \(phonetics[index])"
	}

	var body: some View {
		Button {
			action()
			if bopAwayIsActive {
				bopAwayPulse = true
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
					bopAwayPulse = false
				}
			}
		} label: {
			ZStack {
				Circle()
					.fill(isSelected ? selectedFillColor : fillColor)
					.overlay {
						Circle()
							.stroke(isSelected ? selectedRingColor : Color.clear, lineWidth: isSelected ? 4 : 0)
					}
					.frame(width: bubbleSize, height: bubbleSize)
					.shadow(color: .black.opacity(isSelected ? 0 : 0.3), radius: 4, y: 3)
					.scaleEffect(circleScale)

				Text(bubble.letter.uppercased())
					.font(.system(size: bubbleLetterSize, weight: letterWeight, design: .monospaced))
					.foregroundStyle(isSelected ? selectedTextColor : textColor)
					.minimumScaleFactor(0.55)
					.lineLimit(1)
			}
			.frame(width: size, height: size)
			.contentShape(Rectangle())
			.animation(reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.6), value: isSelected)
			.animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: bopAwayPulse)
		}
		.buttonStyle(.plain)
		.accessibilityLabel(accessibilityLetterLabel)
		.accessibilityValue(speakLetterPositions ? "\(bubble.col + 1) \(bubble.row + 1)" : "")
		.accessibilityAddTraits(isSelected ? [.isSelected] : [])
		.id(accessibilityStableId)
		.transition(bopAwayIsActive || reduceMotion ? .identity : .scale(scale: 0.0).combined(with: .opacity))
		.animation(bopAwayIsActive || reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6), value: bubble.id)
	}

	private var accessibilityStableId: String {
		bopAwayIsActive ? "\(bubble.row)-\(bubble.col)" : bubble.id.uuidString
	}

	private var circleScale: CGFloat {
		if reduceMotion { return 1.0 }
		if bopAwayPulse { return 0.82 }
		if isSelected { return 0.88 }
		return 1.0
	}

	private var bubbleSize: CGFloat {
		size * 0.92
	}

	private var bubbleLetterSize: CGFloat {
		min(size * 0.58, 40)
	}

	private var letterWeight: Font.Weight {
		legibilityWeight == .bold ? .black : .bold
	}
}
