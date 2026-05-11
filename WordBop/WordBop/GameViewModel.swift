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
			"Dark Text"
		case .light:
			"Light Text"
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
			"Normal"
		case .low:
			"Low"
		case .off:
			"Off"
		}
	}
}

struct BestGame: Codable {
	var highestScore: Int = 0
	var highestNonStopScore: Int = 0
	var longestWord: String = ""
	var longestNonStopWord: String = ""
	var mostWords: Int = 0
	var mostNonStopWords: Int = 0
	var largestLetterChain: Int = 0
	var largestNonStopLetterChain: Int = 0

	init() {}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		highestScore = try container.decodeIfPresent(Int.self, forKey: .highestScore) ?? 0
		highestNonStopScore = try container.decodeIfPresent(Int.self, forKey: .highestNonStopScore) ?? 0
		longestWord = try container.decodeIfPresent(String.self, forKey: .longestWord) ?? ""
		longestNonStopWord = try container.decodeIfPresent(String.self, forKey: .longestNonStopWord) ?? ""
		mostWords = try container.decodeIfPresent(Int.self, forKey: .mostWords) ?? 0
		mostNonStopWords = try container.decodeIfPresent(Int.self, forKey: .mostNonStopWords) ?? 0
		largestLetterChain = try container.decodeIfPresent(Int.self, forKey: .largestLetterChain) ?? 0
		largestNonStopLetterChain = try container.decodeIfPresent(Int.self, forKey: .largestNonStopLetterChain) ?? 0
	}
}

enum GameScreen { case start, game, results }

@Observable
final class GameViewModel {

	// MARK: - Config
	static let gameDuration = 120
	static let totalBubbles = 25
	static let letterPool: [String] = Array(
		"aaaaaaaaaabbccddddeeeeeeeeeefffggghhhhiiiiiiijkllll" +
		"mmnnnnnnoooooooppqrrrrrsssssstttttttuuuuvvwwxyyz"
	).map { String($0) }
	static let colorCount = 8
	static let gameplayHeadingPhrases = [
		"Start bopping!",
		"Bop to it!",
		"Bop out some words!",
		"Bop those letters!",
		"Bop to the future!",
		"Start your bopping!",
		"Bop til you Drop!",
		"Bop All The Things!",
		"Bop to the Top!",
		"Commence bopping!"
	]

	// MARK: - Navigation
	var screen: GameScreen = .start

	// MARK: - Game state
	var nonStopMode = false {
		didSet { saveNonStopMode() }
	}
	var speakLetterPositions = false {
		didSet { saveSpeakLetterPositions() }
	}
	var speakLetterPhonetics = false {
		didSet { saveSpeakLetterPhonetics() }
	}
	var bubbleTextColorOption: BubbleTextColorOption = .dark {
		didSet { saveBubbleTextColorOption() }
	}
	var gameAnnouncementVerbosity: GameAnnouncementVerbosity = .normal {
		didSet { saveGameAnnouncementVerbosity() }
	}
	var bubbles: [Bubble] = []
	var selected: [SelectedLetter] = []
	var score = 0
	var wordCount = 0
	var totalLettersUsed = 0
	var madeWords: [String] = []
	var secondsLeft = GameViewModel.gameDuration
	var gameActive = false
	var connectedWordStreak = 0
	var chainPowerUpActive = false
	var chainPowerUpSecondsLeft = 0
	var largestLetterChain = 0
	var gameplayHeading = GameViewModel.gameplayHeadingPhrases[0]

	// MARK: - Best game
	var bestGame = BestGame()

	// MARK: - Services
	let audio = AudioEngine()
	private let dictionary = DictionaryService.shared
	private var gameTimer: Timer?
	private var powerUpTimer: Timer?
	private var announcementWorkItem: DispatchWorkItem?

	// MARK: - Computed
	var currentWord: String { selected.map(\.letter).joined() }

	var wordTrayLabel: String {
		if selected.isEmpty { return "Word tray, empty" }
		return "Word tray: " + selected.map { $0.letter.lowercased() }.joined(separator: ", ")
	}

	var chainMeterValue: String {
		if chainPowerUpActive {
			return "3 times chain bop active, \(chainPowerUpSecondsLeft) seconds left"
		}
		return "\(connectedWordStreak) of 3 chains"
	}

	var chainMeterProgress: Double {
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

	func isSelected(_ bubble: Bubble) -> Bool {
		selected.contains(where: { $0.bubbleId == bubble.id })
	}

	// MARK: - Init
	init() {
		bestGame = loadBestGame()
		nonStopMode = loadNonStopMode()
		speakLetterPositions = loadSpeakLetterPositions()
		speakLetterPhonetics = loadSpeakLetterPhonetics()
		bubbleTextColorOption = loadBubbleTextColorOption()
		gameAnnouncementVerbosity = loadGameAnnouncementVerbosity()
	}

	// MARK: - Game lifecycle

	func startGame() {
		bubbles = []
		selected = []
		score = 0
		wordCount = 0
		totalLettersUsed = 0
		madeWords = []
		secondsLeft = GameViewModel.gameDuration
		gameActive = true
		connectedWordStreak = 0
		chainPowerUpActive = false
		chainPowerUpSecondsLeft = 0
		largestLetterChain = 0
		gameplayHeading = randomGameplayHeading()

		for row in 0..<5 {
			for col in 0..<5 {
				bubbles.append(Bubble(letter: randomLetter(), colorIndex: randomColor(), row: row, col: col))
			}
		}

		screen = .game
		audio.playRoundStartSound()
		if !nonStopMode { startTimer() }
	}

	func endGame() {
		guard gameActive else { return }
		gameActive = false
		stopTimer()
		stopPowerUp()
		audio.playRoundEndSound()
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
		guard gameActive else { return }
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
	}

	private func deselectBubble(_ bubble: Bubble) {
		selected.removeAll { $0.bubbleId == bubble.id }
		audio.stepSelectSoundBack()
		audio.playDeselectSound()
		if selected.isEmpty { audio.resetSelectSound() }
	}

	func clearSelection() {
		guard !selected.isEmpty else {
			return
		}
		selected.removeAll()
		audio.resetSelectSound()
		audio.playBonusSound()
		if nonStopMode {
			announce(GameplayAnnouncements.cleared, includeInLowVerbosity: true)
		} else {
			secondsLeft = min(secondsLeft + 15, GameViewModel.gameDuration)
			announce(GameplayAnnouncements.clearedWithTimeBonus, includeInLowVerbosity: true)
		}
	}

	// MARK: - Make word

	func makeWord() {
		guard gameActive, selected.count >= 3 else { return }
		let word = currentWord.lowercased()

		guard dictionary.contains(word) else {
			audio.playInvalidSound()
			resetChainStreak()
			selected.removeAll()
			audio.resetSelectSound()
			announce(GameplayAnnouncements.invalidWord(word), includeInLowVerbosity: true)
			return
		}

		let chainBonus = calcChainBonus()
		let basePoints = calcScore(word) + chainBonus
		let multiplier = chainPowerUpActive ? 3 : 1
		let points = basePoints * multiplier

		let scoredIds = selected.map(\.bubbleId)
		selected.removeAll()
		audio.resetSelectSound()

		for id in scoredIds { replaceBubble(id: id) }

		score += points
		wordCount += 1
		totalLettersUsed += word.count
		madeWords.append(word)
		if chainBonus > largestLetterChain { largestLetterChain = chainBonus }

		if multiplier > 1 {
			stopPowerUp()
			audio.playChainMultiplierScoreSound(wordLength: word.count)
		} else {
			audio.playWordSound(wordLength: word.count)
		}

		let powerUpActivated = updateChainStreak(chainBonus: chainBonus)

		announce(GameplayAnnouncements.scoredWord(
			word: word,
			points: points,
			chainBonus: chainBonus,
			multiplier: multiplier,
			powerUpActivated: powerUpActivated,
			verbosity: gameAnnouncementVerbosity
		), includeInLowVerbosity: true)
	}

	// MARK: - Scoring

	private func calcScore(_ word: String) -> Int {
		var pts = word.count
		if word.count >= 5 { pts += word.count }
		if word.count >= 7 { pts += word.count * 2 }
		return pts
	}

	private func calcChainBonus() -> Int {
		guard selected.count >= 3 else { return 0 }
		let connected = zip(selected, selected.dropFirst()).allSatisfy { areTouching($0, $1) }
		return connected ? selected.count : 0
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
		audio.startPowerUpChimes(duration: 15)

		powerUpTimer?.invalidate()
		powerUpTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			guard let self else { return }
			self.chainPowerUpSecondsLeft -= 1
			if self.chainPowerUpSecondsLeft <= 0 { self.stopPowerUp() }
		}
	}

	private func stopPowerUp() {
		chainPowerUpActive = false
		chainPowerUpSecondsLeft = 0
		connectedWordStreak = 0
		powerUpTimer?.invalidate()
		powerUpTimer = nil
		audio.stopPowerUpChimes()
	}

	// MARK: - Bubble management

	private func replaceBubble(id: UUID) {
		guard let idx = bubbles.firstIndex(where: { $0.id == id }) else { return }
		let old = bubbles[idx]
		bubbles[idx] = Bubble(letter: randomLetter(), colorIndex: randomColor(), row: old.row, col: old.col)
	}

	private func randomLetter() -> String {
		GameViewModel.letterPool[Int.random(in: 0..<GameViewModel.letterPool.count)]
	}

	private func randomColor() -> Int {
		Int.random(in: 0..<GameViewModel.colorCount)
	}

	private func randomGameplayHeading() -> String {
		GameViewModel.gameplayHeadingPhrases.randomElement() ?? GameViewModel.gameplayHeadingPhrases[0]
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
		if gameAnnouncementVerbosity == .off { return }
		if gameAnnouncementVerbosity == .low, !includeInLowVerbosity { return }
		DispatchQueue.main.async {
			self.announcementWorkItem?.cancel()
			var announcement = AttributedString(message)
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

	private func loadNonStopMode() -> Bool {
		UserDefaults.standard.bool(forKey: "wordBopNonStopMode")
	}

	private func loadSpeakLetterPositions() -> Bool {
		UserDefaults.standard.bool(forKey: "wordBopSpeakLetterPositions")
	}

	private func loadSpeakLetterPhonetics() -> Bool {
		UserDefaults.standard.bool(forKey: "wordBopSpeakLetterPhonetics")
	}

	private func loadBubbleTextColorOption() -> BubbleTextColorOption {
		guard let saved = UserDefaults.standard.string(forKey: "wordBopBubbleTextColorOption") else {
			return .dark
		}
		return BubbleTextColorOption(rawValue: saved) ?? .dark
	}

	private func loadGameAnnouncementVerbosity() -> GameAnnouncementVerbosity {
		guard let saved = UserDefaults.standard.string(forKey: "wordBopGameAnnouncementVerbosity") else {
			return .normal
		}
		return GameAnnouncementVerbosity(rawValue: saved) ?? .normal
	}

	private func saveNonStopMode() {
		UserDefaults.standard.set(nonStopMode, forKey: "wordBopNonStopMode")
	}

	private func saveSpeakLetterPositions() {
		UserDefaults.standard.set(speakLetterPositions, forKey: "wordBopSpeakLetterPositions")
	}

	private func saveSpeakLetterPhonetics() {
		UserDefaults.standard.set(speakLetterPhonetics, forKey: "wordBopSpeakLetterPhonetics")
	}

	private func saveBubbleTextColorOption() {
		UserDefaults.standard.set(bubbleTextColorOption.rawValue, forKey: "wordBopBubbleTextColorOption")
	}

	private func saveGameAnnouncementVerbosity() {
		UserDefaults.standard.set(gameAnnouncementVerbosity.rawValue, forKey: "wordBopGameAnnouncementVerbosity")
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
		if nonStopMode {
			if score > bestGame.highestNonStopScore { bestGame.highestNonStopScore = score; changed = true }
			if !longest.isEmpty, longest.count >= bestGame.longestNonStopWord.count { bestGame.longestNonStopWord = longest; changed = true }
			if wordCount > bestGame.mostNonStopWords { bestGame.mostNonStopWords = wordCount; changed = true }
			if largestLetterChain > bestGame.largestNonStopLetterChain { bestGame.largestNonStopLetterChain = largestLetterChain; changed = true }
		} else {
			if score > bestGame.highestScore { bestGame.highestScore = score; changed = true }
			if !longest.isEmpty, longest.count >= bestGame.longestWord.count { bestGame.longestWord = longest; changed = true }
			if wordCount > bestGame.mostWords { bestGame.mostWords = wordCount; changed = true }
			if largestLetterChain > bestGame.largestLetterChain { bestGame.largestLetterChain = largestLetterChain; changed = true }
		}
		if changed { saveBestGame() }
	}
}
