import SwiftUI

extension Color {
	static let wbBackground  = Color(red: 0.059, green: 0.055, blue: 0.090)
	static let wbSurface     = Color(red: 0.102, green: 0.094, blue: 0.149)
	static let wbPanel       = Color(red: 0.133, green: 0.122, blue: 0.208)
	static let wbText        = Color(red: 1.0,   green: 1.0,   blue: 0.996)
	static let wbMuted       = Color(red: 0.655, green: 0.663, blue: 0.745)
	static let wbAccent1     = Color(red: 1.0,   green: 0.537, blue: 0.024)
	static let wbAccent2     = Color(red: 0.949, green: 0.373, blue: 0.298)
	static let wbAccent3     = Color(red: 0.898, green: 0.192, blue: 0.439)
	static let wbAccent4     = Color(red: 0.239, green: 0.663, blue: 0.988)
	static let wbAccent5     = Color(red: 0.447, green: 0.820, blue: 0.561)
	static let wbTimerGreen  = Color(red: 0.447, green: 0.820, blue: 0.561)
	static let wbSelectedBubble = Color(red: 0.275, green: 0.275, blue: 0.365)
	static let wbSelectedText = Color.white

	static let darkTextBubbleFill: [Color] = [
		Color(red: 1.0,   green: 0.537, blue: 0.024),
		Color(red: 1.0,   green: 0.624, blue: 0.122),
		Color(red: 0.239, green: 0.663, blue: 0.988),
		Color(red: 0.447, green: 0.820, blue: 0.561),
		Color(red: 0.722, green: 0.753, blue: 1.0),
		Color(red: 1.0,   green: 0.820, blue: 0.400),
		Color(red: 0.937, green: 0.522, blue: 0.659),
		Color(red: 0.561, green: 0.941, blue: 0.780),
	]

	static let lightTextBubbleFill: [Color] = [
		Color(red: 0.451, green: 0.141, blue: 0.027),
		Color(red: 0.514, green: 0.128, blue: 0.235),
		Color(red: 0.345, green: 0.176, blue: 0.651),
		Color(red: 0.075, green: 0.298, blue: 0.565),
		Color(red: 0.000, green: 0.373, blue: 0.290),
		Color(red: 0.333, green: 0.263, blue: 0.675),
		Color(red: 0.478, green: 0.267, blue: 0.024),
		Color(red: 0.282, green: 0.251, blue: 0.376),
	]

	static func bubbleFill(for option: BubbleTextColorOption) -> [Color] {
		switch option {
		case .dark:
			darkTextBubbleFill
		case .light:
			lightTextBubbleFill
		}
	}

	static func bubbleText(for option: BubbleTextColorOption) -> Color {
		switch option {
		case .dark:
			.black
		case .light:
			.white
		}
	}

	static func selectedBubbleFill(for option: BubbleTextColorOption) -> Color {
		switch option {
		case .dark:
			wbSelectedBubble
		case .light:
			Color(red: 1.0, green: 0.878, blue: 0.322)
		}
	}

	static func selectedBubbleText(for option: BubbleTextColorOption) -> Color {
		switch option {
		case .dark:
			.white
		case .light:
			.black
		}
	}

	static func selectedBubbleRing(for option: BubbleTextColorOption) -> Color {
		switch option {
		case .dark:
			wbAccent5
		case .light:
			Color(red: 0.075, green: 0.298, blue: 0.565)
		}
	}
}
