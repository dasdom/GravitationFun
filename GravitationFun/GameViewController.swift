//  Created by Dominik Hauser on 22.12.21.
//  
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

  @IBOutlet weak var stepper: UIStepper!
  var gameScene: GameScene?
  @IBOutlet weak var cutoffLabel: UILabel!
  @IBOutlet weak var leadingSettingsConstraint: NSLayoutConstraint!
  @IBOutlet weak var settingsView: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()

    if let view = self.view as! SKView? {
      // Load the SKScene from 'GameScene.sks'
      if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill

        gameScene = scene

        // Present the scene
        view.presentScene(scene)
      }

      view.ignoresSiblingOrder = true

      view.showsFPS = true
      view.showsNodeCount = true
    }

    stepper.value = 1.0

    leadingSettingsConstraint.constant = 0
  }

  override var shouldAutorotate: Bool {
    return true
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }

  @IBAction func stepperChanged(_ sender: UIStepper) {
    cutoffLabel.text = String(format: "%.1lf", sender.value)
    gameScene?.gravityNode?.falloff = Float(sender.value)
  }

  @IBAction func toggleSettings(_ sender: UIButton) {
    let image: UIImage?
    if leadingSettingsConstraint.constant > 1 {
      leadingSettingsConstraint.constant = 0
      image = UIImage(systemName: "chevron.right")
    } else {
      if let convertedOrigin = sender.superview?.convert(sender.frame.origin, to: settingsView) {
        leadingSettingsConstraint.constant = convertedOrigin.x
        image = UIImage(systemName: "chevron.left")
      } else {
        image = nil
      }
    }
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    } completion: { finished in
      sender.setImage(image, for: .normal)
    }
  }

  @IBAction func toggleTrails(_ sender: UISwitch) {
    gameScene?.setEmitter(enabled: sender.isOn)
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }
}
