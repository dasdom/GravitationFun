//  Created by Dominik Hauser on 22.12.21.
//  
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

  var shapeNodes: [SKSpriteNode] = []
  var velocityNode: SKShapeNode?
  var centerNode: SKShapeNode?
  var emitter: SKEmitterNode?

  override func didMove(to view: SKView) {

//    // Create shape node to use during mouse interaction
//    let w = (self.size.width + self.size.height) * 0.05
//    self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//
//    if let spinnyNode = self.spinnyNode {
//      spinnyNode.lineWidth = 2.5
//
//      spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//      spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                        SKAction.fadeOut(withDuration: 0.5),
//                                        SKAction.removeFromParent()]))
//    }

    physicsWorld.contactDelegate = self

    let centerNode = SKShapeNode(circleOfRadius: 10)
    centerNode.physicsBody = SKPhysicsBody(circleOfRadius: 10)
    centerNode.physicsBody?.isDynamic = false
    centerNode.physicsBody?.categoryBitMask = PhysicsCategory.center
    centerNode.physicsBody?.contactTestBitMask = PhysicsCategory.satellite
    addChild(centerNode)
    self.centerNode = centerNode

    emitter = SKEmitterNode(fileNamed: "trail")
    emitter?.targetNode = self
  }


  func touchDown(atPoint pos : CGPoint) {
//    if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//      n.position = pos
//      n.strokeColor = SKColor.green
//      self.addChild(n)
//    }

    let shapeNode = SKSpriteNode(color: .white, size: CGSize(width: 10, height: 10))
    shapeNode.position = pos
    shapeNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    shapeNodes.append(shapeNode)
    addChild(shapeNode)
  }

  func touchMoved(toPoint pos : CGPoint) {
//    if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//      n.position = pos
//      n.strokeColor = SKColor.blue
//      self.addChild(n)
//    }

    if let node = shapeNodes.last {
      let position = node.position
      let length = sqrt(pow(pos.x - position.x, 2) + pow(pos.y - position.y, 2))
      let ratio = min(length/100, 1)
      let color = UIColor(hue: ratio, saturation: 0.8, brightness: 0.8, alpha: 1)
      node.color = color

      if let velocityNode = velocityNode {
        velocityNode.removeFromParent()
      }

      let bezierPath = UIBezierPath()
      bezierPath.move(to: position)
      bezierPath.addLine(to: pos)
      let velocityNode = SKShapeNode(path: bezierPath.cgPath)
      velocityNode.strokeColor = .white
      velocityNode.lineWidth = 2
      insertChild(velocityNode, at: 0)
      self.velocityNode = velocityNode
    }
  }

  func touchUp(atPoint pos : CGPoint) {
//    if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//      n.position = pos
//      n.strokeColor = SKColor.red
//      self.addChild(n)
//    }

    if let velocityNode = velocityNode {
      velocityNode.removeFromParent()
    }

    if let node = shapeNodes.last {
      node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 10), center: position)
      node.physicsBody?.friction = 0
      node.physicsBody?.restitution = 0
      node.physicsBody?.linearDamping = 0
      node.physicsBody?.angularDamping = 0
      node.physicsBody?.categoryBitMask = PhysicsCategory.satellite
      node.physicsBody?.contactTestBitMask = PhysicsCategory.center
      let position = node.position
      node.physicsBody?.velocity = CGVector(dx: position.x - pos.x, dy: position.y - pos.y)

      guard let emitterCopy = emitter?.copy() as? SKEmitterNode else { fatalError() }

      emitterCopy.particleColor = node.color
      node.addChild(emitterCopy)
    }

    removeUseless()
  }

  func removeUseless() {
    let nodesWithoutPhysics = shapeNodes.filter { $0.physicsBody == nil }
    for node in nodesWithoutPhysics {
      node.removeFromParent()
      shapeNodes.removeAll(where: { $0 == node })
    }

    if let velocityNode = velocityNode {
      velocityNode.removeFromParent()
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard touches.count == 1 else {
      removeUseless()
      return
    }
    if let touch = touches.first {
      self.touchDown(atPoint: touch.location(in: self))
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard touches.count == 1 else {
      removeUseless()
      return
    }
    if let touch = touches.first {
      self.touchMoved(toPoint: touch.location(in: self))
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard touches.count == 1 else {
      removeUseless()
      return
    }
    if let touch = touches.first {
      self.touchUp(atPoint: touch.location(in: self))
    }
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard touches.count == 1 else {
      removeUseless()
      return
    }
    if let touch = touches.first {
      self.touchUp(atPoint: touch.location(in: self))
    }
  }


  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
  }
}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
//    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
//    if collision == PhysicsCategory.center | PhysicsCategory.bullet {
//    }

    if contact.bodyA.categoryBitMask == PhysicsCategory.satellite {
      if let node = contact.bodyA.node {
        shapeNodes.removeAll { $0 == node }
        node.removeFromParent()
      }
    } else if contact.bodyB.categoryBitMask == PhysicsCategory.satellite {
      if let node = contact.bodyB.node {
        shapeNodes.removeAll { $0 == node }
        node.removeFromParent()
      }
    }
  }
}
