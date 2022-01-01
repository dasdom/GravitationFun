//  Created by Dominik Hauser on 01.01.22.
//  Copyright © 2022 dasdom. All rights reserved.
//

import Foundation
import SpriteKit

struct NodeFactory {
  static func center() -> SKShapeNode {
    let node = SKShapeNode(circleOfRadius: 5)
    node.lineWidth = 0.1
    node.fillColor = .black
    node.physicsBody = SKPhysicsBody(circleOfRadius: 10)
    node.physicsBody?.isDynamic = false
    node.physicsBody?.categoryBitMask = PhysicsCategory.center
    node.physicsBody?.contactTestBitMask = PhysicsCategory.satellite
    return node
  }

  static func backgroundEmitter(size: CGSize) -> SKEmitterNode? {
    let node = SKEmitterNode(fileNamed: "background")
    node?.particlePositionRange = CGVector(dx: size.width*1.5, dy: size.height*1.5)
    node?.particleLifetime = CGFloat.greatestFiniteMagnitude
    return node
  }

  static func velocity(from: CGPoint, to: CGPoint) -> SKShapeNode {
    let bezierPath = UIBezierPath()
    bezierPath.move(to: from)
    bezierPath.addLine(to: to)
    let node = SKShapeNode(path: bezierPath.cgPath)
    node.strokeColor = .white
    node.lineWidth = 2
    return node
  }
}
