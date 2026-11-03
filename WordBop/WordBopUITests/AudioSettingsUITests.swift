import XCTest

final class AudioSettingsUITests: XCTestCase {
    @MainActor
    func testIndependentNativeVolumeSliders() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US",
                               "-wordBopSoundVolume", "0.4", "-wordBopMusicVolume", "0.7"]
        app.launch()
        let settings = app.buttons["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 10))
        settings.tap()
        let sound = app.sliders["Sound Volume"]
        let music = app.sliders["Music Volume"]
        let scroll = app.scrollViews.firstMatch
        for _ in 0..<10 {
            if sound.isHittable && music.isHittable { break }
            let start = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.8))
            let end = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.35))
            start.press(forDuration: 0.05, thenDragTo: end)
        }
        XCTAssertTrue(sound.isHittable)
        XCTAssertTrue(music.isHittable)
        XCTAssertFalse(app.sliders["Game Volume"].exists)
        XCTAssertEqual(sound.value as? String, "40 percent")
        XCTAssertEqual(music.value as? String, "70 percent")
        sound.adjust(toNormalizedSliderPosition: 0.2)
        XCTAssertEqual(music.value as? String, "70 percent")
        let soundValue = sound.value as? String
        music.adjust(toNormalizedSliderPosition: 0.9)
        XCTAssertEqual(sound.value as? String, soundValue)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Independent audio volume sliders"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
