//  Created by Dominik Hauser on 07.01.22.
//  
//

import UIKit

public enum Friction: Int {
  case none
  case weak
  case strong

  var linearDamping: CGFloat {
    switch self {
      case .none:
        return 0
      case .weak:
        return 0.03
      case .strong:
        return 0.1
    }
  }
}
