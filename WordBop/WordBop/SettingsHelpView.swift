import SwiftUI

struct SettingsHelpView: View {
	var body: some View {
		List {
			Section("Game Mode") {
				Text("Timed mode gives you 2 minutes to make as many words as possible. Used letters are replaced after each word.")
				Text("Bopple keeps the letters in place. Make words using letters that are next to each other in the grid. Each word counts once per round.")
				Text("Non-Stop mode removes the timer so you can keep playing until you choose End Game.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Bopple Timer") {
				Text("Choose 3, 4, 5, or 6 minutes for a Bopple round. 3 minutes is the default. Choose Non-Stop Boppling! to play without a timer and end the round yourself.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Grid Size") {
				Text("Choose how many rows and columns appear in the letter grid, from 3 by 3 to 6 by 6. 5 by 5 is the classic size. Smaller grids have fewer, larger bubbles.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Bubble Language") {
				Text("Choose the language used for bubble letters, accepted words, letter phonetics, and spoken words during play.")
			}
			.listRowBackground(Color.wbBackground)
			Section("BopAway") {
				Text("For an extra challenge, BopAway instantly moves each tapped letter into the word tray and replaces it with a new letter. If you clear the word, those letters are lost. Bop wisely!")
				Text("BopAway applies to Timed and Non-Stop modes. Bopple keeps its letters in place.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Letter Positions") {
				Text("Off leaves letter positions out of the spoken bubble information.")
				Text("Column Number, Row Number speaks the column followed by the row, such as \"W, 2 3.\"")
				Text("Column Letter, Row Number uses letters for columns and numbers for rows, such as \"G, B3\" for the second column, third row.")
				Text("Column Number, Row Letter uses numbers for columns and letters for rows, such as \"W, 3A\" for the third column, first row.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Speak Letter Phonetics") {
				Text("Adds the phonetic version of the bubble letters to the announcement, such as \"a, Alpha.\"")
			}
			.listRowBackground(Color.wbBackground)
			Section("Game Announcements") {
				Text("Choose Normal for full game announcements, Low for shorter updates, or Off to turn off game announcements. This does not turn off VoiceOver navigation or the game sounds.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Bubble Letter Style") {
				Text("Choose the letter shape that is easiest for you to read in the bubbles and word tray.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Bubble Text Color") {
				Text("Pick your preference of light or dark text for the bubbles. Either option will still have colorful bubbles to bop!")
			}
			.listRowBackground(Color.wbBackground)
			Section("Bubble Color Theme") {
				Text("Choose a bubble color set that feels good to play with. Every theme keeps the letter contrast strong.")
				Text("The available themes depend on your Bubble Text Color choice. The BOP sample shows your chosen letter style and colors.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Game Volume") {
				Text("Set how loud the game sounds should be.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Game Haptics") {
				Text("Feel the Bop more with subtle game event vibrations.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Daily Bop Languages") {
				Text("Turn on the languages you want to receive a Daily Bop word each day. At least one language must stay on.")
			}
			.listRowBackground(Color.wbBackground)
			Section("Left-Handed Mode") {
				Text("Mirrors gameplay controls for easier left-handed play.")
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
