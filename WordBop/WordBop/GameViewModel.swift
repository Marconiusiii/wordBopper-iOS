import Foundation
import SwiftUI
import UIKit

struct Bubble: Identifiable {
	var id = UUID()
	var letter: String
	var colorIndex: Int
	let row: Int
	let col: Int
}

struct SelectedLetter {
	let bubbleId: UUID
	let letter: String
	let row: Int
	let col: Int
}

enum BubbleTextColorOption: String, CaseIterable, Identifiable {
	case dark
	case light

	var id: String { rawValue }

	var label: String {
		switch self {
		case .dark:
			String(localized: "Dark Text")
		case .light:
			String(localized: "Light Text")
		}
	}
}

enum BubbleColorTheme: String, CaseIterable, Identifiable {
	case classicBright
	case pastel
	case spring
	case summer
	case candy
	case garden
	case sunrise
	case sky
	case softWhite
	case classicDeep
	case neon
	case fall
	case winter
	case forest
	case ocean
	case sunset
	case galaxy
	case softCharcoal

	var id: String { rawValue }

	var label: String {
		switch self {
		case .classicBright:
			String(localized: "Classic Bright")
		case .pastel:
			String(localized: "Pastel")
		case .spring:
			String(localized: "Spring")
		case .summer:
			String(localized: "Summer")
		case .candy:
			String(localized: "Candy")
		case .garden:
			String(localized: "Garden")
		case .sunrise:
			String(localized: "Sunrise")
		case .sky:
			String(localized: "Sky")
		case .softWhite:
			String(localized: "Soft White")
		case .classicDeep:
			String(localized: "Classic Deep")
		case .neon:
			String(localized: "Neon")
		case .fall:
			String(localized: "Fall")
		case .winter:
			String(localized: "Winter")
		case .forest:
			String(localized: "Forest")
		case .ocean:
			String(localized: "Ocean")
		case .sunset:
			String(localized: "Sunset")
		case .galaxy:
			String(localized: "Galaxy")
		case .softCharcoal:
			String(localized: "Soft Charcoal")
		}
	}

	static func options(for textColorOption: BubbleTextColorOption) -> [BubbleColorTheme] {
		switch textColorOption {
		case .dark:
			[.classicBright, .pastel, .spring, .summer, .candy, .garden, .sunrise, .sky, .softWhite]
		case .light:
			[.classicDeep, .neon, .fall, .winter, .forest, .ocean, .sunset, .galaxy, .softCharcoal]
		}
	}

	static func defaultTheme(for textColorOption: BubbleTextColorOption) -> BubbleColorTheme {
		switch textColorOption {
		case .dark:
			.classicBright
		case .light:
			.classicDeep
		}
	}

	func supports(_ textColorOption: BubbleTextColorOption) -> Bool {
		Self.options(for: textColorOption).contains(self)
	}
}

enum BubbleLetterStyle: String, CaseIterable, Identifiable {
	case playful
	case simple
	case typewriter

	var id: String { rawValue }

	var label: String {
		switch self {
		case .playful:
			String(localized: "Playful")
		case .simple:
			String(localized: "Simple")
		case .typewriter:
			String(localized: "Typewriter")
		}
	}

	var fontDesign: Font.Design {
		switch self {
		case .playful:
			.rounded
		case .simple:
			.default
		case .typewriter:
			.monospaced
		}
	}
}

enum GameAnnouncementVerbosity: String, CaseIterable, Identifiable {
	case normal
	case low
	case off

	var id: String { rawValue }

	var label: String {
		switch self {
		case .normal:
			String(localized: "Normal")
		case .low:
			String(localized: "Low")
		case .off:
			String(localized: "Off", comment: "Announcement verbosity option: announcements turned off")
		}
	}
}

enum GameMode: String, CaseIterable, Identifiable, Codable {
	case timed
	case bopple
	case nonStop

	var id: String { rawValue }

	var label: String {
		switch self {
		case .timed:
			String(localized: "Timed")
		case .bopple:
			String(localized: "Bopple", comment: "Game mode name, brand term kept untranslated")
		case .nonStop:
			String(localized: "Non-Stop")
		}
	}

	var settingsBlurb: String {
		switch self {
		case .timed:
			String(localized: "Make as many words as you can in 2 minutes! Letters change as you use them.")
		case .bopple:
			String(localized: "Bopped letters will not change when you make words. Words must be made up of letters that are next to each other in the grid. How many words can you create in 3 minutes?")
		case .nonStop:
			String(localized: "Bop to the Top! Non-Stop mode takes away the game timer, so bop as many letters and make as many words as you want!")
		}
	}
}

enum BoppleTimerOption: String, CaseIterable, Identifiable {
	case threeMinutes
	case fourMinutes
	case fiveMinutes
	case sixMinutes
	case nonStop

	var id: String { rawValue }

	var label: String {
		switch self {
		case .threeMinutes:
			String(localized: "3 Minutes")
		case .fourMinutes:
			String(localized: "4 Minutes")
		case .fiveMinutes:
			String(localized: "5 Minutes")
		case .sixMinutes:
			String(localized: "6 Minutes")
		case .nonStop:
			String(localized: "Non-Stop Boppling!", comment: "Bopple timer option; Boppling is a brand term")
		}
	}

	var duration: Int? {
		switch self {
		case .threeMinutes:
			180
		case .fourMinutes:
			240
		case .fiveMinutes:
			300
		case .sixMinutes:
			360
		case .nonStop:
			nil
		}
	}
}

enum GridSizeOption: Int, CaseIterable, Identifiable {
	case three = 3
	case four = 4
	case five = 5
	case six = 6

	var id: Int { rawValue }
	var dimension: Int { rawValue }

	var label: String {
		String(localized: "\(rawValue) by \(rawValue)", comment: "Grid size label, e.g. 5 by 5")
	}
}

enum LetterPositionMode: String, CaseIterable, Identifiable {
	case off
	case columnNumberRowNumber
	case columnLetterRowNumber
	case columnNumberRowLetter

	var id: String { rawValue }

	var label: String {
		switch self {
		case .off:
			String(localized: "Off", comment: "Letter position mode: positions not spoken")
		case .columnNumberRowNumber:
			String(localized: "Column Number, Row Number")
		case .columnLetterRowNumber:
			String(localized: "Column Letter, Row Number")
		case .columnNumberRowLetter:
			String(localized: "Column Number, Row Letter")
		}
	}

	var settingsBlurb: String {
		switch self {
		case .off:
			String(localized: "Column and Row positions will not be spoken.")
		case .columnNumberRowNumber:
			String(localized: "Speaks the column number followed by the row number after the letter, like \"W, 2 3\" or \"A, 1 5.\"")
		case .columnLetterRowNumber:
			String(localized: "Speaks columns as A through E and rows as 1 through 5, like \"G, B3\" for column B, row 3.")
		case .columnNumberRowLetter:
			String(localized: "Speaks columns as 1 through 5 and rows as A through E, like \"W, 3A\" for column 3, row A.")
		}
	}
}

struct LanguageModeBestGame: Codable, Identifiable {
	var language: DictionaryLanguage
	var mode: GameMode
	var highestScore: Int = 0
	var longestWord: String = ""
	var mostWords: Int = 0
	var largestLetterChain: Int = 0

	var id: String {
		"\(language.rawValue)-\(mode.rawValue)"
	}

	var heading: String {
		String(localized: "\(language.label) \(mode.label) Mode", comment: "Best-game section heading: <language> <mode> Mode")
	}
}

struct DailyBopLanguageStat: Codable, Identifiable {
	var language: DictionaryLanguage
	var foundCount: Int = 0
	var lastFoundDateKey: String = ""

	var id: String { language.rawValue }
}

struct DailyBopEntry: Identifiable {
	let language: DictionaryLanguage
	let word: String

	var id: String { language.rawValue }
}

struct BestGame: Codable {
	var highestScore: Int = 0
	var highestBoppleScore: Int = 0
	var highestNonStopScore: Int = 0
	var longestWord: String = ""
	var longestBoppleWord: String = ""
	var longestNonStopWord: String = ""
	var mostWords: Int = 0
	var mostBoppleWords: Int = 0
	var mostNonStopWords: Int = 0
	var largestLetterChain: Int = 0
	var largestBoppleLetterChain: Int = 0
	var largestNonStopLetterChain: Int = 0
	var languageModeBestGames: [LanguageModeBestGame] = []
	var dailyBopLanguageStats: [DailyBopLanguageStat] = []

	init() {}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		highestScore = try container.decodeIfPresent(Int.self, forKey: .highestScore) ?? 0
		highestBoppleScore = try container.decodeIfPresent(Int.self, forKey: .highestBoppleScore) ?? 0
		highestNonStopScore = try container.decodeIfPresent(Int.self, forKey: .highestNonStopScore) ?? 0
		longestWord = try container.decodeIfPresent(String.self, forKey: .longestWord) ?? ""
		longestBoppleWord = try container.decodeIfPresent(String.self, forKey: .longestBoppleWord) ?? ""
		longestNonStopWord = try container.decodeIfPresent(String.self, forKey: .longestNonStopWord) ?? ""
		mostWords = try container.decodeIfPresent(Int.self, forKey: .mostWords) ?? 0
		mostBoppleWords = try container.decodeIfPresent(Int.self, forKey: .mostBoppleWords) ?? 0
		mostNonStopWords = try container.decodeIfPresent(Int.self, forKey: .mostNonStopWords) ?? 0
		largestLetterChain = try container.decodeIfPresent(Int.self, forKey: .largestLetterChain) ?? 0
		largestBoppleLetterChain = try container.decodeIfPresent(Int.self, forKey: .largestBoppleLetterChain) ?? 0
		largestNonStopLetterChain = try container.decodeIfPresent(Int.self, forKey: .largestNonStopLetterChain) ?? 0
		languageModeBestGames = try container.decodeIfPresent([LanguageModeBestGame].self, forKey: .languageModeBestGames) ?? []
		dailyBopLanguageStats = try container.decodeIfPresent([DailyBopLanguageStat].self, forKey: .dailyBopLanguageStats) ?? []
	}
}

enum GameScreen { case start, game, results }

@Observable
final class GameViewModel {

	// MARK: - Config
	static let timedGameDuration = 120
	static let boppleGameDuration = 180
	static let colorCount = 8
	static let gameplayHeadingPhrases = [
		String(localized: "Start bopping!"),
		String(localized: "Bop to it!"),
		String(localized: "Bop out some words!"),
		String(localized: "Bop those letters!"),
		String(localized: "Bop to the future!"),
		String(localized: "Start your bopping!"),
		String(localized: "Bop til you Drop!"),
		String(localized: "Bop All The Things!"),
		String(localized: "Bop to the Top!"),
		String(localized: "Commence bopping!")
	]
	static let boppleGameplayHeadingPhrases = [
		String(localized: "The Boppler Effect"),
		String(localized: "Bopple Away!"),
		String(localized: "All the Bopples"),
		String(localized: "Boplift Your Vocabulary!"),
		String(localized: "The Bopple Exquisite"),
		String(localized: "The Bopple Bops Back")
	]
	static let dailyBopGameplayHeadingPhrases = [
		String(localized: "Bop of the Day"),
		String(localized: "Today’s Word Wants You"),
		String(localized: "Daily Bop, Daily Glory"),
		String(localized: "The Word Is Out There"),
		String(localized: "Hunt the Daily Bop"),
		String(localized: "Bop It Before Midnight"),
		String(localized: "Today’s Bop Begins"),
		String(localized: "Chase the Daily Bop"),
		String(localized: "Bop the Day Away"),
		String(localized: "The Daily Word Beckons"),
		String(localized: "Find It, Bop It"),
		String(localized: "Your Daily Bop Awaits"),
		String(localized: "Bop on the Daily"),
		String(localized: "A Good Day to Bop"),
		String(localized: "Get the Big Bopper"),
		String(localized: "Boppin’ 24/7")
	]

	// MARK: - Navigation
	var screen: GameScreen = .start

	// MARK: - Game state
	var gameMode: GameMode = .timed {
		didSet { saveGameMode() }
	}
	var boppleTimerOption: BoppleTimerOption = .threeMinutes {
		didSet { saveBoppleTimerOption() }
	}
	var gridSizeOption: GridSizeOption = .five {
		didSet { saveGridSizeOption() }
	}
	var letterPositionMode: LetterPositionMode = .off {
		didSet { saveLetterPositionMode() }
	}
	var speakLetterPhonetics = false {
		didSet { saveSpeakLetterPhonetics() }
	}
	var bopAway = false {
		didSet { saveBopAway() }
	}
	var bubbleTextColorOption: BubbleTextColorOption = .dark {
		didSet {
			if !bubbleColorTheme.supports(bubbleTextColorOption) {
				bubbleColorTheme = BubbleColorTheme.defaultTheme(for: bubbleTextColorOption)
			}
			saveBubbleTextColorOption()
		}
	}
	var bubbleColorTheme: BubbleColorTheme = .classicBright {
		didSet { saveBubbleColorTheme() }
	}
	var bubbleLetterStyle: BubbleLetterStyle = .playful {
		didSet { saveBubbleLetterStyle() }
	}
	var gameAnnouncementVerbosity: GameAnnouncementVerbosity = .normal {
		didSet { saveGameAnnouncementVerbosity() }
	}
	var gameHapticsEnabled = true {
		didSet {
			haptics.isEnabled = gameHapticsEnabled
			saveGameHapticsEnabled()
		}
	}
	var gameVolume: Double = 0.82 {
		didSet {
			let clampedVolume = min(max(gameVolume, 0), 1)
			if clampedVolume != gameVolume {
				gameVolume = clampedVolume
				return
			}
			audio.volume = Float(clampedVolume)
			saveGameVolume()
		}
	}
	var leftHandedMode = false {
		didSet { saveLeftHandedMode() }
	}
	var dictionaryLanguage: DictionaryLanguage = .english {
		didSet {
			saveDictionaryLanguage()
			dictionary.preload(dictionaryLanguage)
			ensureDailyBopLanguageEnabled(dictionaryLanguage)
		}
	}
	var bubbles: [Bubble] = []
	var selected: [SelectedLetter] = []
	var score = 0
	var wordCount = 0
	var totalLettersUsed = 0
	var madeWords: [String] = []
	var secondsLeft = GameViewModel.timedGameDuration
	var gameActive = false
	var gamePaused = false
	var connectedWordStreak = 0
	var chainPowerUpActive = false
	var chainPowerUpSecondsLeft = 0
	var dailyBopTargetWord: String?
	var dailyBopTargetLanguage: DictionaryLanguage?
	var dailyBopFoundThisRound = false
	var dailyBopBoostActive = false
	var dailyBopBoostSecondsLeft = 0
	var largestLetterChain = 0
	var gameplayHeading = GameViewModel.gameplayHeadingPhrases[0]
	var dailyBopEntries: [DailyBopEntry] = []
	var dailyBopEntriesReady = false
	var dailyBopEntriesLoading = false
	var dailyBopEnabledLanguages: [DictionaryLanguage] = []
	private var consumedBopAwayBubbleIds = Set<UUID>()

	// MARK: - Best game
	var bestGame = BestGame()

	// MARK: - Services
	let audio = AudioEngine()
	private let haptics = HapticsEngine()
	private let dictionary = DictionaryService.shared
	private var gameTimer: Timer?
	private var powerUpTimer: Timer?
	private var powerUpAudioResumeWorkItem: DispatchWorkItem?
	private var dailyBopBoostTimer: Timer?
	private var announcementWorkItem: DispatchWorkItem?
	private var dailyBopEntriesGeneration = UUID()

	// MARK: - Computed
	var currentWord: String { selected.map(\.letter).joined() }

	var gameplayLocale: Locale {
		dictionaryLanguage.locale
	}

	var wordTrayLabel: String {
		if selected.isEmpty { return String(localized: "Word tray, empty") }
		let letters = selected.map { $0.letter.lowercased() }.joined(separator: ", ")
		return String(localized: "Word tray: \(letters)", comment: "VoiceOver label for the word tray, followed by the selected letters")
	}

	var chainMeterValue: String {
		if dailyBopBoostActive {
			return String(localized: "Daily Bop 3 times boost active, \(dailyBopBoostSecondsLeft) seconds left")
		}
		if chainPowerUpActive {
			return String(localized: "3 times chain bop active, \(chainPowerUpSecondsLeft) seconds left")
		}
		return String(localized: "\(connectedWordStreak) of 3 chains", comment: "Chain meter VoiceOver value: <n> of 3 chains")
	}

	var chainMeterProgress: Double {
		if dailyBopBoostActive {
			return (Double(dailyBopBoostSecondsLeft) / 45.0) * 3.0
		}
		if chainPowerUpActive {
			return (Double(chainPowerUpSecondsLeft) / 15.0) * 3.0
		}
		return Double(connectedWordStreak)
	}

	var formattedTime: String {
		let m = secondsLeft / 60
		let s = secondsLeft % 60
		return String(format: "%d:%02d", m, s)
	}

	var timerIsWarning: Bool { secondsLeft <= 20 }

	var makeWordEnabled: Bool { selected.count >= 3 }

	var gridSize: Int { gridSizeOption.dimension }

	var totalDailyBopsFound: Int {
		bestGame.dailyBopLanguageStats.reduce(0) { $0 + $1.foundCount }
	}

	var currentDailyBopRank: String {
		dailyBopRank(for: totalDailyBopsFound)
	}

	var dailyBopLanguageStats: [DailyBopLanguageStat] {
		bestGame.dailyBopLanguageStats
			.filter { $0.foundCount > 0 }
			.sorted { $0.language.label < $1.language.label }
	}

	func dailyBopWasFoundToday(language: DictionaryLanguage) -> Bool {
		bestGame.dailyBopLanguageStats.contains {
			$0.language == language && $0.lastFoundDateKey == dailyBopDateKey()
		}
	}

	private func normalizedDailyBopLanguages() -> [DictionaryLanguage] {
		let saved = dailyBopEnabledLanguages.filter { DictionaryLanguage.allCases.contains($0) }
		let languages = saved.isEmpty ? [dictionaryLanguage] : saved
		return sortedDailyBopLanguages(languages)
	}

	private func sortedDailyBopLanguages(_ languages: [DictionaryLanguage]) -> [DictionaryLanguage] {
		DictionaryLanguage.allCases.filter { languages.contains($0) }
	}

	private func preloadDailyBopCandidates(for languages: [DictionaryLanguage]? = nil) {
		for language in languages ?? normalizedDailyBopLanguages() {
			dictionary.preloadDailyBopCandidates(for: language)
		}
	}

	private func ensureDailyBopLanguageEnabled(_ language: DictionaryLanguage) {
		var languages = normalizedDailyBopLanguages()
		guard !languages.contains(language) else { return }
		languages.append(language)
		dailyBopEnabledLanguages = sortedDailyBopLanguages(languages)
		saveDailyBopEnabledLanguages()
		reloadDailyBopEntries()
	}

	private func reloadDailyBopEntries() {
		dailyBopEntriesGeneration = UUID()
		dailyBopEntriesReady = false
		dailyBopEntriesLoading = false
		dailyBopEntries = []
		prepareDailyBopEntries()
	}

	var showsTimer: Bool {
		switch gameMode {
		case .timed:
			true
		case .bopple:
			boppleTimerOption.duration != nil
		case .nonStop:
			false
		}
	}

	var bopAwayIsActive: Bool {
		bopAway && gameMode != .bopple
	}

	var clearActionTitle: String {
		bopAwayIsActive ? String(localized: "Clear Word") : String(localized: "Clear Letters")
	}

	var clearActionAccessibilityLabel: String {
		bopAwayIsActive ? String(localized: "Clear word") : String(localized: "Clear selected letters")
	}

	func isSelected(_ bubble: Bubble) -> Bool {
		if bopAwayIsActive { return false }
		return selected.contains(where: { $0.bubbleId == bubble.id })
	}

	// MARK: - Init
	init() {
		bestGame = loadBestGame()
		gameMode = loadGameMode()
		boppleTimerOption = loadBoppleTimerOption()
		gridSizeOption = loadGridSizeOption()
		letterPositionMode = loadLetterPositionMode()
		speakLetterPhonetics = loadSpeakLetterPhonetics()
		bopAway = loadBopAway()
		bubbleTextColorOption = loadBubbleTextColorOption()
		bubbleColorTheme = loadBubbleColorTheme(for: bubbleTextColorOption)
		bubbleLetterStyle = loadBubbleLetterStyle()
		gameAnnouncementVerbosity = loadGameAnnouncementVerbosity()
		gameHapticsEnabled = loadGameHapticsEnabled()
		haptics.isEnabled = gameHapticsEnabled
		gameVolume = loadGameVolume()
		audio.volume = Float(gameVolume)
		leftHandedMode = loadLeftHandedMode()
		let savedDictionaryLanguage = loadDictionaryLanguage()
		dailyBopEnabledLanguages = loadDailyBopEnabledLanguages(fallback: savedDictionaryLanguage)
		dictionaryLanguage = savedDictionaryLanguage
		dictionary.preload(dictionaryLanguage)
		preloadDailyBopCandidates()
		prepareDailyBopEntries()
	}

	func prepareDailyBopEntries() {
		guard !dailyBopEntriesReady else { return }
		guard !dailyBopEntriesLoading else { return }
		let languages = normalizedDailyBopLanguages()
		preloadDailyBopCandidates(for: languages)
		let generation = UUID()
		dailyBopEntriesGeneration = generation
		dailyBopEntriesLoading = true
		DispatchQueue.global(qos: .utility).async { [dictionary] in
			let entries = languages.compactMap { language -> DailyBopEntry? in
				let word = dictionary.dailyWord(for: language)
				guard !word.isEmpty else { return nil }
				return DailyBopEntry(language: language, word: word)
			}
			DispatchQueue.main.async {
				guard self.dailyBopEntriesGeneration == generation else { return }
				self.dailyBopEntries = entries
				self.dailyBopEntriesLoading = false
				self.dailyBopEntriesReady = true
			}
		}
	}

	func isDailyBopLanguageEnabled(_ language: DictionaryLanguage) -> Bool {
		normalizedDailyBopLanguages().contains(language)
	}

	func setDailyBopLanguage(_ language: DictionaryLanguage, enabled: Bool) {
		var languages = normalizedDailyBopLanguages()
		if enabled {
			if !languages.contains(language) {
				languages.append(language)
			}
		} else {
			guard languages.count > 1 else { return }
			languages.removeAll { $0 == language }
		}
		dailyBopEnabledLanguages = sortedDailyBopLanguages(languages)
		saveDailyBopEnabledLanguages()
		preloadDailyBopCandidates(for: dailyBopEnabledLanguages)
		reloadDailyBopEntries()
	}

	// MARK: - Game lifecycle

	func startGame(dailyBopEntry: DailyBopEntry? = nil) {
		if let dailyBopEntry {
			dictionaryLanguage = dailyBopEntry.language
			gameMode = .timed
		}
		bubbles = []
		selected = []
		score = 0
		wordCount = 0
		totalLettersUsed = 0
		madeWords = []
		secondsLeft = gameDuration
		gameActive = true
		gamePaused = false
		consumedBopAwayBubbleIds.removeAll()
		connectedWordStreak = 0
		chainPowerUpActive = false
		chainPowerUpSecondsLeft = 0
		dailyBopTargetWord = dailyBopEntry?.word
		dailyBopTargetLanguage = dailyBopEntry?.language
		dailyBopFoundThisRound = false
		dailyBopBoostActive = false
		dailyBopBoostSecondsLeft = 0
		largestLetterChain = 0
		gameplayHeading = randomGameplayHeading()
		dictionary.ensureLoaded(dictionaryLanguage)
		haptics.roundStarted()

		for row in 0..<gridSize {
			for col in 0..<gridSize {
				bubbles.append(Bubble(letter: randomLetter(forRow: row, col: col), colorIndex: randomColor(), row: row, col: col))
			}
		}
		enforceCompactGridVowelMinimum()

		screen = .game
		if dailyBopEntry != nil {
			audio.playDailyBopIntroSound()
		} else {
			audio.playRoundStartSound(for: gameMode)
		}
		if showsTimer { startTimer() }
	}

	func playAgain() {
		if let dailyBopTargetWord, let dailyBopTargetLanguage {
			startGame(dailyBopEntry: DailyBopEntry(language: dailyBopTargetLanguage, word: dailyBopTargetWord))
		} else {
			startGame()
		}
	}

	func pauseGame(playSound: Bool = true) {
		guard gameActive, !gamePaused else { return }
		gamePaused = true
		stopTimer()
		pausePowerUpCountdown()
		pauseDailyBopBoost()
		if playSound { audio.playPauseSound() }
	}

	func resumeGame() {
		guard gameActive, gamePaused else { return }
		gamePaused = false
		audio.playResumeSound()
		if showsTimer { startTimer() }
		if dailyBopBoostActive { resumeDailyBopBoost(audioDelay: 0.55) }
		if chainPowerUpActive { startPowerUpCountdown(audioDelay: 0.55) }
	}

	func endGame() {
		guard gameActive else { return }
		gamePaused = false
		gameActive = false
		stopTimer()
		stopPowerUp()
		stopDailyBopBoost()
		audio.playRoundEndSound()
		haptics.roundEnded()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) { [weak self] in
			self?.showResults()
		}
	}

	private func showResults() {
		updateBestGame()
		screen = .results
	}

	func goHome() {
		announcementWorkItem?.cancel()
		announcementWorkItem = nil
		screen = .start
	}

	// MARK: - Bubble interaction

	func tapBubble(_ bubble: Bubble) {
		guard gameActive, !gamePaused else { return }
		if bopAwayIsActive {
			guard !consumedBopAwayBubbleIds.contains(bubble.id) else { return }
			consumedBopAwayBubbleIds.insert(bubble.id)
			selectBubble(bubble)
			replaceBubble(id: bubble.id)
			return
		}
		if selected.contains(where: { $0.bubbleId == bubble.id }) {
			deselectBubble(bubble)
		} else {
			selectBubble(bubble)
		}
	}

	private func selectBubble(_ bubble: Bubble) {
		if selected.isEmpty { audio.resetSelectSound() }
		selected.append(SelectedLetter(
			bubbleId: bubble.id,
			letter: bubble.letter,
			row: bubble.row,
			col: bubble.col
		))
		audio.playSelectSound()
		haptics.selectLetter()
	}

	private func deselectBubble(_ bubble: Bubble) {
		replaceBubbleIfBopAway(id: bubble.id)
		selected.removeAll { $0.bubbleId == bubble.id }
		audio.stepSelectSoundBack()
		audio.playDeselectSound()
		haptics.deselectLetter()
		if selected.isEmpty { audio.resetSelectSound() }
	}

	func clearSelection() {
		guard gameActive, !gamePaused else { return }
		guard !selected.isEmpty else {
			return
		}
		let clearedIds = bopAwayIsActive ? [] : selected.map(\.bubbleId)
		selected.removeAll()
		for id in clearedIds { replaceBubbleIfBopAway(id: id) }
		audio.resetSelectSound()
		audio.playBonusSound()
		haptics.clearLetters()
		if gameMode == .timed {
			secondsLeft = min(secondsLeft + 15, gameDuration)
			announce(GameplayAnnouncements.clearedWithTimeBonus, includeInLowVerbosity: true)
		} else if bopAwayIsActive {
			announce(GameplayAnnouncements.wordCleared, includeInLowVerbosity: true)
		} else {
			announce(GameplayAnnouncements.cleared, includeInLowVerbosity: true)
		}
	}

	// MARK: - Make word

	func makeWord() {
		guard gameActive, !gamePaused, selected.count >= 3 else { return }
		let word = currentWord.lowercased()

		if gameMode == .bopple, !isFullyConnectedWord() {
			audio.playInvalidSound()
			haptics.invalidWord()
			resetChainStreak()
			selected.removeAll()
			audio.resetSelectSound()
			announce(GameplayAnnouncements.disconnectedBoppleWord, includeInLowVerbosity: true)
			return
		}

		guard dictionary.contains(word, language: dictionaryLanguage) else {
			audio.playInvalidSound()
			haptics.invalidWord()
			resetChainStreak()
			selected.removeAll()
			audio.resetSelectSound()
			announce(GameplayAnnouncements.invalidWord(word, language: dictionaryLanguage), includeInLowVerbosity: true)
			return
		}

		if gameMode == .bopple, madeWords.contains(word) {
			audio.playInvalidSound()
			haptics.invalidWord()
			resetChainStreak()
			selected.removeAll()
			audio.resetSelectSound()
			announce(GameplayAnnouncements.duplicateWord(word, language: dictionaryLanguage), includeInLowVerbosity: true)
			return
		}

		let chainBonus = gameMode == .bopple ? 0 : calcChainBonus()
		let basePoints = calcScore(word) + chainBonus
		let multiplier = gameMode == .bopple ? 1 : (dailyBopBoostActive || chainPowerUpActive ? 3 : 1)
		let points = basePoints * multiplier
		let dailyBopWasFound = isDailyBopWord(word)
		let dailyBopCanActivate = dailyBopWasFound && canActivateDailyBopBoostToday()

		let scoredIds = selected.map(\.bubbleId)
		selected.removeAll()
		audio.resetSelectSound()

		if gameMode != .bopple && !bopAwayIsActive {
			for id in scoredIds { replaceBubble(id: id) }
		}

		score += points
		wordCount += 1
		totalLettersUsed += word.count
		madeWords.append(word)
		if gameMode != .bopple, chainBonus > largestLetterChain { largestLetterChain = chainBonus }

		if dailyBopBoostActive || dailyBopCanActivate {
			audio.playChainMultiplierScoreSound(wordLength: word.count)
			haptics.powerUpScored()
		} else if multiplier > 1 {
			stopPowerUp()
			audio.playChainMultiplierScoreSound(wordLength: word.count)
			haptics.powerUpScored()
		} else {
			audio.playWordSound(wordLength: word.count)
			haptics.wordScored(wordLength: word.count)
		}

		let powerUpActivated = gameMode == .bopple ? false : updateChainStreak(chainBonus: chainBonus)
		let dailyBopActivated = dailyBopCanActivate && activateDailyBopBoostIfNeeded()

		announce(GameplayAnnouncements.scoredWord(
			word: word,
			language: dictionaryLanguage,
			points: points,
			chainBonus: chainBonus,
			multiplier: multiplier,
			powerUpActivated: powerUpActivated,
			dailyBopActivated: dailyBopActivated,
			verbosity: gameAnnouncementVerbosity
		), includeInLowVerbosity: true)
	}

	// MARK: - Scoring

	private func calcScore(_ word: String) -> Int {
		if gameMode == .bopple { return calcBoppleScore(word) }
		var pts = word.count
		if word.count >= 5 { pts += word.count }
		if word.count >= 7 { pts += word.count * 2 }
		return pts
	}

	private func calcBoppleScore(_ word: String) -> Int {
		switch word.count {
		case 3...4:
			1
		case 5:
			2
		case 6:
			3
		case 7:
			5
		default:
			11
		}
	}

	private func calcChainBonus() -> Int {
		guard selected.count >= 3 else { return 0 }
		let longestRun = longestConnectedRunLength()
		return longestRun >= 3 ? longestRun : 0
	}

	private func isFullyConnectedWord() -> Bool {
		guard selected.count >= 3 else { return false }
		return zip(selected, selected.dropFirst()).allSatisfy { areTouching($0, $1) }
	}

	private func longestConnectedRunLength() -> Int {
		var longest = 1
		var current = 1

		for (previous, next) in zip(selected, selected.dropFirst()) {
			if areTouching(previous, next) {
				current += 1
				longest = max(longest, current)
			} else {
				current = 1
			}
		}

		return longest
	}

	private func areTouching(_ a: SelectedLetter, _ b: SelectedLetter) -> Bool {
		let dr = abs(a.row - b.row)
		let dc = abs(a.col - b.col)
		return dr <= 1 && dc <= 1 && (dr + dc) > 0
	}

	// MARK: - Chain streak

	private func updateChainStreak(chainBonus: Int) -> Bool {
		guard chainBonus > 0 else {
			resetChainStreak()
			return false
		}
		connectedWordStreak += 1
		audio.playConnectedWordSound(wordLength: chainBonus)
		audio.playChainStreakSound(streak: connectedWordStreak)
		haptics.chainWord()

		if connectedWordStreak >= 3 {
			activatePowerUp()
			return true
		}
		return false
	}

	private func resetChainStreak() {
		guard !chainPowerUpActive else { return }
		connectedWordStreak = 0
	}

	private func activatePowerUp() {
		connectedWordStreak = 0
		chainPowerUpActive = true
		chainPowerUpSecondsLeft = 15
		haptics.powerUpActivated()
		startPowerUpCountdown()
	}

	private func startPowerUpCountdown(audioDelay: TimeInterval = 0) {
		guard chainPowerUpActive, chainPowerUpSecondsLeft > 0 else { return }
		guard !dailyBopBoostActive else { return }
		powerUpAudioResumeWorkItem?.cancel()
		if audioDelay > 0 {
			let workItem = DispatchWorkItem { [weak self] in
				guard let self, self.chainPowerUpActive, !self.gamePaused else { return }
				self.audio.startPowerUpChimes(duration: Double(self.chainPowerUpSecondsLeft))
			}
			powerUpAudioResumeWorkItem = workItem
			DispatchQueue.main.asyncAfter(deadline: .now() + audioDelay, execute: workItem)
		} else {
			audio.startPowerUpChimes(duration: Double(chainPowerUpSecondsLeft))
		}
		powerUpTimer?.invalidate()
		powerUpTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			guard let self else { return }
			self.chainPowerUpSecondsLeft -= 1
			if self.chainPowerUpSecondsLeft <= 0 { self.stopPowerUp() }
		}
	}

	private func pausePowerUpCountdown() {
		powerUpAudioResumeWorkItem?.cancel()
		powerUpAudioResumeWorkItem = nil
		powerUpTimer?.invalidate()
		powerUpTimer = nil
		audio.stopPowerUpChimes()
	}

	private func stopPowerUp() {
		chainPowerUpActive = false
		chainPowerUpSecondsLeft = 0
		connectedWordStreak = 0
		powerUpTimer?.invalidate()
		powerUpTimer = nil
		powerUpAudioResumeWorkItem?.cancel()
		powerUpAudioResumeWorkItem = nil
		audio.stopPowerUpChimes()
	}

	// MARK: - Daily Bop

	private func isDailyBopWord(_ word: String) -> Bool {
		guard let dailyBopTargetWord, let dailyBopTargetLanguage else { return false }
		guard dailyBopTargetLanguage == dictionaryLanguage else { return false }
		return word == dailyBopTargetWord
	}

	private func activateDailyBopBoostIfNeeded() -> Bool {
		guard !dailyBopFoundThisRound else { return false }
		guard let language = dailyBopTargetLanguage else { return false }
		guard !dailyBopWasFoundToday(language: language) else { return false }
		dailyBopFoundThisRound = true
		recordDailyBopFound(language: language)
		pausePowerUpCountdown()
		dailyBopBoostActive = true
		dailyBopBoostSecondsLeft = 45
		audio.playDailyBopAnthem()
		dailyBopBoostTimer?.invalidate()
		dailyBopBoostTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			guard let self else { return }
			self.dailyBopBoostSecondsLeft -= 1
			if self.dailyBopBoostSecondsLeft <= 0 {
				self.stopDailyBopBoost()
			}
		}
		return true
	}

	private func canActivateDailyBopBoostToday() -> Bool {
		guard !dailyBopFoundThisRound else { return false }
		guard let language = dailyBopTargetLanguage else { return false }
		return !dailyBopWasFoundToday(language: language)
	}

	private func stopDailyBopBoost() {
		dailyBopBoostActive = false
		dailyBopBoostSecondsLeft = 0
		dailyBopBoostTimer?.invalidate()
		dailyBopBoostTimer = nil
		audio.stopDailyBopAnthem()
		if chainPowerUpActive, !gamePaused {
			startPowerUpCountdown(audioDelay: 0.2)
		}
	}

	private func pauseDailyBopBoost() {
		dailyBopBoostTimer?.invalidate()
		dailyBopBoostTimer = nil
		audio.stopDailyBopAnthem()
	}

	private func resumeDailyBopBoost(audioDelay: TimeInterval = 0) {
		guard dailyBopBoostActive, dailyBopBoostSecondsLeft > 0 else { return }
		if audioDelay > 0 {
			DispatchQueue.main.asyncAfter(deadline: .now() + audioDelay) { [weak self] in
				guard let self, self.dailyBopBoostActive, !self.gamePaused else { return }
				self.audio.playDailyBopAnthem()
			}
		} else {
			audio.playDailyBopAnthem()
		}
		dailyBopBoostTimer?.invalidate()
		dailyBopBoostTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			guard let self else { return }
			self.dailyBopBoostSecondsLeft -= 1
			if self.dailyBopBoostSecondsLeft <= 0 {
				self.stopDailyBopBoost()
			}
		}
	}

	private func recordDailyBopFound(language: DictionaryLanguage) {
		let dateKey = dailyBopDateKey()
		let index = bestGame.dailyBopLanguageStats.firstIndex { $0.language == language }
		if let index {
			if bestGame.dailyBopLanguageStats[index].lastFoundDateKey == dateKey { return }
			bestGame.dailyBopLanguageStats[index].foundCount += 1
			bestGame.dailyBopLanguageStats[index].lastFoundDateKey = dateKey
		} else {
			bestGame.dailyBopLanguageStats.append(DailyBopLanguageStat(
				language: language,
				foundCount: 1,
				lastFoundDateKey: dateKey
			))
		}
		saveBestGame()
	}

	private func dailyBopDateKey(date: Date = Date(), calendar: Calendar = .current) -> String {
		let components = calendar.dateComponents([.year, .month, .day], from: date)
		let year = components.year ?? 0
		let month = components.month ?? 0
		let day = components.day ?? 0
		return String(format: "%04d%02d%02d", year, month, day)
	}

	private func dailyBopRank(for count: Int) -> String {
		let ranks = [
			String(localized: "WordBopper Newbie"),
			String(localized: "Bubble Scout"),
			String(localized: "Bop Cadet"),
			String(localized: "Word Wrangler"),
			String(localized: "Bopologist"),
			String(localized: "Bubble Captain"),
			String(localized: "Grid Maestro"),
			String(localized: "Daily Bop Dynamo"),
			String(localized: "Word Wizard"),
			String(localized: "Bop Commander"),
			String(localized: "Letter Legend"),
			String(localized: "Bop Supreme"),
			String(localized: "Vocabulary Virtuoso"),
			String(localized: "Daily Bop Champion"),
			String(localized: "Grand Bopmaster")
		]
		return ranks[min(count / 10, ranks.count - 1)]
	}

	// MARK: - Bubble management

	private func replaceBubble(id: UUID) {
		guard let idx = bubbles.firstIndex(where: { $0.id == id }) else { return }
		let old = bubbles[idx]
		bubbles[idx] = Bubble(letter: randomLetter(forRow: old.row, col: old.col, replacingIndex: idx), colorIndex: randomColor(), row: old.row, col: old.col)
	}

	private func replaceBubbleIfBopAway(id: UUID) {
		guard bopAway, gameMode != .bopple else { return }
		replaceBubble(id: id)
	}

	private func randomLetter(forRow row: Int, col: Int, replacingIndex: Int? = nil) -> String {
		let forceVowel = shouldForceVowel(replacingIndex: replacingIndex)
		let pool = forceVowel ? vowelPool : dictionaryLanguage.letterPool
		var bestCandidate = randomLetterCandidate(from: pool, allowDailyBopNudge: !forceVowel)
		var bestPenalty = letterPlacementPenalty(for: bestCandidate, row: row, col: col, replacingIndex: replacingIndex)

		for _ in 0..<24 {
			let candidate = randomLetterCandidate(from: pool, allowDailyBopNudge: !forceVowel)
			let penalty = letterPlacementPenalty(for: candidate, row: row, col: col, replacingIndex: replacingIndex)
			if penalty == 0 { return candidate }
			if penalty < bestPenalty {
				bestCandidate = candidate
				bestPenalty = penalty
			}
		}
		return bestCandidate
	}

	private func enforceCompactGridVowelMinimum() {
		let minimumVowels = compactGridMinimumVowels
		guard minimumVowels > 0 else { return }
		while vowelCount() < minimumVowels, let index = bubbles.indices.filter({ !isVowel(bubbles[$0].letter) }).randomElement() {
			let old = bubbles[index]
			bubbles[index] = Bubble(letter: randomLetter(forRow: old.row, col: old.col, replacingIndex: index, forceVowel: true), colorIndex: old.colorIndex, row: old.row, col: old.col)
		}
	}

	private func randomLetter(forRow row: Int, col: Int, replacingIndex: Int?, forceVowel: Bool) -> String {
		let pool = forceVowel ? vowelPool : dictionaryLanguage.letterPool
		var bestCandidate = randomLetterCandidate(from: pool, allowDailyBopNudge: !forceVowel)
		var bestPenalty = letterPlacementPenalty(for: bestCandidate, row: row, col: col, replacingIndex: replacingIndex)

		for _ in 0..<24 {
			let candidate = randomLetterCandidate(from: pool, allowDailyBopNudge: !forceVowel)
			let penalty = letterPlacementPenalty(for: candidate, row: row, col: col, replacingIndex: replacingIndex)
			if penalty == 0 { return candidate }
			if penalty < bestPenalty {
				bestCandidate = candidate
				bestPenalty = penalty
			}
		}
		return bestCandidate
	}

	private func randomLetterCandidate(from pool: [String], allowDailyBopNudge: Bool = true) -> String {
		if allowDailyBopNudge, let dailyBopLetter = randomDailyBopLetter(), Int.random(in: 0..<100) < 16 {
			return dailyBopLetter
		}
		return pool[Int.random(in: 0..<pool.count)]
	}

	private func randomDailyBopLetter() -> String? {
		guard let dailyBopTargetWord, dailyBopTargetLanguage == dictionaryLanguage else { return nil }
		let letters = dailyBopTargetWord.map { String($0) }.filter { !$0.isEmpty }
		guard !letters.isEmpty else { return nil }
		return letters[Int.random(in: 0..<letters.count)]
	}

	private var compactGridMinimumVowels: Int {
		switch gridSize {
		case 3:
			2
		case 4:
			3
		default:
			0
		}
	}

	private var vowelPool: [String] {
		dictionaryLanguage.letterPool.filter { isVowel($0) }
	}

	private func shouldForceVowel(replacingIndex: Int?) -> Bool {
		guard compactGridMinimumVowels > 0, let replacingIndex else { return false }
		return vowelCount(excluding: replacingIndex) < compactGridMinimumVowels
	}

	private func vowelCount(excluding excludedIndex: Int? = nil) -> Int {
		bubbles.indices.reduce(0) { count, index in
			guard index != excludedIndex else { return count }
			return isVowel(bubbles[index].letter) ? count + 1 : count
		}
	}

	private func isVowel(_ letter: String) -> Bool {
		["a", "e", "i", "o", "u"].contains(letter.lowercased())
	}

	private func letterPlacementPenalty(for letter: String, row: Int, col: Int, replacingIndex: Int?) -> Int {
		var penalty = 0
		let matchingNeighbors = neighborPositions(forRow: row, col: col).filter { position in
			bubbleLetter(atRow: position.row, col: position.col, replacingIndex: replacingIndex) == letter
		}

		if matchingNeighbors.count >= 2 { penalty += 100 }
		penalty += matchingNeighbors.count * 8

		if createsLineRun(letter: letter, row: row, col: col, replacingIndex: replacingIndex, rowStep: 0, colStep: 1) {
			penalty += 100
		}
		if createsLineRun(letter: letter, row: row, col: col, replacingIndex: replacingIndex, rowStep: 1, colStep: 0) {
			penalty += 100
		}

		return penalty
	}

	private func createsLineRun(letter: String, row: Int, col: Int, replacingIndex: Int?, rowStep: Int, colStep: Int) -> Bool {
		for offset in -2...0 {
			var runCount = 0
			for step in 0..<3 {
				let checkRow = row + (offset + step) * rowStep
				let checkCol = col + (offset + step) * colStep
				if checkRow == row, checkCol == col {
					runCount += 1
				} else if bubbleLetter(atRow: checkRow, col: checkCol, replacingIndex: replacingIndex) == letter {
					runCount += 1
				}
			}
			if runCount >= 3 { return true }
		}
		return false
	}

	private func bubbleLetter(atRow row: Int, col: Int, replacingIndex: Int?) -> String? {
		guard row >= 0, row < gridSize, col >= 0, col < gridSize else { return nil }
		let index = row * gridSize + col
		if index == replacingIndex { return nil }
		guard index >= 0, index < bubbles.count else { return nil }
		return bubbles[index].letter
	}

	private func neighborPositions(forRow row: Int, col: Int) -> [(row: Int, col: Int)] {
		var positions: [(row: Int, col: Int)] = []
		for rowOffset in -1...1 {
			for colOffset in -1...1 {
				guard rowOffset != 0 || colOffset != 0 else { continue }
				let nextRow = row + rowOffset
				let nextCol = col + colOffset
				if nextRow >= 0, nextRow < gridSize, nextCol >= 0, nextCol < gridSize {
					positions.append((nextRow, nextCol))
				}
			}
		}
		return positions
	}

	private func randomColor() -> Int {
		Int.random(in: 0..<GameViewModel.colorCount)
	}

	private func randomGameplayHeading() -> String {
		if dailyBopTargetWord != nil {
			return GameViewModel.dailyBopGameplayHeadingPhrases.randomElement() ?? GameViewModel.dailyBopGameplayHeadingPhrases[0]
		}
		if gameMode == .bopple {
			return GameViewModel.boppleGameplayHeadingPhrases.randomElement() ?? GameViewModel.boppleGameplayHeadingPhrases[0]
		}
		return GameViewModel.gameplayHeadingPhrases.randomElement() ?? GameViewModel.gameplayHeadingPhrases[0]
	}

	private var gameDuration: Int {
		switch gameMode {
		case .timed:
			GameViewModel.timedGameDuration
		case .bopple:
			boppleTimerOption.duration ?? GameViewModel.boppleGameDuration
		case .nonStop:
			GameViewModel.timedGameDuration
		}
	}

	// MARK: - Timer

	private func startTimer() {
		gameTimer?.invalidate()
		gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			guard let self else { return }
			self.secondsLeft -= 1
			if self.secondsLeft <= 10 && self.secondsLeft > 0 {
				self.audio.playTickSound(secondsLeft: self.secondsLeft)
			}
			if self.secondsLeft <= 0 { self.endGame() }
		}
	}

	private func stopTimer() {
		gameTimer?.invalidate()
		gameTimer = nil
	}

	// MARK: - Announcements

	func announce(_ message: String, includeInLowVerbosity: Bool = false) {
		announce(AttributedString(message), includeInLowVerbosity: includeInLowVerbosity)
	}

	func announce(_ message: AttributedString, includeInLowVerbosity: Bool = false) {
		if gameAnnouncementVerbosity == .off { return }
		if gameAnnouncementVerbosity == .low, !includeInLowVerbosity { return }
		DispatchQueue.main.async {
			self.announcementWorkItem?.cancel()
			var announcement = message
			announcement.accessibilitySpeechAnnouncementPriority = .high
			AccessibilityNotification.Announcement(announcement).post()
			self.announcementWorkItem = nil
		}
	}

	// MARK: - Best game

	private func loadBestGame() -> BestGame {
		guard let data = UserDefaults.standard.data(forKey: "wordBopBestGame"),
			  let saved = try? JSONDecoder().decode(BestGame.self, from: data) else {
			return BestGame()
		}
		return saved
	}

	private func loadGameMode() -> GameMode {
		if let saved = UserDefaults.standard.string(forKey: "wordBopGameMode"),
		   let mode = GameMode(rawValue: saved) {
			return mode
		}
		return UserDefaults.standard.bool(forKey: "wordBopNonStopMode") ? .nonStop : .timed
	}

	private func loadBoppleTimerOption() -> BoppleTimerOption {
		guard let saved = UserDefaults.standard.string(forKey: "wordBopBoppleTimerOption") else {
			return .threeMinutes
		}
		return BoppleTimerOption(rawValue: saved) ?? .threeMinutes
	}

	private func loadGridSizeOption() -> GridSizeOption {
		let saved = UserDefaults.standard.integer(forKey: "wordBopGridSize")
		return GridSizeOption(rawValue: saved) ?? .five
	}

	private func loadLetterPositionMode() -> LetterPositionMode {
		if let saved = UserDefaults.standard.string(forKey: "wordBopLetterPositionMode"),
		   let mode = LetterPositionMode(rawValue: saved) {
			return mode
		}
		return UserDefaults.standard.bool(forKey: "wordBopSpeakLetterPositions") ? .columnNumberRowNumber : .off
	}

	private func loadSpeakLetterPhonetics() -> Bool {
		UserDefaults.standard.bool(forKey: "wordBopSpeakLetterPhonetics")
	}

	private func loadBopAway() -> Bool {
		UserDefaults.standard.bool(forKey: "wordBopBopAway")
	}

	private func loadBubbleTextColorOption() -> BubbleTextColorOption {
		guard let saved = UserDefaults.standard.string(forKey: "wordBopBubbleTextColorOption") else {
			return .dark
		}
		return BubbleTextColorOption(rawValue: saved) ?? .dark
	}

	private func loadBubbleColorTheme(for textColorOption: BubbleTextColorOption) -> BubbleColorTheme {
		guard let saved = UserDefaults.standard.string(forKey: "wordBopBubbleColorTheme"),
			  let theme = BubbleColorTheme(rawValue: saved),
			  theme.supports(textColorOption) else {
			return BubbleColorTheme.defaultTheme(for: textColorOption)
		}
		return theme
	}

	private func loadBubbleLetterStyle() -> BubbleLetterStyle {
		guard let saved = UserDefaults.standard.string(forKey: "wordBopBubbleLetterStyle") else {
			return .playful
		}
		return BubbleLetterStyle(rawValue: saved) ?? .playful
	}

	private func loadGameAnnouncementVerbosity() -> GameAnnouncementVerbosity {
		guard let saved = UserDefaults.standard.string(forKey: "wordBopGameAnnouncementVerbosity") else {
			return .normal
		}
		return GameAnnouncementVerbosity(rawValue: saved) ?? .normal
	}

	private func loadGameHapticsEnabled() -> Bool {
		if UserDefaults.standard.object(forKey: "wordBopGameHapticsEnabled") == nil {
			return true
		}
		return UserDefaults.standard.bool(forKey: "wordBopGameHapticsEnabled")
	}

	private func loadGameVolume() -> Double {
		if UserDefaults.standard.object(forKey: "wordBopGameVolume") == nil {
			return 0.82
		}
		return min(max(UserDefaults.standard.double(forKey: "wordBopGameVolume"), 0), 1)
	}

	private func loadLeftHandedMode() -> Bool {
		UserDefaults.standard.bool(forKey: "wordBopLeftHandedMode")
	}

	private func loadDictionaryLanguage() -> DictionaryLanguage {
		guard let saved = UserDefaults.standard.string(forKey: "wordBopDictionaryLanguage") else {
			return .english
		}
		return DictionaryLanguage(rawValue: saved) ?? .english
	}

	private func loadDailyBopEnabledLanguages(fallback: DictionaryLanguage) -> [DictionaryLanguage] {
		guard let saved = UserDefaults.standard.array(forKey: "wordBopDailyBopEnabledLanguages") as? [String] else {
			return sortedDailyBopLanguages([.english, fallback])
		}
		let languages = saved.compactMap { DictionaryLanguage(rawValue: $0) }
		return sortedDailyBopLanguages(languages.isEmpty ? [fallback] : languages)
	}

	private func saveGameMode() {
		UserDefaults.standard.set(gameMode.rawValue, forKey: "wordBopGameMode")
		UserDefaults.standard.set(gameMode == .nonStop, forKey: "wordBopNonStopMode")
	}

	private func saveBoppleTimerOption() {
		UserDefaults.standard.set(boppleTimerOption.rawValue, forKey: "wordBopBoppleTimerOption")
	}

	private func saveGridSizeOption() {
		UserDefaults.standard.set(gridSizeOption.rawValue, forKey: "wordBopGridSize")
	}

	private func saveLetterPositionMode() {
		UserDefaults.standard.set(letterPositionMode.rawValue, forKey: "wordBopLetterPositionMode")
		UserDefaults.standard.set(letterPositionMode != .off, forKey: "wordBopSpeakLetterPositions")
	}

	private func saveSpeakLetterPhonetics() {
		UserDefaults.standard.set(speakLetterPhonetics, forKey: "wordBopSpeakLetterPhonetics")
	}

	private func saveBopAway() {
		UserDefaults.standard.set(bopAway, forKey: "wordBopBopAway")
	}

	private func saveBubbleTextColorOption() {
		UserDefaults.standard.set(bubbleTextColorOption.rawValue, forKey: "wordBopBubbleTextColorOption")
	}

	private func saveBubbleColorTheme() {
		UserDefaults.standard.set(bubbleColorTheme.rawValue, forKey: "wordBopBubbleColorTheme")
	}

	private func saveBubbleLetterStyle() {
		UserDefaults.standard.set(bubbleLetterStyle.rawValue, forKey: "wordBopBubbleLetterStyle")
	}

	private func saveGameAnnouncementVerbosity() {
		UserDefaults.standard.set(gameAnnouncementVerbosity.rawValue, forKey: "wordBopGameAnnouncementVerbosity")
	}

	private func saveGameHapticsEnabled() {
		UserDefaults.standard.set(gameHapticsEnabled, forKey: "wordBopGameHapticsEnabled")
	}

	private func saveGameVolume() {
		UserDefaults.standard.set(gameVolume, forKey: "wordBopGameVolume")
	}

	private func saveLeftHandedMode() {
		UserDefaults.standard.set(leftHandedMode, forKey: "wordBopLeftHandedMode")
	}

	private func saveDictionaryLanguage() {
		UserDefaults.standard.set(dictionaryLanguage.rawValue, forKey: "wordBopDictionaryLanguage")
	}

	private func saveDailyBopEnabledLanguages() {
		UserDefaults.standard.set(dailyBopEnabledLanguages.map(\.rawValue), forKey: "wordBopDailyBopEnabledLanguages")
	}

	private func saveBestGame() {
		guard let data = try? JSONEncoder().encode(bestGame) else { return }
		UserDefaults.standard.set(data, forKey: "wordBopBestGame")
	}

	private func updateBestGame() {
		let longest = madeWords.reduce("") { current, word in
			word.count >= current.count ? word : current
		}
		var changed = false
		if dictionaryLanguage == .english {
			switch gameMode {
			case .timed:
				if score > bestGame.highestScore { bestGame.highestScore = score; changed = true }
				if !longest.isEmpty, longest.count >= bestGame.longestWord.count { bestGame.longestWord = longest; changed = true }
				if wordCount > bestGame.mostWords { bestGame.mostWords = wordCount; changed = true }
				if largestLetterChain > bestGame.largestLetterChain { bestGame.largestLetterChain = largestLetterChain; changed = true }
			case .bopple:
				if score > bestGame.highestBoppleScore { bestGame.highestBoppleScore = score; changed = true }
				if !longest.isEmpty, longest.count >= bestGame.longestBoppleWord.count { bestGame.longestBoppleWord = longest; changed = true }
				if wordCount > bestGame.mostBoppleWords { bestGame.mostBoppleWords = wordCount; changed = true }
			case .nonStop:
				if score > bestGame.highestNonStopScore { bestGame.highestNonStopScore = score; changed = true }
				if !longest.isEmpty, longest.count >= bestGame.longestNonStopWord.count { bestGame.longestNonStopWord = longest; changed = true }
				if wordCount > bestGame.mostNonStopWords { bestGame.mostNonStopWords = wordCount; changed = true }
				if largestLetterChain > bestGame.largestNonStopLetterChain { bestGame.largestNonStopLetterChain = largestLetterChain; changed = true }
			}
		}
		if updateLanguageModeBestGame(longest: longest) {
			changed = true
		}
		if changed { saveBestGame() }
	}

	private func updateLanguageModeBestGame(longest: String) -> Bool {
		guard dictionaryLanguage != .english else { return false }

		let index = bestGame.languageModeBestGames.firstIndex {
			$0.language == dictionaryLanguage && $0.mode == gameMode
		}
		var record = index.map { bestGame.languageModeBestGames[$0] } ?? LanguageModeBestGame(language: dictionaryLanguage, mode: gameMode)
		var changed = index == nil

		if score > record.highestScore {
			record.highestScore = score
			changed = true
		}
		if !longest.isEmpty, longest.count >= record.longestWord.count {
			record.longestWord = longest
			changed = true
		}
		if wordCount > record.mostWords {
			record.mostWords = wordCount
			changed = true
		}
		if gameMode != .bopple, largestLetterChain > record.largestLetterChain {
			record.largestLetterChain = largestLetterChain
			changed = true
		}

		if changed {
			if let index {
				bestGame.languageModeBestGames[index] = record
			} else {
				bestGame.languageModeBestGames.append(record)
			}
		}

		return changed
	}
}
