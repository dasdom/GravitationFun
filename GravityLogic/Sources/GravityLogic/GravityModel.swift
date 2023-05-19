//  Created by Dominik Hauser on 02.01.22.
//  
//

import SpriteKit

public enum SpawnMode: Int {
  case maual
  case automatic
}

public class GravityModel {
  public var satelliteNodes: [Satellite] = []
//  var canon: SKSpriteNode
  var temporaryNodes: [Int:Satellite] = [:]
  var velocityNodes: [Int:SKShapeNode] = [:]
  let emitterForBox: SKEmitterNode
  let emitterForRectangle: SKEmitterNode
  var backgroundEmitter: SKEmitterNode?
  var explosionEmitter: SKEmitterNode?
  private(set) var gravityNode: SKFieldNode
  public var currentSatelliteType: SatelliteType = .box
  public var musicAudioNode: SKAudioNode?
  var soundEnabled = true
  public var mode: GravityMode = .gravity {
    didSet {
      gravityNode.falloff = mode.falloff
      trailLength = mode.trailLength
    }
  }
//  public var spawnMode: SpawnMode = .maual {
//    didSet {
//      let linearDamping: CGFloat
//      switch spawnMode {
//        case .maual:
//          linearDamping = 0
//          gravityNode.falloff = 1.9
//        case .automatic:
//          linearDamping = 0.03
//          gravityNode.falloff = 1
//      }
//      for node in satelliteNodes {
//        node.physicsBody?.linearDamping = linearDamping
//      }
//    }
//  }
//  public var friction: Friction = .none {
//    didSet {
//      let linearDamping = friction.linearDamping
//      for node in satelliteNodes {
//        node.physicsBody?.linearDamping = linearDamping
//      }
//    }
//  }
  public var trailLength: TrailLength = .long {
    didSet {
      setEmitter(enabled: false)

      emitterForBox.particleLifetime = trailLength.lifetime()
      emitterForRectangle.particleLifetime = trailLength.lifetime()

      switch trailLength {
        case .none:
          break
        case .short, .long, .spirograph:
          setEmitter(enabled: true)
      }
    }
  }
  public var particleScale: ParticleScale = .normal {
    didSet {
      setEmitter(enabled: false)
      emitterForBox.particleScale = particleScale.value
      setEmitter(enabled: true)
    }
  }
  public var colorSetting: ColorSetting = .multiColor {
    didSet {
      for node in satelliteNodes {
        node.updateColor(for: colorSetting)
      }
    }
  }

  // MARK: - Setup
  public init() {
    emitterForBox = BoxEmitter()
    emitterForRectangle = RectangleEmitter()
    explosionEmitter = ExplosionEmitter()
    gravityNode = SKFieldNode.radialGravityField()
//    canon = SKSpriteNode(color: .white, size: CGSize(width: 5, height: 20))
  }

  public func setup(scene: SKScene) {
    emitterForBox.targetNode = scene
    emitterForRectangle.targetNode = scene

    backgroundEmitter = NodeFactory.backgroundEmitter(size: scene.size)
    if let backgroundEmitter = backgroundEmitter {
      scene.addChild(backgroundEmitter)
    }

    if scene.children.filter({ $0 is Satellite }).count < 1 {
      scene.addChild(NodeFactory.center())
      gravityNode.falloff = 2.0
      scene.addChild(gravityNode)
//      let secondGravityNode = SKFieldNode.radialGravityField()
//      secondGravityNode.position = .init(x: 100, y: 0)
//      let secondCenter = NodeFactory.center()
//      secondCenter.position = .init(x: 100, y: 0)
//      scene.addChild(secondCenter)
//      scene.addChild(secondGravityNode)
    } else if let gravityNode = scene.children.first(where: { $0 is SKFieldNode }) as? SKFieldNode {
      self.gravityNode = gravityNode
    }

    for child in scene.children {
      if let satellite = child as? Satellite {
        satelliteNodes.append(satellite)
      } else if let emitter = child as? SKEmitterNode, emitter.name == "background" {
        backgroundEmitter = emitter
      } else if let audio = child as? SKAudioNode {
        musicAudioNode = audio
      }
    }
//    let size = scene.size
//    canon.position = CGPoint(x: 0, y: -floor(size.height/2)+30)
//    scene.addChild(canon)
  }

  public func addSound(node: SKAudioNode) {
    musicAudioNode = node
  }

  // MARK: - Satellites

  public func satellite(with position: CGPoint, id: Int) -> SKNode {
    let node = Satellite(position: position)
    satelliteNodes.append(node)
    temporaryNodes[id] = node
    return node
  }

  public func setColorOfSatelliteWith(id: Int, forInput input: CGPoint) {
    let node = temporaryNodes[id]
    node?.addColor(forInput: input, colorSetting: colorSetting)
  }

  public func remove(_ node: SKNode, explosionIn target: SKScene) {
    guard let satellite = node as? Satellite else {
      return
    }
    satelliteNodes.removeAll(where: { $0 == satellite })

    if satelliteNodes.count < 1 {
      musicAudioNode?.removeFromParent()
    }

//    moveEmittersIn(node: satellite, to: target)
    explosion(at: satellite.position, inNode: target)
    satellite.removeFromParent()

//    if spawnMode == .automatic, satelliteNodes.count < 5 {
//      for node in random(size: target.size).nodes {
//        target.addChild(node)
//      }
//    }
  }

  // MARK: - Sound

  public func sound() -> SKAudioNode? {
    guard let musicAudioNode = musicAudioNode,
          musicAudioNode.parent == nil,
          soundEnabled,
          satelliteNodes.count > 0
    else {
      return nil
    }
    musicAudioNode.autoplayLooped = true
    musicAudioNode.isPositional = false
    musicAudioNode.run(SKAction.changeVolume(to: 0.5, duration: 0))
    return musicAudioNode
  }

  public func enableSound() {
    soundEnabled = true
  }

  public func disableSound() {
    musicAudioNode?.removeFromParent()
    soundEnabled = false
  }

  // MARK: - Velocity

  public func updateVelocity(id: Int, input: CGPoint) -> SKNode? {
    if let velocityNode = velocityNodes[id] {
      velocityNode.removeFromParent()
    }

    guard let satellite = temporaryNodes[id] else {
      return nil
    }

    satellite.addColor(forInput: input, colorSetting: colorSetting)

    let correctedPosition = CGPoint(x: satellite.position.x + satellite.radius, y: satellite.position.y + satellite.radius)
    let velocityNode = NodeFactory.velocity(from: correctedPosition, to: input)
    velocityNodes[id] = velocityNode
    return velocityNode
  }

  public func addVelocityToSatellite(id: Int, input: CGPoint) {
    if let velocityNode = velocityNodes[id] {
      velocityNode.removeFromParent()
    }

    velocityNodes.removeValue(forKey: id)

    guard let satellite = temporaryNodes[id] else {
      return
    }

    let position = satellite.position
    let velocity = CGVector(dx: position.x - input.x, dy: position.y - input.y)
    satellite.addPhysicsBody(with: velocity)
//    satellite.physicsBody?.linearDamping = friction.linearDamping

    if trailLength != .none {
      satellite.addEmitter(emitterBox: emitterForBox, emitterRectangle: emitterForRectangle)
    }
  }

  // MARK: - Emitter

  func setEmitter(enabled: Bool) {

    for node in satelliteNodes {
      if enabled {
        node.addEmitter(emitterBox: emitterForBox, emitterRectangle: emitterForRectangle)
      } else {
        let allEmitter = node.children.filter { $0 is SKEmitterNode }
        for emitter in allEmitter {
          emitter.removeFromParent()
        }
      }
    }
  }

//  func moveEmittersIn(node: SKNode, to: SKNode) {
//    let emitters = node.children.filter({ $0 is SKEmitterNode }) as! [SKEmitterNode]
//    for emitter in emitters {
//      emitter.removeFromParent()
//      emitter.position = node.position
//      emitter.numParticlesToEmit = 0
//      emitter.particleBirthRate = 0
//      to.addChild(emitter)
//      DispatchQueue.main.asyncAfter(deadline: .now() + trailLength.lifetime()) {
//        emitter.removeFromParent()
//      }
//    }
//  }

  func explosion(at position: CGPoint, inNode node: SKNode) {
    let emitter = explosionEmitter?.copy() as? SKEmitterNode
    emitter?.position = position
    if let emitter = emitter {
      node.addChild(emitter)
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        emitter.removeFromParent()
      }
    }
  }

  // MARK: - Stars

  public func stars() -> SKEmitterNode? {
    guard backgroundEmitter?.parent == nil else {
      return nil
    }
    return backgroundEmitter
  }

  public func disableStars() {
    backgroundEmitter?.removeFromParent()
  }

  // MARK: - Projectile

  public func projectile(size: CGSize) -> SKNode {
    let projectile = SKSpriteNode(color: .white, size: CGSize(width: 5, height: 5))
    projectile.position = CGPoint(x: 0, y: -floor(size.height/2)+30)
    projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
    projectile.physicsBody?.velocity = CGVector(dx: 0, dy: 500)
    projectile.physicsBody?.affectedByGravity = false
    projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
    projectile.physicsBody?.contactTestBitMask = PhysicsCategory.center | PhysicsCategory.satellite
    return projectile
  }

  // MARK: - Misc

  public func random(size: CGSize) -> (nodes: [SKNode], sound: SKAudioNode?) {
    let satellites = Satellite.random(sceneSize: size, type: currentSatelliteType, colorSetting: colorSetting)
    for satellite in satellites {
      if trailLength != .none {
        satellite.addEmitter(emitterBox: emitterForBox, emitterRectangle: emitterForRectangle)
      }
//      switch spawnMode {
//        case .maual:
          satellite.physicsBody?.linearDamping = 0.0
//        case .automatic:
//          satellite.physicsBody?.linearDamping = 0.01
//      }
//      satellite.physicsBody?.linearDamping = friction.linearDamping
    }
    self.satelliteNodes.append(contentsOf: satellites)
    return (nodes: satellites, sound: sound())
  }

  public func clear() {
    for node in satelliteNodes {
      node.removeFromParent()
    }
    satelliteNodes.removeAll()
    musicAudioNode?.removeFromParent()
  }
}
