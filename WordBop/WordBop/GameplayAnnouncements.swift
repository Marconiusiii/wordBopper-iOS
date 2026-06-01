import Foundation

enum GameplayAnnouncements {
	static let cleared = "Cleared."
	static let wordCleared = "Word cleared."
	static let clearedWithTimeBonus = "Cleared. 15 seconds added."

	static func invalidWord(_ word: String, language: DictionaryLanguage) -> AttributedString {
		spokenWord(word, language: language) + AttributedString(", not valid.")
	}

	static func duplicateWord(_ word: String, language: DictionaryLanguage) -> AttributedString {
		spokenWord(word, language: language) + AttributedString(", already found.")
	}

	static let disconnectedBoppleWord = "Bopple words must use letters that are next to each other."

	static func scoredWord(
		word: String,
		language: DictionaryLanguage,
		points: Int,
		chainBonus: Int,
		multiplier: Int,
		powerUpActivated: Bool,
		verbosity: GameAnnouncementVerbosity
	) -> AttributedString {
		let pointText = points == 1 ? "1 point" : "\(points) points"

		if verbosity == .low {
			return AttributedString(powerUpActivated ? "3 times active!" : "\(pointText).")
		}

		if powerUpActivated {
			return AttributedString("3 times active!")
		}

		var announcement = spokenWord(word, language: language) + AttributedString(", \(pointText)")

		if multiplier > 1 {
			announcement += AttributedString(", 3 times")
		} else if chainBonus > 0 {
			announcement += AttributedString(", chain bonus")
		}

		return announcement + AttributedString(".")
	}

	/// The played word with the chosen language applied so VoiceOver speaks it with
	/// the correct pronunciation. The surrounding announcement text stays in English.
	private static func spokenWord(_ word: String, language: DictionaryLanguage) -> AttributedString {
		var spoken = AttributedString(word)
		spoken.languageIdentifier = language.speechLanguage
		return spoken
	}
}
