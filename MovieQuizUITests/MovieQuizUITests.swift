import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }

    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot()

        app.buttons["Yes"].tap()
        sleep(3)

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot()
        let indexLabel = app.staticTexts["Index"]

        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testNoButton() {
        sleep(3)

        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["No"].tap()
        sleep(3)

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]

        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testGameFinish() {
        for _ in 1...10 {
            let button = app.buttons["Нет"]
            guard button.wait(for: \.isHittable, toEqual: true, timeout: 5)
            else {
                XCTFail("Button not found")
                return
            }
            button.tap()
        }

        let alert = app.alerts["Final game"]
        guard alert.waitForExistence(timeout: 5)
        else {
            XCTFail("Alert not found")
            return
        }
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }

    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }

        let alert = app.alerts["Final game"]
        alert.buttons.firstMatch.tap()

        sleep(2)

        let indexLabel = app.staticTexts["Index"]

        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
