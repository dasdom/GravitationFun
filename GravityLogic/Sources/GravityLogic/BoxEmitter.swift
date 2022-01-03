//  Created by Dominik Hauser on 03.01.22.
//  
//

import SpriteKit

class BoxEmitter: SKEmitterNode {
  override init() {
    super.init()

    particleTexture = SKTextureAtlas(named: "Particle Sprite Atlas").textureNamed("bokeh")
    particleBirthRate = 50
    particleLifetime = 10
    particlePositionRange = CGVector(dx: 3, dy: 3)
    particleAlpha = 0.6
    particleScale = 0.04
    particleColorBlendFactor = 1
  }

  required init?(coder aDecoder: NSCoder) { fatalError() }
}
