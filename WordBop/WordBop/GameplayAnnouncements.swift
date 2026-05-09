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
		powerUpActivated: Bool,
		verbosity: GameAnnouncementVerbosity
	) -> String {
		if verbosity == .low {
			return powerUpActivated ? "3 times active!" : "\(points) points."
		}

		if powerUpActivated {
			return "3 times active!"
		}

		var parts = ["\(word), \(points) points"]

		if multiplier > 1 {
			parts.append("3 times")
		} else if chainBonus > 0 {
			parts.append("chain bonus")
		}

		return parts.joined(separator: ", ") + "."
	}
}
