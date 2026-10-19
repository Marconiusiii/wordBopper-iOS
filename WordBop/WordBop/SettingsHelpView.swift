import SwiftUI

struct SettingsHelpView: View {
	var body: some View {
		List {
			Text("Welcome to WordBopper! Tap letter bubbles, build words, and see where your vocabulary takes you. Race the clock, settle in for a leisurely bop, or take on a fresh word challenge. Find your favorite way to play and get bopping!")
				.listRowBackground(Color.wbBackground)
			Section("Game Mode") {
				Text("Timed gives you 2 minutes to make as many words as you can. Bopped letters are replaced, keeping fresh possibilities coming.")
				Text("Bopple keeps the board steady. Build words from neighboring letters and see how many you can find. Each word counts once per round.")
				Text("Non-timed mode lets you bop 'til you drop! Removes the timer so you can just make as many words as you want without stress or pressure until you choose to end the game.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Grid Size") {
				Text("Choose a grid from 3 by 3 to 6 by 6. Smaller grids give you fewer, larger bubbles; bigger grids give you more letters to work with. 5 by 5 is the classic.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Bubble Language") {
				Text("Choose the language for your letters, words, phonetics, and spoken word announcements. Bop beyond borders!")
			}
			.listRowBackground(Color.wbBackground)
			Section("BopAway") {
				Text("Each letter you tap moves into your word and is immediately replaced by a fresh bubble. Clearing your word discards those letters. Bop wisely!")
				Text("Available in Timed and Non-Stop games.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Letter Positions") {
				Text("Hear each bubble's column followed by its row. Choose numbers for both, or use a letter for either the column or row: \"2 3,\" \"B3,\" or \"2C.\"")
			}
			.listRowBackground(Color.wbBackground)
			Section("Speak Letter Phonetics") {
				Text("Hear a phonetic word with each letter, such as \"A, Alpha.\" Phonetics follow your chosen bubble language.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Game Announcements") {
				Text("Choose Normal for full spoken game updates, Low for shorter updates, or Off for quiet.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Daily Bop Languages") {
				Text("Choose which languages join your daily word challenge. Keep at least one selected and see what's waiting to be bopped.")
			}
			.listRowBackground(Color.wbBackground)
		}
		.listStyle(.plain)
		.listSectionSpacing(0)
		.textCase(nil)
		.font(.body)
		.foregroundStyle(Color.wbText)
		.scrollContentBackground(.hidden)
		.background(Color.wbBackground)
		.ignoresSafeArea(edges: .horizontal)
		.navigationTitle("Help")
		.navigationBarTitleDisplayMode(.inline)
	}
}
