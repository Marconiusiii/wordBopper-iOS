import SwiftUI

struct ResultsView: View {
	@Environment(GameViewModel.self) private var vm

	var body: some View {
		ScrollView {
			VStack(spacing: 16) {
				Text("Round Complete")
					.font(.system(size: 22, weight: .black))
					.foregroundStyle(Color.wbText)
					.accessibilityAddTraits(.isHeader)

				VStack(spacing: 2) {
					Text("\(vm.score)")
						.font(.system(size: 64, weight: .bold, design: .monospaced))
						.foregroundStyle(
							LinearGradient(colors: [.wbAccent1, .wbAccent3],
										   startPoint: .topLeading, endPoint: .bottomTrailing)
						)
					Text("points")
						.font(.system(size: 16))
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
						.font(.system(size: 16, weight: .black))
						.foregroundStyle(Color.wbText)
						.accessibilityAddTraits(.isHeader)

					if vm.madeWords.isEmpty {
						Text("No words made — try again!")
							.font(.system(size: 14))
							.foregroundStyle(Color.wbMuted)
					} else {
						LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
							ForEach(Array(vm.madeWords.enumerated()), id: \.offset) { _, word in
								Text(word)
									.font(.system(size: 14, weight: .bold, design: .monospaced))
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
					.font(.system(size: 20, weight: .black))
					.foregroundStyle(Color.black)
					.frame(maxWidth: .infinity)
					.padding(.vertical, 16)
					.background(
						LinearGradient(colors: [.wbAccent1, .wbAccent2],
									   startPoint: .topLeading, endPoint: .bottomTrailing)
					)
					.clipShape(Capsule())

				Button("Home") { vm.goHome() }
					.font(.system(size: 14, weight: .bold))
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
				.font(.system(size: 32, weight: .bold, design: .monospaced))
				.foregroundStyle(color)
			Text(label)
				.font(.system(size: 11, weight: .bold))
				.foregroundStyle(Color.wbMuted)
				.multilineTextAlignment(.center)
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("\(label): \(value)")
	}
}
