//  Created by Dominik Hauser on 06.01.22.
//  
//

import SpriteKit

class ExplosionEmitter: SKEmitterNode {
  override init() {
    super.init()

    particleTexture = SKTextureAtlas(named: "Particle Sprite Atlas").textureNamed("spark")
    particleColor = .orange
    particleBirthRate = 1000
    numParticlesToEmit = 30
    particleLifetime = 1
    emissionAngleRange = 360
    particleSpeed = 40
    particleSpeedRange = 40
    particleAlpha = 1
    particleAlphaRange = 0.2
    particleAlphaSpeed = -1
    particleScale = 0.1
    particleScaleRange = 0.2
    particleScaleSpeed = -0.6
    particleColorBlendFactor = 1
    particleBlendMode = .add
  }

  required init?(coder aDecoder: NSCoder) { fatalError() }
}
