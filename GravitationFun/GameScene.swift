//  Created by Dominik Hauser on 22.12.21.
//  
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

  var satelliteNodes: [Satellite] = []
  var emitterBox: SKEmitterNode?
  var emitterRectangle: SKEmitterNode?
  var explosionEmitter: SKEmitterNode?
  var backgroundEmitter: SKEmitterNode?
//  var gravityNode: SKFieldNode?
  var touchedNodes: [UITouch:Satellite] = [:]
  var velocityNodes: [UITouch:SKShapeNode] = [:]
  var satelliteType: SatelliteType = .box
  var trailLength: TrailLength = .long
  private var showTrails = true
  private var musicAudioNode: SKAudioNode?
  var colorSetting: ColorSetting = .multiColor {
    didSet {
      for node in satelliteNodes {
        node.updateColor(for: colorSetting)
      }
    }
  }
  var soundEnabled = true {
    didSet {
      if soundEnabled, satelliteNodes.count > 0 {
        setSound(enabled: true)
      } else if false == soundEnabled {
        setSound(enabled: false)
      }
    }
  }

  override init() {
    super.init(size: CGSize(width: 750, height: 1334))

    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    physicsWorld.gravity = .zero
  }

  required init?(coder aDecoder: NSCoder) { fatalError() }

  override func didMove(to view: SKView) {

    physicsWorld.contactDelegate = self

    backgroundEmitter = NodeFactory.backgroundEmitter(size: size)
    if let backgroundEmitter = backgroundEmitter {
      addChild(backgroundEmitter)
    }

    let centerNode = NodeFactory.center()
    addChild(centerNode)

    emitterBox = SKEmitterNode(fileNamed: "trail_box")
    emitterBox?.targetNode = self

    emitterRectangle = SKEmitterNode(fileNamed: "trail_rectangle")
    emitterRectangle?.targetNode = self

    explosionEmitter = SKEmitterNode(fileNamed: "explosion")

    let gravityNode = SKFieldNode.radialGravityField()
    gravityNode.falloff = 1.2
    addChild(gravityNode)
//    self.gravityNode = gravityNode

    let cameraNode = SKCameraNode()
    addChild(cameraNode)
    camera = cameraNode

    let musicAudioNode = SKAudioNode(fileNamed: "gravity.m4a")
    self.musicAudioNode = musicAudioNode

    backgroundColor = .black
  }

  func touchDown(_ touch: UITouch) {

    let pos = touch.location(in: self)
    let node = Satellite(position: pos, type: satelliteType)
    satelliteNodes.append(node)
    addChild(node)
    touchedNodes[touch] = node
  }

  func touchMoved(_ touch: UITouch) {

    let movePosition = touch.location(in: self)

    if let node = touchedNodes[touch] {
      node.addColor(forMovedPosition: movePosition, colorSetting: colorSetting)

      if let velocityNode = velocityNodes[touch] {
        velocityNode.removeFromParent()
      }

      let velocityNode = NodeFactory.velocity(from: node.position, to: movePosition)
      insertChild(velocityNode, at: 0)
      velocityNodes[touch] = velocityNode
    }
  }

  func touchUp(_ touch: UITouch) {

    let endPosition = touch.location(in: self)

    if let velocityNode = velocityNodes[touch] {
      velocityNode.removeFromParent()
    }

    velocityNodes.removeValue(forKey: touch)

    if let node = touchedNodes[touch] {
      let position = node.position
      let velocity = CGVector(dx: position.x - endPosition.x, dy: position.y - endPosition.y)
      node.addPhysicsBody(with: velocity)

      if showTrails {
        node.addEmitter(emitterBox: emitterBox, emitterRectangle: emitterRectangle)
      }
    }

    if satelliteNodes.count == 1, soundEnabled {
      setSound(enabled: true)
    }

    touchedNodes.removeValue(forKey: touch)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    NotificationCenter.default.post(name: closeSettingsNotificationName, object: nil)
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

    emitterBox?.particleLifetime = length.lifetime()
    emitterRectangle?.particleLifetime = length.lifetime()

    switch length {
      case .none:
        break
      case .short, .long:
        setEmitter(enabled: true)
    }
  }

  func setEmitter(enabled: Bool) {

    showTrails = enabled

    for node in satelliteNodes {
      if enabled {
        node.addEmitter(emitterBox: emitterBox, emitterRectangle: emitterRectangle)
      } else {
        let allEmitter = node.children.filter { $0 is SKEmitterNode }
        for emitter in allEmitter {
          emitter.removeFromParent()
        }
      }
    }
  }

  func setStars(enabled: Bool) {
    if let backgroundEmitter = backgroundEmitter {
      if enabled, backgroundEmitter.parent == nil {
        insertChild(backgroundEmitter, at: 0)
      } else {
        backgroundEmitter.removeFromParent()
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

  func setColorSetting(_ setting: ColorSetting) {
    colorSetting = setting
  }

  func random() {
    let satellites = Satellite.random(sceneSize: size, type: satelliteType, colorSetting: colorSetting)
    for satellite in satellites {
      if trailLength != .none {
        satellite.addEmitter(emitterBox: emitterBox, emitterRectangle: emitterRectangle)
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
      if let node = contact.bodyA.node as? Satellite {
        satelliteNodes.removeAll { $0 == node }
        explosion(at: node.position)
        moveEmitter(node: node)
        node.removeFromParent()
      }
    } else if contact.bodyB.categoryBitMask == PhysicsCategory.satellite {
      if let node = contact.bodyB.node as? Satellite {
        satelliteNodes.removeAll { $0 == node }
        explosion(at: node.position)
        moveEmitter(node: node)
        node.removeFromParent()
      }
    }

    if satelliteNodes.count == 0 {
      setSound(enabled: false)
    }
  }
}

extension GameScene {
  func explosion(at position: CGPoint) {
    let emitter = explosionEmitter?.copy() as? SKEmitterNode
    emitter?.position = position
    if let emitter = emitter {
      addChild(emitter)
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        emitter.removeFromParent()
      }
    }
  }

  func moveEmitter(node: Satellite) {
    let emitters = node.children.filter({ $0 is SKEmitterNode }) as! [SKEmitterNode]
    for emitter in emitters {
      emitter.removeFromParent()
      emitter.position = node.position
      emitter.numParticlesToEmit = 0
      emitter.particleBirthRate = 0
      addChild(emitter)
      DispatchQueue.main.asyncAfter(deadline: .now() + trailLength.lifetime()) {
        emitter.removeFromParent()
      }
    }
  }
}
