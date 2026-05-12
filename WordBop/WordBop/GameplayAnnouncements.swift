enum GameplayAnnouncements {
	static let cleared = "Cleared."
	static let clearedWithTimeBonus = "Cleared. 15 seconds added."

	static func invalidWord(_ word: String) -> String {
		"\(word), not valid."
	}

	static func duplicateWord(_ word: String) -> String {
		"\(word), already found."
	}

	static let disconnectedBoppleWord = "Bopple words must use connected letters."

	static func scoredWord(
		word: String,
		points: Int,
		chainBonus: Int,
		multiplier: Int,
		powerUpActivated: Bool,
		verbosity: GameAnnouncementVerbosity
	) -> String {
		let pointText = points == 1 ? "1 point" : "\(points) points"

		if verbosity == .low {
			return powerUpActivated ? "3 times active!" : "\(pointText)."
		}

		if powerUpActivated {
			return "3 times active!"
		}

		var parts = ["\(word), \(pointText)"]

		if multiplier > 1 {
			parts.append("3 times")
		} else if chainBonus > 0 {
			parts.append("chain bonus")
		}

		return parts.joined(separator: ", ") + "."
	}
}
