//  Created by Dominik Hauser on 02.01.22.
//  Copyright © 2022 dasdom. All rights reserved.
//

import XCTest
@testable import Gravity
import SpriteKit

class GameSceneTests: XCTestCase {

  var sut: GameScene!
  var skView: SKView!

  override func setUpWithError() throws {
    skView = SKView(frame: UIScreen.main.bounds)
    sut = GameScene()
    skView.presentScene(sut)
  }

  override func tearDownWithError() throws {
    skView = nil
    sut = nil
  }

}
