import Foundation

enum DictionaryLanguage: String, CaseIterable, Identifiable {
	case english
	case spanish

	var id: String { rawValue }

	var label: String {
		switch self {
		case .english:
			"English"
		case .spanish:
			"Spanish"
		}
	}

	var locale: Locale {
		switch self {
		case .english:
			Locale(identifier: "en")
		case .spanish:
			Locale(identifier: "es")
		}
	}

	var resourceName: String {
		switch self {
		case .english:
			"words"
		case .spanish:
			"words-es"
		}
	}

	var letterPool: [String] {
		switch self {
		case .english:
			Array(
				"aaaaaaaaaabbccddddeeeeeeeeeefffggghhhhiiiiiiijkllll" +
				"mmnnnnnnoooooooppqrrrrrsssssstttttttuuuuvvwwxyyz"
			).map { String($0) }
		case .spanish:
			Array(
				"aaaaaaaaaaaabbccddddeeeeeeeeeeffggghhiiiiiiijkllll" +
				"mmmmnnnnnñoooooooppqrrrrrrssssssttttttuuuuvxyyz"
			).map { String($0) }
		}
	}
}

final class DictionaryService {
	static let shared = DictionaryService()
	private var cachedWords: [DictionaryLanguage: Set<String>] = [:]

	private init() {}

	func contains(_ word: String, language: DictionaryLanguage) -> Bool {
		words(for: language).contains(word.lowercased())
	}

	private func words(for language: DictionaryLanguage) -> Set<String> {
		if let words = cachedWords[language] { return words }
		guard let url = Bundle.main.url(forResource: language.resourceName, withExtension: "txt"),
			  let content = try? String(contentsOf: url, encoding: .utf8) else {
			cachedWords[language] = []
			return []
		}
		let words = Set(content.components(separatedBy: .newlines).filter { !$0.isEmpty })
		cachedWords[language] = words
		return words
	}
}
