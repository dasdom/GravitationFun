//  Created by Dominik Hauser on 30.12.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SpriteKit

struct Background {
  static func add(_ count: Int, starsTo scene: SKScene) {
    let size = scene.size

    for _ in 0..<count {
      let randomX = CGFloat.random(in: -size.width...size.width)
      let randomY = CGFloat.random(in: -size.height...size.width)
      let radius = CGFloat.random(in: 0.1...0.5)

      let star = SKShapeNode(circleOfRadius: radius)
      star.position = CGPoint(x: randomX, y: randomY)
      star.fillColor = .white
      scene.addChild(star)
    }
  }
}
