# Game Center Walkthrough for WordBopper 1.7.0

## Goal

WordBopper 1.7.0 should add Game Center in a focused, accessible way:

1. Let players compare scores through leaderboards.
2. Reward meaningful milestones through achievements.
3. Keep gameplay fully usable if a player is not signed in to Game Center.
4. Avoid adding multiplayer or social pressure in the first Game Center pass.
5. Update the privacy policy before release.

Apple references:

1. [Game Center overview in App Store Connect](https://developer.apple.com/help/app-store-connect/configure-game-center/overview-of-game-center/)
2. [Enable an app version for Game Center](https://developer.apple.com/help/app-store-connect/configure-game-center/enable-an-app-version-for-game-center/)
3. [Authenticating a player](https://developer.apple.com/documentation/gamekit/authenticating_a_player?changes=latest_min_8_8)
4. [Manage achievements](https://developer.apple.com/help/app-store-connect/configure-game-center/manage-achievements)
5. [Game Center properties](https://developer.apple.com/help/app-store-connect/reference/game-center/game-center-properties)
6. [Testing Game Center](https://developer.apple.com/help/app-store-connect/configure-game-center/overview-of-testing-game-center/)

## Recommended 1.7.0 Scope

Start with:

1. Game Center authentication.
2. A Game Center access point.
3. Leaderboards for Timed and Bopple.
4. A small set of achievements.
5. Local fallback behavior when Game Center is unavailable.

Defer:

1. Real-time multiplayer.
2. Turn-based matches.
3. Challenges.
4. Daily Challenge leaderboards.
5. Language-specific leaderboards.

This keeps 1.7.0 useful without turning the update into a much larger platform project.

## Product Design

### Player Experience

When WordBopper launches, the app should attempt to authenticate the local Game Center player. If Game Center is available, the player can open the Game Center dashboard from the Start screen or Game Settings.

If the player is not signed in, gameplay should still work exactly as it does now. Scores and achievements simply do not submit.

### Accessible UI Placement

Recommended placement:

1. Add a compact `Game Center` button in Game Settings near About WordBopper.
2. Optionally show the native Game Center access point when authenticated.
3. Avoid placing Game Center UI in the active gameplay screen for 1.7.0.

Reasoning:

1. The gameplay screen is already time-sensitive.
2. VoiceOver users should not have new social UI competing with the grid, word tray, Make Word, Clear Word, or End controls.
3. Game Settings already contains optional features and secondary actions.

## App Store Connect Setup

### Prerequisites

You need an App Store Connect role that can manage Game Center. Apple lists Account Holder, Admin, App Manager, Developer, or Marketing for many Game Center configuration tasks, while score/player management is more restricted.

The app bundle ID currently used by WordBopper is:

```text
com.marconius.WordBop
```

### Enable Game Center for the App Version

1. Open App Store Connect.
2. Select WordBopper.
3. Select the iOS app version for `1.7.0`.
4. Find the Game Center section.
5. Enable Game Center for that version.
6. Save.

Important: Apple notes that apps offering Game Center features need the Game Center entitlement and Game Center features configured in App Store Connect before review.

### Add Leaderboards

Create these leaderboards first:

| Reference Name | Leaderboard ID | Display Name | Score Format | Sort |
| --- | --- | --- | --- | --- |
| Timed Score | `com.marconius.WordBop.leaderboard.timed.score` | Timed Score | Integer | High to Low |
| Bopple Score | `com.marconius.WordBop.leaderboard.bopple.score` | Bopple Score | Integer | High to Low |

Optional for a later 1.7.x update:

| Reference Name | Leaderboard ID | Display Name | Score Format | Sort |
| --- | --- | --- | --- | --- |
| Timed Words | `com.marconius.WordBop.leaderboard.timed.words` | Timed Words | Integer | High to Low |
| Bopple Words | `com.marconius.WordBop.leaderboard.bopple.words` | Bopple Words | Integer | High to Low |
| Non-Stop Score | `com.marconius.WordBop.leaderboard.nonstop.score` | Non-Stop Score | Integer | High to Low |

Recommendation: Do not launch with Non-Stop leaderboards unless we decide Non-Stop is meant to be competitive. Since Non-Stop has no time limit, it is not naturally fair as a global score comparison.

### Add Achievements

Apple allows up to 100 achievements per app and up to 1000 total achievement points. Achievement IDs are permanent after creation, and point values cannot be changed after the achievement is live for an app version, so choose stable IDs.

Recommended 1.7.0 achievement set:

| Reference Name | Achievement ID | Display Name | Points | Hidden | Repeatable |
| --- | --- | --- | --- | --- | --- |
| First Bop | `com.marconius.WordBop.achievement.first_bop` | First Bop | 10 | No | No |
| Word Bopper | `com.marconius.WordBop.achievement.word_bopper` | Word Bopper | 25 | No | No |
| Big Bop | `com.marconius.WordBop.achievement.big_bop` | Big Bop | 50 | No | No |
| Bopple Beginner | `com.marconius.WordBop.achievement.bopple_beginner` | Bopple Beginner | 25 | No | No |
| Chain Reaction | `com.marconius.WordBop.achievement.chain_reaction` | Chain Reaction | 50 | No | No |
| Triple Bop | `com.marconius.WordBop.achievement.triple_bop` | Triple Bop | 75 | No | No |
| Multilingual Bopper | `com.marconius.WordBop.achievement.multilingual_bopper` | Multilingual Bopper | 100 | No | No |
| Non-Stop Bopper | `com.marconius.WordBop.achievement.nonstop_bopper` | Non-Stop Bopper | 25 | No | No |
| Bop Master | `com.marconius.WordBop.achievement.bop_master` | Bop Master | 100 | No | No |

Total: 460 points.

### Achievement Criteria

| Achievement | Criteria |
| --- | --- |
| First Bop | Score the first valid word in any mode. |
| Word Bopper | Score 10 valid words in one round. |
| Big Bop | Score a word with 8 or more letters. |
| Bopple Beginner | Complete one Bopple round with at least one valid word. |
| Chain Reaction | Score a connected chain word in Timed or Non-Stop. |
| Triple Bop | Activate the 3x multiplier. |
| Multilingual Bopper | Score at least one valid word in three different Bubble Languages. |
| Non-Stop Bopper | Score 25 words in one Non-Stop session. |
| Bop Master | Score 100 or more points in a Timed round. |

### Achievement Copy

Use this as a starting point for App Store Connect localization metadata.

| Display Name | Pre-Earned Description | Earned Description |
| --- | --- | --- |
| First Bop | Make your first valid word. | You made your first valid word. The bopping has begun. |
| Word Bopper | Make 10 words in one round. | You made 10 words in one round. Nicely bopped. |
| Big Bop | Make a word with 8 or more letters. | You made a word with 8 or more letters. Big bop energy. |
| Bopple Beginner | Complete a Bopple round with at least one word. | You completed a Bopple round with a valid word. |
| Chain Reaction | Make a connected chain word. | You made a connected chain word. |
| Triple Bop | Activate the 3x multiplier. | You activated the 3x multiplier. |
| Multilingual Bopper | Make words in three Bubble Languages. | You made words in three Bubble Languages. |
| Non-Stop Bopper | Make 25 words in one Non-Stop session. | You made 25 words in one Non-Stop session. |
| Bop Master | Score 100 points in a Timed round. | You scored 100 points in a Timed round. |

### Achievement Images

App Store Connect requires an image for each achievement localization. Apple lists the achievement image requirement as a `.jpeg`, `.jpg`, or `.png`, 1024 x 1024 pixels, at least 72 ppi, and RGB color space.

Image direction:

1. Use high-contrast icons that fit WordBopper's colorful bubble style.
2. Avoid text inside the images.
3. Use simple shapes that still make sense at small sizes.
4. Keep the image names aligned with achievement IDs.

Example asset names:

```text
achievement-first-bop.png
achievement-word-bopper.png
achievement-big-bop.png
achievement-bopple-beginner.png
achievement-chain-reaction.png
achievement-triple-bop.png
achievement-multilingual-bopper.png
achievement-nonstop-bopper.png
achievement-bop-master.png
```

## Xcode Setup

### Add Game Center Capability

1. Open the WordBop project in Xcode.
2. Select the WordBop app target.
3. Open Signing & Capabilities.
4. Click `+ Capability`.
5. Add `Game Center`.
6. Confirm Xcode adds the Game Center entitlement.

Expected entitlement:

```xml
<key>com.apple.developer.game-center</key>
<true/>
```

If Xcode shows Game Center enabled but the entitlement is missing, Apple recommends removing and re-enabling the capability.

### Add GameKit Import

The implementation files that need GameKit should import:

```swift
import GameKit
```

Recommended new file:

```text
WordBop/WordBop/GameCenterService.swift
```

## Code Architecture

Add a small service that owns all Game Center work:

```swift
import GameKit
import SwiftUI

@MainActor
final class GameCenterService: NSObject, ObservableObject {
	var isAuthenticated = false
	var accessPointIsActive = false

	func authenticate() {
		GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
			guard let self else { return }

			if let viewController {
				// Present this from SwiftUI with a sheet or root presenter.
				return
			}

			self.isAuthenticated = GKLocalPlayer.local.isAuthenticated
			GKAccessPoint.shared.isActive = self.isAuthenticated
		}
	}

	func submitScore(_ score: Int, leaderboardID: String) async {
		guard GKLocalPlayer.local.isAuthenticated else { return }
		do {
			try await GKLeaderboard.submitScore(
				score,
				context: 0,
				player: GKLocalPlayer.local,
				leaderboardIDs: [leaderboardID]
			)
		} catch {
			// Keep gameplay quiet. Log in debug if needed.
		}
	}

	func reportAchievement(id: String, percentComplete: Double = 100) async {
		guard GKLocalPlayer.local.isAuthenticated else { return }
		let achievement = GKAchievement(identifier: id)
		achievement.percentComplete = percentComplete
		achievement.showsCompletionBanner = true

		do {
			try await GKAchievement.report([achievement])
		} catch {
			// Keep gameplay quiet. Log in debug if needed.
		}
	}
}
```

This should be refined during implementation, especially around presenting the authentication view controller from SwiftUI.

## Suggested Constants

Create stable IDs in one place:

```swift
enum GameCenterID {
	enum Leaderboard {
		static let timedScore = "com.marconius.WordBop.leaderboard.timed.score"
		static let boppleScore = "com.marconius.WordBop.leaderboard.bopple.score"
	}

	enum Achievement {
		static let firstBop = "com.marconius.WordBop.achievement.first_bop"
		static let wordBopper = "com.marconius.WordBop.achievement.word_bopper"
		static let bigBop = "com.marconius.WordBop.achievement.big_bop"
		static let boppleBeginner = "com.marconius.WordBop.achievement.bopple_beginner"
		static let chainReaction = "com.marconius.WordBop.achievement.chain_reaction"
		static let tripleBop = "com.marconius.WordBop.achievement.triple_bop"
		static let multilingualBopper = "com.marconius.WordBop.achievement.multilingual_bopper"
		static let nonstopBopper = "com.marconius.WordBop.achievement.nonstop_bopper"
		static let bopMaster = "com.marconius.WordBop.achievement.bop_master"
	}
}
```

## Where To Hook Into WordBopper

### Authenticate

Call Game Center authentication when the app starts.

Best location:

1. `WordBopApp.swift`, if the service is created at app level.
2. Or `ContentView.swift`, with `.task` or `.onAppear`, if the service is injected into the environment.

### Submit Leaderboard Scores

Scores should submit only after a round ends and best-game updates are finished.

Current likely hook:

```swift
private func showResults() {
	updateBestGame()
	screen = .results
}
```

Add submission after `updateBestGame()`:

1. Timed mode: submit `score` to Timed Score leaderboard.
2. Bopple mode: submit `score` to Bopple Score leaderboard.
3. Non-Stop mode: do not submit for 1.7.0 unless we intentionally add a Non-Stop leaderboard.

### Award Achievements

Award achievements at the moment the game knows the milestone happened.

Suggested locations:

1. First Bop: after a valid word is accepted.
2. Big Bop: after a valid word of 8 or more letters is accepted.
3. Chain Reaction: after `chainBonus > 0`.
4. Triple Bop: inside `activatePowerUp()`.
5. Word Bopper: after `wordCount` reaches 10 in a round.
6. Bopple Beginner: at round end if `gameMode == .bopple` and `wordCount > 0`.
7. Non-Stop Bopper: when `gameMode == .nonStop` and `wordCount >= 25`.
8. Bop Master: at round end if `gameMode == .timed` and `score >= 100`.
9. Multilingual Bopper: after scoring a valid word, track languages used locally and award when the set reaches 3.

### Local Progress Tracking

Game Center tracks completed achievements, but WordBopper should keep a lightweight local record too:

1. Languages used for `Multilingual Bopper`.
2. Whether a player has had at least one valid word.
3. Optional debug state for achievement testing.

Use `UserDefaults` for this. Do not add any server-side tracking.

## Accessibility Notes

1. Game Center must never be required to play.
2. If Game Center authentication prompts appear, they should be user-initiated or appear during a calm app moment, not during active gameplay.
3. Do not announce score submissions with custom VoiceOver announcements during gameplay.
4. Let native Game Center UI handle its own accessibility.
5. If adding a Game Center button, use a native SwiftUI `Button` with the label `Game Center`.
6. If using `GKAccessPoint`, test with VoiceOver to confirm it does not interfere with Start, Game Settings, About, or the gameplay grid.
7. Do not put Game Center controls in the gameplay screen for 1.7.0.

## Testing Checklist

### Local Build

1. Add Game Center capability.
2. Confirm entitlement exists.
3. Build on device.
4. Launch while signed in to Game Center.
5. Launch while signed out of Game Center.
6. Confirm gameplay still works when not authenticated.
7. Confirm no crash when score submission fails.

### App Store Connect

1. Create leaderboards.
2. Create achievements.
3. Add required achievement images.
4. Enable Game Center for the 1.7.0 app version.
5. Attach or submit Game Center components for review as required.

### TestFlight

Apple says prerelease Game Center testing occurs in the same server environment as released games. Test carefully:

1. Use a dedicated Game Center test account if privacy matters.
2. Test Timed score submission.
3. Test Bopple score submission.
4. Test every achievement.
5. Confirm completed achievements do not repeatedly banner.
6. Confirm achievements and leaderboards appear in the Game Center dashboard.
7. Confirm VoiceOver can reach and dismiss Game Center UI.
8. Confirm iOS app playable on Mac still works or fails gracefully if Game Center behavior differs.

## Privacy Policy Changes

Adding Game Center changes the privacy policy because WordBopper will interact with Apple's Game Center services.

The current privacy posture should stay simple:

1. WordBopper still should not create its own account system.
2. WordBopper still should not run its own analytics server.
3. WordBopper should not collect names, emails, contacts, or precise location.
4. Game Center will handle player identity, leaderboards, achievements, and related social/game profile features through Apple.

### Recommended Privacy Policy Section

Add a section like this:

```html
<h2>Game Center</h2>
<p>WordBopper uses Apple Game Center for optional leaderboards and achievements. If you use Game Center, Apple may process your Game Center player profile, nickname, scores, achievements, and related gameplay activity according to Apple's own privacy practices and your Game Center settings.</p>
<p>WordBopper does not create its own player accounts and does not receive your email address, real name, contacts, or precise location from Game Center. If you are not signed in to Game Center, you can still play the game, but leaderboard scores and achievements will not be submitted.</p>
```

### App Privacy Nutrition Label

Before release, review App Store Connect's App Privacy answers.

Likely impact:

1. If WordBopper only uses Game Center through Apple frameworks and does not separately collect or transmit player data to Marco/Chancey-controlled servers, the app's direct data collection may remain limited.
2. If App Store Connect asks about gameplay content or product interaction data, answer based on the final implementation, not just this plan.
3. If leaderboards expose scores through Game Center, mention this clearly in the privacy policy even if Apple is the service provider.

Important: This is not legal advice. It is implementation guidance for making the policy honestly describe the feature.

## Release Checklist

1. Add Game Center capability in Xcode.
2. Add `GameCenterService`.
3. Add stable leaderboard and achievement ID constants.
4. Authenticate the local player at app startup.
5. Add a Game Center button or access point outside gameplay.
6. Submit Timed and Bopple scores at round end.
7. Award achievements from gameplay milestones.
8. Keep all Game Center failures quiet and non-blocking.
9. Update the privacy policy.
10. Update App Store Connect privacy answers if needed.
11. Test signed-in and signed-out behavior.
12. Test with VoiceOver.
13. Test in TestFlight.
14. Submit Game Center components with the 1.7.0 app version.

## Future Ideas

1. Daily Challenge leaderboard.
2. Language-specific leaderboards.
3. Friend challenges.
4. Achievement for first 10-letter word.
5. Achievement for scoring in every Bubble Language.
6. Leaderboard sets by game mode.
7. Shared Game Center group if Android or another Apple-platform version ever maps to an Apple app ecosystem equivalent.
