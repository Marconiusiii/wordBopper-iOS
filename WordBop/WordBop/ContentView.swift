import SwiftUI

struct ContentView: View {
	@Environment(GameViewModel.self) private var vm

	var body: some View {
		ZStack {
			Color.wbBackground.ignoresSafeArea()

			switch vm.screen {
			case .start:
				StartView()
			case .game:
				GameView()
			case .results:
				ResultsView()
			}
		}
		.preferredColorScheme(.dark)
	}
}
