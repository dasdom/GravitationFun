//  Created by Dominik Hauser on 22.12.21.
//  
//

import SpriteKit
import GameplayKit

enum TrailLength: Int {
  case none
  case short
  case long
}

class GameScene: SKScene {

  var satelliteNodes: [SKSpriteNode] = []
  var centerNode: SKShapeNode?
  var emitter: SKEmitterNode?
  var gravityNode: SKFieldNode?
  var touchedNodes: [UITouch:Satellite] = [:]
  var velocityNodes: [UITouch:SKShapeNode] = [:]
  var satelliteType: SatelliteType = .box
  var trailLength: TrailLength = .long
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
    centerNode.lineWidth = 0.5
    centerNode.glowWidth = 0.5
    centerNode.fillColor = .black
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

    let cameraNode = SKCameraNode()
    addChild(cameraNode)
    camera = cameraNode

    let musicAudioNode = SKAudioNode(fileNamed: "gravity.m4a")
    self.musicAudioNode = musicAudioNode
  }

  func touchDown(_ touch: UITouch) {

    let pos = touch.location(in: self)
    let node = Satellite(position: pos, type: satelliteType)
    satelliteNodes.append(node)
    addChild(node)
    touchedNodes[touch] = node
  }

  func touchMoved(_ touch: UITouch) {

    let pos = touch.location(in: self)

    if let node = touchedNodes[touch] {
      let position = node.position
      let length = sqrt(pow(pos.x - position.x, 2) + pow(pos.y - position.y, 2))
      let ratio = min(length/150, 1)
      let color = UIColor(hue: ratio, saturation: 0.8, brightness: 0.9, alpha: 1)
      node.color = color

      if let velocityNode = velocityNodes[touch] {
        velocityNode.removeFromParent()
      }

      let bezierPath = UIBezierPath()
      bezierPath.move(to: position)
      bezierPath.addLine(to: pos)
      let velocityNode = SKShapeNode(path: bezierPath.cgPath)
      velocityNode.strokeColor = .white
      velocityNode.lineWidth = 2
      insertChild(velocityNode, at: 0)
      velocityNodes[touch] = velocityNode
    }
  }

  func touchUp(_ touch: UITouch) {

    let pos = touch.location(in: self)

    if let velocityNode = velocityNodes[touch] {
      velocityNode.removeFromParent()
    }

    velocityNodes.removeValue(forKey: touch)

    if let node = touchedNodes[touch] {
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

    touchedNodes.removeValue(forKey: touch)
  }

  func removeUseless() {
    let nodesWithoutPhysics = satelliteNodes.filter { $0.physicsBody == nil }
    for node in nodesWithoutPhysics {
      node.removeFromParent()
      satelliteNodes.removeAll(where: { $0 == node })
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      touchDown(touch)
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      touchMoved(touch)
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      touchUp(touch)
    }
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      touchUp(touch)
    }
  }

  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
  }

  func setTrailLength(to length: TrailLength) {

    trailLength = length

    setEmitter(enabled: false)

    switch length {
      case .none:
        break
      case .short:
        emitter?.particleLifetime = 1
        setEmitter(enabled: true)
      case .long:
        emitter?.particleLifetime = 10
        setEmitter(enabled: true)
    }
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

  func zoom(to zoomValue: CGFloat) {
    let zoomInAction = SKAction.scale(to: 1-(zoomValue-1), duration: 0.3)
    camera?.run(zoomInAction)
  }

  func setSound(enabled: Bool) {
    if enabled, soundEnabled {
      if let musicAudioNode = musicAudioNode, musicAudioNode.parent == nil {
        musicAudioNode.autoplayLooped = true
        musicAudioNode.isPositional = false
        musicAudioNode.run(SKAction.changeVolume(to: 0.5, duration: 0))
        addChild(musicAudioNode)
      }
    } else {
      self.musicAudioNode?.removeFromParent()
    }
  }

  func random() {
    let satellites = Satellite.random(sceneSize: size, type: satelliteType)
    for satellite in satellites {
      if trailLength != .none {
        satellite.addEmitter(emitter: emitter)
      }
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
