//  Created by Dominik Hauser on 27.12.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import SpriteKit

public enum SatelliteType: Int {
  case box
  case rectangle
}

public class Satellite: SKShapeNode {

//  let type: SatelliteType
  public let radius: CGFloat = 5
  var colorRatio: CGFloat = 0
  public override class var supportsSecureCoding: Bool {
    return true
  }

  class func random(amount: Int = 10, sceneSize: CGSize, type: SatelliteType, colorSetting: ColorSetting) -> [Satellite] {
    var satellites: [Satellite] = []
    let left = Bool.random()
    for _ in 0..<amount {
      let maxValue = sceneSize.width/2 - 10
      var randomX = CGFloat.random(in: 50..<maxValue)
      let randomYVelocity = CGFloat.random(in: 50..<200)
      if left {
        randomX *= -1
      }
      let position = CGPoint(x: randomX, y: 0)

      let satellite = Satellite(position: position)
      let randomXVelocity = CGFloat.random(in: -40...40)
      let length = sqrt(pow(randomXVelocity, 2) + pow(randomYVelocity, 2))
      satellite.colorRatio = min(length/150, 1)
      satellite.updateColor(for: colorSetting)
      let velocity = CGVector(dx: randomXVelocity, dy: randomYVelocity)
      satellite.addPhysicsBody(with: velocity)

      satellites.append(satellite)
    }
    return satellites
  }

  init(position: CGPoint) {

//    let size: CGSize
//    switch type {
//      case .box:
//        size = CGSize(width: 10, height: 10)
//      case .rectangle:
//        size = CGSize(width: 5, height: 20)
//    }
//
//    self.type = type

//    super.init(texture: nil, color: .white, size: size)
    super.init()
    path = CGPath(ellipseIn: .init(x: 0, y: 0, width: radius*2, height: radius*2), transform: nil)

    lineWidth = 0
    fillColor = .white

    self.position = position
//    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    zPosition = 2
  }

  required init?(coder aDecoder: NSCoder) {

//    type = .box

    super.init(coder: aDecoder)
  }

  func addColor(forInput input: CGPoint, colorSetting: ColorSetting) {
    let length = sqrt(pow(input.x - position.x, 2) + pow(input.y - position.y, 2))
    colorRatio = min(length/150, 1)
    updateColor(for: colorSetting)
  }

  func updateColor(for colorSetting: ColorSetting) {
    switch colorSetting {
      case .multiColor:
        fillColor = UIColor(hue: colorRatio, saturation: 0.8, brightness: 0.9, alpha: 1)
      case .blackAndWhite:
        fillColor = UIColor(white: colorRatio, alpha: 1)
    }
    let emitters = children.filter({ $0 is SKEmitterNode }) as! [SKEmitterNode]
    for emitter in emitters {
      emitter.particleColor = fillColor
    }
  }

  func addPhysicsBody(with velocity: CGVector) {
    self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
    physicsBody?.friction = 0
//    physicsBody?.restitution = 0
    physicsBody?.linearDamping = 0
    physicsBody?.angularDamping = 0
    physicsBody?.categoryBitMask = PhysicsCategory.satellite
    physicsBody?.contactTestBitMask = PhysicsCategory.center
    physicsBody?.velocity = velocity
    physicsBody?.mass = 10
  }

  func addEmitter(emitterBox: SKEmitterNode?, emitterRectangle: SKEmitterNode?) {

//    switch type {
//      case .box:
        guard let emitterCopy = emitterBox?.copy() as? SKEmitterNode else {
          return
        }

    emitterBox?.position = .init(x: radius, y: radius)

        emitterCopy.particleColor = fillColor
        addChild(emitterCopy)

//      case .rectangle:
//        guard let emitterCopy = emitterRectangle?.copy() as? SKEmitterNode else {
//          return
//        }
//
//        emitterCopy.particleColor = fillColor
//        emitterCopy.position = CGPoint(x: 0, y: -10)
//        addChild(emitterCopy)
//
//        guard let emitterCopy2 = emitterRectangle?.copy() as? SKEmitterNode else {
//          return
//        }
//
//        emitterCopy2.particleColor = fillColor
//        addChild(emitterCopy2)
//
//        emitterCopy2.position = CGPoint(x: 0, y: 10)
//    }
  }
}
