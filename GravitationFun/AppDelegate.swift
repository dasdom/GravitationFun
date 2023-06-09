//  Created by Dominik Hauser on 22.12.21.
//  
//

import UIKit
import RevenueCat

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    if let apiKey = infoForKey("RevenueCatKey") {
      Purchases.logLevel = .verbose
      Purchases.configure(withAPIKey: apiKey)
    }

    application.isIdleTimerDisabled = true

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = GameViewController()
    window?.makeKeyAndVisible()

    return true
  }
}

func infoForKey(_ key: String) -> String? {
  return (Bundle.main.infoDictionary?[key] as? String)?
    .replacingOccurrences(of: "\\", with: "")
}
