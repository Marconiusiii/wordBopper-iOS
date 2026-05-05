import SwiftUI
import UIKit

struct GameView: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	var body: some View {
		GeometryReader { geo in
			let safeHeight = geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom
			let cellSize = cellSize(in: geo.size.width, height: safeHeight)

			VStack(spacing: 0) {
				Text(vm.gameplayHeading)
					.font(.headline.weight(.black))
					.foregroundStyle(Color.wbText)
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.horizontal, 16)
					.padding(.top, 8)
					.padding(.bottom, 6)
					.background(Color.wbSurface)
					.accessibilityAddTraits(.isHeader)
					.accessibilitySortPriority(100)

				GameHeaderBar()
				ChainMeterBar()
				WordTrayBar()

				BubbleGridView(cellSize: cellSize)
					.frame(maxWidth: .infinity)
					.padding(.horizontal, 4)
					.padding(.vertical, 6)

				ActionBar(bottomInset: geo.safeAreaInsets.bottom)
					.frame(maxHeight: .infinity)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.ignoresSafeArea(edges: .bottom)
		}
		.onAppear {
			UIAccessibility.post(notification: .screenChanged, argument: vm.gameplayHeading)
		}
	}

	private func cellSize(in width: CGFloat, height: CGFloat) -> CGFloat {
		let actionBarHeight: CGFloat = dynamicTypeSize.isAccessibilitySize ? 246 : 112
		let reservedHeight: CGFloat = 47 + 56 + 36 + 56 + actionBarHeight + 16
		let availableHeight = height - reservedHeight
		let fromHeight = availableHeight / 5
		let fromWidth  = (width - 8) / 5
		let minimumSize: CGFloat = dynamicTypeSize.isAccessibilitySize ? 48 : 44
		return max(minimumSize, min(fromHeight, fromWidth, 72))
	}
}

// MARK: - Header bar

private struct GameHeaderBar: View {
	@Environment(GameViewModel.self) private var vm

	var body: some View {
		HStack {
			VStack(alignment: .leading, spacing: 2) {
				Text("Time")
					.font(.caption.weight(.bold))
					.foregroundStyle(Color.wbMuted)
				Text(vm.formattedTime)
					.font(.system(.title2, design: .monospaced).weight(.bold))
					.foregroundStyle(vm.timerIsWarning ? Color.wbAccent2 : Color.wbTimerGreen)
					.contentTransition(.numericText())
			}
			Spacer()
			VStack(spacing: 2) {
				Text("Score")
					.font(.caption.weight(.bold))
					.foregroundStyle(Color.wbMuted)
				Text("\(vm.score)")
					.font(.system(.title2, design: .monospaced).weight(.bold))
					.foregroundStyle(Color.wbAccent1)
					.contentTransition(.numericText())
			}
			Spacer()
			VStack(alignment: .trailing, spacing: 2) {
				Text("Words")
					.font(.caption.weight(.bold))
					.foregroundStyle(Color.wbMuted)
				Text("\(vm.wordCount)")
					.font(.system(.title2, design: .monospaced).weight(.bold))
					.foregroundStyle(Color.wbAccent4)
					.contentTransition(.numericText())
			}
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 10)
		.background(Color.wbSurface)
		.overlay(alignment: .bottom) {
			Divider().background(Color.white.opacity(0.06))
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("Time: \(vm.formattedTime), Score: \(vm.score), Words: \(vm.wordCount)")
	}
}

// MARK: - Chain meter bar

private struct ChainMeterBar: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	var body: some View {
			HStack(spacing: 8) {
				Text("Chained Words")
					.font(.caption.weight(.bold))
					.foregroundStyle(Color.wbMuted)

				GeometryReader { geo in
					ZStack(alignment: .leading) {
						RoundedRectangle(cornerRadius: 999)
							.fill(Color.wbPanel)
							.frame(height: 8)
						RoundedRectangle(cornerRadius: 999)
							.fill(chainGradient)
							.frame(width: geo.size.width * (vm.chainMeterProgress / 3.0), height: 8)
							.animation(reduceMotion ? nil : .linear(duration: 0.1), value: vm.chainMeterProgress)
					}
				}
				.frame(height: 8)

			Text(chainDisplayText)
				.font(.system(.caption, design: .monospaced).weight(.bold))
				.foregroundStyle(Color.wbAccent5)
				.frame(minWidth: 44, alignment: .trailing)
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 6)
		.background(Color.wbSurface)
		.overlay(alignment: .bottom) {
			Divider().background(Color.white.opacity(0.06))
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("Chained words")
		.accessibilityValue(vm.chainMeterValue)
	}

	private var chainGradient: LinearGradient {
		if vm.chainPowerUpActive {
			return LinearGradient(colors: [.wbAccent1, .wbAccent5, .wbAccent4],
								  startPoint: .leading, endPoint: .trailing)
		}
		return LinearGradient(colors: [.wbAccent5, .wbAccent4],
							  startPoint: .leading, endPoint: .trailing)
	}

	private var chainDisplayText: String {
		vm.chainPowerUpActive ? "3x \(vm.chainPowerUpSecondsLeft)s" : "\(vm.connectedWordStreak)/3"
	}
}

// MARK: - Word tray

private struct WordTrayBar: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text("Word tray")
				.font(.caption.weight(.bold))
				.foregroundStyle(Color.wbMuted)

			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 6) {
					if vm.selected.isEmpty {
						Text("Your word appears here as you bop letters.")
							.font(.callout)
							.foregroundStyle(Color.wbMuted)
					} else {
						ForEach(vm.selected, id: \.bubbleId) { sel in
							Text(sel.letter.uppercased())
								.font(.system(.title3, design: .monospaced).weight(.bold))
								.foregroundStyle(Color.black)
								.frame(width: 36, height: 36)
								.background(Color.wbAccent4)
								.clipShape(RoundedRectangle(cornerRadius: 10))
								.transition(reduceMotion ? .identity : .scale(scale: 0.0).combined(with: .opacity))
						}
					}
				}
				.animation(reduceMotion ? nil : .spring(response: 0.2), value: vm.selected.map(\.bubbleId))
				.padding(.horizontal, 1)
			}
			.frame(height: 40)
		}
		.padding(.horizontal, 16)
		.padding(.top, 6)
		.padding(.bottom, 8)
		.background(Color.wbSurface)
		.overlay(alignment: .bottom) {
			Divider().background(Color.white.opacity(0.06))
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel(vm.wordTrayLabel)
	}
}

// MARK: - Action bar

private struct ActionBar: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	let bottomInset: CGFloat

	var body: some View {
		ZStack {
			HStack(spacing: 0) {
				clearButton
				makeWordButton
				endGameButton
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
		.background(Color.wbSurface)
		.overlay(alignment: .top) {
			Divider().background(Color.white.opacity(0.07))
		}
	}

	private var clearButton: some View {
		Button { vm.clearSelection() } label: {
			ButtonZone(bottomInset: bottomInset) {
				secondaryButtonVisual("Clear")
			}
		}
		.buttonStyle(.plain)
		.keyboardShortcut(.cancelAction)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.contentShape(Rectangle())
		.accessibilityLabel("Clear selected letters")
	}

	private var makeWordButton: some View {
		Button { vm.makeWord() } label: {
			ButtonZone(bottomInset: bottomInset) {
				makeWordButtonVisual("Make Word", enabled: vm.makeWordEnabled)
			}
		}
		.buttonStyle(.plain)
		.disabled(!vm.makeWordEnabled)
		.keyboardShortcut(.defaultAction)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.contentShape(Rectangle())
	}

	private var endGameButton: some View {
		Button { vm.endGame() } label: {
			ButtonZone(bottomInset: bottomInset) {
				dangerButtonVisual("End Game")
			}
		}
		.buttonStyle(.plain)
		.keyboardShortcut(".", modifiers: .command)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.contentShape(Rectangle())
	}

	private func makeWordButtonVisual(_ title: String, enabled: Bool) -> some View {
		Text(title)
			.font(.headline.weight(.black))
			.foregroundStyle(enabled ? Color.black : Color.wbMuted)
			.frame(maxWidth: .infinity)
			.frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 72 : 64)
			.background(
				enabled
				? LinearGradient(colors: [.wbAccent5, .wbAccent4], startPoint: .topLeading, endPoint: .bottomTrailing)
				: LinearGradient(colors: [.wbPanel, .wbPanel], startPoint: .topLeading, endPoint: .bottomTrailing)
			)
			.clipShape(RoundedRectangle(cornerRadius: 14))
	}

	private func secondaryButtonVisual(_ title: String) -> some View {
		Text(title)
			.font(.subheadline.weight(.bold))
			.foregroundStyle(Color.wbMuted)
			.frame(maxWidth: .infinity)
			.frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 66 : 60)
			.padding(.horizontal, 12)
			.background(Color.wbPanel)
			.clipShape(RoundedRectangle(cornerRadius: 14))
			.overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08)))
	}

	private func dangerButtonVisual(_ title: String) -> some View {
		Text(title)
			.font(.subheadline.weight(.bold))
			.foregroundStyle(Color.wbAccent2)
			.frame(minWidth: dynamicTypeSize.isAccessibilitySize ? 112 : 92)
			.frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 66 : 52)
			.padding(.horizontal, 12)
			.background(Color.wbAccent2.opacity(0.15))
			.clipShape(RoundedRectangle(cornerRadius: 14))
			.overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.wbAccent2.opacity(0.25)))
	}
}

private struct ButtonZone<Content: View>: View {
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
				.padding(.horizontal, 5)
				.padding(.bottom, bottomInset)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.contentShape(Rectangle())
	}
}
