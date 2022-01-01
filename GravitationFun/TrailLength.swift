//  Created by Dominik Hauser on 01.01.22.
//  Copyright © 2022 dasdom. All rights reserved.
//

import UIKit

enum TrailLength: Int {
  case none
  case short
  case long

  func lifetime() -> CGFloat {
    switch self {
      case .none:
        return 0
      case .short:
        return 1
      case .long:
        return 10
    }
  }
}
