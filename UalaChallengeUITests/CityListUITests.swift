//
//  CityListUITests.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 26/3/25.
//

import XCTest

final class CityListViewUITests: XCTestCase {

    var app:XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }

    func testDefaultState() throws {

        // Given
        let cityCell1 = app.buttons["New York USA-cell"]
        let cityCell2 = app.buttons["Los Angeles USA-cell"]
        let cityCell3 = app.buttons["New York Canada-cell"]
        let resultsText = app.staticTexts["Results: 3"]


        // Then
        XCTAssertTrue(cityCell1.exists)
        XCTAssertTrue(cityCell2.exists)
        XCTAssertTrue(cityCell3.exists)
        XCTAssertTrue(resultsText.exists)
    }

    func testSearchCity() throws {
        // Given
        let searchField = app.textFields["customSearchBar"]
        XCTAssertTrue(searchField.exists)

        // When
        searchField.tap()
        searchField.typeText("New York")

        let cityCell1 = app.buttons["New York Canada-cell"]
        let cityCell2 = app.buttons["New York USA-cell"]
        let resultsText = app.staticTexts["Results: 2"]


        // Then
        XCTAssertTrue(cityCell1.exists)
        XCTAssertTrue(cityCell2.exists)
        XCTAssertTrue(resultsText.waitForExistence(timeout: 5))
    }

    func testSearchCityNotFound() throws {
        // Given
        let searchField = app.textFields["customSearchBar"]
        XCTAssertTrue(searchField.exists)

        // When
        searchField.tap()
        searchField.typeText("No Existence")


        // Then
        let resultsText = app.staticTexts["Results: 0"]
        XCTAssertTrue(resultsText.waitForExistence(timeout: 5))
    }

    func testToggleShowFavorites()  throws  {
        // Given
        let toggle = app.switches["FavoriteToggle"].switches.firstMatch
        XCTAssertTrue(toggle.exists)

        toggle.tap()

        // When
        let cityCell1 = app.buttons["New York Canada-cell"]

        // Then
        let resultsText = app.staticTexts["Results: 1"]
        XCTAssertTrue(resultsText.waitForExistence(timeout: 5))
        XCTAssertTrue(cityCell1.waitForExistence(timeout: 5))
    }

    func testToggleShowFavoritesNoMatch() throws  {
        // Given
        let toggle = app.switches["FavoriteToggle"].switches.firstMatch
        XCTAssertTrue(toggle.exists)

        toggle.tap()

        // When
        let searchField = app.textFields["customSearchBar"]
        XCTAssertTrue(searchField.exists)

        searchField.tap()
        searchField.typeText("los angeles")


        // Then
        let resultsText = app.staticTexts["Results: 0"]
        XCTAssertTrue(resultsText.waitForExistence(timeout: 5))
    }

    func testSelectCity() throws {
        // Given
        let cityCell = app.buttons["New York USA-cell"]
        XCTAssertTrue(cityCell.exists)

        // When
        cityCell.tap()

        // Then
        let detailView = app.maps.firstMatch
        XCTAssertTrue(detailView.exists)
    }

    func testSetFavorite() throws {
        // Given
        let cityCell1 = app.buttons["New York USA-cell"]
        let cityCell2 = app.buttons["New York Canada-cell"]
        let favorite = cityCell1.buttons["New York USA-favorite-button"]
        let toggle = app.switches["FavoriteToggle"].switches.firstMatch
        XCTAssertTrue(toggle.exists)

        // When
        favorite.tap()
        toggle.tap()

        let resultsText = app.staticTexts["Results: 2"]

        // Then
        XCTAssertTrue(cityCell1.exists)
        XCTAssertTrue(cityCell2.exists)
        XCTAssertTrue(resultsText.waitForExistence(timeout: 5))

    }

    func testRemoveFavorite() throws {
        // Given
        let cityCell = app.buttons["New York Canada-cell"]
        let favorite = cityCell.buttons["New York Canada-favorite-button"]
        let toggle = app.switches["FavoriteToggle"].switches.firstMatch
        XCTAssertTrue(toggle.exists)

        // When
        favorite.tap()
        toggle.tap()

        let resultsText = app.staticTexts["Results: 0"]

        // Then
        XCTAssertTrue(resultsText.waitForExistence(timeout: 5))
        XCTAssertFalse(cityCell.waitForExistence(timeout: 5))
    }
}
