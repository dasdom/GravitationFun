//  Created by Dominik Hauser on 18.05.23.
//  
//


import Foundation

public enum GravityMode: Int, Codable {
  case gravity
  case spirograph

  var name: String {
    switch self {
      case .gravity:
        return "Gravity"
      case .spirograph:
        return "Spirograph"
    }
  }

  var falloff: Float {
    switch self {
      case .gravity:
        return 2.0
      case .spirograph:
        return 1.9
    }
  }

  var trailLength: TrailLength {
    switch self {
      case .gravity:
        return .long
      case .spirograph:
        return .spirograph
    }
  }
}
