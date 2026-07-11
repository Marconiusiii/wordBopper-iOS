import SwiftUI
import UIKit

struct ResultsView: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	@State private var lookupRequest: DictionaryLookupRequest?
	@State private var unavailableLookup: DictionaryLookupRequest?
	@AccessibilityFocusState private var isDailyBopWordFocused: Bool

	var body: some View {
		GeometryReader { geo in
			let contentWidth = edgeToEdgeWidth(in: geo)
			let longestWordLanguage = longestWord == "—" ? nil : vm.dictionaryLanguage
			VStack(spacing: 0) {
				ScrollView {
					VStack(spacing: 16) {
						Text("Round Complete")
							.font(.title2.weight(.black))
							.foregroundStyle(Color.wbText)
							.accessibilityAddTraits(.isHeader)

						VStack(spacing: 2) {
							Text("\(vm.score)")
								.font(.system(.largeTitle, design: .monospaced).weight(.bold))
								.foregroundStyle(
									LinearGradient(colors: [.wbAccent1, .wbAccent3],
												   startPoint: .topLeading, endPoint: .bottomTrailing)
								)
							Text("points")
								.font(.body)
								.foregroundStyle(Color.wbMuted)
						}
						.accessibilityElement(children: .ignore)
						.accessibilityLabel("\(vm.score) points")

						VStack(spacing: 10) {
							if dynamicTypeSize.isAccessibilitySize {
								ResultStat(value: "\(vm.wordCount)", label: String(localized: "Words made"), color: .wbAccent4)
								ResultStat(value: "\(vm.totalLettersUsed)", label: String(localized: "Letters used"), color: .wbAccent5)
								ResultStat(value: averageLength, label: String(localized: "Average length"), color: .wbAccent1)
								ResultStat(value: longestWord, label: String(localized: "Longest word"), color: .wbAccent3, valueLanguage: longestWordLanguage)
							} else {
								HStack(spacing: 16) {
									ResultStat(value: "\(vm.wordCount)", label: String(localized: "Words made"), color: .wbAccent4)
									ResultStat(value: "\(vm.totalLettersUsed)", label: String(localized: "Letters used"), color: .wbAccent5)
								}

								HStack(spacing: 16) {
									ResultStat(value: averageLength, label: String(localized: "Average length"), color: .wbAccent1)
									ResultStat(value: longestWord, label: String(localized: "Longest word"), color: .wbAccent3, valueLanguage: longestWordLanguage)
								}
							}
							}
							.frame(maxWidth: .infinity)
							.contentShape(Rectangle())

						VStack(alignment: .leading, spacing: 10) {
							if vm.dailyBopFoundThisRound, let dailyBopWord = vm.dailyBopTargetWord, !dailyBopWord.isEmpty {
								DailyWordBoppedSection(
									word: dailyBopWord,
									language: vm.dailyBopTargetLanguage ?? vm.dictionaryLanguage,
									isWordFocused: $isDailyBopWordFocused
								) {
									let request = DictionaryLookupRequest(
										word: dailyBopWord,
										language: vm.dailyBopTargetLanguage ?? vm.dictionaryLanguage
									)
									if UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: dailyBopWord) {
										lookupRequest = request
									} else {
										unavailableLookup = request
									}
								}
							}

							Text("Word List")
								.font(.headline.weight(.black))
								.foregroundStyle(Color.wbText)
								.accessibilityAddTraits(.isHeader)

							if vm.madeWords.isEmpty {
								Text("No words made — try again!")
									.font(.callout)
									.foregroundStyle(Color.wbMuted)
							} else {
									VStack(spacing: 8) {
										ForEach(Array(vm.madeWords.enumerated()), id: \.offset) { _, word in
											Text(word)
												.font(.system(.callout, design: .monospaced).weight(.bold))
												.foregroundStyle(Color.wbText)
												.environment(\.locale, vm.gameplayLocale)
												.padding(.vertical, 5)
											.padding(.horizontal, 10)
											.frame(maxWidth: .infinity)
											.background(Color.wbPanel)
											.clipShape(RoundedRectangle(cornerRadius: 12))
											.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08)))
												.accessibilityElement(children: .ignore)
												.accessibilityLabel(word)
										}
									}
									.environment(\.locale, vm.gameplayLocale)
								}
						}
						.padding(16)
						.background(Color.wbSurface)
						.clipShape(RoundedRectangle(cornerRadius: 20))
						.overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07)))
						.frame(maxWidth: .infinity)
					}
					.padding(.vertical, 24)
					.frame(width: contentWidth)
				}
				.frame(width: contentWidth)

				ResultsActionBar(bottomInset: geo.safeAreaInsets.bottom)
			}
			.frame(width: contentWidth, height: geo.size.height)
			.ignoresSafeArea(edges: horizontalSafeAreaEdges(in: geo))
		}
		.onAppear {
			UIAccessibility.post(notification: .screenChanged, argument: "Round Complete")
		}
		.sheet(item: $lookupRequest, onDismiss: refocusDailyBopWord) { request in
			DictionaryLookupView(word: request.word)
				.ignoresSafeArea()
		}
		.sheet(item: $unavailableLookup, onDismiss: refocusDailyBopWord) { request in
			DictionaryLookupUnavailableView(request: request)
		}
	}

	private var averageLength: String {
		guard vm.wordCount > 0 else { return "—" }
		return String(format: "%.1f", Double(vm.totalLettersUsed) / Double(vm.wordCount))
	}

	private var longestWord: String {
		vm.madeWords.max { $0.count < $1.count } ?? "—"
	}

	private func edgeToEdgeWidth(in geo: GeometryProxy) -> CGFloat {
		isLandscape(in: geo) ? geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing : geo.size.width
	}

	private func horizontalSafeAreaEdges(in geo: GeometryProxy) -> Edge.Set {
		isLandscape(in: geo) ? .horizontal : []
	}

	private func isLandscape(in geo: GeometryProxy) -> Bool {
		geo.size.width > geo.size.height
	}

	private func refocusDailyBopWord() {
		isDailyBopWordFocused = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
			isDailyBopWordFocused = true
		}
	}
}

private struct DictionaryLookupRequest: Identifiable {
	let word: String
	let language: DictionaryLanguage

	var id: String { "\(language.rawValue)-\(word)" }
}

private struct DailyWordBoppedSection: View {
	let word: String
	let language: DictionaryLanguage
	let isWordFocused: AccessibilityFocusState<Bool>.Binding
	let action: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text("Daily Word Bopped!")
				.font(.headline.weight(.black))
				.foregroundStyle(Color.wbText)
				.accessibilityAddTraits(.isHeader)

			Button(action: action) {
				Text(spokenWord)
					.font(.system(.title3, design: .monospaced).weight(.black))
					.foregroundStyle(Color.black)
					.environment(\.locale, language.locale)
					.frame(maxWidth: .infinity, minHeight: 58)
					.padding(.horizontal, 12)
					.background(
						LinearGradient(colors: [.wbAccent2, .wbAccent5],
									   startPoint: .topLeading, endPoint: .bottomTrailing)
					)
					.clipShape(RoundedRectangle(cornerRadius: 14))
					.contentShape(Rectangle())
			}
			.buttonStyle(.plain)
			.accessibilityHint(Text("Looks up \(spokenWord) in Dictionary if available"))
			.accessibilityFocused(isWordFocused)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	private var spokenWord: AttributedString {
		var text = AttributedString(word)
		text.languageIdentifier = language.speechLanguage
		return text
	}
}

private struct DictionaryLookupView: UIViewControllerRepresentable {
	let word: String

	func makeUIViewController(context: Context) -> UIReferenceLibraryViewController {
		UIReferenceLibraryViewController(term: word)
	}

	func updateUIViewController(_ uiViewController: UIReferenceLibraryViewController, context: Context) {}
}

private struct DictionaryLookupUnavailableView: View {
	@Environment(\.dismiss) private var dismiss
	let request: DictionaryLookupRequest

	var body: some View {
		NavigationStack {
			VStack(spacing: 16) {
				Text("Dictionary Lookup")
					.font(.title2.weight(.black))
					.foregroundStyle(Color.wbText)
					.accessibilityAddTraits(.isHeader)

				Text(unavailableMessage)
					.font(.body)
					.foregroundStyle(Color.wbText)
					.multilineTextAlignment(.center)
					.fixedSize(horizontal: false, vertical: true)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.padding(24)
			.background(Color.wbBackground)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Close") {
						dismiss()
					}
				}
			}
		}
		.preferredColorScheme(.dark)
	}

	private var unavailableMessage: AttributedString {
		var text = AttributedString(String(localized: "Dictionary does not have a lookup result for "))
		var word = AttributedString(request.word)
		word.languageIdentifier = request.language.speechLanguage
		text += word
		text += AttributedString(".")
		return text
	}
}

private struct ResultsActionBar: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	let bottomInset: CGFloat

	var body: some View {
		HStack(spacing: 0) {
			Button {
				vm.startGame()
			} label: {
				BottomButtonZone(bottomInset: bottomInset) {
					Text("Play Again")
						.font(.title3.weight(.black))
						.foregroundStyle(Color.black)
						.multilineTextAlignment(.center)
						.lineLimit(2)
						.minimumScaleFactor(0.8)
						.frame(maxWidth: .infinity)
						.frame(minHeight: 52)
						.padding(.horizontal, 6)
						.background(
							LinearGradient(colors: [.wbAccent1, .wbAccent2],
										   startPoint: .topLeading, endPoint: .bottomTrailing)
						)
						.clipShape(Capsule())
				}
			}
			.keyboardShortcut(.defaultAction)

			Button {
				vm.goHome()
			} label: {
				BottomButtonZone(bottomInset: bottomInset) {
					Text("Return Home")
						.font(.title3.weight(.bold))
						.foregroundStyle(Color.wbMuted)
						.multilineTextAlignment(.center)
						.lineLimit(2)
						.minimumScaleFactor(0.8)
						.frame(maxWidth: .infinity)
						.frame(minHeight: 52)
						.padding(.horizontal, 6)
						.background(Color.wbPanel)
						.clipShape(Capsule())
						.overlay(Capsule().stroke(Color.white.opacity(0.08)))
				}
			}
			.keyboardShortcut(.cancelAction)
		}
		.frame(height: (dynamicTypeSize.isAccessibilitySize ? 96 : 68) + bottomInset)
		.background(Color.wbBackground)
	}
}

private struct BottomButtonZone<Content: View>: View {
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
				.padding(.horizontal, 10)
				.padding(.bottom, bottomInset + 8)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.contentShape(Rectangle())
	}
}

private struct ResultStat: View {
	let value: String
	let label: String
	let color: Color
	var valueLanguage: DictionaryLanguage?

	var body: some View {
		VStack(spacing: 2) {
			Text(spokenValue)
				.font(.system(.title, design: .monospaced).weight(.bold))
				.foregroundStyle(color)
				.minimumScaleFactor(0.75)
				.lineLimit(1)
			Text(verbatim: label)
				.font(.caption.weight(.bold))
				.foregroundStyle(Color.wbMuted)
				.multilineTextAlignment(.center)
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel(Text(spokenAccessibilityLabel))
	}

	private var spokenValue: AttributedString {
		var text = AttributedString(value)
		if let valueLanguage {
			text.languageIdentifier = valueLanguage.speechLanguage
		}
		return text
	}

	private var spokenAccessibilityLabel: AttributedString {
		var text = AttributedString(label + ": ")
		text += spokenValue
		return text
	}
}
