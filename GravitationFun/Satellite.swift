//  Created by Dominik Hauser on 27.12.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SpriteKit

class Satellite: SKSpriteNode {

  class func random(amount: Int = 10, sceneSize: CGSize, emitter: SKEmitterNode?) -> [Satellite] {
    var satellites: [Satellite] = []
    let left = Bool.random()
    for _ in 0..<amount {
      let maxValue = sceneSize.width/2 - 10
      var randomX = CGFloat.random(in: 50..<maxValue)
      let randomYVelocity = CGFloat.random(in: 20..<200)
      if left {
        randomX *= -1
      }
      let position = CGPoint(x: randomX, y: 0)

      let satellite = Satellite(position: position)
      let randomXVelocity = CGFloat.random(in: -20...20)
      let length = sqrt(pow(randomXVelocity, 2) + pow(randomYVelocity, 2))
      let ratio = min(length/150, 1)
      let color = UIColor(hue: ratio, saturation: 0.8, brightness: 0.9, alpha: 1)
      satellite.color = color
      let velocity = CGVector(dx: randomXVelocity, dy: randomYVelocity)
      satellite.addPhysicsBody(with: velocity)

      satellite.addEmitter(emitter: emitter)

      satellites.append(satellite)
    }
    return satellites
  }

  init(position: CGPoint) {
    super.init(texture: nil, color: .white, size: CGSize(width: 10, height: 10))

    self.position = position
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    zPosition = 2
  }

  required init?(coder aDecoder: NSCoder) { fatalError() }

  func addPhysicsBody(with velecity: CGVector) {
    self.physicsBody = SKPhysicsBody(rectangleOf: size)
    physicsBody?.friction = 0
    physicsBody?.restitution = 0
    physicsBody?.linearDamping = 0
    physicsBody?.angularDamping = 0
    physicsBody?.categoryBitMask = PhysicsCategory.satellite
    physicsBody?.contactTestBitMask = PhysicsCategory.center
    physicsBody?.velocity = velecity
  }

  func addEmitter(emitter: SKEmitterNode?) {
    guard let emitterCopy = emitter?.copy() as? SKEmitterNode else { fatalError() }

    emitterCopy.particleColor = color
    addChild(emitterCopy)
  }
}
