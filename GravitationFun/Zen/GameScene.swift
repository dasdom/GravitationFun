//  Created by Dominik Hauser on 22.12.21.
//  
//

import SpriteKit
import GameplayKit
import GravityLogic

class GameScene: SKScene {

  let model = GravityModel()
  var zoomValue: CGFloat = 1.0
  override class var supportsSecureCoding: Bool {
    return true
  }

  override init() {
    super.init(size: CGSize(width: 750, height: 1334))

    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    physicsWorld.gravity = .zero
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func didMove(to view: SKView) {

//    NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

    physicsWorld.contactDelegate = self

    model.setup(scene: self)

    let cameraNode = SKCameraNode()
    addChild(cameraNode)
    camera = cameraNode

    if nil == model.musicAudioNode {
      let musicAudioNode = SKAudioNode(fileNamed: "gravity.m4a")
      model.addSound(node: musicAudioNode)
    }

    backgroundColor = .black
  }

//  @objc func applicationDidEnterBackground() {
//    do {
//      let sceneData = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
//      UserDefaults.standard.set(sceneData, forKey: "currentScene")
//    } catch {
//      print("\(#file), \(#line): \(error)")
//    }
//  }

  class func loadScene(from data: Data) -> GameScene? {
    let scene: GameScene?

    do {
      if let savedScene = try NSKeyedUnarchiver.unarchivedObject(ofClass: GameScene.self, from: data) {
        scene = savedScene
      } else {
        scene = nil
      }
    } catch {
      scene = nil
    }

    return scene
  }

  // https://stackoverflow.com/a/31502698/498796
  override func update(_ currentTime: TimeInterval) {
    if model.realGravity {
      let strength: CGFloat = 10
      let dt: CGFloat = 1.0/60.0
      for node1 in model.satelliteNodes {
        for node2 in model.satelliteNodes {
          if nil == node1.physicsBody || nil == node2.physicsBody {
            continue
          }
          let m1 = node1.physicsBody!.mass*strength
          let m2 = node2.physicsBody!.mass*strength
          let disp = CGVector(dx: node2.position.x-node1.position.x, dy: node2.position.y-node1.position.y)
          let radius = sqrt(disp.dx*disp.dx+disp.dy*disp.dy)
          if radius < node1.size.width*1.3 { //Radius lower-bound.
            continue
          }
          let force = (m1*m2)/(radius*radius);
          let normal = CGVector(dx: disp.dx/radius, dy: disp.dy/radius)
          let impulse = CGVector(dx: normal.dx*force*dt, dy: normal.dy*force*dt)

          node1.physicsBody!.velocity = CGVector(dx: node1.physicsBody!.velocity.dx + impulse.dx, dy: node1.physicsBody!.velocity.dy + impulse.dy)
        }
      }
    }
  }

  func touchDown(_ touch: UITouch) {
    print("\(touch)")
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
    self.zoomValue = zoomValue
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

  func fire() {
    let projectile = model.projectile(size: size)
    addChild(projectile)
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
    if contact.bodyA.categoryBitMask == PhysicsCategory.projectile {
      if let node = contact.bodyA.node {
        node.removeFromParent()
      }
    } else if contact.bodyB.categoryBitMask == PhysicsCategory.projectile {
      if let node = contact.bodyB.node {
        node.removeFromParent()
      }
    }
  }
}
