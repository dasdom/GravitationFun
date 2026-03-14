//  Created by Dominik Hauser on 22.12.21.
//  
//

import SpriteKit
import GameplayKit
import OSLog

class GameScene: SKScene {

  let model = GravityModel()
  var zoomValue: CGFloat = 1.0
  var numberOfSatellites = 0
  var updateSatellitesHandler: ((Int) -> Void)?
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
    if model.satelliteNodes.count != numberOfSatellites {
      updateSatellitesHandler?(model.satelliteNodes.count)
      numberOfSatellites = model.satelliteNodes.count
    }

    if model.mode == .gravity {
      let strength: CGFloat = 10
      let dt: CGFloat = 1.0/60.0
      for node1 in model.satelliteNodes {
        let distance = sqrt(node1.position.x*node1.position.x+node1.position.y*node1.position.y)
        if distance > 3000 {
          print("distance: \(distance), removing")
          model.clear(nodes: [node1])
          continue
        }
        for node2 in model.satelliteNodes {
          if nil == node1.physicsBody || nil == node2.physicsBody {
            continue
          }
          if node1 == node2 {
            continue
          }
          let m1 = node1.physicsBody!.mass*strength
          let m2 = node2.physicsBody!.mass*strength
          let disp = CGVector(dx: node2.position.x-node1.position.x, dy: node2.position.y-node1.position.y)
          let radius = sqrt(disp.dx*disp.dx+disp.dy*disp.dy)
          if radius < node1.radius*1.3 { //Radius lower-bound.
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
    let logger = Logger(subsystem: "GravityFun", category: "GameScene")
    logger.info("\(touch)")
    NSLog("%@", touch)
    if model.mode == .spirograph,
       model.satelliteNodes.count > 9 {
      return
    }
    let position = touch.location(in: self)
    let node = model.satellite(with: position, radius: model.radius, id: touch.hash)
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

  func setColorSetting(_ setting: ColorSetting) {
    model.colorSetting = setting
  }

  func random(direction: Direction) {
    let (nodes, _) = model.random(sceneSize: size, radius: model.radius, direction: direction)
    for node in nodes {
      addChild(node)
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
        model.remove(node, explosionIn: self)
      }
    } else if contact.bodyB.categoryBitMask == PhysicsCategory.satellite {
      if let node = contact.bodyB.node {
        model.remove(node, explosionIn: self)
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
