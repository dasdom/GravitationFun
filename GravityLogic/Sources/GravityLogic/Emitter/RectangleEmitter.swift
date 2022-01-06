//  Created by Dominik Hauser on 03.01.22.
//  
//

import SpriteKit

class RectangleEmitter: SKEmitterNode {
  override init() {
    super.init()

    particleTexture = SKTextureAtlas(named: "Particle Sprite Atlas").textureNamed("bokeh")
    particleBirthRate = 30
    particleLifetime = 10
    particleAlpha = 0.6
    particleScale = 0.04
    particleColorBlendFactor = 1
  }

  required init?(coder aDecoder: NSCoder) { fatalError() }
}
