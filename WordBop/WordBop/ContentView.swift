import SwiftUI

struct ContentView: View {
	@Environment(GameViewModel.self) private var vm

	var body: some View {
		ZStack {
			Color.wbBackground.ignoresSafeArea()

			switch vm.screen {
			case .start:
				StartView()
					.transition(.opacity)
			case .game:
				GameView()
					.transition(.opacity)
			case .results:
				ResultsView()
					.transition(.opacity)
			}
		}
		.animation(.easeInOut(duration: 0.3), value: vm.screen)
		.preferredColorScheme(.dark)
	}
}
