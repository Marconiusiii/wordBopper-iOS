import Foundation

enum DictionaryLanguage: String, CaseIterable, Identifiable {
	case english
	case spanish
	case french
	case german
	case italian

	var id: String { rawValue }

	var label: String {
		switch self {
		case .english:
			"English"
		case .spanish:
			"Spanish"
		case .french:
			"French"
		case .german:
			"German"
		case .italian:
			"Italian"
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
		case .italian:
			Locale(identifier: "it")
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
		case .italian:
			"it"
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
		case .italian:
			"words-it"
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
		case .french:
			Array(
				"aaaaaaaaabbccçddddeeeeeeeeeeeeéèêffgghhiiiiiiîjkl" +
				"llllmmnnnnnooooooôppqrrrrrrssssssttttttuuuuùûvxyyz"
			).map { String($0) }
		case .german:
			Array(
				"aaaaaaaääbbcccddddeeeeeeeeeeffffgggghhhhiiiiijkllll" +
				"mmmnnnnnnoooooööppqrrrrrrssssssßttttttuuuuüüvwxyz"
			).map { String($0) }
		case .italian:
			Array(
				"aaaaaaaaaaaàbbcccddddeeeeeeeeèéffgghhiiiiiiiìlll" +
				"mmmnnnnnnooooooooòppqrrrrrrssssssttttttuuuuùvvz"
			).map { String($0) }
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
