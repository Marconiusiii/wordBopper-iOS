import SwiftUI
import UIKit

struct GameView: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	var body: some View {
		GeometryReader { geo in
			let safeHeight = geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom
			let orientation = orientation(for: geo.size)

			Group {
				if orientation == .landscape {
					landscapeLayout(in: geo, safeHeight: safeHeight)
				} else {
					portraitLayout(in: geo, safeHeight: safeHeight)
				}
			}
			.id(layoutIdentity(for: orientation, size: geo.size))
		}
		.onAppear {
			UIAccessibility.post(notification: .screenChanged, argument: vm.gameplayHeading)
		}
	}

	private enum GameplayOrientation: String {
		case portrait
		case landscape
	}

	private func orientation(for size: CGSize) -> GameplayOrientation {
		size.width > size.height ? .landscape : .portrait
	}

	private func layoutIdentity(for orientation: GameplayOrientation, size: CGSize) -> String {
		let widthBucket = Int(size.width.rounded(.down))
		let heightBucket = Int(size.height.rounded(.down))
		return [
			orientation.rawValue,
			"\(widthBucket)x\(heightBucket)",
			"grid\(vm.gridSize)",
			vm.leftHandedMode ? "left" : "right",
			vm.gameMode.rawValue
		].joined(separator: "-")
	}

	private func gridIdentity(for orientation: GameplayOrientation) -> String {
		[
			orientation.rawValue,
			"grid\(vm.gridSize)",
			vm.leftHandedMode ? "left" : "right",
			vm.gameMode.rawValue
		].joined(separator: "-")
	}

	private func portraitLayout(in geo: GeometryProxy, safeHeight: CGFloat) -> some View {
		VStack(spacing: 0) {
			headingText

			GameHeaderBar()
			if vm.gameMode != .bopple {
				ChainMeterBar()
			}
			WordTrayBar()
				.frame(height: wordTrayHeight)

			BubbleGridView()
				.frame(maxWidth: .infinity)
				.frame(maxHeight: .infinity)
				.layoutPriority(1)
				.padding(.horizontal, 4)
				.padding(.vertical, 6)
				.environment(\.locale, vm.gameplayLocale)
				.id(gridIdentity(for: .portrait))

			ActionBar(bottomInset: geo.safeAreaInsets.bottom)
				.frame(height: actionBarHeight(bottomInset: geo.safeAreaInsets.bottom))
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.ignoresSafeArea(edges: .bottom)
	}

	private func landscapeLayout(in geo: GeometryProxy, safeHeight: CGFloat) -> some View {
		let safeWidth = geo.size.width - geo.safeAreaInsets.leading - geo.safeAreaInsets.trailing
		let controlsWidth = landscapeControlsWidth(safeWidth: safeWidth)
		let gridPanelWidth = max(0, safeWidth - controlsWidth)

		return HStack(spacing: 0) {
			if vm.leftHandedMode {
				landscapeControlsPanel(bottomInset: geo.safeAreaInsets.bottom)
					.frame(width: controlsWidth)
					.frame(maxHeight: .infinity)

				landscapeGridPanel(endGamePlacement: .trailing)
					.frame(width: gridPanelWidth)
					.frame(maxHeight: .infinity)
			} else {
				landscapeGridPanel(endGamePlacement: .leading)
					.frame(width: gridPanelWidth)
					.frame(maxHeight: .infinity)

				landscapeControlsPanel(bottomInset: geo.safeAreaInsets.bottom)
					.frame(width: controlsWidth)
					.frame(maxHeight: .infinity)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.ignoresSafeArea(edges: .bottom)
	}

	private func landscapeGridPanel(endGamePlacement: EndGamePlacement) -> some View {
		VStack(spacing: 0) {
			LandscapeTitleRow(placement: endGamePlacement) {
				headingText
			}
			.frame(height: landscapeTitleHeight)

			WordTrayBar()
				.frame(height: wordTrayHeight)

			BubbleGridView()
				.frame(maxWidth: .infinity)
				.frame(maxHeight: .infinity)
				.layoutPriority(1)
				.padding(.horizontal, 4)
				.padding(.vertical, 6)
				.environment(\.locale, vm.gameplayLocale)
				.id(gridIdentity(for: .landscape))
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.wbBackground)
	}

	private func landscapeControlsPanel(bottomInset: CGFloat) -> some View {
		VStack(spacing: 0) {
			VStack(spacing: 0) {
				LandscapeStatsPanel()
				if vm.gameMode != .bopple {
					ChainMeterBar()
				}
			}
			.frame(maxWidth: .infinity)
			.background(Color.wbSurface)

			LandscapeActionPanel(bottomInset: bottomInset)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.layoutPriority(1)
		}
		.background(Color.wbSurface)
		.overlay(alignment: vm.leftHandedMode ? .trailing : .leading) {
			Divider().background(Color.white.opacity(0.07))
		}
	}

	private var headingText: some View {
		Text(vm.gameplayHeading)
			.font(.headline.weight(.black))
			.foregroundStyle(Color.wbText)
			.lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
			.fixedSize(horizontal: false, vertical: true)
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.horizontal, 12)
			.padding(.top, 4)
			.padding(.bottom, 4)
			.background(Color.wbSurface)
			.accessibilityAddTraits(.isHeader)
	}

	private func actionBarHeight(bottomInset: CGFloat) -> CGFloat {
		let base: CGFloat = dynamicTypeSize.isAccessibilitySize ? 142 : 104
		return base + bottomInset
	}

	private func landscapeControlsWidth(safeWidth: CGFloat) -> CGFloat {
		let preferredShare: CGFloat = dynamicTypeSize.isAccessibilitySize ? 0.36 : 0.30
		let minimumWidth: CGFloat = dynamicTypeSize.isAccessibilitySize ? 300 : 236
		let maximumShare: CGFloat = dynamicTypeSize.isAccessibilitySize ? 0.42 : 0.36
		let preferredWidth = safeWidth * preferredShare
		let maximumWidth = safeWidth * maximumShare
		return min(max(preferredWidth, minimumWidth), maximumWidth)
	}

	private var landscapeTitleHeight: CGFloat {
		dynamicTypeSize.isAccessibilitySize ? 58 : 44
	}

	private var wordTrayHeight: CGFloat {
		dynamicTypeSize.isAccessibilitySize ? 60 : 50
	}

}

// MARK: - Header bar

private struct GameHeaderBar: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	var body: some View {
		HStack(spacing: 0) {
			if vm.leftHandedMode {
				endGameButton(dividerAlignment: .trailing)
				statsContentView
			} else {
				statsContentView
				endGameButton(dividerAlignment: .leading)
			}
		}
		.frame(height: dynamicTypeSize.isAccessibilitySize ? 70 : 54)
		.background(Color.wbSurface)
		.overlay(alignment: .bottom) {
			Divider().background(Color.white.opacity(0.06))
		}
	}

	private var statsContentView: some View {
		statsContent
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.padding(.horizontal, 16)
			.padding(.vertical, 10)
			.accessibilityElement(children: .ignore)
			.accessibilityLabel(headerAccessibilityLabel)
	}

	private func endGameButton(dividerAlignment: Alignment) -> some View {
		Button { vm.endGame() } label: {
			Text("End Game")
				.font(.subheadline.weight(.bold))
				.foregroundStyle(Color.wbAccent2)
				.multilineTextAlignment(.center)
				.minimumScaleFactor(0.8)
				.lineLimit(2)
				.frame(width: endGameButtonWidth)
				.frame(maxHeight: .infinity)
				.background(Color.wbAccent2.opacity(0.15))
				.overlay(alignment: dividerAlignment) {
					Divider().background(Color.wbAccent2.opacity(0.25))
				}
		}
		.buttonStyle(.plain)
		.keyboardShortcut(".", modifiers: .command)
		.contentShape(Rectangle())
		.accessibilityLabel("End game")
	}

	private var statsContent: some View {
		Group {
			if dynamicTypeSize.isAccessibilitySize {
				VStack(alignment: .leading, spacing: 8) {
					if vm.showsTimer {
						statBlock(
							label: "Time",
							value: vm.formattedTime,
							color: vm.timerIsWarning ? .wbAccent2 : .wbTimerGreen,
							alignment: .leading
						)
					}

					HStack(spacing: 16) {
						statBlock(label: "Score", value: "\(vm.score)", color: .wbAccent1, alignment: .leading)
						statBlock(label: "Words", value: "\(vm.wordCount)", color: .wbAccent4, alignment: .leading)
					}
				}
			} else {
				HStack {
					if vm.showsTimer {
						statBlock(
							label: "Time",
							value: vm.formattedTime,
							color: vm.timerIsWarning ? .wbAccent2 : .wbTimerGreen,
							alignment: .leading
						)
						Spacer(minLength: 8)
					}

					statBlock(label: "Score", value: "\(vm.score)", color: .wbAccent1)
					Spacer(minLength: 8)
					statBlock(label: "Words", value: "\(vm.wordCount)", color: .wbAccent4, alignment: .trailing)
				}
			}
		}
	}

	private func statBlock(label: String, value: String, color: Color, alignment: HorizontalAlignment = .center) -> some View {
		VStack(alignment: alignment, spacing: 2) {
			Text(label)
				.font(.caption.weight(.bold))
				.foregroundStyle(Color.wbMuted)
			Text(value)
				.font(.system(.title2, design: .monospaced).weight(.bold))
				.foregroundStyle(color)
				.contentTransition(.numericText())
				.minimumScaleFactor(0.75)
				.lineLimit(1)
		}
	}

	private var endGameButtonWidth: CGFloat {
		dynamicTypeSize.isAccessibilitySize ? 144 : 104
	}

	private var headerAccessibilityLabel: String {
		if !vm.showsTimer { return "Score: \(vm.score), Words: \(vm.wordCount)" }
		return "Time: \(vm.formattedTime), Score: \(vm.score), Words: \(vm.wordCount)"
	}
}

private enum EndGamePlacement {
	case leading
	case trailing
}

private struct LandscapeTitleRow<Heading: View>: View {
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	let placement: EndGamePlacement
	let heading: Heading

	init(placement: EndGamePlacement, @ViewBuilder heading: () -> Heading) {
		self.placement = placement
		self.heading = heading()
	}

	var body: some View {
		HStack(spacing: 0) {
			if placement == .leading {
				EndGameButton(width: endGameWidth, dividerAlignment: .trailing)
				heading
			} else {
				heading
				EndGameButton(width: endGameWidth, dividerAlignment: .leading)
			}
		}
	}

	private var endGameWidth: CGFloat {
		dynamicTypeSize.isAccessibilitySize ? 132 : 112
	}
}

private struct EndGameButton: View {
	@Environment(GameViewModel.self) private var vm
	let width: CGFloat
	let dividerAlignment: Alignment

	init(width: CGFloat, dividerAlignment: Alignment = .trailing) {
		self.width = width
		self.dividerAlignment = dividerAlignment
	}

	var body: some View {
		Button { vm.endGame() } label: {
			Text("End Game")
				.font(.subheadline.weight(.bold))
				.foregroundStyle(Color.wbAccent2)
				.multilineTextAlignment(.center)
				.minimumScaleFactor(0.75)
				.lineLimit(3)
				.frame(width: width)
				.frame(maxHeight: .infinity)
				.background(Color.wbAccent2.opacity(0.15))
				.overlay(alignment: dividerAlignment) {
					Divider().background(Color.wbAccent2.opacity(0.25))
				}
		}
		.buttonStyle(.plain)
		.keyboardShortcut(".", modifiers: .command)
		.contentShape(Rectangle())
		.accessibilityLabel("End game")
	}
}

private struct LandscapeStatsPanel: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	var body: some View {
		VStack(alignment: .leading, spacing: dynamicTypeSize.isAccessibilitySize ? 12 : 8) {
			if vm.showsTimer {
				statBlock(
					label: "Time",
					value: vm.formattedTime,
					color: vm.timerIsWarning ? .wbAccent2 : .wbTimerGreen
				)
			}

			HStack(spacing: 12) {
				statBlock(label: "Score", value: "\(vm.score)", color: .wbAccent1)
				statBlock(label: "Words", value: "\(vm.wordCount)", color: .wbAccent4)
			}
		}
		.padding(.horizontal, 14)
		.padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 10 : 8)
		.frame(maxWidth: .infinity, alignment: .topLeading)
		.background(Color.wbSurface)
		.accessibilityElement(children: .ignore)
		.accessibilityLabel(headerAccessibilityLabel)
	}

	private func statBlock(label: String, value: String, color: Color) -> some View {
		VStack(alignment: .leading, spacing: 2) {
			Text(label)
				.font(.caption.weight(.bold))
				.foregroundStyle(Color.wbMuted)
			Text(value)
				.font(.system(.title2, design: .monospaced).weight(.bold))
				.foregroundStyle(color)
				.contentTransition(.numericText())
				.minimumScaleFactor(0.7)
				.lineLimit(1)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	private var headerAccessibilityLabel: String {
		if !vm.showsTimer { return "Score: \(vm.score), Words: \(vm.wordCount)" }
		return "Time: \(vm.formattedTime), Score: \(vm.score), Words: \(vm.wordCount)"
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
		.padding(.vertical, 4)
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
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	@Environment(\.legibilityWeight) private var legibilityWeight

	var body: some View {
		VStack(alignment: .leading, spacing: 2) {
			Text("Word tray")
				.font(.caption.weight(.bold))
				.foregroundStyle(Color.wbMuted)

			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 6) {
					if vm.selected.isEmpty {
						Text("Your word appears here as you bop letters.")
							.font(.callout)
							.foregroundStyle(Color.wbMuted)
							.fixedSize(horizontal: false, vertical: true)
					} else {
						ForEach(vm.selected, id: \.bubbleId) { sel in
							Text(sel.letter.uppercased())
								.font(.system(.title2, design: vm.bubbleLetterStyle.fontDesign).weight(letterWeight))
								.foregroundStyle(Color.black)
								.minimumScaleFactor(0.55)
								.lineLimit(1)
								.frame(width: tileSize, height: tileSize)
								.background(Color.wbAccent4)
								.clipShape(RoundedRectangle(cornerRadius: 10))
								.transition(reduceMotion ? .identity : .scale(scale: 0.0).combined(with: .opacity))
						}
					}
				}
				.animation(reduceMotion ? nil : .spring(response: 0.2), value: vm.selected.map(\.bubbleId))
				.padding(.horizontal, 1)
				}
				.frame(height: tileSize)
				.environment(\.locale, vm.gameplayLocale)
			}
		.padding(.horizontal, 12)
		.padding(.top, 4)
		.padding(.bottom, 5)
		.background(Color.wbSurface)
		.overlay(alignment: .bottom) {
			Divider().background(Color.white.opacity(0.06))
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel(vm.wordTrayLabel)
	}

	private var letterWeight: Font.Weight {
		legibilityWeight == .bold ? .black : .bold
	}

	private var tileSize: CGFloat {
		dynamicTypeSize.isAccessibilitySize ? 40 : 32
	}
}

// MARK: - Action bar

private struct ActionBar: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	let bottomInset: CGFloat

	var body: some View {
		GeometryReader { geo in
			HStack(spacing: 0) {
				if vm.leftHandedMode {
					makeWordButton
					clearButton(width: geo.size.width * (dynamicTypeSize.isAccessibilitySize ? 0.42 : 0.34))
				} else {
					clearButton(width: geo.size.width * (dynamicTypeSize.isAccessibilitySize ? 0.42 : 0.34))
					makeWordButton
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
		.background(Color.wbSurface)
		.overlay(alignment: .top) {
			Divider().background(Color.white.opacity(0.07))
		}
	}

	private func clearButton(width: CGFloat) -> some View {
		Button { vm.clearSelection() } label: {
			ButtonZone(bottomInset: bottomInset) {
				secondaryButtonVisual(vm.clearActionTitle)
			}
		}
		.buttonStyle(.plain)
		.keyboardShortcut(.cancelAction)
		.frame(width: width)
		.frame(maxHeight: .infinity)
		.contentShape(Rectangle())
		.accessibilityLabel(vm.clearActionAccessibilityLabel)
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

	private func makeWordButtonVisual(_ title: String, enabled: Bool) -> some View {
		Text(title)
			.font(.headline.weight(.black))
			.foregroundStyle(enabled ? Color.black : Color.wbMuted)
			.multilineTextAlignment(.center)
			.lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
			.minimumScaleFactor(0.6)
			.fixedSize(horizontal: false, vertical: true)
			.frame(maxWidth: .infinity)
			.padding(.horizontal, 12)
			.padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 14 : 10)
			.frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 92 : 64)
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
			.multilineTextAlignment(.center)
			.lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
			.minimumScaleFactor(0.6)
			.fixedSize(horizontal: false, vertical: true)
			.frame(maxWidth: .infinity)
			.padding(.horizontal, 12)
			.padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 14 : 10)
			.frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 88 : 60)
			.background(Color.wbPanel)
			.clipShape(RoundedRectangle(cornerRadius: 14))
			.overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08)))
	}

}

private struct LandscapeActionPanel: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	let bottomInset: CGFloat

	var body: some View {
		VStack(spacing: 0) {
			Button { vm.clearSelection() } label: {
				landscapeButtonVisual(vm.clearActionTitle, isPrimary: false, enabled: true)
			}
			.buttonStyle(.plain)
			.keyboardShortcut(.cancelAction)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.contentShape(Rectangle())
			.accessibilityLabel(vm.clearActionAccessibilityLabel)

			Button { vm.makeWord() } label: {
				landscapeButtonVisual("Make Word", isPrimary: true, enabled: vm.makeWordEnabled)
			}
			.buttonStyle(.plain)
			.disabled(!vm.makeWordEnabled)
			.keyboardShortcut(.defaultAction)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.contentShape(Rectangle())
		}
		.padding(.bottom, bottomInset)
		.background(Color.wbSurface)
		.overlay(alignment: .top) {
			Divider().background(Color.white.opacity(0.07))
		}
	}

	private func landscapeButtonVisual(_ title: String, isPrimary: Bool, enabled: Bool) -> some View {
		Text(title)
			.font((isPrimary ? Font.headline : Font.subheadline).weight(isPrimary ? .black : .bold))
			.foregroundStyle(isPrimary && enabled ? Color.black : Color.wbMuted)
			.multilineTextAlignment(.center)
			.lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
			.minimumScaleFactor(0.6)
			.fixedSize(horizontal: false, vertical: true)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.padding(.horizontal, 12)
			.padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 14 : 10)
			.background(buttonBackground(isPrimary: isPrimary, enabled: enabled))
			.overlay(alignment: .top) {
				Divider().background(Color.white.opacity(0.08))
			}
	}

	private func buttonBackground(isPrimary: Bool, enabled: Bool) -> some ShapeStyle {
		if isPrimary && enabled {
			return LinearGradient(colors: [.wbAccent5, .wbAccent4], startPoint: .topLeading, endPoint: .bottomTrailing)
		}
		return LinearGradient(colors: [.wbPanel, .wbPanel], startPoint: .topLeading, endPoint: .bottomTrailing)
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
