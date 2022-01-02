//  Created by Dominik Hauser on 01.01.22.
//  Copyright © 2022 dasdom. All rights reserved.
//

import UIKit

public enum TrailLength: Int {
  case none
  case short
  case long

  public func lifetime() -> CGFloat {
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
