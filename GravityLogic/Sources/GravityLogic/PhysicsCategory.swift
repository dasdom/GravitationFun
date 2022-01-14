//  Created by Dominik Hauser on 13/05/2021.
//  
//

import Foundation

public enum PhysicsCategory {
  public static let center:     UInt32 = 0b0001
  public static let satellite:  UInt32 = 0b0010
  public static let projectile: UInt32 = 0b0100
}
