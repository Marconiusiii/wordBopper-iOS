import SwiftUI

@main
struct WordBopApp: App {
	@State private var vm = GameViewModel()

	// Hosted tests start their own StoreKit session before opening a store.
	@State private var supportStore = SupportStore(listen: ProcessInfo.processInfo.environment["WORDBOP_HOSTED_TEST"] == nil)

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(vm)
				.environment(supportStore)
		}
	}
}
