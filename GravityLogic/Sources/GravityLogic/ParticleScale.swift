//  Created by Dominik Hauser on 19.05.23.
//  
//


import Foundation

public enum ParticleScale: Int {
  case thin
  case normal
  case thick

  var value: CGFloat {
    switch self {
      case .thin:
        return 0.8
      case .normal:
        return 1.0
      case .thick:
        return 2.0
    }
  }
}
