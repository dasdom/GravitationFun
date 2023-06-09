//  Created by Dominik Hauser on 14.05.23.
//  Copyright © 2023 dasdom. All rights reserved.
//


import Foundation

extension FileManager {

  var documentsURL: URL {
    guard let url = FileManager.default.urls(
      for: .documentDirectory,
      in: .userDomainMask).first else {
      fatalError()
    }
    return url
  }

  var sceneStatesURL: URL {
    return documentsURL.appendingPathComponent("scene_states.json ")
  }
}
