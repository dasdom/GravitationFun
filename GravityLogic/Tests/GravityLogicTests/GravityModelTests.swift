//  Created by Dominik Hauser on 03.01.22.
//  
//

import XCTest
@testable import GravityLogic

class GravityModelTests: XCTestCase {

  var sut: GravityModel!

  override func setUpWithError() throws {
    sut = GravityModel()
  }

  override func tearDownWithError() throws {
    sut = nil
  }

  func test_loadsEmitterBox() {
    XCTAssertNotNil(sut.emitterForBox)
  }

  func test_loadEmitterRectangle() {
    XCTAssertNotNil(sut.emitterForRectangle)
  }

  func test_loadEmitterExplosion() {
    XCTAssertNotNil(sut.explosionEmitter)
  }
}
