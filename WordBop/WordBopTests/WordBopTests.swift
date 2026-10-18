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
	#if DEBUG
	@MainActor
	@Test func debugDailyBopFollowsConnectedRowsAndPreservesOtherBubbles() {
		var bubbles = (0..<16).map { Bubble(letter: "z", colorIndex: $0 % 3, row: $0 / 4, col: $0 % 4) }
		let original = bubbles
		GameViewModel.seedDailyBopForTesting("abcdefghij", in: &bubbles, gridSize: 4)
		let path = [0, 1, 2, 3, 7, 6, 5, 4, 8, 9]
		#expect(path.map { bubbles[$0].letter }.joined() == "abcdefghij")
		for index in bubbles.indices {
			#expect(bubbles[index].id == original[index].id)
			#expect(bubbles[index].colorIndex == original[index].colorIndex)
			if !path.contains(index) { #expect(bubbles[index].letter == "z") }
		}
	}

	@MainActor
	@Test func debugDailyBopDoesNotPartiallySeedAnOversizedWord() {
		var bubbles = (0..<9).map { Bubble(letter: "z", colorIndex: 0, row: $0 / 3, col: $0 % 3) }
		GameViewModel.seedDailyBopForTesting("abcdefghij", in: &bubbles, gridSize: 3)
		#expect(bubbles.allSatisfy { $0.letter == "z" })
	}
	#endif

	@Test func dailyWordsFollowLocalMidnight() throws {
		let dictionary = DictionaryService.shared
		var local = Calendar(identifier: .gregorian)
		local.timeZone = try #require(TimeZone(identifier: "America/Los_Angeles"))
		var utc = Calendar(identifier: .gregorian)
		utc.timeZone = try #require(TimeZone(secondsFromGMT: 0))
		let midnight = try date(from: "20261101", calendar: local)
		let october = try date(from: "20261031", calendar: utc)
		let november = try date(from: "20261101", calendar: utc)
		for language in DictionaryLanguage.allCases {
			#expect(dictionary.dailyWord(for: language, date: midnight.addingTimeInterval(-1), calendar: local)
				== dictionary.dailyWord(for: language, date: october, calendar: utc))
			#expect(dictionary.dailyWord(for: language, date: midnight, calendar: local)
				== dictionary.dailyWord(for: language, date: november, calendar: utc))
		}
	}

	@MainActor
	@Test func questUsesInclusiveLocalDatesAcrossDaylightSaving() throws {
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = try #require(TimeZone(identifier: "America/Los_Angeles"))
		let start = try date(from: "20261101", calendar: calendar)
		let end = try date(from: "20261130", calendar: calendar)
		let quest = BopHuntEvent(id: "harvest", title: "Harvest", starts: start, ends: end,
			completionBonus: 0, wordsByLanguage: [.english: ["leaf", "harvest"]])
		#expect(!quest.isActive(on: start.addingTimeInterval(-1), calendar: calendar))
		#expect(quest.isActive(on: start, calendar: calendar))
		let december = try date(from: "20261201", calendar: calendar)
		#expect(quest.isActive(on: december.addingTimeInterval(-1), calendar: calendar))
		#expect(!quest.isActive(on: december, calendar: calendar))
	}

	@MainActor
	@Test func questRewardsSurviveSavingWithoutAwardingDuplicates() throws {
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
		let start = try date(from: "20261101", calendar: calendar)
		let end = try date(from: "20261130", calendar: calendar)
		let quest = BopHuntEvent(id: "harvest", title: "Harvest", starts: start, ends: end,
			completionBonus: 99, wordsByLanguage: [.english: ["leaf", "harvest"]])
		var progress = BopHuntProgress(huntID: quest.id)
		#expect(progress.record("leaf", in: quest, language: .english, date: start, calendar: calendar) == 1)
		#expect(progress.record("leaf", in: quest, language: .english, date: start, calendar: calendar) == 0)
		let saved = try JSONEncoder().encode(progress)
		progress = try JSONDecoder().decode(BopHuntProgress.self, from: saved)
		#expect(progress.record("harvest", in: quest, language: .english, date: end, calendar: calendar) == 3)
		let completed = try JSONEncoder().encode(progress)
		progress = try JSONDecoder().decode(BopHuntProgress.self, from: completed)
		#expect(progress.record("harvest", in: quest, language: .english, date: end, calendar: calendar) == 0)
		#expect(progress.awardedCompletionBonusLanguages == [.english])
	}

	@MainActor
	@Test func expiredQuestCannotAwardWords() throws {
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
		let start = try date(from: "20261101", calendar: calendar)
		let end = try date(from: "20261130", calendar: calendar)
		let quest = BopHuntEvent(id: "harvest", title: "Harvest", starts: start, ends: end,
			completionBonus: 0, wordsByLanguage: [.english: ["leaf"]])
		var progress = BopHuntProgress(huntID: quest.id)
		let expired = try date(from: "20261201", calendar: calendar)
		#expect(progress.record("leaf", in: quest, language: .english, date: expired, calendar: calendar) == 0)
		#expect(progress.foundWordsByLanguage.isEmpty)
		#expect(progress.awardedCompletionBonusLanguages.isEmpty)
	}

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
