import SwiftUI

struct ResultsView: View {
	@Environment(GameViewModel.self) private var vm
	let titleFocus: AccessibilityFocusState<ScreenTitleFocus?>.Binding

	var body: some View {
		ScrollView {
			VStack(spacing: 16) {
				Text("Round Complete")
					.font(.title2.weight(.black))
					.foregroundStyle(Color.wbText)
					.accessibilityAddTraits(.isHeader)
					.accessibilityFocused(titleFocus, equals: .results)

				VStack(spacing: 2) {
					Text("\(vm.score)")
						.font(.system(.largeTitle, design: .monospaced).weight(.bold))
						.foregroundStyle(
							LinearGradient(colors: [.wbAccent1, .wbAccent3],
										   startPoint: .topLeading, endPoint: .bottomTrailing)
						)
					Text("points")
						.font(.body)
						.foregroundStyle(Color.wbMuted)
				}
				.accessibilityElement(children: .ignore)
				.accessibilityLabel("\(vm.score) points")

				HStack(spacing: 24) {
					ResultStat(value: "\(vm.wordCount)",      label: "Words made",    color: .wbAccent4)
					ResultStat(value: "\(vm.totalLettersUsed)", label: "Letters used", color: .wbAccent5)
					ResultStat(value: averageLength,          label: "Average length", color: .wbAccent1)
				}
				.frame(maxWidth: .infinity)

				VStack(alignment: .leading, spacing: 10) {
					Text("Your words")
						.font(.headline.weight(.black))
						.foregroundStyle(Color.wbText)
						.accessibilityAddTraits(.isHeader)

					if vm.madeWords.isEmpty {
						Text("No words made — try again!")
							.font(.callout)
							.foregroundStyle(Color.wbMuted)
						} else {
							LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
								ForEach(Array(vm.madeWords.enumerated()), id: \.offset) { _, word in
									Text(word)
										.font(.system(.callout, design: .monospaced).weight(.bold))
										.foregroundStyle(Color.wbText)
										.padding(.vertical, 5)
										.padding(.horizontal, 10)
									.frame(maxWidth: .infinity)
									.background(Color.wbPanel)
									.clipShape(RoundedRectangle(cornerRadius: 12))
									.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08)))
							}
						}
					}
				}
				.padding(16)
				.background(Color.wbSurface)
				.clipShape(RoundedRectangle(cornerRadius: 20))
				.overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07)))
				.frame(maxWidth: .infinity)

				Button("Play Again") { vm.startGame() }
					.font(.title3.weight(.black))
					.foregroundStyle(Color.black)
					.frame(maxWidth: .infinity)
					.padding(.vertical, 16)
					.background(
						LinearGradient(colors: [.wbAccent1, .wbAccent2],
									   startPoint: .topLeading, endPoint: .bottomTrailing)
					)
					.clipShape(Capsule())

				Button("Home") { vm.goHome() }
					.font(.subheadline.weight(.bold))
					.foregroundStyle(Color.wbMuted)
					.frame(maxWidth: .infinity)
					.padding(.vertical, 10)
					.background(Color.wbPanel)
					.clipShape(Capsule())
					.overlay(Capsule().stroke(Color.white.opacity(0.08)))
			}
			.padding(.horizontal, 20)
			.padding(.vertical, 24)
		}
	}

	private var averageLength: String {
		guard vm.wordCount > 0 else { return "—" }
		return String(format: "%.1f", Double(vm.totalLettersUsed) / Double(vm.wordCount))
	}
}

private struct ResultStat: View {
	let value: String
	let label: String
	let color: Color

	var body: some View {
		VStack(spacing: 2) {
			Text(value)
				.font(.system(.title, design: .monospaced).weight(.bold))
				.foregroundStyle(color)
			Text(label)
				.font(.caption.weight(.bold))
				.foregroundStyle(Color.wbMuted)
				.multilineTextAlignment(.center)
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("\(label): \(value)")
	}
}
