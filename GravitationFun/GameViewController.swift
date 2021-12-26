//  Created by Dominik Hauser on 22.12.21.
//  
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

  var gameScene: GameScene?
  var leadingSettingsConstraint: NSLayoutConstraint?
  var settingsView: SettingsView?

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
      view.preferredFramesPerSecond = UIScreen.main.maximumFramesPerSecond

      view.showsFPS = true
      view.showsNodeCount = true
    }

    let settingsView = SettingsView()
    settingsView.translatesAutoresizingMaskIntoConstraints = false
    settingsView.cutOffStepper.value = 1.0
    settingsView.showHideButton.addTarget(self, action: #selector(toggleSettings(_:)), for: .touchUpInside)
    settingsView.cutOffStepper.addTarget(self, action: #selector(stepperChanged(_:)), for: .valueChanged)
    settingsView.trailsSwitch.addTarget(self, action: #selector(toggleTrails(_:)), for: .valueChanged)
    settingsView.clearButton.addTarget(self , action: #selector(clear(_:)), for: .touchUpInside)
    if let fieldNode = gameScene?.gravityNode {
      settingsView.cutOffValueLabel.text = "\(fieldNode.falloff)"
    }

    view.addSubview(settingsView)

    let leadingSettingsConstraint = settingsView.showHideButton.leadingAnchor.constraint(equalTo: view.leadingAnchor)

    NSLayoutConstraint.activate([
      settingsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      leadingSettingsConstraint
    ])

    self.settingsView = settingsView
    self.leadingSettingsConstraint = leadingSettingsConstraint
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

  @objc func stepperChanged(_ sender: UIStepper) {
    settingsView?.cutOffValueLabel.text = String(format: "%.1lf", sender.value)
    gameScene?.gravityNode?.falloff = Float(sender.value)
  }

  @objc func toggleSettings(_ sender: UIButton) {
    let image: UIImage?

    guard let leadingSettingsConstraint = leadingSettingsConstraint else {
      return
    }

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

  @objc func toggleTrails(_ sender: UISwitch) {
    gameScene?.setEmitter(enabled: sender.isOn)
  }

  @objc func clear(_ sender: UIButton) {
    gameScene?.clear()
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }
}
