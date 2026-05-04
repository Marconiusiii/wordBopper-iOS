import SwiftUI

struct GameView: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	var body: some View {
		GeometryReader { geo in
			let safeHeight = geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom
			let cellSize = cellSize(in: geo.size.width, height: safeHeight)

			VStack(spacing: 0) {
				GameHeaderBar()
				ChainMeterBar()
				WordTrayBar()

				BubbleGridView(cellSize: cellSize)
					.frame(maxWidth: .infinity)
					.padding(.horizontal, 8)
					.padding(.vertical, 8)

				ActionBar()
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		}
	}

	private func cellSize(in width: CGFloat, height: CGFloat) -> CGFloat {
		let actionBarHeight: CGFloat = dynamicTypeSize.isAccessibilitySize ? 198 : 88
		let reservedHeight: CGFloat = 56 + 40 + 64 + actionBarHeight + 16
		let availableHeight = height - reservedHeight
		let fromHeight = (availableHeight - 6 * 4) / 5
		let fromWidth  = (width - 16 - 6 * 4) / 5
		return max(44, min(fromHeight, fromWidth, 76))
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
					.lineLimit(2)

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
		.accessibilityAddTraits(vm.chainPowerUpActive ? .updatesFrequently : [])
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
					.accessibilityHidden(true)

			ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: 6) {
						if vm.selected.isEmpty {
							Text("Your word appears here as you bop letters.")
								.font(.callout)
								.foregroundStyle(Color.wbMuted)
								.lineLimit(1)
								.minimumScaleFactor(0.8)
						} else {
							ForEach(vm.selected, id: \.bubbleId) { sel in
								Text(sel.letter.uppercased())
									.font(.system(.title3, design: .monospaced).weight(.bold))
									.foregroundStyle(Color.black)
									.frame(minWidth: 38, minHeight: 38)
									.padding(2)
									.background(Color.wbAccent4)
									.clipShape(RoundedRectangle(cornerRadius: 10))
									.transition(.scale(scale: 0.0).combined(with: .opacity))
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

	var body: some View {
		Group {
			if dynamicTypeSize.isAccessibilitySize {
				VStack(spacing: 10) {
					actionButtons
				}
			} else {
				HStack(spacing: 10) {
					actionButtons
				}
			}
		}
		.padding(.horizontal, 12)
		.padding(.top, 10)
		.padding(.bottom, 18)
		.background(Color.wbSurface)
		.overlay(alignment: .top) {
			Divider().background(Color.white.opacity(0.07))
		}
	}

	@ViewBuilder
	private var actionButtons: some View {
		Button("Clear") { vm.clearSelection() }
			.buttonStyle(SecondaryButtonStyle())
			.accessibilityLabel("Clear selected letters")

			Button("Make Word") { vm.makeWord() }
				.buttonStyle(MakeWordBtnStyle())
				.disabled(!vm.makeWordEnabled)

		Button("End Game") { vm.endGame() }
			.buttonStyle(DangerButtonStyle())
	}
}

// MARK: - Button styles

private struct MakeWordBtnStyle: ButtonStyle {
	@Environment(\.isEnabled) private var isEnabled

		func makeBody(configuration: Configuration) -> some View {
			configuration.label
				.font(.headline.weight(.black))
				.foregroundStyle(isEnabled ? Color.black : Color.wbMuted)
				.frame(maxWidth: .infinity)
				.frame(minHeight: 56)
				.padding(.vertical, 4)
				.background(
					isEnabled
					? LinearGradient(colors: [.wbAccent5, .wbAccent4], startPoint: .topLeading, endPoint: .bottomTrailing)
				: LinearGradient(colors: [.wbPanel, .wbPanel], startPoint: .topLeading, endPoint: .bottomTrailing)
			)
			.clipShape(RoundedRectangle(cornerRadius: 14))
			.scaleEffect(configuration.isPressed ? 0.95 : 1.0)
			.animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
	}
}

private struct SecondaryButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.subheadline.weight(.bold))
			.foregroundStyle(Color.wbMuted)
			.frame(maxWidth: .infinity)
			.frame(minWidth: 96, minHeight: 56)
			.padding(.horizontal, 14)
			.padding(.vertical, 4)
			.background(Color.wbPanel)
			.clipShape(RoundedRectangle(cornerRadius: 14))
			.overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08)))
			.scaleEffect(configuration.isPressed ? 0.95 : 1.0)
			.animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
	}
}

private struct DangerButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.subheadline.weight(.bold))
			.foregroundStyle(Color.wbAccent2)
			.frame(maxWidth: .infinity)
			.frame(minWidth: 96, minHeight: 56)
			.padding(.horizontal, 14)
			.padding(.vertical, 4)
			.background(Color.wbAccent2.opacity(0.15))
			.clipShape(RoundedRectangle(cornerRadius: 14))
			.overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.wbAccent2.opacity(0.25)))
			.scaleEffect(configuration.isPressed ? 0.95 : 1.0)
			.animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
	}
}
