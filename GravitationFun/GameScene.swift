//  Created by Dominik Hauser on 22.12.21.
//  
//

import SpriteKit
import GameplayKit
import GravityLogic

class GameScene: SKScene {

  let model = GravityModel()

  override init() {
    super.init(size: CGSize(width: 750, height: 1334))

    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    physicsWorld.gravity = .zero
  }

  required init?(coder aDecoder: NSCoder) { fatalError() }

  override func didMove(to view: SKView) {

    physicsWorld.contactDelegate = self

    model.setup(scene: self)

    let cameraNode = SKCameraNode()
    addChild(cameraNode)
    camera = cameraNode

    let musicAudioNode = SKAudioNode(fileNamed: "gravity.m4a")
    model.addSound(node: musicAudioNode)

    backgroundColor = .black
  }

  func touchDown(_ touch: UITouch) {
    
    let position = touch.location(in: self)
    let node = model.satellite(with: position, id: touch.hash)
    addChild(node)
  }

  func touchMoved(_ touch: UITouch) {

    let movePosition = touch.location(in: self)

    if let velocityNode = model.updateVelocity(id: touch.hash, input: movePosition) {
      insertChild(velocityNode, at: 0)
    }
  }

  func touchUp(_ touch: UITouch) {

    let endPosition = touch.location(in: self)

    if let sound = model.sound() {
      addChild(sound)
    }

    model.addVelocityToSatellite(id: touch.hash, input: endPosition)
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
    model.trailLength = length
  }

  func setFriction(to friction: Friction) {
    model.friction = friction
  }

  func setSpawnMode(_ mode: SpawnMode) {
    model.spawnMode = mode
  }

  func setStars(enabled: Bool) {
    if enabled, let stars = model.stars() {
      insertChild(stars, at: 0)
    } else {
      model.disableStars()
    }
  }

  func zoom(to zoomValue: CGFloat) {
    let zoomInAction = SKAction.scale(to: 1-(zoomValue-1), duration: 0.3)
    camera?.run(zoomInAction)
  }

  func setSound(enabled: Bool) {
    if enabled {
      model.enableSound()
      if let sound = model.sound() {
        addChild(sound)
      }
    } else {
      model.disableSound()
    }
  }

  func setSatelliteType(_ type: SatelliteType) {
    model.currentSatelliteType = type
  }

  func setColorSetting(_ setting: ColorSetting) {
    model.colorSetting = setting
  }

  func random() {
    let (nodes, sound) = model.random(size: size)
    for node in nodes {
      addChild(node)
    }

    if let sound = sound {
      addChild(sound)
    }
  }

  func clear() {
    model.clear()
  }
}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {

    if contact.bodyA.categoryBitMask == PhysicsCategory.satellite {
      if let node = contact.bodyA.node {
        model.remove(node, moveEmitterTo: self)
      }
    } else if contact.bodyB.categoryBitMask == PhysicsCategory.satellite {
      if let node = contact.bodyB.node {
        model.remove(node, moveEmitterTo: self)
      }
    }
  }
}
