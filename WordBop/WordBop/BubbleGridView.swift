import SwiftUI

struct BubbleGridView: View {
	@Environment(GameViewModel.self) private var vm

	var body: some View {
		GeometryReader { geo in
			let cellWidth = geo.size.width / CGFloat(vm.gridSize)
			let cellHeight = geo.size.height / CGFloat(vm.gridSize)
			let visualSize = min(cellWidth, cellHeight)

			VStack(spacing: 0) {
				ForEach(0..<vm.gridSize, id: \.self) { row in
					HStack(spacing: 0) {
						ForEach(0..<vm.gridSize, id: \.self) { col in
							let index = row * vm.gridSize + col
							if index < vm.bubbles.count {
								let bubble = vm.bubbles[index]
								let selected = vm.isSelected(bubble)
								BubbleButton(
									bubble: bubble,
									isSelected: selected,
									bopAwayIsActive: vm.bopAwayIsActive,
									visualSize: visualSize,
									touchWidth: cellWidth,
									touchHeight: cellHeight,
									letterPositionMode: vm.letterPositionMode,
									speakLetterPhonetics: vm.speakLetterPhonetics,
									dictionaryLanguage: vm.dictionaryLanguage,
									speechLanguage: vm.dictionaryLanguage.speechLanguage,
									textColorOption: vm.bubbleTextColorOption,
									letterStyle: vm.bubbleLetterStyle
								) {
									vm.tapBubble(bubble)
								}
							}
						}
					}
					.frame(height: cellHeight)
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
	}
}

struct BubbleButton: View {
	@Environment(\.accessibilityReduceMotion) private var reduceMotion
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	@Environment(\.legibilityWeight) private var legibilityWeight
	let bubble: Bubble
	let isSelected: Bool
	let bopAwayIsActive: Bool
	let visualSize: CGFloat
	let touchWidth: CGFloat
	let touchHeight: CGFloat
	let letterPositionMode: LetterPositionMode
	let speakLetterPhonetics: Bool
	let dictionaryLanguage: DictionaryLanguage
	let speechLanguage: String
	let textColorOption: BubbleTextColorOption
	let letterStyle: BubbleLetterStyle
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
		guard let phoneticName = dictionaryLanguage.phoneticName(for: letter) else { return letter }
		return "\(letter), \(phoneticName)"
	}

	private var accessibilityPositionValue: String {
		switch letterPositionMode {
		case .off:
			return ""
		case .columnNumberRowNumber:
			return "\(localizedNumber(bubble.col + 1)) \(localizedNumber(bubble.row + 1))"
		case .columnLetterRowNumber:
			return "\(gridLetter(for: bubble.col))\(bubble.row + 1)"
		case .columnNumberRowLetter:
			return "\(bubble.col + 1)\(gridLetter(for: bubble.row))"
		}
	}

	private func localizedNumber(_ number: Int) -> String {
		let formatter = NumberFormatter()
		formatter.locale = Locale(identifier: speechLanguage)
		formatter.numberStyle = .spellOut
		return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
	}

	private func gridLetter(for index: Int) -> String {
		UnicodeScalar(65 + index).map(String.init) ?? "A"
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
					.font(.system(size: bubbleLetterSize, weight: letterWeight, design: letterStyle.fontDesign))
					.foregroundStyle(isSelected ? selectedTextColor : textColor)
					.minimumScaleFactor(0.55)
					.lineLimit(1)
			}
			.frame(width: touchWidth, height: touchHeight)
			.contentShape(Rectangle())
			.animation(reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.6), value: isSelected)
			.animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: bopAwayPulse)
		}
		.buttonStyle(.plain)
		.accessibilityLabel(accessibilityLetterLabel)
		.accessibilityValue(accessibilityPositionValue)
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
		visualSize * 0.92
	}

	private var bubbleLetterSize: CGFloat {
		let scale = dynamicTypeSize.isAccessibilitySize ? 0.66 : 0.58
		let cap: CGFloat = dynamicTypeSize.isAccessibilitySize ? 74 : 66
		return min(visualSize * scale, cap)
	}

	private var letterWeight: Font.Weight {
		legibilityWeight == .bold ? .black : .bold
	}
}
