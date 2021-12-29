//  Created by Dominik Hauser on 22.12.21.
//  
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

  var gameScene: GameScene?
  var contentView: GameView {
    return view as! GameView
  }

  override func loadView() {
    let contentView = GameView(frame: UIScreen.main.bounds)

    let settingsView = contentView.settingsView
    settingsView.showHideButton.addTarget(self, action: #selector(toggleSettings(_:)), for: .touchUpInside)
    settingsView.cutOffStepper.addTarget(self, action: #selector(falloffChanged(_:)), for: .valueChanged)
    settingsView.zoomSwitch.addTarget(self, action: #selector(toggleZoomButtons(_:)), for: .valueChanged)
    settingsView.soundSwitch.addTarget(self, action: #selector(toggleSound(_:)), for: .valueChanged)
    settingsView.shareImageButton.addTarget(self, action: #selector(shareImage(_:)), for: .touchUpInside)
    settingsView.randomButton.addTarget(self, action: #selector(random(_:)), for: .touchUpInside)
    settingsView.clearButton.addTarget(self, action: #selector(clear(_:)), for: .touchUpInside)
    settingsView.typControl.addTarget(self, action: #selector(changeType(_:)), for: .valueChanged)
    settingsView.trailLengthControl.addTarget(self, action: #selector(changeTrailLength(_:)), for: .valueChanged)

    contentView.zoomStepper.addTarget(self, action: #selector(zoomChanged(_:)), for: .valueChanged)
    contentView.fastForwardButton.addTarget(self, action: #selector(fastForwardTouchDown(_:)), for: .touchDown)
    contentView.fastForwardButton.addTarget(self, action: #selector(fastForwardTouchUp(_:)), for: .touchUpInside)
    contentView.fastForwardButton.addTarget(self, action: #selector(fastForwardTouchUp(_:)), for: .touchUpOutside)

    view = contentView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let view = self.contentView.skView
    // Load the SKScene from 'GameScene.sks'
    if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
      // Set the scale mode to scale to fit the window
      scene.scaleMode = .aspectFill

      gameScene = scene

      // Present the scene
      view.presentScene(scene)
    }

    if let fieldNode = gameScene?.gravityNode {
      contentView.settingsView.cutOffValueLabel.text = "\(fieldNode.falloff)"
    }

    if let cameraNode = gameScene?.camera {
      contentView.zoomLabel.text = String(format: "%ld", Int(cameraNode.xScale * 100)) + "%"
    }

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

  @objc func falloffChanged(_ sender: UIStepper) {
    contentView.settingsView.cutOffValueLabel.text = String(format: "%.1lf", sender.value)
    gameScene?.gravityNode?.falloff = Float(sender.value)
  }

  @objc func zoomChanged(_ sender: UIStepper) {
    contentView.zoomLabel.text = String(format: "%ld", Int(sender.value * 100)) + "%"
    gameScene?.zoom(to: sender.value)
  }

  @objc func fastForwardTouchDown(_ sender: UIButton) {
    contentView.skView.scene?.physicsWorld.speed = 4
  }

  @objc func fastForwardTouchUp(_ sender: UIButton) {
    contentView.skView.scene?.physicsWorld.speed = 1
  }

  @objc func toggleSettings(_ sender: UIButton) {
    let image: UIImage?

    guard let leadingSettingsConstraint = contentView.leadingSettingsConstraint else {
      return
    }

    if leadingSettingsConstraint.constant > 1 {
      leadingSettingsConstraint.constant = 0
      image = UIImage(systemName: "chevron.right")
    } else {
      if let convertedOrigin = sender.superview?.convert(sender.frame.origin, to: contentView.settingsView) {
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

  @objc func toggleZoomButtons(_ sender: UISwitch) {
    contentView.zoomStackView.isHidden = false == sender.isOn
  }

  @objc func changeTrailLength(_ sender: UISegmentedControl) {
    guard let length = TrailLength(rawValue: sender.selectedSegmentIndex) else {
      return
    }
    gameScene?.setTrailLength(to: length)
  }

  @objc func toggleSound(_ sender: UISwitch) {
    gameScene?.soundEnabled = sender.isOn
  }

  @objc func changeType(_ sender: UISegmentedControl) {
    guard let type = SatelliteType(rawValue: sender.selectedSegmentIndex) else {
      gameScene?.satelliteType = .box
      return
    }
    gameScene?.satelliteType = type
  }

  @objc func random(_ sender: UIButton) {
    gameScene?.random()
  }

  @objc func shareImage(_ sender: UIButton) {
    guard let scene = gameScene else {
      return
    }
    guard let image = getScreenshot(scene: scene) else {
      return
    }
    let settingsView = contentView.settingsView
    let activity = UIActivityViewController(activityItems: [image, "#GravityZenApp"], applicationActivities: nil)
    //    activity.completionWithItemsHandler = { _, _, _, _ in
    //      SKStoreReviewController.requestReview()
    //    }
    activity.popoverPresentationController?.sourceView = settingsView.shareImageButton
    self.present(activity, animated: true)
  }

  @objc func clear(_ sender: UIButton) {
    gameScene?.clear()
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  func getScreenshot(scene: SKScene) -> UIImage? {
    guard let view = scene.view else {
      return nil
    }

//    let snapshotView = view.snapshotView(afterScreenUpdates: true)
    let bounds = view.bounds

    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)

    view.drawHierarchy(in: bounds, afterScreenUpdates: true)

    let screenshotImage = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    return screenshotImage
  }
}
