//  Created by Dominik Hauser on 14.05.23.
//  Copyright © 2023 dasdom. All rights reserved.
//


import Foundation
import GravityLogic

struct GravityZenState: Codable {
  let date: Date
  let imageData: Data
  let gameState: Data
  let mode: GravityMode
}
