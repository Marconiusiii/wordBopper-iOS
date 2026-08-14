import Foundation

enum GameplayAnnouncements {
	static var cleared: String { String(localized: "Cleared.") }
	static var wordCleared: String { String(localized: "Word cleared.") }
	static var clearedWithTimeBonus: String { String(localized: "Cleared. 15 seconds added.") }

	static func invalidWord(_ word: String, language: DictionaryLanguage) -> AttributedString {
		spokenWord(word, language: language) + AttributedString(String(localized: ", not valid.", comment: "Spoken after an invalid word; leading comma joins it to the word"))
	}

	static func duplicateWord(_ word: String, language: DictionaryLanguage) -> AttributedString {
		spokenWord(word, language: language) + AttributedString(String(localized: ", already found.", comment: "Spoken after a duplicate word; leading comma joins it to the word"))
	}

	static var disconnectedBoppleWord: String { String(localized: "Bopple words must use letters that are next to each other.") }

	static func scoredWord(
		word: String,
		language: DictionaryLanguage,
		points: Int,
		chainBonus: Int,
		multiplier: Int,
		powerUpActivated: Bool,
		dailyBopActivated: Bool = false,
		bopHuntFound: Bool = false,
		verbosity: GameAnnouncementVerbosity
	) -> AttributedString {
		let pointText = String(localized: "\(points) points", comment: "Score points spoken aloud; supports plural rules, e.g. 1 point / 5 points")

		if verbosity == .low {
			if dailyBopActivated { return AttributedString(String(localized: "Daily Bop found! 3 times boost active!")) }
			if bopHuntFound { return AttributedString(String(localized: "Bop Hunt word found!")) }
			if powerUpActivated { return AttributedString(String(localized: "3 times active!")) }
			return AttributedString(String(localized: "\(pointText).", comment: "Low-verbosity score readout: the point count followed by a period"))
		}

		if dailyBopActivated {
			return spokenWord(word, language: language) + AttributedString(String(localized: ", Daily Bop found! 3 times boost active!", comment: "Spoken after the daily word is found; leading comma joins it to the word"))
		}

		if powerUpActivated {
			return AttributedString(String(localized: "3 times active!"))
		}

		var announcement = spokenWord(word, language: language) + AttributedString(String(localized: ", \(pointText)", comment: "Joins the spoken word to its point count, e.g. 'cat, 3 points'"))

		if multiplier > 1 {
			announcement += AttributedString(String(localized: ", 3 times", comment: "Spoken suffix when a 3x multiplier is active"))
		} else if chainBonus > 0 {
			announcement += AttributedString(String(localized: ", chain bonus", comment: "Spoken suffix when a chain bonus is earned"))
		}

		if bopHuntFound {
			announcement += AttributedString(String(localized: ", Bop Hunt word found", comment: "Spoken suffix when a monthly Bop Hunt word is found"))
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
