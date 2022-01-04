//  Created by Dominik Hauser on 02.01.22.
//  
//

import SpriteKit

public enum SpawnMode: Int {
  case maual
  case automatic
}

public class GravityModel {
  var satelliteNodes: [Satellite] = []
  var temporaryNodes: [Int:Satellite] = [:]
  var velocityNodes: [Int:SKShapeNode] = [:]
  let emitterBox: SKEmitterNode
  let emitterRectangle: SKEmitterNode
  var backgroundEmitter: SKEmitterNode?
  var explosionEmitter: SKEmitterNode?
  let gravityNode: SKFieldNode
  public var currentSatelliteType: SatelliteType = .box
  private var musicAudioNode: SKAudioNode?
  var soundEnabled = true
  public var spawnMode: SpawnMode = .maual {
    didSet {
      let linearDamping: CGFloat
      switch spawnMode {
        case .maual:
          linearDamping = 0
          gravityNode.falloff = 1.2
        case .automatic:
          linearDamping = 0.03
          gravityNode.falloff = 1
      }
      for node in satelliteNodes {
        node.physicsBody?.linearDamping = linearDamping
      }
    }
  }
  public var trailLength: TrailLength = .long {
    didSet {
      setEmitter(enabled: false)

      emitterBox.particleLifetime = trailLength.lifetime()
      emitterRectangle.particleLifetime = trailLength.lifetime()

      switch trailLength {
        case .none:
          break
        case .short, .long:
          setEmitter(enabled: true)
      }
    }
  }
  public var colorSetting: ColorSetting = .multiColor {
    didSet {
      for node in satelliteNodes {
        node.updateColor(for: colorSetting)
      }
    }
  }

  // MARK: - Setupg
  public init() {
    emitterBox = BoxEmitter()
    emitterRectangle = RectangleEmitter()
    explosionEmitter = SKEmitterNode(fileNamed: "explosion")
    gravityNode = SKFieldNode.radialGravityField()
  }

  public func setup(scene: SKScene) {
    emitterBox.targetNode = scene
    emitterRectangle.targetNode = scene

    backgroundEmitter = NodeFactory.backgroundEmitter(size: scene.size)
    if let backgroundEmitter = backgroundEmitter {
      scene.addChild(backgroundEmitter)
    }

    scene.addChild(NodeFactory.center())

    gravityNode.falloff = 1.2
    scene.addChild(gravityNode)
  }

  public func addSound(node: SKAudioNode) {
    musicAudioNode = node
  }

  // MARK: - Satellites

  public func satellite(with position: CGPoint, id: Int) -> SKNode {
    let node = Satellite(position: position, type: currentSatelliteType)
    satelliteNodes.append(node)
    temporaryNodes[id] = node
    return node
  }

  public func setColorOfSatelliteWith(id: Int, forInput input: CGPoint) {
    let node = temporaryNodes[id]
    node?.addColor(forInput: input, colorSetting: colorSetting)
  }

  public func remove(_ node: SKNode, moveEmitterTo target: SKScene) {
    guard let satellite = node as? Satellite else {
      return
    }
    satelliteNodes.removeAll(where: { $0 == satellite })

    if satelliteNodes.count < 1 {
      disableSound()
    }

    moveEmittersIn(node: satellite, to: target)
    explosion(at: satellite.position, inNode: target)
    satellite.removeFromParent()

    if satelliteNodes.count < 5 {
      for node in random(size: target.size).nodes {
        target.addChild(node)
      }
    }
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

    let velocityNode = NodeFactory.velocity(from: satellite.position, to: input)
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

    if trailLength != .none {
      satellite.addEmitter(emitterBox: emitterBox, emitterRectangle: emitterRectangle)
    }
  }

  // MARK: - Emitter

  func setEmitter(enabled: Bool) {

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

  func moveEmittersIn(node: SKNode, to: SKNode) {
    let emitters = node.children.filter({ $0 is SKEmitterNode }) as! [SKEmitterNode]
    for emitter in emitters {
      emitter.removeFromParent()
      emitter.position = node.position
      emitter.numParticlesToEmit = 0
      emitter.particleBirthRate = 0
      to.addChild(emitter)
      DispatchQueue.main.asyncAfter(deadline: .now() + trailLength.lifetime()) {
        emitter.removeFromParent()
      }
    }
  }

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

  // MARK: - Misc

  public func random(size: CGSize) -> (nodes: [SKNode], sound: SKAudioNode?) {
    let satellites = Satellite.random(sceneSize: size, type: currentSatelliteType, colorSetting: colorSetting)
    for satellite in satellites {
      if trailLength != .none {
        satellite.addEmitter(emitterBox: emitterBox, emitterRectangle: emitterRectangle)
      }
      switch spawnMode {
        case .maual:
          satellite.physicsBody?.linearDamping = 0.0
        case .automatic:
          satellite.physicsBody?.linearDamping = 0.01
      }
    }
    self.satelliteNodes.append(contentsOf: satellites)
    return (nodes: satellites, sound: sound())
  }

  public func clear() {
    for node in satelliteNodes {
      node.removeFromParent()
    }
    satelliteNodes.removeAll()
    disableSound()
  }
}
