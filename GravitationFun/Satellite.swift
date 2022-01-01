//  Created by Dominik Hauser on 27.12.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SpriteKit

enum SatelliteType: Int {
  case box
  case rectangle
}

class Satellite: SKSpriteNode {

  let type: SatelliteType

  class func random(amount: Int = 10, sceneSize: CGSize, type: SatelliteType) -> [Satellite] {
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

      let satellite = Satellite(position: position, type: type)
      let randomXVelocity = CGFloat.random(in: -20...20)
      let length = sqrt(pow(randomXVelocity, 2) + pow(randomYVelocity, 2))
      let ratio = min(length/150, 1)
      let color = UIColor(hue: ratio, saturation: 1, brightness: 0.9, alpha: 1)
//      let color = UIColor(white: ratio, alpha: 1.0)
      satellite.color = color
      let velocity = CGVector(dx: randomXVelocity, dy: randomYVelocity)
      satellite.addPhysicsBody(with: velocity)

      satellites.append(satellite)
    }
    return satellites
  }

  init(position: CGPoint, type: SatelliteType) {

    let size: CGSize
    switch type {
      case .box:
        size = CGSize(width: 10, height: 10)
      case .rectangle:
        size = CGSize(width: 5, height: 20)
    }

    self.type = type

    super.init(texture: nil, color: .white, size: size)

    self.position = position
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    zPosition = 2
  }

  required init?(coder aDecoder: NSCoder) { fatalError() }

  func addColor(forMovedPosition movePosition: CGPoint) {
    let length = sqrt(pow(movePosition.x - position.x, 2) + pow(movePosition.y - position.y, 2))
    let ratio = min(length/150, 1)
    color = UIColor(hue: ratio, saturation: 0.8, brightness: 0.9, alpha: 1)
  }

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

  func addEmitter(emitterBox: SKEmitterNode?, emitterRectangle: SKEmitterNode?) {

    switch type {
      case .box:
        guard let emitterCopy = emitterBox?.copy() as? SKEmitterNode else {
          return
        }

        emitterCopy.particleColor = color
        addChild(emitterCopy)

      case .rectangle:
        guard let emitterCopy = emitterRectangle?.copy() as? SKEmitterNode else {
          return
        }

        emitterCopy.particleColor = color
        emitterCopy.position = CGPoint(x: 0, y: -10)
        addChild(emitterCopy)

        guard let emitterCopy2 = emitterRectangle?.copy() as? SKEmitterNode else {
          return
        }

        emitterCopy2.particleColor = color
        addChild(emitterCopy2)

        emitterCopy2.position = CGPoint(x: 0, y: 10)
    }
  }
}
