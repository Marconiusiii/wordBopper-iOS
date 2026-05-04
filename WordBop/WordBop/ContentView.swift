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
		.onChange(of: vm.screen) { _, screen in
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
