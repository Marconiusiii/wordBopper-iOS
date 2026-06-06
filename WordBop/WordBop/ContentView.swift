import SwiftUI
#if canImport(DeclaredAgeRange)
import DeclaredAgeRange
#endif

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
		.task {
			await checkDeclaredAgeRangeIfRequired()
		}
	}

	@MainActor
	private func checkDeclaredAgeRangeIfRequired() async {
#if canImport(DeclaredAgeRange) && !targetEnvironment(simulator)
		if #available(iOS 26.0, *) {
			await DeclaredAgeRangeCompliance.checkIfRequired()
		}
#endif
	}
}

#if canImport(DeclaredAgeRange) && !targetEnvironment(simulator)
@available(iOS 26.0, *)
private enum DeclaredAgeRangeCompliance {
	@Environment(\.requestAgeRange) private static var requestAgeRange

	@MainActor
	static func checkIfRequired() async {
		do {
			if #available(iOS 26.4, *) {
				let features = try await AgeRangeService.shared.requiredRegulatoryFeatures
				guard features.contains(.declaredAgeRangeRequired) else { return }
			} else if #available(iOS 26.2, *) {
				let isEligible = try await AgeRangeService.shared.isEligibleForAgeFeatures
				guard isEligible else { return }
			}

			_ = try await requestAgeRange(ageGates: 13, 16, 18)
		} catch {
			// Age range sharing is platform-managed and optional outside required regions.
		}
	}
}
#endif
