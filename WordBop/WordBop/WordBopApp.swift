import SwiftUI

@main
struct WordBopApp: App {
	@State private var vm = GameViewModel()

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(vm)
		}
	}
}
