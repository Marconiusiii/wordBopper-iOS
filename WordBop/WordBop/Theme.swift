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

	static let bubbleFill: [Color] = [
		Color(red: 1.0,   green: 0.537, blue: 0.024),
		Color(red: 0.949, green: 0.373, blue: 0.298),
		Color(red: 0.898, green: 0.192, blue: 0.439),
		Color(red: 0.239, green: 0.663, blue: 0.988),
		Color(red: 0.447, green: 0.820, blue: 0.561),
		Color(red: 0.722, green: 0.753, blue: 1.0),
		Color(red: 1.0,   green: 0.820, blue: 0.400),
		Color(red: 0.937, green: 0.522, blue: 0.659),
	]

	static let bubbleText: [Color] = [
		.black, .white, .white, .black, .black, .black, .black, .black,
	]
}
