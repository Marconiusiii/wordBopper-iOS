//
//  WordBopUITests.swift
//  WordBopUITests
//
//  Created by Marco Salsiccia on 5/3/26.
//

import XCTest

final class WordBopUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    @MainActor
    func testAppStoreScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        XCTAssertTrue(app.buttons["Start Game"].waitForExistence(timeout: 15))

        setGameMode("Timed", in: app)
        startGame(in: app, menuButton: "Pause Game")
        _ = selectAvailableWord(in: app)
        capture("01-timed-selected")

        scoreSelectedWordIfPossible(in: app)
        scoreAnotherWord(in: app)
        scoreAnotherWord(in: app)
        endGame(in: app, menuButton: "Pause Game")
        capture("06-round-results")
        returnHome(in: app)

        setGameMode("Bopple", in: app)
        startGame(in: app, menuButton: "Pause Game")
        selectFirstGridButtons(count: 4, in: app)
        capture("02-bopple-selected")
        endGame(in: app, menuButton: "Pause Game")
        returnHome(in: app)

        setGameMode("Non-Stop", in: app)
        startGame(in: app, menuButton: "Game Options")
        _ = selectAvailableWord(in: app)
        capture("03-non-stop-selected")
        endGame(in: app, menuButton: "Game Options")
        returnHome(in: app)

        openSettings(in: app)
        let bubbleLanguage = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH 'Bubble Language,'")
        ).firstMatch
        scrollToHittable(bubbleLanguage, in: app)
        bubbleLanguage.tap()
        XCTAssertTrue(app.buttons["Brazilian Portuguese"].waitForExistence(timeout: 5))
        capture("04-seven-languages")
        app.buttons["English"].tap()

        let letterPositions = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH 'Letter Positions,'")
        ).firstMatch
        scrollToHittable(letterPositions, in: app)
        letterPositions.tap()
        XCTAssertTrue(app.buttons["Column Number, Row Number"].waitForExistence(timeout: 5))
        app.buttons["Column Number, Row Number"].tap()

        let phonetics = app.switches["Speak Letter Phonetics"]
        if phonetics.isHittable, phonetics.value as? String != "1" {
            phonetics.tap()
        }
        capture("05-accessibility")
    }

    @MainActor
    private func openSettings(in app: XCUIApplication) {
        let settings = app.buttons["Game Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()
        XCTAssertTrue(app.staticTexts["Game Settings"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func setGameMode(_ mode: String, in app: XCUIApplication) {
        openSettings(in: app)
        let modeButton = app.buttons[mode]
        XCTAssertTrue(modeButton.waitForExistence(timeout: 5))
        modeButton.tap()
        closeSettings(in: app)
    }

    @MainActor
    private func closeSettings(in app: XCUIApplication) {
        app.buttons["Close"].tap()
        waitUntilHittable(app.buttons["Start Game"])
    }

    @MainActor
    private func startGame(in app: XCUIApplication, menuButton: String) {
        app.buttons["Start Game"].tap()
        XCTAssertTrue(app.buttons[menuButton].waitForExistence(timeout: 15))
    }

    @MainActor
    private func endGame(in app: XCUIApplication, menuButton: String) {
        let menu = app.buttons[menuButton]
        XCTAssertTrue(menu.waitForExistence(timeout: 5))
        menu.tap()
        XCTAssertTrue(app.buttons["End Game"].waitForExistence(timeout: 5))
        app.buttons["End Game"].tap()
        XCTAssertTrue(app.staticTexts["Round Complete"].waitForExistence(timeout: 10))
    }

    @MainActor
    private func returnHome(in app: XCUIApplication) {
        let home = app.buttons["Return Home"]
        XCTAssertTrue(home.waitForExistence(timeout: 5))
        home.tap()
        waitUntilHittable(app.buttons["Start Game"])
    }

    @MainActor
    private func scoreSelectedWordIfPossible(in app: XCUIApplication) {
        let makeWord = app.buttons["Make Word"]
        if makeWord.isEnabled {
            makeWord.tap()
            _ = makeWord.waitForExistence(timeout: 2)
        }
    }

    @MainActor
    private func scoreAnotherWord(in app: XCUIApplication) {
        guard selectAvailableWord(in: app) != nil else { return }
        scoreSelectedWordIfPossible(in: app)
    }

    @MainActor
    @discardableResult
    private func selectAvailableWord(in app: XCUIApplication) -> String? {
        let buttons = gridButtons(in: app)
        var buttonsByLetter: [Character: [XCUIElement]] = [:]

        for button in buttons {
            guard let letter = button.label.lowercased().first else { continue }
            buttonsByLetter[letter, default: []].append(button)
        }

        for word in candidateWords {
            var offsets: [Character: Int] = [:]
            var selectedButtons: [XCUIElement] = []
            var canBuild = true

            for letter in word {
                let offset = offsets[letter, default: 0]
                guard let choices = buttonsByLetter[letter], offset < choices.count else {
                    canBuild = false
                    break
                }
                selectedButtons.append(choices[offset])
                offsets[letter] = offset + 1
            }

            if canBuild {
                selectedButtons.forEach { $0.tap() }
                return word
            }
        }

        selectFirstGridButtons(count: 4, in: app)
        return nil
    }

    @MainActor
    private func selectFirstGridButtons(count: Int, in app: XCUIApplication) {
        for button in gridButtons(in: app).prefix(count) {
            button.tap()
        }
    }

    @MainActor
    private func gridButtons(in app: XCUIApplication) -> [XCUIElement] {
        app.buttons.allElementsBoundByIndex.filter { button in
            let label = button.label
            return label.count == 1
                && label.range(of: "^[A-Za-z]$", options: .regularExpression) != nil
                && button.isHittable
        }
    }

    @MainActor
    private func scrollToHittable(_ element: XCUIElement, in app: XCUIApplication) {
        XCTAssertTrue(element.waitForExistence(timeout: 5))
        for _ in 0..<6 where !element.isHittable {
            app.swipeUp()
        }
        waitUntilHittable(element)
    }

    @MainActor
    private func waitUntilHittable(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 5))
        expectation(for: NSPredicate(format: "isHittable == true"), evaluatedWith: element)
        waitForExpectations(timeout: 5)
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private var candidateWords: [String] {
        [
            "stone", "train", "sound", "house", "plant", "heart", "light", "water",
            "word", "game", "play", "time", "score", "chain", "make", "bop",
            "cat", "dog", "sun", "run", "red", "one", "two", "ten", "top", "tap",
            "sit", "set", "sat", "see", "sea", "say", "yes", "yet", "you", "use",
            "the", "and", "are", "can", "day", "new", "now", "not", "out", "our",
            "all", "any", "big", "bit", "box", "boy", "car", "cut", "did", "eat",
            "far", "fit", "get", "got", "had", "has", "her", "him", "his", "hot",
            "how", "its", "let", "man", "map", "may", "old", "put", "she", "sky",
            "try", "way", "who", "why", "win", "won", "book", "door", "food", "good",
            "home", "kind", "land", "long", "look", "love", "moon", "move", "name",
            "open", "road", "room", "show", "small", "start", "stop", "thing", "think"
        ]
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
