import MessageUI
import SwiftUI
import UIKit

struct StartView: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	@State private var showingInstructions = false
	@State private var showingDailyBop = false
	@State private var showingBopHunt = false
	@State private var showingGameSettings = false
	@State private var announcedInitialScreen = false
	@State private var sheetTrigger: HomeSheetTrigger?
	@AccessibilityFocusState private var focusedHomeTrigger: HomeSheetTrigger?

	private enum HomeSheetTrigger: Hashable {
		case howToPlay
		case gameSettings
		case dailyBop
		case bopHunt
	}

	var body: some View {
		GeometryReader { geo in
			let contentWidth = edgeToEdgeWidth(in: geo)
			ScrollView {
				VStack(spacing: 0) {
					VStack(spacing: 2) {
						Text("WordBopper")
							.font(.largeTitle.weight(.black))
							.foregroundStyle(Color.wbText)
							.multilineTextAlignment(.center)
							.lineLimit(2)
							.minimumScaleFactor(0.8)

						Text("By Chancey Fleet and Marco Salsiccia")
							.font(.footnote.weight(.semibold))
							.foregroundStyle(Color.wbMuted)
							.multilineTextAlignment(.center)
							.fixedSize(horizontal: false, vertical: true)
					}
					.accessibilityElement(children: .combine)
					.accessibilityAddTraits(.isHeader)
					.frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 96 : 72)
					.contentShape(Rectangle())

					startScreenTopRow

					startGameButton
						.layoutPriority(3)

					dailyBopButton

					bopHuntButton

					BestGameCard(bestGame: vm.bestGame, dailyBopRank: vm.currentDailyBopRank)
						.layoutPriority(2)
				}
				.frame(width: contentWidth)
				.frame(minHeight: geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom, alignment: .top)
				.padding(.top, 24)
				.padding(.bottom, geo.safeAreaInsets.bottom)
			}
			.frame(width: contentWidth)
			.ignoresSafeArea(edges: horizontalSafeAreaEdges(in: geo))
		}
		.onAppear {
			if !announcedInitialScreen {
				UIAccessibility.post(notification: .screenChanged, argument: "WordBopper")
				announcedInitialScreen = true
			}
			vm.refreshActiveBopHunt()
			vm.audio.prepareDailyBopAnthemPreview()
			vm.prepareDailyBopEntries()
		}
		.sheet(isPresented: $showingInstructions, onDismiss: restoreSheetTriggerFocus) {
			InstructionsSheet()
				.presentationDragIndicator(.hidden)
		}
		.sheet(isPresented: $showingDailyBop, onDismiss: restoreSheetTriggerFocus) {
			DailyBopSheet()
				.environment(vm)
				.presentationDragIndicator(.hidden)
		}
		.sheet(isPresented: $showingBopHunt, onDismiss: restoreSheetTriggerFocus) {
			BopHuntSheet()
				.environment(vm)
				.presentationDragIndicator(.hidden)
		}
			.sheet(isPresented: $showingGameSettings, onDismiss: restoreSheetTriggerFocus) {
				GameSettingsSheet()
					.environment(vm)
					.presentationDragIndicator(.hidden)
			}
		}

	private func edgeToEdgeWidth(in geo: GeometryProxy) -> CGFloat {
		isLandscape(in: geo) ? geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing : geo.size.width
	}

	private func horizontalSafeAreaEdges(in geo: GeometryProxy) -> Edge.Set {
		isLandscape(in: geo) ? .horizontal : []
	}

	private func isLandscape(in geo: GeometryProxy) -> Bool {
		geo.size.width > geo.size.height
	}

	private var startScreenTopRow: some View {
		Group {
			if dynamicTypeSize.isAccessibilitySize {
				VStack(spacing: 0) {
					howToPlayButton
					gameSettingsButton
				}
			} else {
				HStack(spacing: 0) {
					howToPlayButton
					gameSettingsButton
				}
			}
		}
		.frame(maxWidth: .infinity)
		.frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 116 : 58)
	}

	private var dailyBopButton: some View {
		Button {
			sheetTrigger = .dailyBop
			showingDailyBop = true
		} label: {
			Text("Daily Bop")
				.font(.headline.weight(.black))
				.foregroundStyle(Color.black)
				.multilineTextAlignment(.center)
				.lineLimit(2)
				.frame(maxWidth: .infinity)
				.frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 82 : 66)
				.background(
					LinearGradient(
						colors: [.wbAccent5, .wbAccent4],
						startPoint: .topLeading,
						endPoint: .bottomTrailing
					)
				)
				.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.accessibilityFocused($focusedHomeTrigger, equals: .dailyBop)
	}

	private var bopHuntButton: some View {
		Button {
			sheetTrigger = .bopHunt
			showingBopHunt = true
		} label: {
			Text("BopQuest")
				.font(.headline.weight(.black))
				.foregroundStyle(Color.black)
				.multilineTextAlignment(.center)
				.lineLimit(2)
				.frame(maxWidth: .infinity)
				.frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 82 : 66)
				.background(
					LinearGradient(
						colors: [.wbAccent1, .wbAccent3],
						startPoint: .topLeading,
						endPoint: .bottomTrailing
					)
				)
				.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.accessibilityFocused($focusedHomeTrigger, equals: .bopHunt)
	}

	private var startGameButton: some View {
		Button {
			vm.startGame()
		} label: {
			ZStack {
				LinearGradient(colors: [.wbAccent1, .wbAccent2],
							   startPoint: .topLeading, endPoint: .bottomTrailing)
				Text("Start Game")
					.font(.title.weight(.black))
					.foregroundStyle(Color.black)
					.multilineTextAlignment(.center)
					.lineLimit(2)
					.minimumScaleFactor(0.8)
					.frame(maxWidth: .infinity)
			}
			.frame(maxWidth: .infinity)
			.frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 150 : 132)
			.clipShape(RoundedRectangle(cornerRadius: 28))
			.contentShape(Rectangle())
		}
		.keyboardShortcut(.defaultAction)
	}

	private var howToPlayButton: some View {
		Button {
			sheetTrigger = .howToPlay
			showingInstructions = true
		} label: {
			Text("How to Play")
				.font(.footnote.weight(.semibold))
				.foregroundStyle(Color.wbAccent5)
				.underline()
				.multilineTextAlignment(.center)
				.lineLimit(2)
				.frame(maxWidth: .infinity)
				.frame(minHeight: 58)
				.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.accessibilityFocused($focusedHomeTrigger, equals: .howToPlay)
	}

	private var gameSettingsButton: some View {
		Button {
			sheetTrigger = .gameSettings
			showingGameSettings = true
		} label: {
			Text("Game Settings")
				.font(.footnote.weight(.semibold))
				.foregroundStyle(Color.wbAccent5)
				.underline()
				.multilineTextAlignment(.center)
				.lineLimit(2)
				.frame(maxWidth: .infinity)
				.frame(minHeight: 58)
				.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.accessibilityFocused($focusedHomeTrigger, equals: .gameSettings)
	}

	private func restoreSheetTriggerFocus() {
		guard let sheetTrigger else { return }
		Task { @MainActor in
			await Task.yield()
			focusedHomeTrigger = sheetTrigger
			self.sheetTrigger = nil
		}
	}

}

private struct DailyBopSheet: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dismiss) private var dismiss
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	@AccessibilityFocusState private var focusedEntryID: String?
	@State private var showedLoadingState = false

	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				let contentWidth = sheetContentWidth(in: geo)
				ScrollView {
					VStack(spacing: 0) {
						Text("Daily Bop")
							.font(.title2.weight(.black))
							.foregroundStyle(Color.wbText)
							.accessibilityAddTraits(.isHeader)
							.frame(maxWidth: .infinity, minHeight: 72)
							.contentShape(Rectangle())

						Text("Find one special word each day in any language. Bop it during a Timed game to kick off a 45-second 3x boost.")
							.font(.body)
							.foregroundStyle(Color.wbText)
							.fixedSize(horizontal: false, vertical: true)
							.frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
							.padding(.horizontal, 24)
							.contentShape(Rectangle())

						if vm.dailyBopEntriesReady {
							VStack(spacing: 0) {
								ForEach(vm.dailyBopEntries) { entry in
									Button {
										dismiss()
										vm.startGame(dailyBopEntry: entry)
									} label: {
										DailyBopEntryLabel(
											entry: entry,
											foundToday: vm.dailyBopWasFoundToday(language: entry.language)
										)
											.frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 74 : 58)
											.contentShape(Rectangle())
									}
									.buttonStyle(.plain)
									.accessibilityFocused($focusedEntryID, equals: entry.id)
								}
							}
							.frame(maxWidth: .infinity)
						} else {
							DailyBopLoadingView()
						}
					}
					.frame(width: contentWidth)
					.frame(minHeight: geo.size.height, alignment: .top)
				}
				.frame(width: contentWidth)
			}
			.ignoresSafeArea(edges: .horizontal)
			.background(Color.wbBackground)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Close") {
						dismiss()
					}
				}
			}
		}
		.preferredColorScheme(.dark)
		.onAppear {
			if !vm.dailyBopEntriesReady {
				showedLoadingState = true
				vm.prepareDailyBopEntries()
				UIAccessibility.post(notification: .announcement, argument: String(localized: "Loading Daily Bops..."))
			}
		}
		.onChange(of: vm.dailyBopEntriesReady) { _, isReady in
			guard isReady, showedLoadingState, let firstEntry = vm.dailyBopEntries.first else { return }
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				focusedEntryID = firstEntry.id
			}
		}
	}

	private func sheetContentWidth(in geo: GeometryProxy) -> CGFloat {
		geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing
	}
}

private struct DailyBopLoadingView: View {
	var body: some View {
		ProgressView {
			Text("Loading Daily Bops...")
				.font(.body.weight(.semibold))
				.foregroundStyle(Color.wbText)
		}
		.progressViewStyle(.circular)
		.tint(Color.wbAccent5)
		.frame(maxWidth: .infinity, minHeight: 96)
		.padding(.horizontal, 24)
		.contentShape(Rectangle())
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("Loading Daily Bops...")
	}
}

private struct DailyBopEntryLabel: View {
	let entry: DailyBopEntry
	let foundToday: Bool

	var body: some View {
		HStack(spacing: 12) {
			Text(entry.language.label)
				.font(.body.weight(.semibold))
				.foregroundStyle(Color.wbText)
				.frame(maxWidth: .infinity, alignment: .leading)

			Text(spokenWord)
				.font(.system(.body, design: .rounded).weight(.black))
				.foregroundStyle(Color.wbAccent5)
				.frame(maxWidth: .infinity, alignment: .trailing)

			if foundToday {
				Text("Found")
					.font(.caption.weight(.black))
					.foregroundStyle(Color.black)
					.padding(.vertical, 5)
					.padding(.horizontal, 8)
					.background(Color.wbAccent1)
					.clipShape(Capsule())
			}
		}
		.padding(.horizontal, 24)
		.background(Color.wbBackground)
		.accessibilityElement(children: .ignore)
		.accessibilityLabel(Text(accessibilityLabel))
	}

	private var spokenWord: AttributedString {
		var word = AttributedString(entry.word)
		word.languageIdentifier = entry.language.speechLanguage
		return word
	}

	private var accessibilityLabel: AttributedString {
		var label = AttributedString(entry.language.label + ": ")
		label += spokenWord
		if foundToday {
			label += AttributedString(String(localized: ", Found"))
		}
		return label
	}
}

struct BopHuntSheet: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dismiss) private var dismiss
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				let contentWidth = sheetContentWidth(in: geo)
				ScrollView {
					VStack(spacing: 0) {
						Text(vm.activeBopHunt?.title ?? String(localized: "BopQuest"))
							.font(.title2.weight(.black))
							.foregroundStyle(Color.wbText)
							.accessibilityAddTraits(.isHeader)
							.frame(maxWidth: .infinity, minHeight: 72)
							.contentShape(Rectangle())

						Text("Find as many themed words as you can before the hunt ends. Any game mode counts.")
							.font(.body)
							.foregroundStyle(Color.wbText)
							.fixedSize(horizontal: false, vertical: true)
							.frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
							.padding(.horizontal, 24)
							.contentShape(Rectangle())

						if vm.activeBopHuntIsAvailableForCurrentLanguage {
							Text(vm.activeBopHuntProgressText)
								.font(.headline.weight(.black))
								.foregroundStyle(Color.wbAccent5)
								.frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
								.padding(.horizontal, 24)
								.contentShape(Rectangle())

							VStack(spacing: 0) {
								let words = vm.activeBopHuntWords
								ForEach(Array(words.enumerated()), id: \.element.id) { index, item in
									BopHuntWordRow(item: item, index: index + 1, total: words.count)
										.frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 72 : 56)
								}
							}
							.frame(maxWidth: .infinity)
						} else {
							Text("There is no active BopQuest for the selected language right now.")
								.font(.headline.weight(.semibold))
								.foregroundStyle(Color.wbText)
								.fixedSize(horizontal: false, vertical: true)
								.frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
								.padding(.horizontal, 24)
								.contentShape(Rectangle())
						}
					}
					.frame(width: contentWidth)
					.frame(minHeight: geo.size.height, alignment: .top)
				}
				.frame(width: contentWidth)
			}
			.ignoresSafeArea(edges: .horizontal)
			.background(Color.wbBackground)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Close") {
						dismiss()
					}
				}
			}
		}
		.preferredColorScheme(.dark)
	}

	private func sheetContentWidth(in geo: GeometryProxy) -> CGFloat {
		geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing
	}
}

private struct BopHuntWordRow: View {
	let item: BopHuntWord
	let index: Int
	let total: Int

	var body: some View {
		HStack(spacing: 12) {
			Text(item.word)
				.font(.system(.body, design: .rounded).weight(.black))
				.foregroundStyle(item.found ? Color.wbAccent5 : Color.wbText)
				.frame(maxWidth: .infinity, alignment: .leading)

			if item.found {
				Text("Found")
					.font(.caption.weight(.black))
					.foregroundStyle(Color.black)
					.padding(.vertical, 5)
					.padding(.horizontal, 8)
					.background(Color.wbAccent1)
					.clipShape(Capsule())
			}
		}
		.padding(.horizontal, 24)
		.background(Color.wbBackground)
		.contentShape(Rectangle())
		.accessibilityElement(children: .ignore)
		.accessibilityLabel(accessibilityLabel)
	}

	private var accessibilityLabel: Text {
		if item.found {
			Text("\(item.word), found, \(index) of \(total)", comment: "BopQuest word row accessibility label for a found word")
		} else {
			Text("\(item.word), \(index) of \(total)", comment: "BopQuest word row accessibility label")
		}
	}
}

private struct InstructionsSheet: View {
	@Environment(\.dismiss) private var dismiss

	private let instructions = [
		"Tap letter bubbles anywhere on the grid to build words.",
		"Use regular dictionary words. Names, places, and other proper nouns do not count.",
		"Build words with at least 3 letters in a row that are next to each other in the grid to earn a chain bonus. Do this three times in a row to activate a timed 3x score multiplier.",
		"Hit Make Word to score. Hit Clear Letters to deselect all selected letters and get 15 seconds added to the timer in Timed mode.",
		"When BopAway is on, each letter you tap moves into the word tray and gets replaced right away. Hit Clear Word to erase the current word from the tray.",
		"Timed mode has 2 minutes on the clock, and letters change as you use them. Non-Stop mode turns off the timer and lets you Bop til you drop!",
		"For VoiceOver users, use Vertical Navigation in your rotor or explore by touch to quickly navigate the grid."
	]
	private let boppleInstructions = [
		"Words must be made up of letters that are next to each other in the grid.",
		"Letters stay in place after you make words.",
		"Each word only counts once per Bopple round, so keep hunting for new ones.",
		"3 or 4 letter words score 1 point, 5 letters score 2, 6 letters score 3, 7 letters score 5, and 8 or more letters score 11.",
		"Play together with friends at the same time to see who can Bopple the best! All on their own devices, of course."
	]
	private let dailyBopInstructions = [
		"Daily Bop gives each language one special word from midnight to 11:59 PM in your local time zone.",
		"Choose a Daily Bop word to start a Timed game in that language.",
		"Find the Daily Bop word during the round to launch a 45-second 3x boost.",
		"You can earn that boost once per language each day.",
		"Each Daily Bop word you find adds to your rank on the home screen."
	]
	private let bopHuntInstructions = [
		"BopQuest gives you a themed list of words to find before the quest ends.",
		"Any game mode counts, so you can find BopQuest words while playing Timed, Bopple, Non-Stop, or Daily Bop.",
		"Each BopQuest word adds to your rank the first time you find it.",
		"Find every word in a BopQuest to earn a completion bonus equal to the number of words in that quest.",
		"Open BopQuest from the home screen or pause menu to review your progress."
	]

	private var keyboardHeading: String {
		ProcessInfo.processInfo.isiOSAppOnMac ? "Keyboard Controls" : "External Keyboard"
	}

	private var keyboardInstructions: [String] {
		var items: [String] = []
		if ProcessInfo.processInfo.isiOSAppOnMac {
			items.append("Use Tab and Shift-Tab to move between controls. Press Space to activate the focused control.")
		} else {
			items.append("With Full Keyboard Access turned on, use Tab and Shift-Tab to move between controls. Press Space to activate the focused control.")
		}
		items.append("Press Return to start a game, make the current word, resume a paused game, or play again.")
		items.append("Press Escape to clear the current letters or word. On the Round Results screen, Escape returns home.")
		items.append("Press Command-period during a game to open Pause Game or Game Options.")
		return items
	}

		var body: some View {
			NavigationStack {
				GeometryReader { geo in
					let contentWidth = sheetContentWidth(in: geo)
					ScrollView {
						VStack(spacing: 0) {
					Text("How to Play")
					.font(.title2.weight(.black))
					.foregroundStyle(Color.wbText)
					.accessibilityAddTraits(.isHeader)
					.frame(maxWidth: .infinity, minHeight: 72)
					.contentShape(Rectangle())

				VStack(alignment: .leading, spacing: 0) {
					ForEach(instructions, id: \.self) { item in
						InstructionRow(item)
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)

				Text(keyboardHeading)
					.font(.headline.weight(.black))
					.foregroundStyle(Color.wbText)
					.frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
					.padding(.horizontal, 24)
					.contentShape(Rectangle())
					.accessibilityAddTraits(.isHeader)

				VStack(alignment: .leading, spacing: 0) {
					ForEach(keyboardInstructions, id: \.self) { item in
						InstructionRow(item)
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)

				Text("Bopple")
					.font(.headline.weight(.black))
					.foregroundStyle(Color.wbText)
					.frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
					.padding(.horizontal, 24)
					.contentShape(Rectangle())
					.accessibilityAddTraits(.isHeader)

				VStack(alignment: .leading, spacing: 0) {
					ForEach(boppleInstructions, id: \.self) { item in
						InstructionRow(item)
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)

				Text("Daily Bop")
					.font(.headline.weight(.black))
					.foregroundStyle(Color.wbText)
					.frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
					.padding(.horizontal, 24)
					.contentShape(Rectangle())
					.accessibilityAddTraits(.isHeader)

				VStack(alignment: .leading, spacing: 0) {
					ForEach(dailyBopInstructions, id: \.self) { item in
						InstructionRow(item)
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)

				Text("BopQuest")
					.font(.headline.weight(.black))
					.foregroundStyle(Color.wbText)
					.frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
					.padding(.horizontal, 24)
					.contentShape(Rectangle())
					.accessibilityAddTraits(.isHeader)

				VStack(alignment: .leading, spacing: 0) {
					ForEach(bopHuntInstructions, id: \.self) { item in
						InstructionRow(item)
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
						}
						.frame(width: contentWidth)
						.frame(minHeight: geo.size.height, alignment: .top)
					}
					.frame(width: contentWidth)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
				.ignoresSafeArea(edges: .horizontal)
				.background(Color.wbBackground)
				.toolbar {
					ToolbarItem(placement: .topBarTrailing) {
					Button("Close") {
						dismiss()
					}
				}
			}
			}
			.preferredColorScheme(.dark)
		}

		private func sheetContentWidth(in geo: GeometryProxy) -> CGFloat {
			geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing
		}
	}

private struct InstructionRow: View {
	let item: String

	init(_ item: String) {
		self.item = item
	}

	var body: some View {
		HStack(alignment: .top, spacing: 8) {
			Text("•")
				.foregroundStyle(Color.wbAccent5)
				.accessibilityHidden(true)
			Text(item)
				.font(.body)
				.foregroundStyle(Color.wbText)
				.fixedSize(horizontal: false, vertical: true)
		}
		.padding(.horizontal, 24)
		.padding(.vertical, 8)
		.frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
		.contentShape(Rectangle())
		.accessibilityElement(children: .combine)
	}
}

private struct GameSettingsSheet: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dismiss) private var dismiss
	@Namespace private var gameModeNamespace
	@Namespace private var boppleTimerNamespace
	@Namespace private var gridSizeNamespace
	@Namespace private var dictionaryLanguageNamespace
	@Namespace private var letterPositionNamespace
	@Namespace private var bubbleLetterStyleNamespace
	@Namespace private var bubbleTextColorNamespace
	@Namespace private var bubbleColorThemeNamespace
	@Namespace private var gameAnnouncementsNamespace
	@AccessibilityFocusState private var isBoppleTimerFocused: Bool
	@AccessibilityFocusState private var isGridSizeFocused: Bool
	@AccessibilityFocusState private var isDictionaryLanguageFocused: Bool
	@AccessibilityFocusState private var isLetterPositionFocused: Bool
	@AccessibilityFocusState private var isBubbleColorThemeFocused: Bool
	@State private var showingAbout = false

		var body: some View {
			NavigationStack {
				GeometryReader { geo in
					let contentWidth = sheetContentWidth(in: geo)
					ScrollView {
						VStack(spacing: 0) {
							Text("Game Settings")
							.font(.title2.weight(.black))
							.foregroundStyle(Color.wbText)
							.accessibilityAddTraits(.isHeader)
							.frame(maxWidth: .infinity, minHeight: 72)
							.contentShape(Rectangle())

							SettingsPickerBlock(title: "Game Mode", namespace: gameModeNamespace, pairID: "gameMode") {
								Picker("Game Mode", selection: Binding(
									get: { vm.gameMode },
									set: { vm.gameMode = $0 }
								)) {
									ForEach(GameMode.allCases) { mode in
										Text(mode.label).tag(mode)
									}
								}
								.pickerStyle(.segmented)
							}

							SettingsDescriptionRow(verbatim: vm.gameMode.settingsBlurb)

							SettingsPickerBlock(title: "Grid Size", namespace: gridSizeNamespace, pairID: "gridSize") {
								Picker("Grid Size", selection: Binding(
									get: { vm.gridSizeOption },
									set: { option in
										vm.gridSizeOption = option
										refocusGridSizePicker()
									}
								)) {
									ForEach(GridSizeOption.allCases) { option in
										Text(option.label).tag(option)
									}
								}
								.pickerStyle(.menu)
								.accessibilityFocused($isGridSizeFocused)
							}

							SettingsDescriptionRow("Choose a smaller grid for a quicker, easier bop, or a larger grid for a bigger challenge. 5 by 5 is the classic size.")

							if vm.gameMode == .bopple {
								SettingsPickerBlock(title: "Bopple Timer", namespace: boppleTimerNamespace, pairID: "boppleTimer") {
									Picker("Bopple Timer", selection: Binding(
										get: { vm.boppleTimerOption },
										set: { option in
											vm.boppleTimerOption = option
											refocusBoppleTimerPicker()
										}
									)) {
										ForEach(BoppleTimerOption.allCases) { option in
											Text(option.label).tag(option)
										}
									}
									.pickerStyle(.menu)
									.accessibilityFocused($isBoppleTimerFocused)
								}

								SettingsDescriptionRow("Choose how long you'd like to Bopple for. 3 Minutes is the default.")
							}

							SettingsPickerBlock(title: "Bubble Language", namespace: dictionaryLanguageNamespace, pairID: "dictionaryLanguage") {
								Picker("Bubble Language", selection: Binding(
									get: { vm.dictionaryLanguage },
									set: { language in
										vm.dictionaryLanguage = language
										refocusDictionaryLanguagePicker()
									}
								)) {
									ForEach(DictionaryLanguage.allCases) { language in
										Text(language.label).tag(language)
									}
								}
								.pickerStyle(.menu)
								.accessibilityFocused($isDictionaryLanguageFocused)
							}

							SettingsDescriptionRow("Choose the language you want to Bop in. The rest of the app stays in English for now.")

							SettingsSectionHeading("Daily Bop")

							ForEach(DictionaryLanguage.allCases) { language in
								SettingsLanguageToggleRow(title: language.label, isOn: Binding(
									get: { vm.isDailyBopLanguageEnabled(language) },
									set: { vm.setDailyBopLanguage(language, enabled: $0) }
								))
							}

							SettingsDescriptionRow("Choose which languages get a Daily Bop word each day. Fewer languages make Daily Bop load faster.")

						SettingsPickerBlock(title: "Letter Positions", namespace: letterPositionNamespace, pairID: "letterPositions") {
							Picker("Letter Positions", selection: Binding(
								get: { vm.letterPositionMode },
								set: { mode in
									vm.letterPositionMode = mode
									refocusLetterPositionPicker()
								}
							)) {
								ForEach(LetterPositionMode.allCases) { mode in
									Text(mode.label).tag(mode)
								}
							}
							.pickerStyle(.menu)
							.accessibilityFocused($isLetterPositionFocused)
						}

						SettingsDescriptionRow(verbatim: vm.letterPositionMode.settingsBlurb)

						SettingsSectionHeading("Letter Phonetics")

						SettingsToggleRow(title: "Speak Letter Phonetics", isOn: Binding(
							get: { vm.speakLetterPhonetics },
							set: { vm.speakLetterPhonetics = $0 }
						))

						SettingsDescriptionRow("Adds the phonetic version of the bubble letters to the announcement, such as \"a, Alpha.\"")

							SettingsSectionHeading("BopAway")

							SettingsToggleRow(title: "BopAway", isOn: Binding(
								get: { vm.bopAway },
								set: { vm.bopAway = $0 }
							))

							SettingsDescriptionRow("For an extra challenge, BopAway instantly moves each tapped letter into the word tray and replaces it with a new letter. If you clear the word, those letters are lost. Bop wisely!")

							SettingsPickerBlock(title: "Bubble Letter Style", namespace: bubbleLetterStyleNamespace, pairID: "bubbleLetterStyle") {
								Picker("Bubble Letter Style", selection: Binding(
									get: { vm.bubbleLetterStyle },
									set: { vm.bubbleLetterStyle = $0 }
									)) {
										ForEach(BubbleLetterStyle.allCases) { option in
											Text(option.label)
												.font(.system(.body, design: option.fontDesign).weight(.bold))
												.tag(option)
										}
									}
								.pickerStyle(.segmented)
							}

							SettingsDescriptionRow("Choose the letter shape that is easiest for you to read in the bubbles and word tray.")

							SettingsPickerBlock(title: "Bubble Text Color", namespace: bubbleTextColorNamespace, pairID: "bubbleTextColor") {
								Picker("Bubble Text Color", selection: Binding(
									get: { vm.bubbleTextColorOption },
									set: { vm.bubbleTextColorOption = $0 }
								)) {
									ForEach(BubbleTextColorOption.allCases) { option in
										Text(option.label).tag(option)
									}
								}
								.pickerStyle(.segmented)
							}

						SettingsDescriptionRow("Pick your preference of light or dark text for the bubbles. Either option will still have colorful bubbles to bop!")

							SettingsPickerBlock(title: "Bubble Color Theme", namespace: bubbleColorThemeNamespace, pairID: "bubbleColorTheme") {
								Picker("Bubble Color Theme", selection: Binding(
									get: { vm.bubbleColorTheme },
									set: { theme in
										vm.bubbleColorTheme = theme
										refocusBubbleColorThemePicker()
									}
								)) {
									ForEach(BubbleColorTheme.options(for: vm.bubbleTextColorOption)) { theme in
										Text(theme.label).tag(theme)
									}
								}
								.pickerStyle(.menu)
								.accessibilityFocused($isBubbleColorThemeFocused)
							}

						SettingsDescriptionRow("Choose a bubble color set that feels good to play with. Every theme keeps the letter contrast strong.")

						BubbleThemePreview(
							textColorOption: vm.bubbleTextColorOption,
							colorTheme: vm.bubbleColorTheme,
							letterStyle: vm.bubbleLetterStyle
						)

						SettingsSectionHeading("Game Volume")

						SettingsSliderRow(title: "Game Volume", value: Binding(
							get: { vm.gameVolume },
							set: { vm.gameVolume = $0 }
						))

						SettingsDescriptionRow("Set how loud the game sounds should be.")

						SettingsPickerBlock(title: "Game Announcements", namespace: gameAnnouncementsNamespace, pairID: "gameAnnouncements") {
							Picker("Game Announcements", selection: Binding(
								get: { vm.gameAnnouncementVerbosity },
								set: { vm.gameAnnouncementVerbosity = $0 }
							)) {
								ForEach(GameAnnouncementVerbosity.allCases) { option in
									Text(option.label).tag(option)
								}
							}
							.pickerStyle(.segmented)
						}

						SettingsDescriptionRow("Controls spoken game announcements for scoring, invalid words, and cleared letters.")

						SettingsSectionHeading("Left-Handed Mode")

						SettingsToggleRow(title: "Left-Handed Mode", isOn: Binding(
							get: { vm.leftHandedMode },
							set: { vm.leftHandedMode = $0 }
						))

						SettingsDescriptionRow("Mirrors gameplay controls for easier left-handed play.")

						SettingsSectionHeading("Game Haptics")

						SettingsToggleRow(title: "Game Haptics", isOn: Binding(
							get: { vm.gameHapticsEnabled },
							set: { vm.gameHapticsEnabled = $0 }
						))

						SettingsDescriptionRow("Feel the Bop more with subtle game event vibrations.")

							SettingsLinkButtonRow(title: "About WordBopper") {
								showingAbout = true
							}
						}
						.frame(width: contentWidth)
						.frame(minHeight: geo.size.height, alignment: .top)
					}
					.frame(width: contentWidth)
					.scrollIndicators(.visible)
				}
				.ignoresSafeArea(edges: .horizontal)
				.background(Color.wbBackground)
				.toolbar {
					ToolbarItem(placement: .topBarTrailing) {
					Button("Close") {
						dismiss()
					}
				}
			}
		}
		.sheet(isPresented: $showingAbout) {
			AboutWordBopperSheet()
				.environment(vm)
				.presentationDragIndicator(.hidden)
			}
			.preferredColorScheme(.dark)
		}

		private func sheetContentWidth(in geo: GeometryProxy) -> CGFloat {
			geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing
		}

	private func refocusDictionaryLanguagePicker() {
		isDictionaryLanguageFocused = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
			isDictionaryLanguageFocused = true
		}
	}

	private func refocusBoppleTimerPicker() {
		isBoppleTimerFocused = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
			isBoppleTimerFocused = true
		}
	}

	private func refocusGridSizePicker() {
		isGridSizeFocused = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
			isGridSizeFocused = true
		}
	}

	private func refocusLetterPositionPicker() {
		isLetterPositionFocused = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
			isLetterPositionFocused = true
		}
	}

	private func refocusBubbleColorThemePicker() {
		isBubbleColorThemeFocused = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
			isBubbleColorThemeFocused = true
		}
	}
}

private struct SettingsLinkButtonRow: View {
	let title: LocalizedStringKey
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			ZStack {
				Color.wbBackground
				Text(title)
					.font(.body.weight(.semibold))
					.foregroundStyle(Color.wbAccent5)
					.underline()
					.multilineTextAlignment(.center)
					.lineLimit(2)
					.padding(.horizontal, 24)
			}
			.frame(maxWidth: .infinity, minHeight: 64)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
	}
}

private struct SettingsToggleRow: View {
	let title: LocalizedStringKey
	@Binding var isOn: Bool

	var body: some View {
		ZStack {
			Color.wbBackground
			Toggle(title, isOn: $isOn)
				.font(.body)
				.foregroundStyle(Color.wbText)
				.tint(Color.wbAccent5)
				.padding(.horizontal, 24)
		}
		.frame(maxWidth: .infinity, minHeight: 64)
		.contentShape(Rectangle())
	}
}

private struct SettingsLanguageToggleRow: View {
	let title: String
	@Binding var isOn: Bool

	var body: some View {
		ZStack {
			Color.wbBackground
			Toggle(title, isOn: $isOn)
				.font(.body)
				.foregroundStyle(Color.wbText)
				.tint(Color.wbAccent5)
				.padding(.horizontal, 24)
		}
		.frame(maxWidth: .infinity, minHeight: 64)
		.contentShape(Rectangle())
	}
}

private struct SettingsSectionHeading: View {
	let title: LocalizedStringKey

	init(_ title: LocalizedStringKey) {
		self.title = title
	}

	var body: some View {
		ZStack(alignment: .leading) {
			Color.wbBackground
			Text(title)
				.font(.body.weight(.semibold))
				.foregroundStyle(Color.wbText)
				.padding(.horizontal, 24)
		}
		.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
		.contentShape(Rectangle())
		.accessibilityAddTraits(.isHeader)
	}
}

private struct SettingsDescriptionRow: View {
	let text: Text
	let fillsRemainingSpace: Bool

	init(_ text: LocalizedStringKey, fillsRemainingSpace: Bool = false) {
		self.text = Text(text)
		self.fillsRemainingSpace = fillsRemainingSpace
	}

	init(verbatim text: String, fillsRemainingSpace: Bool = false) {
		self.text = Text(verbatim: text)
		self.fillsRemainingSpace = fillsRemainingSpace
	}

	var body: some View {
		ZStack(alignment: .leading) {
			Color.wbBackground
			text
				.font(.footnote)
				.foregroundStyle(Color.wbMuted)
				.fixedSize(horizontal: false, vertical: true)
				.padding(.horizontal, 24)
		}
		.frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
		.frame(maxHeight: fillsRemainingSpace ? .infinity : nil, alignment: .topLeading)
		.contentShape(Rectangle())
	}
}

private struct SettingsPickerBlock<Content: View>: View {
	let title: LocalizedStringKey
	let namespace: Namespace.ID
	let pairID: String
	let content: Content

	init(title: LocalizedStringKey, namespace: Namespace.ID, pairID: String, @ViewBuilder content: () -> Content) {
		self.title = title
		self.namespace = namespace
		self.pairID = pairID
		self.content = content()
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			ZStack(alignment: .leading) {
				Color.wbBackground
				Text(title)
					.font(.body.weight(.semibold))
					.foregroundStyle(Color.wbText)
					.padding(.horizontal, 24)
			}
			.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
			.contentShape(Rectangle())
			.accessibilityAddTraits(.isHeader)
			.accessibilityLabeledPair(
				role: .label,
				id: pairID,
				in: namespace
			)

			ZStack {
				Color.wbBackground
				content
					.frame(maxWidth: .infinity)
					.tint(Color.wbAccent5)
					.foregroundStyle(Color.wbAccent5)
					.padding(.horizontal, 24)
			}
			.frame(maxWidth: .infinity, minHeight: 52)
			.contentShape(Rectangle())
			.accessibilityLabeledPair(
				role: .content,
				id: pairID,
				in: namespace
			)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.contentShape(Rectangle())
	}
}

private struct SettingsSliderRow: View {
	let title: LocalizedStringKey
	@Binding var value: Double

	private var percentValue: Int {
		Int((value * 100).rounded())
	}

	var body: some View {
		ZStack {
			Color.wbBackground
			Slider(value: $value, in: 0...1) {
				Text(title)
			}
			.labelsHidden()
			.tint(Color.wbAccent5)
			.padding(.horizontal, 24)
			.accessibilityValue("\(percentValue) percent")
		}
		.frame(maxWidth: .infinity, minHeight: 64)
		.contentShape(Rectangle())
	}
}

private struct BubbleThemePreview: View {
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	@Environment(\.legibilityWeight) private var legibilityWeight
	let textColorOption: BubbleTextColorOption
	let colorTheme: BubbleColorTheme
	let letterStyle: BubbleLetterStyle

	private let sampleLetters = ["B", "O", "P"]

	private var palette: [Color] {
		Color.bubbleFill(for: textColorOption, theme: colorTheme)
	}

	private var textColor: Color {
		Color.bubbleText(for: textColorOption)
	}

	var body: some View {
		ZStack {
			Color.wbBackground
			HStack(spacing: 10) {
				ForEach(Array(sampleLetters.enumerated()), id: \.offset) { index, letter in
					Text(letter)
						.font(.system(size: letterSize, weight: letterWeight, design: letterStyle.fontDesign))
						.foregroundStyle(textColor)
						.lineLimit(1)
						.minimumScaleFactor(0.7)
						.frame(width: bubbleSize, height: bubbleSize)
						.background(palette[index % palette.count])
						.clipShape(Circle())
						.shadow(color: .black.opacity(0.25), radius: 4, y: 3)
				}
			}
			.padding(.vertical, 10)
			.padding(.horizontal, 24)
		}
		.frame(maxWidth: .infinity, minHeight: 76)
		.contentShape(Rectangle())
		.accessibilityHidden(true)
	}

	private var bubbleSize: CGFloat {
		switch dynamicTypeSize {
		case .accessibility3, .accessibility4, .accessibility5:
			58
		case .accessibility1, .accessibility2:
			54
		default:
			50
		}
	}

	private var letterSize: CGFloat {
		bubbleSize * 0.48
	}

	private var letterWeight: Font.Weight {
		legibilityWeight == .bold ? .black : .bold
	}
}

private struct AboutWordBopperSheet: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dismiss) private var dismiss
	@Environment(\.openURL) private var openURL

	@AccessibilityFocusState private var isFeedbackButtonFocused: Bool
	@State private var isShowingMailComposer = false
	@State private var activeMailDraft = WordBopMailDraft.feedback
	@State private var showingAcknowledgments = false

		var body: some View {
			NavigationStack {
				GeometryReader { geo in
					let contentWidth = sheetContentWidth(in: geo)
					ScrollView {
						VStack(spacing: 18) {
							Text("About WordBopper")
								.font(.title2.weight(.black))
								.foregroundStyle(Color.wbText)
								.multilineTextAlignment(.center)
								.fixedSize(horizontal: false, vertical: true)
								.accessibilityAddTraits(.isHeader)
								.frame(maxWidth: .infinity, minHeight: 72)
								.contentShape(Rectangle())

							VStack(alignment: .leading, spacing: 12) {
								Text("Chancey wanted this game to exist and vibe coded the initial version, then passed it to Marco to refine it into the original web game. Marco then decided to rewrite the whole game for iOS, and now here you are bopping away. Thanks for playing!")
									.foregroundStyle(Color.wbText)

								Text("If you enjoy this game, try out our other game on the App Store:")
									.foregroundStyle(Color.wbText)

								Link(destination: URL(string: "https://apps.apple.com/us/app/whack-a-braille/id6760976367")!) {
									HStack(spacing: 12) {
										Image("WhackABrailleIcon")
											.resizable()
											.scaledToFit()
											.frame(width: 44, height: 44)
											.clipShape(RoundedRectangle(cornerRadius: 10))
											.accessibilityHidden(true)

										Text("Whack A Braille!")
											.font(.headline.weight(.black))
											.underline()
											.multilineTextAlignment(.leading)
											.fixedSize(horizontal: false, vertical: true)
									}
									.frame(maxWidth: .infinity)
									.frame(minHeight: 56)
									.contentShape(Rectangle())
								}
								.foregroundStyle(Color.wbAccent5)
								.accessibilityAddTraits(.isLink)
								.accessibilityRemoveTraits(.isButton)
								.accessibilityHint("Opens in the App Store")
							}
							.font(.body)
							.multilineTextAlignment(.leading)
							.padding(.horizontal, 24)
							.frame(maxWidth: .infinity, alignment: .leading)
							.contentShape(Rectangle())

							VStack(spacing: 0) {
								Button {
									sendMail(.feedback)
								} label: {
									Text("Send Game Feedback")
										.frame(maxWidth: .infinity)
										.frame(minHeight: 48)
										.contentShape(Rectangle())
								}
								.accessibilityHint("Opens Mail so you can send feedback about the game.")
								.accessibilityFocused($isFeedbackButtonFocused)

								Button {
									sendMail(.missingWord(language: vm.dictionaryLanguage, mode: vm.gameMode))
								} label: {
									Text("Report Missing Word")
										.frame(maxWidth: .infinity)
										.frame(minHeight: 48)
										.contentShape(Rectangle())
								}
								.accessibilityHint("Opens Mail with the current language and game mode included.")
							}
							.buttonStyle(.borderedProminent)
							.tint(Color.wbAccent5)
							.foregroundStyle(Color.black)
							.frame(maxWidth: .infinity)
							.contentShape(Rectangle())

							VStack(spacing: 8) {
								Link("Privacy Policy", destination: URL(string: "https://marconius.com/wbPrivacy/")!)
									.underline()
									.frame(maxWidth: .infinity, minHeight: 44)
									.contentShape(Rectangle())
									.accessibilityAddTraits(.isLink)
									.accessibilityRemoveTraits(.isButton)
									.accessibilityHint("Opens in external browser")

								Button {
									showingAcknowledgments = true
								} label: {
									Text("Acknowledgments")
									.frame(maxWidth: .infinity)
									.frame(minHeight: 44)
									.contentShape(Rectangle())
								}
								.buttonStyle(.plain)
								.accessibilityHint("Opens word list credits and license acknowledgments.")

								Text("© 2026 Chancey Fleet and Marco Salsiccia, \(versionText)")
									.frame(maxWidth: .infinity, minHeight: 44)
									.contentShape(Rectangle())
							}
							.font(.footnote.weight(.semibold))
							.foregroundStyle(Color.wbMuted)
							.multilineTextAlignment(.center)
						}
						.frame(width: contentWidth, alignment: .top)
						.padding(.top, 36)
						.padding(.bottom, 24)
					}
					.frame(width: contentWidth)
				}
				.ignoresSafeArea(edges: .horizontal)
				.background(Color.wbBackground)
				.toolbar {
					ToolbarItem(placement: .topBarTrailing) {
					Button("Close") {
						dismiss()
					}
				}
			}
		}
		.sheet(isPresented: $isShowingMailComposer, onDismiss: refocusFeedbackButton) {
			MailComposerView(
				recipient: "marco@marconius.com",
				subject: activeMailDraft.subject,
				body: activeMailDraft.body,
				onFinish: { _ in }
			)
		}
		.sheet(isPresented: $showingAcknowledgments) {
			AcknowledgmentsSheet()
				.presentationDragIndicator(.hidden)
		}
		.preferredColorScheme(.dark)
	}

		private func sheetContentWidth(in geo: GeometryProxy) -> CGFloat {
			geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing
		}

	private func sendMail(_ draft: WordBopMailDraft) {
		activeMailDraft = draft
		if MFMailComposeViewController.canSendMail() {
			isShowingMailComposer = true
		} else {
			openMailFallback(for: draft)
		}
	}

	private func openMailFallback(for draft: WordBopMailDraft) {
		if let mailURL = draft.mailURL(recipient: "marco@marconius.com") {
			openURL(mailURL)
		}
		refocusFeedbackButton()
	}

	private func refocusFeedbackButton() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			isFeedbackButtonFocused = true
		}
	}

	private var versionText: String {
		let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
		let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
		return String(localized: "Version \(version) (\(build))", comment: "App version string, e.g. Version 1.0.0 (1)")
	}
}

private struct AcknowledgmentsSheet: View {
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				let contentWidth = sheetContentWidth(in: geo)
				ScrollView {
					VStack(spacing: 0) {
						Text("Acknowledgments")
							.font(.title2.weight(.black))
							.foregroundStyle(Color.wbText)
							.multilineTextAlignment(.center)
							.fixedSize(horizontal: false, vertical: true)
							.accessibilityAddTraits(.isHeader)
							.frame(maxWidth: .infinity, minHeight: 72)
							.contentShape(Rectangle())

						Text("Massive thanks to the following developers and resources for our language word lists.")
							.font(.body)
							.foregroundStyle(Color.wbText)
							.fixedSize(horizontal: false, vertical: true)
							.frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
							.padding(.horizontal, 24)
							.contentShape(Rectangle())

						VStack(spacing: 0) {
							ForEach(LanguageAcknowledgment.all) { acknowledgment in
								LanguageAcknowledgmentDisclosure(acknowledgment: acknowledgment)
							}
						}
						.frame(maxWidth: .infinity)
					}
					.frame(width: contentWidth, alignment: .top)
					.padding(.top, 36)
					.padding(.bottom, 24)
				}
				.frame(width: contentWidth)
			}
			.ignoresSafeArea(edges: .horizontal)
			.background(Color.wbBackground)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Close") {
						dismiss()
					}
				}
			}
		}
		.preferredColorScheme(.dark)
	}

	private func sheetContentWidth(in geo: GeometryProxy) -> CGFloat {
		geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing
	}
}

private struct LanguageAcknowledgmentDisclosure: View {
	let acknowledgment: LanguageAcknowledgment

	var body: some View {
		DisclosureGroup {
			VStack(alignment: .leading, spacing: 12) {
				ForEach(acknowledgment.items) { item in
					switch item {
					case let .text(text):
						AcknowledgmentTextRow(text)
					case let .link(title, url):
						AcknowledgmentLinkRow(title: title, url: url)
					}
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.bottom, 16)
			.contentShape(Rectangle())
		} label: {
			Text(LocalizedStringKey(acknowledgment.language))
				.font(.body.weight(.semibold))
				.foregroundStyle(Color.wbText)
				.frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
				.contentShape(Rectangle())
		}
		.frame(maxWidth: .infinity)
		.padding(.horizontal, 24)
		.tint(Color.wbAccent5)
	}
}

private struct AcknowledgmentTextRow: View {
	let text: String

	init(_ text: String) {
		self.text = text
	}

	var body: some View {
		Text(text)
			.font(.footnote)
			.foregroundStyle(Color.wbMuted)
			.fixedSize(horizontal: false, vertical: true)
			.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
			.multilineTextAlignment(.leading)
			.contentShape(Rectangle())
	}
}

private struct AcknowledgmentLinkRow: View {
	let title: String
	let url: URL

	init(title: String, url: String) {
		self.title = title
		self.url = URL(string: url)!
	}

	var body: some View {
		Link(title, destination: url)
			.font(.footnote.weight(.semibold))
			.foregroundStyle(Color.wbAccent5)
			.underline()
			.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
			.contentShape(Rectangle())
			.accessibilityAddTraits(.isLink)
			.accessibilityRemoveTraits(.isButton)
			.accessibilityHint("Opens in external browser")
	}
}

private struct LanguageAcknowledgment: Identifiable {
	let language: String
	let items: [AcknowledgmentItem]

	var id: String { language }

	static let all: [LanguageAcknowledgment] = [
		LanguageAcknowledgment(
			language: "English",
			items: [
				.text("Word list copyright 2000-2026 by Kevin Atkinson."),
				.text("Permission to use, copy, modify, distribute, and sell any part of the English Speller Database (ESDB, previously known as SCOWLv2), or word lists created from it, is hereby granted without fee, provided that the above copyright notice appears in all copies and that both the above copyright notice and this notice appear in supporting documentation. Kevin Atkinson makes no representations about the suitability of this database for any purpose. It is provided \"as is\" without express or implied warranty."),
				.text("ESDB is derived from many sources, most of which are in the Public Domain. Data from the Corpus of Contemporary American English (COCA) was also used."),
				.text("More information about COCA is available at:"),
				.link("Corpus of Contemporary American English", "https://www.english-corpora.org/coca/"),
				.text("The primary source of words for ESDB comes from 12dicts and ENABLE2K. Both are in the Public Domain, but Alan Beale deserves special credit as the author of 12dicts and a major contributor to ENABLE2K."),
				.text("The English word list also includes words from the Wordnik Wordlist, an open-source word list for game developers."),
				.text("Wordnik Wordlist copyright 2020 Wordnik. The Wordnik Wordlist is made available under the MIT License. Permission is granted, free of charge, to use, copy, modify, merge, publish, distribute, sublicense, and sell copies, provided that the copyright notice and permission notice are included in copies or substantial portions of the software.")
			]
		),
		LanguageAcknowledgment(
			language: "Spanish",
			items: [
				.text("The Spanish word list is derived from Letterpress word lists made available under the Creative Commons CC0 1.0 Universal public domain dedication."),
				.link("Creative Commons CC0 1.0 Universal", "https://creativecommons.org/publicdomain/zero/1.0/")
			]
		),
		LanguageAcknowledgment(
			language: "French",
			items: [
				.text("The French word list is derived from Letterpress word lists made available under the Creative Commons CC0 1.0 Universal public domain dedication."),
				.link("Creative Commons CC0 1.0 Universal", "https://creativecommons.org/publicdomain/zero/1.0/")
			]
		),
		LanguageAcknowledgment(
			language: "German",
			items: [
				.text("The German word list is derived from Letterpress word lists made available under the Creative Commons CC0 1.0 Universal public domain dedication."),
				.link("Creative Commons CC0 1.0 Universal", "https://creativecommons.org/publicdomain/zero/1.0/")
			]
		),
		LanguageAcknowledgment(
			language: "Dutch",
			items: [
				.text("The Dutch word list is derived from the Dutch word list by OpenTaal."),
				.link("OpenTaal", "https://opentaal.org"),
				.text("OpenTaal makes the Dutch language files freely available under the Revised BSD License and/or the Creative Commons Attribution 3.0 Unported License."),
				.link("Revised BSD License", "https://opensource.org/licenses/BSD-3-Clause"),
				.link("Creative Commons Attribution 3.0 Unported License", "https://creativecommons.org/licenses/by/3.0/legalcode.txt"),
				.text("Dutch word list copyright 2020 OpenTaal; 2006-2011 OpenTaal; 2001-2005 Simon Brouwer and others; 1996 Nederlandstalige TeX Gebruikersgroep.")
			]
		),
		LanguageAcknowledgment(
			language: "Italian",
			items: [
				.text("The Italian word list includes words derived from Letterpress word lists made available under the Creative Commons CC0 1.0 Universal public domain dedication."),
				.link("Creative Commons CC0 1.0 Universal", "https://creativecommons.org/publicdomain/zero/1.0/"),
				.text("The Italian word list also includes forms derived from Morph-it!, a free morphological lexicon for the Italian language by Marco Baroni and Eros Zanchetta."),
				.text("Morph-it! is dual-licensed under the Creative Commons Attribution ShareAlike 2.0 License and the GNU Lesser General Public License. Morph-it! copyright 2004-2007 Marco Baroni and Eros Zanchetta."),
				.link("Creative Commons Attribution ShareAlike 2.0 License", "https://creativecommons.org/licenses/by-sa/2.0/"),
				.link("GNU Lesser General Public License", "https://www.gnu.org/licenses/lgpl-3.0.html")
			]
		),
		LanguageAcknowledgment(
			language: "Brazilian Portuguese",
			items: [
				.text("The Brazilian Portuguese word list is derived from the pythonprobr/palavras word list, which is based primarily on the LibreOffice Brazilian Portuguese spelling dictionary and made available under the Mozilla Public License 2.0."),
				.link("pythonprobr/palavras", "https://github.com/pythonprobr/palavras"),
				.link("Mozilla Public License 2.0", "https://www.mozilla.org/MPL/2.0/")
			]
		)
	]
}

private enum AcknowledgmentItem: Identifiable {
	case text(String)
	case link(String, String)

	var id: String {
		switch self {
		case let .text(text):
			"text-\(text)"
		case let .link(title, url):
			"link-\(title)-\(url)"
		}
	}
}

private struct BestGameCard: View {
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	let bestGame: BestGame
	let dailyBopRank: String
	@State private var isExpanded = true

	var body: some View {
		DisclosureGroup(isExpanded: $isExpanded) {
			statsContent
			.transition(.opacity)
		} label: {
			Text("Your best game")
				.font(.headline.weight(.black))
				.foregroundStyle(Color.wbText)
				.frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
				.padding(.horizontal, 14)
				.contentShape(Rectangle())
		}
		.disclosureGroupStyle(.automatic)
		.tint(Color.wbText)
		.background(Color.wbSurface)
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.07)))
		.frame(maxWidth: .infinity)
	}

	private var statsContent: some View {
		VStack(alignment: .leading, spacing: 0) {
			modeSection(
				title: String(localized: "Timed Mode"),
				highestScoreLabel: String(localized: "Highest score"),
				highestScore: bestGame.highestScore,
				longestWord: bestGame.longestWord,
				mostWords: bestGame.mostWords,
				largestChain: bestGame.largestLetterChain
			)

			modeSection(
				title: String(localized: "Bopple Mode", comment: "Best-game section; Bopple is a brand term"),
				highestScoreLabel: String(localized: "Best score"),
				highestScore: bestGame.highestBoppleScore,
				longestWord: bestGame.longestBoppleWord,
				mostWords: bestGame.mostBoppleWords,
				largestChain: nil
			)

			modeSection(
				title: String(localized: "Non-Stop Mode"),
				highestScoreLabel: String(localized: "Best score"),
				highestScore: bestGame.highestNonStopScore,
				longestWord: bestGame.longestNonStopWord,
				mostWords: bestGame.mostNonStopWords,
				largestChain: bestGame.largestNonStopLetterChain
			)

			ForEach(languageModeBestGames) { record in
				languageModeSection(record)
			}

			dailyBopSection
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	private var languageModeBestGames: [LanguageModeBestGame] {
		bestGame.languageModeBestGames.filter { $0.language != .english }.sorted {
			if $0.language.label == $1.language.label {
				return $0.mode.rawValue < $1.mode.rawValue
			}
			return $0.language.label < $1.language.label
		}
	}

	@ViewBuilder
	private func modeSection(
		title: String,
		highestScoreLabel: String,
		highestScore: Int,
		longestWord: String,
		mostWords: Int,
		largestChain: Int?
	) -> some View {
		sectionHeading(title)

		statPair(
			BestStat(label: highestScoreLabel, value: "\(highestScore)"),
			BestStat(label: String(localized: "Longest word"), value: longestWord.isEmpty ? String(localized: "None yet") : longestWord)
		)

		if let largestChain {
			statPair(
				BestStat(label: String(localized: "Most words"), value: "\(mostWords)"),
				BestStat(label: String(localized: "Largest chain"), value: "\(largestChain)")
			)
		} else {
			BestStat(label: String(localized: "Most words"), value: "\(mostWords)")
		}
	}

	@ViewBuilder
	private func languageModeSection(_ record: LanguageModeBestGame) -> some View {
		sectionHeading(record.heading)

		statPair(
			BestStat(label: record.mode == .timed ? String(localized: "Highest score") : String(localized: "Best score"), value: "\(record.highestScore)"),
			BestStat(
				label: String(localized: "Longest word"),
				value: record.longestWord.isEmpty ? String(localized: "None yet") : record.longestWord,
				valueLanguage: record.longestWord.isEmpty ? nil : record.language
			)
		)

		if record.mode == .bopple {
			BestStat(label: String(localized: "Most words"), value: "\(record.mostWords)")
		} else {
			statPair(
				BestStat(label: String(localized: "Most words"), value: "\(record.mostWords)"),
				BestStat(label: String(localized: "Largest chain"), value: "\(record.largestLetterChain)")
			)
		}
	}

	private var dailyBopSection: some View {
		Group {
			sectionHeading(String(localized: "Daily Bop"))

			statPair(
				BestStat(label: String(localized: "Rank"), value: dailyBopRank),
				BestStat(label: String(localized: "Daily Bops found"), value: "\(totalDailyBopsFound)")
			)

			if bestGame.bopHuntRankPoints > 0 {
				BestStat(label: String(localized: "BopQuest points"), value: "\(bestGame.bopHuntRankPoints)")
			}

			ForEach(dailyBopLanguageStats) { stat in
				BestStat(
					label: String(localized: "\(stat.language.label) Daily Bops", comment: "Daily Bop language count label"),
					value: "\(stat.foundCount)"
				)
			}
		}
	}

	private var totalDailyBopsFound: Int {
		bestGame.dailyBopLanguageStats.reduce(0) { $0 + $1.foundCount }
	}

	private var dailyBopLanguageStats: [DailyBopLanguageStat] {
		bestGame.dailyBopLanguageStats
			.filter { $0.foundCount > 0 }
			.sorted { $0.language.label < $1.language.label }
	}

	private func sectionHeading(_ title: String) -> some View {
		Text(title)
			.font(.caption.weight(.bold))
			.foregroundStyle(Color.wbMuted)
			.frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
			.padding(.horizontal, 14)
			.contentShape(Rectangle())
			.accessibilityElement(children: .ignore)
			.accessibilityLabel(title)
			.accessibilityAddTraits(.isHeader)
	}

	@ViewBuilder
	private func statPair<First: View, Second: View>(_ first: First, _ second: Second) -> some View {
		if dynamicTypeSize.isAccessibilitySize {
			VStack(spacing: 0) {
				first
				second
			}
		} else {
			HStack(spacing: 0) {
				first
				second
			}
		}
	}
}

private struct BestStat: View {
	let label: String
	let value: String
	var valueLanguage: DictionaryLanguage?

	var body: some View {
		VStack(alignment: .leading, spacing: 2) {
			Text(verbatim: label)
				.font(.caption.weight(.bold))
				.foregroundStyle(Color.wbMuted)
			Text(spokenValue)
				.font(.system(.body, design: .monospaced).weight(.bold))
				.foregroundStyle(Color.wbText)
				.fixedSize(horizontal: false, vertical: true)
		}
		.padding(.horizontal, 14)
		.padding(.vertical, 8)
		.frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
		.contentShape(Rectangle())
		.accessibilityElement(children: .ignore)
		.accessibilityLabel(Text(spokenAccessibilityLabel))
	}

	private var spokenValue: AttributedString {
		var text = AttributedString(value)
		if let valueLanguage {
			text.languageIdentifier = valueLanguage.speechLanguage
		}
		return text
	}

	private var spokenAccessibilityLabel: AttributedString {
		var text = AttributedString(label + ": ")
		text += spokenValue
		return text
	}
}
