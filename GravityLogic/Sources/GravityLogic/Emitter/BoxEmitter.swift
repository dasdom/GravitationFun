//  Created by Dominik Hauser on 03.01.22.
//  
//

import SpriteKit

class BoxEmitter: RectangleEmitter {
  override init() {
    super.init()

    particleBirthRate = 50
    particlePositionRange = CGVector(dx: 3, dy: 3)
  }

  required init?(coder aDecoder: NSCoder) { fatalError() }
}
