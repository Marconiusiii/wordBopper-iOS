import SwiftUI
import UIKit

struct StartView: View {
	@Environment(GameViewModel.self) private var vm
	@State private var showingAbout = false
	@State private var showingGameSettings = false

	var body: some View {
		GeometryReader { geo in
			ScrollView {
				VStack(spacing: 20) {
					Text("WordBopper")
						.font(.largeTitle.weight(.black))
						.foregroundStyle(Color.wbText)
						.accessibilityAddTraits(.isHeader)
						.accessibilitySortPriority(100)

					VStack(alignment: .leading, spacing: 6) {
						let instructions = [
							"Tap letter bubbles anywhere on the 5 by 5 grid to build words.",
							"If you build a word with connected letters, you get a bonus.",
							"Make three connected words in a row to activate a timed 3 times bonus.",
							"Hit Make Word to score.",
							"Used letters are replaced instantly.",
							"2 minutes on the clock. Go!"
						]
						ForEach(instructions, id: \.self) { item in
							HStack(alignment: .top, spacing: 8) {
								Text("•")
									.foregroundStyle(Color.wbAccent5)
									.accessibilityHidden(true)
								Text(item)
									.font(.body)
									.foregroundStyle(Color.wbText)
									.fixedSize(horizontal: false, vertical: true)
							}
						}
					}
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.horizontal, 4)

					gameSettingsButton

					Button {
						vm.startGame()
					} label: {
						Text("Start Game")
							.font(.title3.weight(.black))
							.foregroundStyle(Color.black)
							.frame(maxWidth: .infinity)
							.padding(.vertical, 16)
							.background(
								LinearGradient(colors: [.wbAccent1, .wbAccent2],
											   startPoint: .topLeading, endPoint: .bottomTrailing)
							)
							.clipShape(Capsule())
					}
					.keyboardShortcut(.defaultAction)

					BestGameCard(bestGame: vm.bestGame)

					aboutButton
				}
				.frame(maxWidth: .infinity)
				.frame(minHeight: geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom, alignment: .top)
				.padding(.horizontal, 20)
				.padding(.top, 24)
			}
		}
		.onAppear {
			UIAccessibility.post(notification: .screenChanged, argument: "WordBopper")
		}
		.sheet(isPresented: $showingAbout) {
			AboutWordBopperSheet()
				.presentationDragIndicator(.hidden)
		}
		.sheet(isPresented: $showingGameSettings) {
			GameSettingsSheet()
				.presentationDragIndicator(.hidden)
		}
	}

	private var gameSettingsButton: some View {
		Button {
			showingGameSettings = true
		} label: {
			Text("Game Settings")
				.font(.footnote.weight(.semibold))
				.foregroundStyle(Color.wbAccent5)
				.underline()
				.padding(.vertical, 2)
		}
		.buttonStyle(.plain)
	}

	private var aboutButton: some View {
		Button {
			showingAbout = true
		} label: {
			VStack(spacing: 0) {
				Spacer(minLength: 0)
				Text("About WordBopper")
					.font(.footnote.weight(.semibold))
					.foregroundStyle(Color.wbAccent5)
					.underline()
					.padding(.bottom, 24)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.contentShape(Rectangle())
	}
}

private struct GameSettingsSheet: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack {
			VStack(spacing: 18) {
				Text("Game Settings")
					.font(.title2.weight(.black))
					.foregroundStyle(Color.wbText)
					.accessibilityAddTraits(.isHeader)

				Toggle("Non-Stop Mode", isOn: Binding(
					get: { vm.nonStopMode },
					set: { vm.nonStopMode = $0 }
				))
					.font(.body)
					.foregroundStyle(Color.wbText)

				Text("Bop to the Top! Non-Stop mode takes away the game timer, so bop as many letters and make as many words as you want!")
					.font(.footnote)
					.foregroundStyle(Color.wbMuted)
					.frame(maxWidth: .infinity, alignment: .leading)
					.fixedSize(horizontal: false, vertical: true)

				Toggle("Speak Letter Positions", isOn: Binding(
					get: { vm.speakLetterPositions },
					set: { vm.speakLetterPositions = $0 }
				))
					.font(.body)
					.foregroundStyle(Color.wbText)

				Text("Adds Column and Row locations to the letters, like \"B, 2 5\" for Column 2, Row 5.")
					.font(.footnote)
					.foregroundStyle(Color.wbMuted)
					.frame(maxWidth: .infinity, alignment: .leading)
					.fixedSize(horizontal: false, vertical: true)

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
		.preferredColorScheme(.dark)
	}
}

private struct AboutWordBopperSheet: View {
	@Environment(\.dismiss) private var dismiss

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

				VStack(spacing: 8) {
					Text("© 2026, \(versionText)")
					Link("Privacy Policy", destination: URL(string: "https://marconius.com/wbPrivacy/")!)
						.underline()
						.accessibilityAddTraits(.isLink)
						.accessibilityRemoveTraits(.isButton)
						.accessibilityHint("Opens in external browser")
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
		.preferredColorScheme(.dark)
	}

	private var versionText: String {
		let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
		let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
		return "Version \(version) (\(build))"
	}
}

private struct BestGameCard: View {
	let bestGame: BestGame
	@State private var isExpanded = false

	var body: some View {
		VStack(spacing: 10) {
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
			}
			.buttonStyle(.plain)
			.accessibilityAddTraits(.isHeader)
			.accessibilityValue(isExpanded ? "Expanded" : "Collapsed")

			if isExpanded {
				VStack(alignment: .leading, spacing: 14) {
					Text("Timed")
						.font(.caption.weight(.bold))
						.foregroundStyle(Color.wbMuted)
						.accessibilityAddTraits(.isHeader)

					HStack(spacing: 10) {
						BestStat(label: "Highest score", value: "\(bestGame.highestScore)")
						BestStat(label: "Longest word", value: bestGame.longestWord.isEmpty ? "None yet" : bestGame.longestWord)
					}

					HStack(spacing: 10) {
						BestStat(label: "Most words", value: "\(bestGame.mostWords)")
						BestStat(label: "Largest chain", value: "\(bestGame.largestLetterChain)")
					}

					Text("Non-Stop")
						.font(.caption.weight(.bold))
						.foregroundStyle(Color.wbMuted)
						.accessibilityAddTraits(.isHeader)

					HStack(spacing: 10) {
						BestStat(label: "Best score", value: "\(bestGame.highestNonStopScore)")
						BestStat(label: "Longest word", value: bestGame.longestNonStopWord.isEmpty ? "None yet" : bestGame.longestNonStopWord)
					}

					HStack(spacing: 10) {
						BestStat(label: "Most words", value: "\(bestGame.mostNonStopWords)")
						BestStat(label: "Largest chain", value: "\(bestGame.largestNonStopLetterChain)")
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.transition(.opacity)
			}
		}
		.padding(14)
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
		.frame(maxWidth: .infinity, alignment: .leading)
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("\(label): \(value)")
	}
}
