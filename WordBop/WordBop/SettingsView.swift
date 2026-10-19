import SwiftUI

struct SettingsView: View {
	@Environment(GameViewModel.self) private var vm
	@Environment(\.dismiss) private var dismiss
	@AccessibilityFocusState private var isDictionaryLanguageFocused: Bool
	@AccessibilityFocusState private var isLetterPositionFocused: Bool
	@AccessibilityFocusState private var isBubbleColorThemeFocused: Bool
	@State private var showingAbout = false
	@Namespace private var settingsLabels

	var body: some View {
		@Bindable var settings = vm
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 0) {
					NavigationLink {
						SettingsHelpView()
					} label: {
						Text("Help")
							.frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
					}

					Text("Game")
						.font(.headline)
						.accessibilityAddTraits(.isHeader)
						.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
					Group {
						VStack(alignment: .leading, spacing: 8) {
							Text("Game Mode")
								.accessibilityLabeledPair(role: .label, id: "gameMode", in: settingsLabels)
							Picker("", selection: $settings.gameMode) {
								ForEach(GameMode.allCases) { mode in
									Text(mode.label).tag(mode)
								}
							}
							.pickerStyle(.segmented)
							.accessibilityLabeledPair(role: .content, id: "gameMode", in: settingsLabels)
						}

						if vm.gameMode == .bopple {
							VStack(alignment: .leading, spacing: 0) {
								Text("Bopple Timer")
									.accessibilityHidden(true)
								Picker("Bopple Timer", selection: $settings.boppleTimerOption) {
									ForEach(BoppleTimerOption.allCases) { option in
										Text(option.label).tag(option)
									}
								}
								.pickerStyle(.wheel)
								.accessibilityElement(children: .contain)
								.accessibilityLabel("Bopple Timer")
							}
						}

						VStack(alignment: .leading, spacing: 0) {
							Text("Grid Size")
								.accessibilityHidden(true)
							Picker("Grid Size", selection: $settings.gridSizeOption) {
								ForEach(GridSizeOption.allCases) { option in
									Text(option.label).tag(option)
								}
							}
							.pickerStyle(.wheel)
							.accessibilityElement(children: .contain)
							.accessibilityLabel("Grid Size")
						}

						LabeledContent("Bubble Language") {
							Picker(
								"",
								selection: Binding(
									get: { vm.dictionaryLanguage },
									set: { language in
										vm.dictionaryLanguage = language
										refocusDictionaryLanguagePicker()
									}
								)
							) {
								ForEach(DictionaryLanguage.allCases) { language in
									Text(language.label).tag(language)
								}
							}
							.pickerStyle(.menu)
							.accessibilityFocused($isDictionaryLanguageFocused)
						}

						Toggle("BopAway", isOn: $settings.bopAway)
					}
					.padding(.vertical, 8)

					Text("Speech and announcements")
						.font(.headline)
						.accessibilityAddTraits(.isHeader)
						.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
					Group {
						LabeledContent("Letter Positions") {
							Picker(
								"",
								selection: Binding(
									get: { vm.letterPositionMode },
									set: { mode in
										vm.letterPositionMode = mode
										refocusLetterPositionPicker()
									}
								)
							) {
								ForEach(LetterPositionMode.allCases) { mode in
									Text(mode.label).tag(mode)
								}
							}
							.pickerStyle(.menu)
							.accessibilityFocused($isLetterPositionFocused)
						}

						Toggle("Speak Letter Phonetics", isOn: $settings.speakLetterPhonetics)

						VStack(alignment: .leading, spacing: 0) {
							Text("Game Announcements")
								.accessibilityHidden(true)
							Picker("Game Announcements", selection: $settings.gameAnnouncementVerbosity) {
								ForEach(GameAnnouncementVerbosity.allCases) { option in
									Text(option.label).tag(option)
								}
							}
							.pickerStyle(.wheel)
							.accessibilityElement(children: .contain)
							.accessibilityLabel("Game Announcements")
						}
					}

					.padding(.vertical, 8)

					Text("Appearance")
						.font(.headline)
						.accessibilityAddTraits(.isHeader)
						.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
					Group {
						VStack(alignment: .leading, spacing: 8) {
							Text("Bubble Letter Style")
								.accessibilityLabeledPair(role: .label, id: "letterStyle", in: settingsLabels)
							Picker("", selection: $settings.bubbleLetterStyle) {
								ForEach(BubbleLetterStyle.allCases) { option in
									Text(option.label)
										.font(
											.system(.body, design: option.fontDesign).weight(
												.bold)
										)
										.tag(option)
								}
							}
							.pickerStyle(.segmented)
							.accessibilityLabeledPair(role: .content, id: "letterStyle", in: settingsLabels)
						}

						VStack(alignment: .leading, spacing: 8) {
							Text("Bubble Text Color")
								.accessibilityLabeledPair(role: .label, id: "textColor", in: settingsLabels)
							Picker("", selection: $settings.bubbleTextColorOption) {
								ForEach(BubbleTextColorOption.allCases) { option in
									Text(option.label).tag(option)
								}
							}
							.pickerStyle(.segmented)
							.accessibilityLabeledPair(role: .content, id: "textColor", in: settingsLabels)
						}

						LabeledContent("Bubble Color Theme") {
							Picker(
								"",
								selection: Binding(
									get: { vm.bubbleColorTheme },
									set: { theme in
										vm.bubbleColorTheme = theme
										refocusBubbleColorThemePicker()
									}
								)
							) {
								ForEach(BubbleColorTheme.options(for: vm.bubbleTextColorOption)) { theme in
									Text(theme.label).tag(theme)
								}
							}
							.pickerStyle(.menu)
							.accessibilityFocused($isBubbleColorThemeFocused)
						}

						BubbleThemePreview(
							textColorOption: vm.bubbleTextColorOption,
							colorTheme: vm.bubbleColorTheme, letterStyle: vm.bubbleLetterStyle)
					}
					.padding(.vertical, 8)

					Text("Sound and feedback")
						.font(.headline)
						.accessibilityAddTraits(.isHeader)
						.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
					Group {
						VStack(alignment: .leading, spacing: 8) {
							Text("Game Volume")
								.accessibilityHidden(true)
							Slider(value: $settings.gameVolume, in: 0...1) {
								Text("Game Volume")
							}
							.accessibilityValue("\(Int((vm.gameVolume * 100).rounded())) percent")
						}
						Toggle("Game Haptics", isOn: $settings.gameHapticsEnabled)
					}
					.padding(.vertical, 8)

					Text("Daily Bop")
						.font(.headline)
						.accessibilityAddTraits(.isHeader)
						.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
					NavigationLink {
						DailyBopLanguagesView()
					} label: {
						Text("Daily Bop Languages")
							.frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
					}
					.accessibilityHint("Double-tap to choose your Daily Bop Languages")
					.accessibilityValue(selectedDailyBopLanguages)

					Text("Controls")
						.font(.headline)
						.accessibilityAddTraits(.isHeader)
						.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
					Toggle("Left-Handed Mode", isOn: $settings.leftHandedMode)
						.frame(minHeight: 56)

					Text("About")
						.font(.headline)
						.accessibilityAddTraits(.isHeader)
						.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
					Button {
						showingAbout = true
					} label: {
						Text("About WordBopper")
							.frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
					}
				}
				.padding(.horizontal, 16)
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			.background(Color.wbBackground)
			.ignoresSafeArea(edges: .horizontal)
			.foregroundStyle(Color.wbText)
			.tint(Color.wbAccent5)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Close") { dismiss() }
				}
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
		}
		.sheet(isPresented: $showingAbout) {
			AboutWordBopperSheet()
				.environment(vm)
				.presentationDragIndicator(.hidden)
		}
		.preferredColorScheme(.dark)
	}

	private var selectedDailyBopLanguages: String {
		DictionaryLanguage.allCases
			.filter { vm.isDailyBopLanguageEnabled($0) }
			.map(\.label)
			.joined(separator: ", ")
	}

	private func refocusDictionaryLanguagePicker() {
		isDictionaryLanguageFocused = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
			isDictionaryLanguageFocused = true
		}
	}

	private func refocusLetterPositionPicker() {
		isLetterPositionFocused = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
			isLetterPositionFocused = true
		}
	}

	private func refocusBubbleColorThemePicker() {
		isBubbleColorThemeFocused = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
			isBubbleColorThemeFocused = true
		}
	}
}

private struct BubbleThemePreview: View {
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	@Environment(\.legibilityWeight) private var legibilityWeight
	let textColorOption: BubbleTextColorOption
	let colorTheme: BubbleColorTheme
	let letterStyle: BubbleLetterStyle

	private let sampleLetters = ["B", "O", "P"]

	private var palette: [Color] {
		Color.bubbleFill(for: textColorOption, theme: colorTheme)
	}

	private var textColor: Color {
		Color.bubbleText(for: textColorOption)
	}

	var body: some View {
		ZStack {
			Color.wbBackground
			HStack(spacing: 10) {
				ForEach(Array(sampleLetters.enumerated()), id: \.offset) { index, letter in
					Text(letter)
						.font(.system(size: letterSize, weight: letterWeight, design: letterStyle.fontDesign))
						.foregroundStyle(textColor)
						.lineLimit(1)
						.minimumScaleFactor(0.7)
						.frame(width: bubbleSize, height: bubbleSize)
						.background(palette[index % palette.count])
						.clipShape(Circle())
						.shadow(color: .black.opacity(0.25), radius: 4, y: 3)
				}
			}
			.padding(.vertical, 10)
			.padding(.horizontal, 24)
		}
		.frame(maxWidth: .infinity, minHeight: 76)
		.contentShape(Rectangle())
		.accessibilityHidden(true)
	}

	private var bubbleSize: CGFloat {
		switch dynamicTypeSize {
		case .accessibility3, .accessibility4, .accessibility5:
			58
		case .accessibility1, .accessibility2:
			54
		default:
			50
		}
	}

	private var letterSize: CGFloat {
		bubbleSize * 0.48
	}

	private var letterWeight: Font.Weight {
		legibilityWeight == .bold ? .black : .bold
	}
}

private struct DailyBopLanguagesView: View {
	@Environment(GameViewModel.self) private var vm

	var body: some View {
		List {
			ForEach(DictionaryLanguage.allCases) { language in
				Toggle(language.label, isOn: Binding(
					get: { vm.isDailyBopLanguageEnabled(language) },
					set: { vm.setDailyBopLanguage(language, enabled: $0) }
				))
				.listRowBackground(Color.wbBackground)
			}
		}
		.listStyle(.plain)
		.environment(\.defaultMinListRowHeight, 56)
		.scrollContentBackground(.hidden)
		.background(Color.wbBackground)
		.ignoresSafeArea(edges: .horizontal)
		.foregroundStyle(Color.wbText)
		.tint(Color.wbAccent5)
		.navigationTitle("Daily Bop Languages")
		.navigationBarTitleDisplayMode(.inline)
	}
}
