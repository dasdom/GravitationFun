//  Created by Dominik Hauser on 31.12.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import XCTest

class GravityUITests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func test_takeScreenshots() throws {
    // UI tests must launch the application that they test.
    let app = XCUIApplication()
    app.launch()

    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

    let forwardButton = app.buttons["Forward"]
    let backButton = app.buttons["Back"]
    let diceButton = app.buttons["dice"]
    let trashButton = app.buttons["trash"]
    let saveButton = app.buttons["Save"]
    let loadButton = app.buttons["Load"]
    let shareButton = app.buttons["Share"]
    let doneButton = app.buttons["Done"]
    let thickButton = app.buttons["thick"]
    let normalButton = app.buttons["normal"]

    forwardButton.tap()
    for _ in 0..<5 {
      sleep(2)
      diceButton.tap()
    }

    thickButton.tap()
    backButton.tap()

    sleep(40)

    takeScreenshot(named: "circles_1")

    forwardButton.tap()
    saveButton.tap()

    trashButton.tap()

    for _ in 0..<5 {
      sleep(2)
      diceButton.tap()
    }

    thickButton.tap()
    backButton.tap()

    sleep(50)

    takeScreenshot(named: "circles_2")

    forwardButton.tap()
    normalButton.tap()
    backButton.tap()

    sleep(50)

    takeScreenshot(named: "circles_3")

    forwardButton.tap()
    saveButton.tap()

//    app.buttons["rectangle"].tap()
//
//    for _ in 0..<5 {
//      sleep(2)
//      diceButton.tap()
//    }
//    backButton.tap()
//
//    sleep(20)
//
//    takeScreenshot(named: "rectangles")

    takeScreenshot(named: "settings")

    loadButton.tap()

    takeScreenshot(named: "saved")

    doneButton.tap()

    app.switches["Show zoom buttons"].tap()
    backButton.tap()

    app.buttons["Decrement"].tap()
    app.buttons["Decrement"].tap()
    app.buttons["Decrement"].tap()

    takeScreenshot(named: "zoomed_out")

    forwardButton.tap()
    shareButton.tap()

    takeScreenshot(named: "share")
  }
  
}

extension GravityUITests {
  func takeScreenshot(named name: String) {
    sleep(1)

    // Take the screenshot
    let fullScreenshot = XCUIScreen.main.screenshot()

    // Create a new attachment to save our screenshot
    // and give it a name consisting of the "named"
    // parameter and the device name, so we can find
    // it later.
    let screenshotAttachment = XCTAttachment(
      uniformTypeIdentifier: "public.png",
      name: "Screenshot-\(UIDevice.current.name)-\(name).png",
      payload: fullScreenshot.pngRepresentation,
      userInfo: nil)

    // Usually Xcode will delete attachments after
    // the test has run; we don't want that!
    screenshotAttachment.lifetime = .keepAlways

    // Add the attachment to the test log,
    // so we can retrieve it later
    add(screenshotAttachment)
  }
}
