//  Created by Dominik Hauser on 03.01.22.
//  
//

import SpriteKit

class RectangleEmitter: SKEmitterNode {
  override init() {
    super.init()

//    particleTexture = SKTextureAtlas(named: "Particle Sprite Atlas").textureNamed("bokeh")
    particleSize = .init(width: 1, height: 1)
    particleBirthRate = 30
    particleLifetime = TrailLength.long.lifetime()
    particleAlpha = 0.7
    particleScale = 1
    particleColorBlendFactor = 1
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
