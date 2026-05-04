import SwiftUI

struct StartView: View {
	@Environment(GameViewModel.self) private var vm
	let titleFocus: AccessibilityFocusState<ScreenTitleFocus?>.Binding

	var body: some View {
		ScrollView {
			VStack(spacing: 20) {
				Text("WordBop")
					.font(.largeTitle.weight(.black))
					.foregroundStyle(Color.wbText)
					.accessibilityAddTraits(.isHeader)
					.accessibilityFocused(titleFocus, equals: .home)
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

				BestGameCard(bestGame: vm.bestGame)

				VStack(spacing: 6) {
					Text("© 2026 Chancey Fleet and Marco Salsiccia")
						.font(.footnote)
						.foregroundStyle(Color.wbMuted)
						.multilineTextAlignment(.center)
						.frame(maxWidth: .infinity)

					Link("Privacy Policy", destination: URL(string: "https://marconius.com/wbPrivacy/")!)
						.font(.footnote.weight(.semibold))
						.foregroundStyle(Color.wbAccent5)
				}
				.padding(.top, 4)
			}
			.padding(.horizontal, 20)
			.padding(.vertical, 24)
		}
		.onAppear {
			titleFocus.wrappedValue = .home
		}
	}
}

private struct BestGameCard: View {
	let bestGame: BestGame

	var body: some View {
		VStack(spacing: 10) {
			Text("Your best game")
				.font(.headline.weight(.black))
				.foregroundStyle(Color.wbText)
				.accessibilityAddTraits(.isHeader)

			LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
				BestStat(label: "Highest score",  value: "\(bestGame.highestScore)")
				BestStat(label: "Longest word",   value: bestGame.longestWord.isEmpty ? "None yet" : bestGame.longestWord)
				BestStat(label: "Most words",     value: "\(bestGame.mostWords)")
				BestStat(label: "Largest chain",  value: "\(bestGame.largestLetterChain)")
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
