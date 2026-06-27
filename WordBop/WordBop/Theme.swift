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

	static func bubbleFill(for option: BubbleTextColorOption, theme: BubbleColorTheme) -> [Color] {
		guard theme.supports(option) else {
			return bubbleFill(for: option, theme: BubbleColorTheme.defaultTheme(for: option))
		}

		return switch theme {
		case .classicBright:
			darkTextBubbleFill
		case .pastel:
			[
				Color(red: 1.000, green: 0.733, blue: 0.820),
				Color(red: 0.741, green: 0.902, blue: 1.000),
				Color(red: 0.792, green: 0.941, blue: 0.753),
				Color(red: 1.000, green: 0.878, blue: 0.545),
				Color(red: 0.859, green: 0.776, blue: 1.000),
				Color(red: 1.000, green: 0.788, blue: 0.698),
				Color(red: 0.733, green: 0.929, blue: 0.902),
				Color(red: 0.949, green: 0.827, blue: 0.925),
			]
		case .spring:
			[
				Color(red: 0.741, green: 0.929, blue: 0.522),
				Color(red: 0.992, green: 0.737, blue: 0.816),
				Color(red: 1.000, green: 0.902, blue: 0.455),
				Color(red: 0.549, green: 0.878, blue: 0.749),
				Color(red: 0.816, green: 0.741, blue: 1.000),
				Color(red: 0.996, green: 0.792, blue: 0.529),
				Color(red: 0.690, green: 0.886, blue: 1.000),
				Color(red: 0.929, green: 0.851, blue: 0.502),
			]
		case .summer:
			[
				Color(red: 1.000, green: 0.780, blue: 0.149),
				Color(red: 0.137, green: 0.820, blue: 0.957),
				Color(red: 1.000, green: 0.490, blue: 0.302),
				Color(red: 0.553, green: 0.902, blue: 0.349),
				Color(red: 1.000, green: 0.914, blue: 0.357),
				Color(red: 0.310, green: 0.780, blue: 1.000),
				Color(red: 1.000, green: 0.627, blue: 0.365),
				Color(red: 0.678, green: 0.855, blue: 0.278),
			]
		case .candy:
			[
				Color(red: 1.000, green: 0.576, blue: 0.741),
				Color(red: 0.561, green: 0.843, blue: 1.000),
				Color(red: 1.000, green: 0.753, blue: 0.227),
				Color(red: 0.722, green: 0.624, blue: 1.000),
				Color(red: 0.518, green: 0.922, blue: 0.706),
				Color(red: 1.000, green: 0.624, blue: 0.475),
				Color(red: 0.937, green: 0.788, blue: 1.000),
				Color(red: 0.996, green: 0.886, blue: 0.345),
			]
		case .garden:
			[
				Color(red: 0.557, green: 0.859, blue: 0.514),
				Color(red: 0.792, green: 0.749, blue: 0.373),
				Color(red: 0.933, green: 0.733, blue: 0.463),
				Color(red: 0.667, green: 0.890, blue: 0.694),
				Color(red: 0.765, green: 0.847, blue: 0.502),
				Color(red: 0.988, green: 0.808, blue: 0.584),
				Color(red: 0.478, green: 0.824, blue: 0.675),
				Color(red: 0.882, green: 0.780, blue: 0.420),
			]
		case .sunrise:
			[
				Color(red: 1.000, green: 0.655, blue: 0.271),
				Color(red: 1.000, green: 0.784, blue: 0.337),
				Color(red: 0.984, green: 0.549, blue: 0.463),
				Color(red: 1.000, green: 0.890, blue: 0.502),
				Color(red: 0.957, green: 0.686, blue: 0.671),
				Color(red: 1.000, green: 0.718, blue: 0.424),
				Color(red: 0.925, green: 0.765, blue: 0.925),
				Color(red: 1.000, green: 0.835, blue: 0.482),
			]
		case .sky:
			[
				Color(red: 0.475, green: 0.812, blue: 1.000),
				Color(red: 0.631, green: 0.886, blue: 1.000),
				Color(red: 0.788, green: 0.831, blue: 1.000),
				Color(red: 0.557, green: 0.890, blue: 0.937),
				Color(red: 0.722, green: 0.906, blue: 1.000),
				Color(red: 0.612, green: 0.741, blue: 1.000),
				Color(red: 0.518, green: 0.855, blue: 0.890),
				Color(red: 0.831, green: 0.890, blue: 1.000),
			]
		case .softWhite:
			Array(repeating: Color(red: 0.925, green: 0.933, blue: 0.949), count: 8)
		case .classicDeep:
			lightTextBubbleFill
		case .neon:
			[
				Color(red: 0.000, green: 0.376, blue: 0.455),
				Color(red: 0.408, green: 0.086, blue: 0.592),
				Color(red: 0.655, green: 0.000, blue: 0.290),
				Color(red: 0.000, green: 0.435, blue: 0.302),
				Color(red: 0.110, green: 0.231, blue: 0.702),
				Color(red: 0.635, green: 0.255, blue: 0.000),
				Color(red: 0.486, green: 0.000, blue: 0.529),
				Color(red: 0.000, green: 0.353, blue: 0.706),
			]
		case .fall:
			[
				Color(red: 0.514, green: 0.141, blue: 0.024),
				Color(red: 0.576, green: 0.247, blue: 0.031),
				Color(red: 0.459, green: 0.286, blue: 0.075),
				Color(red: 0.533, green: 0.075, blue: 0.114),
				Color(red: 0.365, green: 0.286, blue: 0.125),
				Color(red: 0.600, green: 0.325, blue: 0.039),
				Color(red: 0.420, green: 0.176, blue: 0.039),
				Color(red: 0.435, green: 0.110, blue: 0.165),
			]
		case .winter:
			[
				Color(red: 0.122, green: 0.247, blue: 0.439),
				Color(red: 0.075, green: 0.345, blue: 0.451),
				Color(red: 0.271, green: 0.251, blue: 0.514),
				Color(red: 0.118, green: 0.322, blue: 0.365),
				Color(red: 0.188, green: 0.251, blue: 0.396),
				Color(red: 0.051, green: 0.392, blue: 0.478),
				Color(red: 0.302, green: 0.314, blue: 0.510),
				Color(red: 0.141, green: 0.298, blue: 0.490),
			]
		case .forest:
			[
				Color(red: 0.047, green: 0.286, blue: 0.188),
				Color(red: 0.141, green: 0.333, blue: 0.118),
				Color(red: 0.235, green: 0.302, blue: 0.078),
				Color(red: 0.075, green: 0.357, blue: 0.267),
				Color(red: 0.220, green: 0.271, blue: 0.149),
				Color(red: 0.000, green: 0.333, blue: 0.318),
				Color(red: 0.314, green: 0.294, blue: 0.098),
				Color(red: 0.102, green: 0.251, blue: 0.157),
			]
		case .ocean:
			[
				Color(red: 0.000, green: 0.298, blue: 0.451),
				Color(red: 0.000, green: 0.373, blue: 0.416),
				Color(red: 0.055, green: 0.220, blue: 0.514),
				Color(red: 0.000, green: 0.435, blue: 0.565),
				Color(red: 0.075, green: 0.251, blue: 0.392),
				Color(red: 0.000, green: 0.337, blue: 0.624),
				Color(red: 0.000, green: 0.282, blue: 0.333),
				Color(red: 0.141, green: 0.314, blue: 0.573),
			]
		case .sunset:
			[
				Color(red: 0.596, green: 0.165, blue: 0.059),
				Color(red: 0.518, green: 0.102, blue: 0.259),
				Color(red: 0.443, green: 0.110, blue: 0.506),
				Color(red: 0.706, green: 0.267, blue: 0.000),
				Color(red: 0.369, green: 0.141, blue: 0.514),
				Color(red: 0.612, green: 0.204, blue: 0.275),
				Color(red: 0.471, green: 0.204, blue: 0.110),
				Color(red: 0.302, green: 0.149, blue: 0.490),
			]
		case .galaxy:
			[
				Color(red: 0.149, green: 0.137, blue: 0.365),
				Color(red: 0.290, green: 0.102, blue: 0.439),
				Color(red: 0.086, green: 0.188, blue: 0.424),
				Color(red: 0.333, green: 0.078, blue: 0.333),
				Color(red: 0.133, green: 0.235, blue: 0.329),
				Color(red: 0.247, green: 0.153, blue: 0.514),
				Color(red: 0.078, green: 0.153, blue: 0.345),
				Color(red: 0.376, green: 0.122, blue: 0.431),
			]
		case .softCharcoal:
			Array(repeating: Color(red: 0.173, green: 0.184, blue: 0.212), count: 8)
		}
	}

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
