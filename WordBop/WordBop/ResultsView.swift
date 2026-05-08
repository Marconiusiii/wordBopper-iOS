import SwiftUI
import UIKit

struct ResultsView: View {
	@Environment(GameViewModel.self) private var vm

	var body: some View {
		GeometryReader { geo in
			VStack(spacing: 0) {
				ScrollView {
					VStack(spacing: 16) {
						Text("Round Complete")
							.font(.title2.weight(.black))
							.foregroundStyle(Color.wbText)
							.accessibilityAddTraits(.isHeader)
							.accessibilitySortPriority(100)

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

						VStack(spacing: 10) {
							HStack(spacing: 16) {
								ResultStat(value: "\(vm.wordCount)", label: "Words made", color: .wbAccent4)
								ResultStat(value: "\(vm.totalLettersUsed)", label: "Letters used", color: .wbAccent5)
							}

							HStack(spacing: 16) {
								ResultStat(value: averageLength, label: "Average length", color: .wbAccent1)
								ResultStat(value: longestWord, label: "Longest word", color: .wbAccent3)
							}
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
								VStack(spacing: 8) {
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
											.accessibilityElement(children: .ignore)
											.accessibilityLabel(word)
									}
								}
							}
						}
						.padding(16)
						.background(Color.wbSurface)
						.clipShape(RoundedRectangle(cornerRadius: 20))
						.overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07)))
						.frame(maxWidth: .infinity)
					}
					.padding(.horizontal, 20)
					.padding(.vertical, 24)
				}

				ResultsActionBar(bottomInset: geo.safeAreaInsets.bottom)
			}
		}
		.onAppear {
			UIAccessibility.post(notification: .screenChanged, argument: "Round Complete")
		}
	}

	private var averageLength: String {
		guard vm.wordCount > 0 else { return "—" }
		return String(format: "%.1f", Double(vm.totalLettersUsed) / Double(vm.wordCount))
	}

	private var longestWord: String {
		vm.madeWords.max { $0.count < $1.count } ?? "—"
	}
}

private struct ResultsActionBar: View {
	@Environment(GameViewModel.self) private var vm
	let bottomInset: CGFloat

	var body: some View {
		HStack(spacing: 0) {
			Button {
				vm.startGame()
			} label: {
				BottomButtonZone(bottomInset: bottomInset) {
					Text("Play Again")
						.font(.title3.weight(.black))
						.foregroundStyle(Color.black)
						.frame(maxWidth: .infinity)
						.frame(minHeight: 52)
						.padding(.horizontal, 6)
						.background(
							LinearGradient(colors: [.wbAccent1, .wbAccent2],
										   startPoint: .topLeading, endPoint: .bottomTrailing)
						)
						.clipShape(Capsule())
				}
			}
			.keyboardShortcut(.defaultAction)

			Button {
				vm.goHome()
			} label: {
				BottomButtonZone(bottomInset: bottomInset) {
					Text("Return Home")
						.font(.title3.weight(.bold))
						.foregroundStyle(Color.wbMuted)
						.frame(maxWidth: .infinity)
						.frame(minHeight: 52)
						.padding(.horizontal, 6)
						.background(Color.wbPanel)
						.clipShape(Capsule())
						.overlay(Capsule().stroke(Color.white.opacity(0.08)))
				}
			}
			.keyboardShortcut(.cancelAction)
		}
		.frame(height: 68 + bottomInset)
		.background(Color.wbBackground)
	}
}

private struct BottomButtonZone<Content: View>: View {
	let bottomInset: CGFloat
	let content: Content

	init(bottomInset: CGFloat, @ViewBuilder content: () -> Content) {
		self.bottomInset = bottomInset
		self.content = content()
	}

	var body: some View {
		ZStack(alignment: .bottom) {
			Color.clear
			content
				.padding(.horizontal, 10)
				.padding(.bottom, bottomInset + 8)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.contentShape(Rectangle())
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
