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
			return "\(bubble.col + 1) \(bubble.row + 1)"
		case .columnLetterRowNumber:
			return "\(gridLetter(for: bubble.col))\(bubble.row + 1)"
		case .columnNumberRowLetter:
			return "\(bubble.col + 1)\(gridLetter(for: bubble.row))"
		}
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
					.lineLimit(1)
					.fixedSize()
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

	// The circle is allowed to grow until adjacent bubbles just touch
	// (no overlap). It fills the cell save for a hairline so neighboring
	// circles read as distinct shapes rather than a merged blob.
	private var bubbleSize: CGFloat {
		visualSize * 0.97
	}

	// Letter sizing honors Dynamic Type first, then is clamped to the
	// largest size whose drawn glyph still fits inside the cell with a
	// no-overlap margin on every side. The clamp — not Dynamic Type — is
	// the guarantee that letters never touch, clip, or get truncated.
	//
	// `letterFitFraction` is the share of the square cell the glyph's
	// bounding box may occupy. It is tuned for the worst case: a wide
	// uppercase glyph ("W"/"M") in the black weight of the widest font
	// design (monospaced). Because the cap derives from the cell size,
	// it is automatically correct at every grid dimension and in both
	// orientations (cells are always square via min(cellW, cellH)).
	private var bubbleLetterSize: CGFloat {
		// Map the system text size to a point target so a low-vision
		// user's Dynamic Type setting genuinely enlarges the letter,
		// rather than being a minor nudge as before.
		let target = dynamicTypeTargetPointSize
		let cap = visualSize * letterFitFraction
		return min(target, cap)
	}

	// Point size the user's Dynamic Type setting "wants" for the letter,
	// before the per-cell fit clamp is applied. The largest accessibility
	// sizes ask for a very large glyph; the clamp then caps it to fit.
	private var dynamicTypeTargetPointSize: CGFloat {
		switch dynamicTypeSize {
		case .xSmall:           return 44
		case .small:            return 48
		case .medium:           return 52
		case .large:            return 56
		case .xLarge:           return 62
		case .xxLarge:          return 68
		case .xxxLarge:         return 76
		case .accessibility1:   return 88
		case .accessibility2:   return 100
		case .accessibility3:   return 116
		case .accessibility4:   return 132
		case .accessibility5:   return 148
		@unknown default:       return 56
		}
	}

	// Fraction of the cell the glyph box may fill. The black weight needs
	// a touch more breathing room than bold to keep adjacent glyphs from
	// crowding, so the no-overlap margin tightens slightly when Bold Text
	// (legibilityWeight == .bold) is on.
	private var letterFitFraction: CGFloat {
		legibilityWeight == .bold ? 0.66 : 0.70
	}

	private var letterWeight: Font.Weight {
		legibilityWeight == .bold ? .black : .bold
	}
}
