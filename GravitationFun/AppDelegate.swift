//  Created by Dominik Hauser on 22.12.21.
//  
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    application.isIdleTimerDisabled = true

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = GameViewController()
    window?.makeKeyAndVisible()

    return true
  }
}

