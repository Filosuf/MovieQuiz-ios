//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by 1234 on 02.09.2022.
//

import XCTest

// swiftlint:disable all
class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testYesButton() {
        let firstPoster = app.images["Poster"] // находим первоначальный постер

        app.buttons["Yes"].tap() // находим кнопку `Да` и нажимаем её

        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let indexLabel = app.staticTexts["Index"]

        sleep(3)

        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster) // проверяем, что постеры разные
    }

    func testNoButton() {
        let firstPoster = app.images["Poster"] // находим первоначальный постер

        app.buttons["No"].tap() // находим кнопку `Нет` и нажимаем её

        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let indexLabel = app.staticTexts["Index"]

        sleep(3)

        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster) // проверяем, что постеры разные
    }

    func testShowAlert() {
        for _ in 1...10 {
            sleep(3)
            app.buttons["No"].tap() // находим кнопку `Нет` и нажимаем её 10 раз
        }

        let alert = app.alerts["result_alert"] // находим алерт

        sleep(5)

        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!" || alert.label == "Новый рекорд!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Начать новую игру")
    }

    func testHideAlert() {
        for _ in 1...10 {
            sleep(5)
            app.buttons["No"].tap() // находим кнопку `Нет` и нажимаем её 10 раз
        }

        let alert = app.alerts["result_alert"] // находим алерт

        sleep(5)

        alert.buttons.firstMatch.tap() // находим кнопку на алерте `Начать новую игру` и нажимаем её

        sleep(3)

        let indexLabel = app.staticTexts["Index"]

        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
// swiftlint:enable all
