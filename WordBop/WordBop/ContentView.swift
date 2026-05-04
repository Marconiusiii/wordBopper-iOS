import SwiftUI

struct ContentView: View {
	@Environment(GameViewModel.self) private var vm
	@AccessibilityFocusState private var focusedTitle: ScreenTitleFocus?

	var body: some View {
		ZStack {
			Color.wbBackground.ignoresSafeArea()

			switch vm.screen {
			case .start:
				StartView(titleFocus: $focusedTitle)
			case .game:
				GameView(titleFocus: $focusedTitle)
			case .results:
				ResultsView(titleFocus: $focusedTitle)
			}
		}
		.preferredColorScheme(.dark)
		.task {
			moveFocus(to: vm.screen)
		}
		.onChange(of: vm.screen) { _, screen in
			moveFocus(to: screen)
		}
	}

	private func moveFocus(to screen: GameScreen) {
		focusedTitle = nil

		Task { @MainActor in
			try? await Task.sleep(for: .milliseconds(120))
			focusedTitle = ScreenTitleFocus(screen)
		}
	}
}

enum ScreenTitleFocus: Hashable {
	case home
	case gameplay
	case results

	init(_ screen: GameScreen) {
		switch screen {
		case .start:
			self = .home
		case .game:
			self = .gameplay
		case .results:
			self = .results
		}
	}
}
