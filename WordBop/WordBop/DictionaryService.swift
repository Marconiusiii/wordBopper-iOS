import Foundation

enum DictionaryLanguage: String, CaseIterable, Identifiable, Codable {
	case english
	case spanish
	case french
	case german
	case dutch
	case italian
	case brazilianPortuguese

	var id: String { rawValue }

	var label: String {
		switch self {
		case .english:
			String(localized: "English", comment: "Bubble Language name")
		case .spanish:
			String(localized: "Spanish", comment: "Bubble Language name")
		case .french:
			String(localized: "French", comment: "Bubble Language name")
		case .german:
			String(localized: "German", comment: "Bubble Language name")
		case .dutch:
			String(localized: "Dutch", comment: "Bubble Language name")
		case .italian:
			String(localized: "Italian", comment: "Bubble Language name")
		case .brazilianPortuguese:
			String(localized: "Brazilian Portuguese", comment: "Bubble Language name")
		}
	}

	var locale: Locale {
		switch self {
		case .english:
			Locale(identifier: "en")
		case .spanish:
			Locale(identifier: "es")
		case .french:
			Locale(identifier: "fr")
		case .german:
			Locale(identifier: "de")
		case .dutch:
			Locale(identifier: "nl-NL")
		case .italian:
			Locale(identifier: "it")
		case .brazilianPortuguese:
			Locale(identifier: "pt-BR")
		}
	}

	var speechLanguage: String {
		switch self {
		case .english:
			"en"
		case .spanish:
			"es"
		case .french:
			"fr"
		case .german:
			"de"
		case .dutch:
			"nl-NL"
		case .italian:
			"it"
		case .brazilianPortuguese:
			"pt-BR"
		}
	}

	var resourceName: String {
		switch self {
		case .english:
			"words-en"
		case .spanish:
			"words-es"
		case .french:
			"words-fr"
		case .german:
			"words-de"
		case .dutch:
			"words-nl"
		case .italian:
			"words-it"
		case .brazilianPortuguese:
			"words-pt-BR"
		}
	}

	var dailyResourceName: String {
		"daily-\(resourceName)"
	}

	var letterPool: [String] {
		Array(tunedLetterDistribution).map { String($0) }
	}

	private var tunedLetterDistribution: String {
		switch self {
		case .english:
			"aaaaaaabccccdddeeeeeeeeeeefgghhiiiiiiiiiiiijklllllmmnnnnnnoooooopppppqrrrrrrrsssssssssttttttuuuvwxyz"
		case .spanish:
			"aaaaaaaaaaaaaaaabbccccdddeeeeeeeeeeefghiiiiiiijklllmmmnnnnnnnnñooooooppqrrrrrrrrsssssssssttttuuvwxyz"
		case .french:
			"aaaaaaaaabcccddeeeeeeeeeeeeeefghiiiiiiiiijklllllllmmnnnnnnnoooooppqrrrrrrrrssssssssssttttttuuuvwxyzç"
		case .german:
			"aaaaaabbccddeeeeeeeeeeeeeeeffggghhhhiiiiiiiiiijkkllllmmnnnnnnnnnooopqrrrrrrrssssssstttttttuuuuvwxyzß"
		case .dutch:
			"aaaaaaabbbcccddddeeeeeeeeeeeeeeeffggghhiiiiiiiijjkkkllllmmmmnnnnnnnnoooooopppqrrrrrrrsssssssttttttuuuvvwwxyz"
		case .italian:
			"aaaaaaaaaaabccccddeeeeeeeeeefgghiiiiiiiiiiiijklllmmmmmmnnnnnnooooooooppqrrrrrrrrsssssssttttttuvvwxyz"
		case .brazilianPortuguese:
			"aaaaaaaaaaaaaaaabcccccddeeeeeeeeefghiiiiiiiiiiijkllllmmmnnnnnoooooooooooppqrrrrrrrsssstttttuuuvwxyzç"
		}
	}

	func phoneticName(for letter: String) -> String? {
		phonetics[letter.lowercased()]
	}

	private var phonetics: [String: String] {
		switch self {
		case .english:
			[
				"a": "Alpha",
				"b": "Bravo",
				"c": "Charlie",
				"d": "Delta",
				"e": "Echo",
				"f": "Foxtrot",
				"g": "Golf",
				"h": "Hotel",
				"i": "India",
				"j": "Juliet",
				"k": "Kilo",
				"l": "Lima",
				"m": "Mike",
				"n": "November",
				"o": "Oscar",
				"p": "Papa",
				"q": "Quebec",
				"r": "Romeo",
				"s": "Sierra",
				"t": "Tango",
				"u": "Uniform",
				"v": "Victor",
				"w": "Whiskey",
				"x": "XRay",
				"y": "Yankee",
				"z": "Zulu"
			]
		case .spanish:
			[
				"a": "Antonio",
				"b": "Barcelona",
				"c": "Carmen",
				"d": "Dolores",
				"e": "España",
				"f": "Francia",
				"g": "Granada",
				"h": "Historia",
				"i": "Inés",
				"j": "José",
				"k": "Kilo",
				"l": "Lorenzo",
				"m": "Madrid",
				"n": "Navarra",
				"ñ": "Ñoño",
				"o": "Oviedo",
				"p": "París",
				"q": "Queso",
				"r": "Ramón",
				"s": "Sevilla",
				"t": "Toledo",
				"u": "Úrsula",
				"v": "Valencia",
				"w": "Washington",
				"x": "Xilófono",
				"y": "Yolanda",
				"z": "Zaragoza"
			]
		case .french:
			[
				"a": "Anatole",
				"b": "Berthe",
				"c": "Célestin",
				"d": "Désiré",
				"e": "Eugène",
				"f": "François",
				"g": "Gaston",
				"h": "Henri",
				"i": "Irma",
				"j": "Joseph",
				"k": "Kléber",
				"l": "Louis",
				"m": "Marcel",
				"n": "Nicolas",
				"o": "Oscar",
				"p": "Pierre",
				"q": "Quintal",
				"r": "Raoul",
				"s": "Suzanne",
				"t": "Thérèse",
				"u": "Ursule",
				"v": "Victor",
				"x": "Xavier",
				"y": "Yvonne",
				"z": "Zoé"
			]
		case .german:
			[
				"a": "Anton",
				"b": "Berta",
				"c": "Cäsar",
				"d": "Dora",
				"e": "Emil",
				"f": "Friedrich",
				"g": "Gustav",
				"h": "Heinrich",
				"i": "Ida",
				"j": "Julius",
				"k": "Kaufmann",
				"l": "Ludwig",
				"m": "Martha",
				"n": "Nordpol",
				"o": "Otto",
				"p": "Paula",
				"q": "Quelle",
				"r": "Richard",
				"s": "Samuel",
				"ß": "Eszett",
				"t": "Theodor",
				"u": "Ulrich",
				"v": "Viktor",
				"w": "Wilhelm",
				"x": "Xanthippe",
				"y": "Ypsilon",
				"z": "Zacharias"
			]
		case .dutch:
			[
				"a": "Anton",
				"b": "Bernard",
				"c": "Cornelis",
				"d": "Dirk",
				"e": "Eduard",
				"f": "Ferdinand",
				"g": "Gerard",
				"h": "Hendrik",
				"i": "Izaak",
				"j": "Jan",
				"k": "Karel",
				"l": "Lodewijk",
				"m": "Maria",
				"n": "Nico",
				"o": "Otto",
				"p": "Pieter",
				"q": "Quirinus",
				"r": "Rudolf",
				"s": "Simon",
				"t": "Theodoor",
				"u": "Utrecht",
				"v": "Victor",
				"w": "Willem",
				"x": "Xantippe",
				"y": "Ypsilon",
				"z": "Zaandam"
			]
		case .italian:
			[
				"a": "Ancona",
				"b": "Bologna",
				"c": "Como",
				"d": "Domodossola",
				"e": "Empoli",
				"f": "Firenze",
				"g": "Genova",
				"h": "Hotel",
				"i": "Imola",
				"j": "Jolly",
				"k": "Kappa",
				"l": "Livorno",
				"m": "Milano",
				"n": "Napoli",
				"o": "Otranto",
				"p": "Palermo",
				"q": "Quarto",
				"r": "Roma",
				"s": "Savona",
				"t": "Torino",
				"u": "Udine",
				"v": "Venezia",
				"w": "Washington",
				"x": "Xilofono",
				"y": "Yacht",
				"z": "Zara"
			]
		case .brazilianPortuguese:
			[
				"a": "Amor",
				"b": "Bola",
				"c": "Casa",
				"ç": "Cedilha",
				"d": "Dado",
				"e": "Escola",
				"f": "Faca",
				"g": "Gato",
				"h": "Hotel",
				"i": "Ilha",
				"j": "Janela",
				"k": "Kilo",
				"l": "Lua",
				"m": "Mesa",
				"n": "Navio",
				"o": "Olho",
				"p": "Pato",
				"q": "Queijo",
				"r": "Rua",
				"s": "Sapo",
				"t": "Tatu",
				"u": "Uva",
				"v": "Vaca",
				"w": "Washington",
				"x": "Xadrez",
				"y": "Yoga",
				"z": "Zebra"
			]
		}
	}
}

final class DictionaryService {
	static let shared = DictionaryService()
	private var cachedWords: [DictionaryLanguage: Set<String>] = [:]
	private var cachedDailyCandidates: [DictionaryLanguage: [String]] = [:]
	private var cachedDailyWords: [String: String] = [:]
	private let queue = DispatchQueue(label: "com.marconius.WordBop.DictionaryService", qos: .userInitiated)

	private init() {}

	func contains(_ word: String, language: DictionaryLanguage) -> Bool {
		let normalizedWord = normalized(word, for: language)
		return queue.sync {
			wordsOnQueue(for: language).contains(normalizedWord)
		}
	}

	func preload(_ language: DictionaryLanguage) {
		queue.async {
			_ = self.wordsOnQueue(for: language)
		}
	}

	func preloadDailyBopCandidates(for language: DictionaryLanguage) {
		queue.async {
			_ = self.dailyCandidatesOnQueue(for: language)
		}
	}

	func ensureLoaded(_ language: DictionaryLanguage) {
		queue.sync {
			_ = wordsOnQueue(for: language)
		}
	}

	func dailyWord(for language: DictionaryLanguage, date: Date = Date(), calendar: Calendar = .current) -> String {
		let dateKey = dailyDateKey(for: date, calendar: calendar)
		return queue.sync {
			dailyWordOnQueue(for: language, dateKey: dateKey)
		}
	}

	private func dailyWordOnQueue(for language: DictionaryLanguage, dateKey: String) -> String {
		let cacheKey = "\(language.rawValue)-\(dateKey)"
		if let word = cachedDailyWords[cacheKey] { return word }
		let candidates = dailyCandidatesOnQueue(for: language)
		let word = candidates.reduce(into: (word: "", score: Int.max)) { best, word in
			let score = stableSeed("\(language.rawValue)-\(dateKey)-\(word)")
			if score < best.score {
				best = (word, score)
			}
		}
		.word
		cachedDailyWords[cacheKey] = word
		return word
	}

	private func dailyCandidatesOnQueue(for language: DictionaryLanguage) -> [String] {
		if let candidates = cachedDailyCandidates[language] { return candidates }
		if let url = Bundle.main.url(forResource: language.dailyResourceName, withExtension: "txt"),
		   let content = try? String(contentsOf: url, encoding: .utf8) {
			let candidates = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
			cachedDailyCandidates[language] = candidates
			return candidates
		}

		let candidates = dailyCandidatesFromFullDictionaryOnQueue(for: language)
		cachedDailyCandidates[language] = candidates
		return candidates
	}

	private func dailyCandidatesFromFullDictionaryOnQueue(for language: DictionaryLanguage) -> [String] {
		guard let url = Bundle.main.url(forResource: language.resourceName, withExtension: "txt"),
			  let content = try? String(contentsOf: url, encoding: .utf8) else { return [] }
		let candidates = Array(Set(content.components(separatedBy: .newlines)
			.map { normalized($0, for: language) }
			.filter { isDailyCandidate($0) }))
		return candidates
	}

	private func isDailyCandidate(_ word: String) -> Bool {
		guard (6...10).contains(word.count) else { return false }
		return word.allSatisfy { $0.isLetter }
	}

	private func wordsOnQueue(for language: DictionaryLanguage) -> Set<String> {
		if let words = cachedWords[language] { return words }
		guard let url = Bundle.main.url(forResource: language.resourceName, withExtension: "txt"),
			  let content = try? String(contentsOf: url, encoding: .utf8) else {
			cachedWords[language] = []
			return []
		}
		let words = Set(content.components(separatedBy: .newlines).map { normalized($0, for: language) }.filter { !$0.isEmpty })
		cachedWords[language] = words
		return words
	}

	func normalized(_ word: String, for language: DictionaryLanguage) -> String {
		let protectedCharacters: [Character: String]
		switch language {
		case .english, .dutch, .italian:
			protectedCharacters = [:]
		case .spanish:
			protectedCharacters = ["ñ": "__WB_NTILDE__"]
		case .french, .brazilianPortuguese:
			protectedCharacters = ["ç": "__WB_CCEDILLA__"]
		case .german:
			protectedCharacters = ["ß": "__WB_ESZETT__"]
		}

		var normalizedWord = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
		for (character, token) in protectedCharacters {
			normalizedWord = normalizedWord.replacingOccurrences(of: String(character), with: token)
		}
		normalizedWord = normalizedWord.folding(options: [.diacriticInsensitive], locale: language.locale)
		normalizedWord = normalizedWord.replacingOccurrences(of: "æ", with: "ae")
		normalizedWord = normalizedWord.replacingOccurrences(of: "œ", with: "oe")
		for (character, token) in protectedCharacters {
			normalizedWord = normalizedWord.replacingOccurrences(of: token.lowercased(), with: String(character))
			normalizedWord = normalizedWord.replacingOccurrences(of: token, with: String(character))
		}
		return normalizedWord
	}

	private func dailyDateKey(for date: Date, calendar: Calendar) -> String {
		let components = calendar.dateComponents([.year, .month, .day], from: date)
		let year = components.year ?? 0
		let month = components.month ?? 0
		let day = components.day ?? 0
		return String(format: "%04d%02d%02d", year, month, day)
	}

	private func stableSeed(_ string: String) -> Int {
		var hash: UInt64 = 14_695_981_039_346_656_037
		for byte in string.utf8 {
			hash ^= UInt64(byte)
			hash &*= 1_099_511_628_211
		}
		return Int(hash % UInt64(Int.max))
	}
}
