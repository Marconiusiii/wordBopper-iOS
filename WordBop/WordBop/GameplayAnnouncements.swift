enum GameplayAnnouncements {
	static let cleared = "Cleared."
	static let clearedWithTimeBonus = "Cleared. 15 seconds added."

	static func invalidWord(_ word: String) -> String {
		"\(word), not valid."
	}

	static func scoredWord(
		word: String,
		points: Int,
		chainBonus: Int,
		multiplier: Int,
		powerUpActivated: Bool
	) -> String {
		var parts = ["\(word), \(points) points"]

		if multiplier > 1 {
			parts.append("3 times")
		} else if chainBonus > 0 {
			parts.append("chain bonus")
		}

		if powerUpActivated {
			parts.append("3 times ready")
		}

		return parts.joined(separator: ", ") + "."
	}
}
