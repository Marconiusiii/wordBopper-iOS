//
//  WordBopTests.swift
//  WordBopTests
//
//  Created by Marco Salsiccia on 5/3/26.
//

import Foundation
import Testing
@testable import WordBop

struct WordBopTests {

	@Test func dailyCandidateResourcesMatchFullDictionaries() throws {
		let dictionary = DictionaryService.shared

		for language in DictionaryLanguage.allCases {
			let dailyURL = try #require(Bundle.main.url(
				forResource: language.dailyResourceName,
				withExtension: "txt"
			))
			let dictionaryURL = try #require(Bundle.main.url(
				forResource: language.resourceName,
				withExtension: "txt"
			))
			let dailyContent = try String(contentsOf: dailyURL, encoding: .utf8)
			let dictionaryContent = try String(contentsOf: dictionaryURL, encoding: .utf8)
			let candidates = dailyContent.components(separatedBy: .newlines).filter { !$0.isEmpty }
			let expectedCandidates = Set(dictionaryContent.components(separatedBy: .newlines)
				.map { dictionary.normalized($0, for: language) }
				.filter { (6...10).contains($0.count) && $0.allSatisfy(\.isLetter) })

			#expect(!candidates.isEmpty)
			#expect(candidates == candidates.sorted())
			#expect(candidates.count == Set(candidates).count)
			#expect(candidates.allSatisfy { (6...10).contains($0.count) && $0.allSatisfy(\.isLetter) })
			#expect(Set(candidates) == expectedCandidates)
		}
	}

	@Test func dailyWordsRemainDeterministicAndValid() throws {
		let dictionary = DictionaryService.shared
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))

		for (dateKey, expectedWords) in expectedDailyWords {
			let date = try date(from: dateKey, calendar: calendar)
			for language in DictionaryLanguage.allCases {
				let first = dictionary.dailyWord(for: language, date: date, calendar: calendar)
				let second = dictionary.dailyWord(for: language, date: date, calendar: calendar)

				#expect(first == second)
				#expect(first == expectedWords[language])
				#expect(dictionary.contains(first, language: language))
			}
		}
	}

	private func date(from key: String, calendar: Calendar) throws -> Date {
		let year = try #require(Int(key.prefix(4)))
		let month = try #require(Int(key.dropFirst(4).prefix(2)))
		let day = try #require(Int(key.suffix(2)))
		return try #require(calendar.date(from: DateComponents(year: year, month: month, day: day)))
	}

	private var expectedDailyWords: [String: [DictionaryLanguage: String]] {
		[
			"20260101": [
				.english: "magistral", .spanish: "carreto", .french: "simienne",
				.german: "erwarmt", .dutch: "dauwworm", .italian: "belliniane",
				.brazilianPortuguese: "pezenho"
			],
			"20260214": [
				.english: "noshing", .spanish: "giramos", .french: "pateux",
				.german: "abgottin", .dutch: "blijvende", .italian: "scafante",
				.brazilianPortuguese: "doutrora"
			],
			"20260802": [
				.english: "coenures", .spanish: "tapareis", .french: "malvenus",
				.german: "zierform", .dutch: "hikken", .italian: "autofaga",
				.brazilianPortuguese: "granitagem"
			],
			"20261031": [
				.english: "ventricose", .spanish: "enojaras", .french: "bilassiez",
				.german: "oligopolen", .dutch: "zeekapel", .italian: "omegna",
				.brazilianPortuguese: "encanitar"
			],
			"20261231": [
				.english: "angrier", .spanish: "semihombre", .french: "cheddites",
				.german: "goldrubine", .dutch: "schifpot", .italian: "scianchi",
				.brazilianPortuguese: "apocrifia"
			]
		]
	}

}
