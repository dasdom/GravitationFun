//  Created by Dominik Hauser on 22.12.21.
//  
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

  var satelliteNodes: [SKSpriteNode] = []
  var velocityNode: SKShapeNode?
  var centerNode: SKShapeNode?
  var emitter: SKEmitterNode?
  var gravityNode: SKFieldNode?
  private var showTrails = true
  private var musicAudioNode: SKAudioNode?
  var soundEnabled = true {
    didSet {
      if soundEnabled, satelliteNodes.count > 0 {
        setSound(enabled: true)
      } else if false == soundEnabled {
        setSound(enabled: false)
      }
    }
  }

  override func didMove(to view: SKView) {

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

    let gravityNode = SKFieldNode.radialGravityField()
    gravityNode.falloff = 1.0
    addChild(gravityNode)
    self.gravityNode = gravityNode
  }


  func touchDown(atPoint pos : CGPoint) {

    let spriteNode = Satellite(position: pos)
    satelliteNodes.append(spriteNode)
    addChild(spriteNode)
  }

  func touchMoved(toPoint pos : CGPoint) {

    if let node = satelliteNodes.last {
      let position = node.position
      let length = sqrt(pow(pos.x - position.x, 2) + pow(pos.y - position.y, 2))
      let ratio = min(length/150, 1)
      let color = UIColor(hue: ratio, saturation: 0.8, brightness: 0.9, alpha: 1)
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

    if let velocityNode = velocityNode {
      velocityNode.removeFromParent()
    }

    if let node = satelliteNodes.last as? Satellite {
      let position = node.position
      let velocity = CGVector(dx: position.x - pos.x, dy: position.y - pos.y)
      node.addPhysicsBody(with: velocity)

      if showTrails {
        node.addEmitter(emitter: emitter)
      }
    }

    if satelliteNodes.count == 1, soundEnabled {
      setSound(enabled: true)
    }

    removeUseless()
  }

  func removeUseless() {
    let nodesWithoutPhysics = satelliteNodes.filter { $0.physicsBody == nil }
    for node in nodesWithoutPhysics {
      node.removeFromParent()
      satelliteNodes.removeAll(where: { $0 == node })
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

  func setEmitter(enabled: Bool) {

    showTrails = enabled

    for node in satelliteNodes {
      if enabled, let node = node as? Satellite {
        node.addEmitter(emitter: emitter)
      } else {
        let allEmitter = node.children.filter { $0 is SKEmitterNode }
        for emitter in allEmitter {
          emitter.removeFromParent()
        }
      }
    }
  }

  func setSound(enabled: Bool) {
    if enabled {
      let musicAudioNode = SKAudioNode(fileNamed: "gravity.m4a")
      musicAudioNode.autoplayLooped = true
      musicAudioNode.isPositional = false
      musicAudioNode.run(SKAction.changeVolume(to: 0.5, duration: 0))
      addChild(musicAudioNode)
      self.musicAudioNode = musicAudioNode
    } else {
      self.musicAudioNode?.removeFromParent()
      self.musicAudioNode = nil
    }
  }

  func random() {
    let satellites = Satellite.random(sceneSize: size, emitter: emitter)
    for satellite in satellites {
      addChild(satellite)
    }
    self.satelliteNodes.append(contentsOf: satellites)
    setSound(enabled: true)
  }

  func clear() {
    for node in satelliteNodes {
      node.removeFromParent()
    }
    satelliteNodes.removeAll()
    setSound(enabled: false)
  }
}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {

    if contact.bodyA.categoryBitMask == PhysicsCategory.satellite {
      if let node = contact.bodyA.node {
        satelliteNodes.removeAll { $0 == node }
        node.removeFromParent()
      }
    } else if contact.bodyB.categoryBitMask == PhysicsCategory.satellite {
      if let node = contact.bodyB.node {
        satelliteNodes.removeAll { $0 == node }
        node.removeFromParent()
      }
    }

    if satelliteNodes.count == 0 {
      setSound(enabled: false)
    }
  }
}
