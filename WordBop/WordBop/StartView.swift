import MessageUI
import SwiftUI
import UIKit

struct StartView: View {
	@Environment(GameViewModel.self) private var vm
	@State private var showingInstructions = false
	@State private var showingGameSettings = false

	var body: some View {
		GeometryReader { geo in
			VStack(spacing: 0) {
				Text("WordBopper")
					.font(.largeTitle.weight(.black))
					.foregroundStyle(Color.wbText)
					.accessibilityAddTraits(.isHeader)
					.accessibilitySortPriority(100)
					.frame(maxWidth: .infinity, minHeight: 72)
					.contentShape(Rectangle())

				startScreenTopRow

				startGameButton
					.layoutPriority(3)

				BestGameCard(bestGame: vm.bestGame)
					.layoutPriority(2)
			}
			.frame(maxWidth: .infinity)
			.frame(minHeight: geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom, alignment: .top)
			.padding(.horizontal, 20)
			.padding(.top, 24)
			.padding(.bottom, geo.safeAreaInsets.bottom)
		}
		.onAppear {
			UIAccessibility.post(notification: .screenChanged, argument: "WordBopper")
		}
		.sheet(isPresented: $showingInstructions) {
			InstructionsSheet()
				.presentationDragIndicator(.hidden)
		}
		.sheet(isPresented: $showingGameSettings) {
			GameSettingsSheet()
				.presentationDragIndicator(.hidden)
		}
	}

	private var startScreenTopRow: some View {
		HStack(spacing: 0) {
			howToPlayButton
			gameSettingsButton
		}
		.frame(maxWidth: .infinity)
		.frame(minHeight: 58)
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
					.frame(maxWidth: .infinity)
			}
			.frame(maxWidth: .infinity)
			.frame(minHeight: 132)
			.clipShape(RoundedRectangle(cornerRadius: 28))
			.contentShape(Rectangle())
		}
		.keyboardShortcut(.defaultAction)
	}

	private var howToPlayButton: some View {
		Button {
			showingInstructions = true
		} label: {
			Text("How to Play")
				.font(.footnote.weight(.semibold))
				.foregroundStyle(Color.wbAccent5)
				.underline()
				.frame(maxWidth: .infinity)
				.frame(minHeight: 58)
				.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
	}

	private var gameSettingsButton: some View {
		Button {
			showingGameSettings = true
		} label: {
			Text("Game Settings")
				.font(.footnote.weight(.semibold))
				.foregroundStyle(Color.wbAccent5)
				.underline()
				.frame(maxWidth: .infinity)
				.frame(minHeight: 58)
				.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
	}

}

private struct InstructionsSheet: View {
	@Environment(\.dismiss) private var dismiss

	private let instructions = [
		"Tap letter bubbles anywhere on the 5 by 5 grid to build words.",
		"Build words from letters that are next to each other to earn a bonus. Do this three times in a row to activate a timed 3x score multiplier.",
		"Hit Make Word to score. Hit Clear Letters to deselect all selected letters and get 15 seconds added to the timer in Timed mode.",
		"Timed mode has 2 minutes on the clock, and letters change as you use them. Non-Stop mode turns off the timer and lets you Bop til you drop!",
		"For VoiceOver users, use Vertical Navigation in your rotor or explore by touch to quickly navigate the grid."
	]
	private let boppleInstructions = [
		"Words must be made up of letters that are next to each other in the grid.",
		"Letters stay in place after you make words.",
		"3 or 4 letter words score 1 point, 5 letters score 2, 6 letters score 3, 7 letters score 5, and 8 or more letters score 11.",
		"Play together with friends at the same time to see who can Bopple the best! All on their own devices, of course."
	]

	var body: some View {
		NavigationStack {
			GeometryReader { geo in
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
					}
					.frame(maxWidth: .infinity)
					.frame(minHeight: geo.size.height, alignment: .top)
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
	@Namespace private var bubbleTextColorNamespace
	@Namespace private var gameAnnouncementsNamespace
	@State private var showingAbout = false

	var body: some View {
		NavigationStack {
			GeometryReader { geo in
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

						SettingsDescriptionRow(vm.gameMode.settingsBlurb)

						SettingsToggleRow(title: "Speak Letter Positions", isOn: Binding(
							get: { vm.speakLetterPositions },
							set: { vm.speakLetterPositions = $0 }
						))

						SettingsDescriptionRow("Adds Column and Row locations to the letters, like \"B, 2 5\" for Column 2, Row 5.")

						SettingsToggleRow(title: "Speak Letter Phonetics", isOn: Binding(
							get: { vm.speakLetterPhonetics },
							set: { vm.speakLetterPhonetics = $0 }
						))

						SettingsDescriptionRow("Adds the phonetic version of the bubble letters to the announcement, such as \"a, Alpha.\"")

						SettingsToggleRow(title: "BopAway", isOn: Binding(
							get: { vm.bopAway },
							set: { vm.bopAway = $0 }
						))

						SettingsDescriptionRow("For an extra challenge, BopAway will instantly replace a deselected letter with a new letter. If you clear selected letters, all of those letters will be replaced. Bop wisely!")

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

						SettingsLinkButtonRow(title: "About WordBopper") {
							showingAbout = true
						}
					}
					.frame(maxWidth: .infinity)
					.frame(minHeight: geo.size.height, alignment: .top)
				}
				.scrollIndicators(.visible)
			}
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
				.presentationDragIndicator(.hidden)
		}
		.preferredColorScheme(.dark)
	}
}

private struct SettingsLinkButtonRow: View {
	let title: String
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Text(title)
				.font(.body.weight(.semibold))
				.foregroundStyle(Color.wbAccent5)
				.underline()
				.frame(maxWidth: .infinity, minHeight: 64)
				.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.background(Color.wbBackground)
	}
}

private struct SettingsToggleRow: View {
	let title: String
	@Binding var isOn: Bool

	var body: some View {
		Toggle(title, isOn: $isOn)
			.font(.body)
			.foregroundStyle(Color.wbText)
			.padding(.horizontal, 24)
			.frame(maxWidth: .infinity, minHeight: 64)
			.contentShape(Rectangle())
			.background(Color.wbBackground)
	}
}

private struct SettingsDescriptionRow: View {
	let text: String
	let fillsRemainingSpace: Bool

	init(_ text: String, fillsRemainingSpace: Bool = false) {
		self.text = text
		self.fillsRemainingSpace = fillsRemainingSpace
	}

	var body: some View {
		Text(text)
			.font(.footnote)
			.foregroundStyle(Color.wbMuted)
			.fixedSize(horizontal: false, vertical: true)
			.frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
			.frame(maxHeight: fillsRemainingSpace ? .infinity : nil, alignment: .topLeading)
			.padding(.horizontal, 24)
			.padding(.vertical, 10)
			.contentShape(Rectangle())
			.background(Color.wbBackground)
	}
}

private struct SettingsPickerBlock<Content: View>: View {
	let title: String
	let namespace: Namespace.ID
	let pairID: String
	let content: Content

	init(title: String, namespace: Namespace.ID, pairID: String, @ViewBuilder content: () -> Content) {
		self.title = title
		self.namespace = namespace
		self.pairID = pairID
		self.content = content()
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Text(title)
				.font(.body)
				.foregroundStyle(Color.wbText)
				.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
				.contentShape(Rectangle())
				.accessibilityLabeledPair(
					role: .label,
					id: pairID,
					in: namespace
				)

			content
				.frame(maxWidth: .infinity)
				.frame(minHeight: 44)
				.contentShape(Rectangle())
				.accessibilityLabeledPair(
					role: .content,
					id: pairID,
					in: namespace
				)
		}
		.padding(.horizontal, 24)
		.padding(.vertical, 10)
		.frame(maxWidth: .infinity, alignment: .leading)
		.contentShape(Rectangle())
		.background(Color.wbBackground)
	}
}

private struct AboutWordBopperSheet: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.openURL) private var openURL

	@AccessibilityFocusState private var isFeedbackButtonFocused: Bool
	@State private var isShowingMailComposer = false

	var body: some View {
		NavigationStack {
			VStack(spacing: 18) {
				Text("About WordBopper")
					.font(.title2.weight(.black))
					.foregroundStyle(Color.wbText)
					.accessibilityAddTraits(.isHeader)

				Text("By Chancey Fleet and Marco Salsiccia")
					.font(.body)
					.foregroundStyle(Color.wbText)
					.multilineTextAlignment(.center)

				Button("Send Game Feedback") {
					if MFMailComposeViewController.canSendMail() {
						isShowingMailComposer = true
					} else {
						openMailFallback()
					}
				}
				.accessibilityHint("Opens Mail so you can send feedback about the game.")
				.accessibilityFocused($isFeedbackButtonFocused)

				VStack(spacing: 8) {
					Link("Privacy Policy", destination: URL(string: "https://marconius.com/wbPrivacy/")!)
						.underline()
						.accessibilityAddTraits(.isLink)
						.accessibilityRemoveTraits(.isButton)
						.accessibilityHint("Opens in external browser")

					Text("© 2026, \(versionText)")
				}
				.font(.footnote.weight(.semibold))
				.foregroundStyle(Color.wbMuted)
				.multilineTextAlignment(.center)

				Spacer(minLength: 0)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
			.padding(.horizontal, 24)
			.padding(.top, 36)
			.padding(.bottom, 24)
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
				subject: "WordBoppper iOS Feedback",
				body: nil,
				onFinish: { _ in }
			)
		}
		.preferredColorScheme(.dark)
	}

	private func openMailFallback() {
		let subject =
			"WordBoppper iOS Feedback"
			.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

		let mailURL =
			URL(string: "mailto:marco@marconius.com?subject=\(subject)")!

		openURL(mailURL)
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
		return "Version \(version) (\(build))"
	}
}

private struct BestGameCard: View {
	let bestGame: BestGame
	@State private var isExpanded = true

	var body: some View {
		VStack(spacing: 0) {
			Button {
				isExpanded.toggle()
			} label: {
				HStack {
					Text("Your best game")
						.font(.headline.weight(.black))
					Spacer()
					Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
						.font(.caption.weight(.bold))
						.accessibilityHidden(true)
				}
				.foregroundStyle(Color.wbText)
				.frame(maxWidth: .infinity)
				.frame(minHeight: 52)
				.padding(.horizontal, 14)
				.contentShape(Rectangle())
			}
			.buttonStyle(.plain)
			.accessibilityAddTraits(.isHeader)
			.accessibilityValue(isExpanded ? "Expanded" : "Collapsed")

			if isExpanded {
				VStack(alignment: .leading, spacing: 0) {
					Text("Timed Mode")
						.font(.caption.weight(.bold))
						.foregroundStyle(Color.wbMuted)
						.frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
						.padding(.horizontal, 14)
						.accessibilityAddTraits(.isHeader)
						.accessibilityElement(children: .combine)

					HStack(spacing: 0) {
						BestStat(label: "Highest score", value: "\(bestGame.highestScore)")
						BestStat(label: "Longest word", value: bestGame.longestWord.isEmpty ? "None yet" : bestGame.longestWord)
					}

					HStack(spacing: 0) {
						BestStat(label: "Most words", value: "\(bestGame.mostWords)")
						BestStat(label: "Largest chain", value: "\(bestGame.largestLetterChain)")
					}

					Text("Bopple Mode")
						.font(.caption.weight(.bold))
						.foregroundStyle(Color.wbMuted)
						.frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
						.padding(.horizontal, 14)
						.accessibilityAddTraits(.isHeader)
						.accessibilityElement(children: .combine)

					HStack(spacing: 0) {
						BestStat(label: "Best score", value: "\(bestGame.highestBoppleScore)")
						BestStat(label: "Longest word", value: bestGame.longestBoppleWord.isEmpty ? "None yet" : bestGame.longestBoppleWord)
					}

					BestStat(label: "Most words", value: "\(bestGame.mostBoppleWords)")

					Text("Non-Stop Mode")
						.font(.caption.weight(.bold))
						.foregroundStyle(Color.wbMuted)
						.frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
						.padding(.horizontal, 14)
						.accessibilityAddTraits(.isHeader)
						.accessibilityElement(children: .combine)

					HStack(spacing: 0) {
						BestStat(label: "Best score", value: "\(bestGame.highestNonStopScore)")
						BestStat(label: "Longest word", value: bestGame.longestNonStopWord.isEmpty ? "None yet" : bestGame.longestNonStopWord)
					}

					HStack(spacing: 0) {
						BestStat(label: "Most words", value: "\(bestGame.mostNonStopWords)")
						BestStat(label: "Largest chain", value: "\(bestGame.largestNonStopLetterChain)")
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.transition(.opacity)
			}
		}
		.background(Color.wbSurface)
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.07)))
		.frame(maxWidth: .infinity)
	}
}

private struct BestStat: View {
	let label: String
	let value: String

	var body: some View {
		VStack(alignment: .leading, spacing: 2) {
			Text(label)
				.font(.caption.weight(.bold))
				.foregroundStyle(Color.wbMuted)
			Text(value)
				.font(.system(.body, design: .monospaced).weight(.bold))
				.foregroundStyle(Color.wbText)
		}
		.padding(.horizontal, 14)
		.padding(.vertical, 8)
		.frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
		.contentShape(Rectangle())
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("\(label): \(value)")
	}
}
