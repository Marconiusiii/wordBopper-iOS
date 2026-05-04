import Foundation

final class DictionaryService {
	static let shared = DictionaryService()
	private var words: Set<String> = []

	private init() {
		guard let url = Bundle.main.url(forResource: "words", withExtension: "txt"),
			  let content = try? String(contentsOf: url, encoding: .utf8) else { return }
		words = Set(content.components(separatedBy: .newlines).filter { !$0.isEmpty })
	}

	func contains(_ word: String) -> Bool {
		words.contains(word.lowercased())
	}
}
