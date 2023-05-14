//  Created by Dominik Hauser on 03.01.22.
//  
//

import SpriteKit

class BoxEmitter: RectangleEmitter {
  override class var supportsSecureCoding: Bool {
    return true
  }
  override init() {
    super.init()

    particleBirthRate = 60
    particlePositionRange = CGVector(dx: 1, dy: 1)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
