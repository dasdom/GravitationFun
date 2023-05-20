//  Created by Dominik Hauser on 22.12.21.
//  
//

import UIKit
import SpriteKit
import GameplayKit
import Combine
import StoreKit
import GravityLogic

let closeSettingsNotificationName = Notification.Name(rawValue: "closeSettingsNotification")

class GameViewController: UIViewController {

  var gameScene: GameScene?
  var token: AnyCancellable?
  var contentView: GameView {
    return view as! GameView
  }

  override func loadView() {
    let contentView = GameView(frame: UIScreen.main.bounds)

    let settingsView = contentView.settingsView
    settingsView.showHideButton.addTarget(self, action: #selector(toggleSettings(_:)), for: .touchUpInside)
//    settingsView.cutOffStepper.addTarget(self, action: #selector(falloffChanged(_:)), for: .valueChanged)
    settingsView.zoomSwitch.addTarget(self, action: #selector(toggleZoomButtons(_:)), for: .valueChanged)
    settingsView.starsSwitch.addTarget(self, action: #selector(toggleStars(_:)), for: .valueChanged)
    settingsView.soundSwitch.addTarget(self, action: #selector(toggleSound(_:)), for: .valueChanged)
//    settingsView.realGravitySwitch.addTarget(self, action: #selector(toggleRealGravity(_:)), for: .valueChanged)
    settingsView.gravityControl.addTarget(self, action: #selector(changeGravity(_:)), for: .valueChanged)
    settingsView.loadButton.addTarget(self, action: #selector(loadScene(_:)), for: .touchUpInside)
    settingsView.saveButton.addTarget(self, action: #selector(saveScene(_:)), for: .touchUpInside)
    settingsView.shareImageButton.addTarget(self, action: #selector(shareImage(_:)), for: .touchUpInside)
    settingsView.randomButton.addTarget(self, action: #selector(random(_:)), for: .touchUpInside)
    settingsView.clearButton.addTarget(self, action: #selector(clear(_:)), for: .touchUpInside)
    settingsView.colorControl.addTarget(self, action: #selector(changeColor(_:)), for: .valueChanged)
//    settingsView.typeControl.addTarget(self, action: #selector(changeType(_:)), for: .valueChanged)
    settingsView.trailLengthControl.addTarget(self, action: #selector(changeTrailLength(_:)), for: .valueChanged)
    settingsView.trailThicknessControl.addTarget(self, action: #selector(changeTrailThickness(_:)), for: .valueChanged)
//    settingsView.frictionControl.addTarget(self, action: #selector(changeFriction(_:)), for: .valueChanged)
//    settingsView.spawnControl.addTarget(self, action: #selector(changeSpawnMode(_:)), for: .valueChanged)
//    settingsView.canonSwitch.addTarget(self, action: #selector(toggleFireButton(_:)), for: .valueChanged)

    contentView.zoomStepper.addTarget(self, action: #selector(zoomChanged(_:)), for: .valueChanged)
    contentView.fastForwardButton.addTarget(self, action: #selector(fastForwardTouchDown(_:)), for: .touchDown)
    contentView.fastForwardButton.addTarget(self, action: #selector(fastForwardTouchUp(_:)), for: .touchUpInside)
    contentView.fastForwardButton.addTarget(self, action: #selector(fastForwardTouchUp(_:)), for: .touchUpOutside)

//    contentView.fireButton.addTarget(self, action: #selector(fire(_:)), for: .touchUpInside)

    view = contentView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let view = self.contentView.skView
    // Load the SKScene from 'GameScene.sks'
//    if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
      // Set the scale mode to scale to fit the window

    let scene = GameScene()
      scene.scaleMode = .aspectFill

    scene.updateSatellitesHandler = { [weak self] count in
      self?.contentView.satellitesCountLabel.text = "\(count)"
    }

      gameScene = scene

      // Present the scene
      view.presentScene(scene)
//    }

//    if let fieldNode = gameScene?.gravityNode {
//      contentView.settingsView.cutOffValueLabel.text = "\(fieldNode.falloff)"
//    }

    if let cameraNode = gameScene?.camera {
      contentView.zoomLabel.text = String(format: "%ld", Int(cameraNode.xScale * 100)) + "%"
    }

    token = NotificationCenter.default
      .publisher(for: closeSettingsNotificationName, object: nil)
      .sink { [weak self] _ in
        self?.contentView.hideSettingsIfNeeded()
    }
  }

  deinit {
    token?.cancel()
    token = nil
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

//  @objc func falloffChanged(_ sender: UIStepper) {
//    contentView.settingsView.cutOffValueLabel.text = String(format: "%.1lf", sender.value)
//    gameScene?.gravityNode?.falloff = Float(sender.value)
//  }

  @objc func zoomChanged(_ sender: UIStepper) {
    if let zoomValue = gameScene?.zoomValue {
      if abs(sender.value - 0.25) < 0.01 {
        if zoomValue > 0.25 {
          sender.stepValue = 0.05
        } else {
          sender.stepValue = 0.25
        }
      }
    }
    contentView.zoomLabel.text = String(format: "%ld", Int(sender.value * 100)) + "%"
    gameScene?.zoom(to: sender.value)
  }

  @objc func fastForwardTouchDown(_ sender: UIButton) {
    gameScene?.physicsWorld.speed = 4
    gameScene?.setTrailLength(to: .none)
  }

  @objc func fastForwardTouchUp(_ sender: UIButton) {
    gameScene?.physicsWorld.speed = 1
    let selectedTrailLengthIndex = contentView.settingsView.trailLengthControl.selectedSegmentIndex
    guard let length = TrailLength(rawValue: selectedTrailLengthIndex) else {
      return
    }
    gameScene?.setTrailLength(to: length)
  }

  @objc func toggleSettings(_ sender: UIButton) {
    contentView.toggleSettings()
  }

  @objc func toggleStars(_ sender: UISwitch) {
    gameScene?.setStars(enabled: sender.isOn)
  }

  @objc func toggleZoomButtons(_ sender: UISwitch) {
    contentView.zoomStackView.isHidden = !sender.isOn
  }

  @objc func changeTrailLength(_ sender: UISegmentedControl) {
    guard let length = TrailLength(rawValue: sender.selectedSegmentIndex) else {
      return
    }
    gameScene?.setTrailLength(to: length)
  }

  @objc func changeTrailThickness(_ sender: UISegmentedControl) {
    guard let particleScale = ParticleScale(rawValue: sender.selectedSegmentIndex) else {
      return
    }
    gameScene?.model.particleScale = particleScale
  }

//  @objc func changeFriction(_ sender: UISegmentedControl) {
//    guard let friction = Friction(rawValue: sender.selectedSegmentIndex) else {
//      return
//    }
//    gameScene?.setFriction(to: friction)
//  }

  @objc func toggleSound(_ sender: UISwitch) {
    gameScene?.setSound(enabled: sender.isOn)

//    if false == sender.isOn {
//      Synth.shared.play(carrierFrequency: 440.0, modulatorFrequency: 800, modulatorAmplitude: 1)
//    }
  }

//  @objc func toggleRealGravity(_ sender: UISwitch) {
//    gameScene?.model.realGravity = sender.isOn
//  }

  @objc func changeGravity(_ sender: UISegmentedControl) {
    guard let scene = gameScene else {
      return
    }
    guard let mode = GravityMode(rawValue: sender.selectedSegmentIndex) else {
      return
    }

    scene.model.mode = mode
    switch mode {
      case .gravity:
        contentView.settingsView.trailLengthControl.isEnabled = true
        contentView.settingsView.randomButton.isEnabled = true
      case .spirograph:
        contentView.settingsView.trailLengthControl.isEnabled = false
        contentView.settingsView.randomButton.isEnabled = false
    }
  }

//  @objc func changeType(_ sender: UISegmentedControl) {
//    guard let type = SatelliteType(rawValue: sender.selectedSegmentIndex) else {
//      return
//    }
//    gameScene?.setSatelliteType(type)
//  }

//  @objc func changeSpawnMode(_ sender: UISegmentedControl) {
//    guard let mode = SpawnMode(rawValue: sender.selectedSegmentIndex) else {
//      return
//    }
//    gameScene?.setSpawnMode(mode)
//    if mode == .automatic {
//      gameScene?.random()
//    }
//  }

//  @objc func toggleFireButton(_ sender: UISwitch) {
//    contentView.fireButton.isHidden = !sender.isOn
//    if false == contentView.zoomStackView.isHidden {
//      contentView.zoomStackView.isHidden = sender.isOn
//    }
//  }

  @objc func changeColor(_ sender: UISegmentedControl) {
    guard let colorSetting = ColorSetting(rawValue: sender.selectedSegmentIndex) else {
      return
    }
    gameScene?.setColorSetting(colorSetting)
  }

  @objc func random(_ sender: UIButton) {
    gameScene?.random()
    if let count = gameScene?.model.satelliteNodes.count {
      contentView.satellitesCountLabel.text = "\(count)"
    }
  }

  @objc func saveScene(_ sender: UIButton) {
    guard let scene = self.gameScene else {
      return
    }
    guard let image = self.getScreenshot(scene: scene) else {
      return
    }
    guard let jpegData = image.jpegData(compressionQuality: 0.2) else {
      return
    }

    DispatchQueue.global(qos: .background).async {
      var sceneStates: [GravityZenState]
      do {
        let data = try Data(contentsOf: FileManager.default.sceneStatesURL)
        sceneStates = try JSONDecoder().decode([GravityZenState].self, from: data)
      } catch {
        print("\(#file), \(#line): \(error)")
        sceneStates = []
      }

      if sceneStates.count > 10 {
        DispatchQueue.main.async {
          let alert = UIAlertController(title: "Too many saved", message: "You already have more than 10 states saved. Please delete states you do not want to keep before saving a new state.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          self.present(alert, animated: true)
        }
      } else {

        do {
          let sceneData = try NSKeyedArchiver.archivedData(withRootObject: scene, requiringSecureCoding: true)
          let gravityZenState = GravityZenState(date: .now, imageData: jpegData, gameState: sceneData, mode: scene.model.mode)
          sceneStates.append(gravityZenState)
        } catch {
          print("\(#file), \(#line): \(error)")
        }

        if false == sceneStates.isEmpty {
          do {
            let data = try JSONEncoder().encode(sceneStates)
            try data.write(to: FileManager.default.sceneStatesURL)
          } catch {
            print("\(#file), \(#line): \(error)")
          }
        }
      }
    }
  }

  @objc func loadScene(_ sender: UIButton) {
    let next = ZenStatesViewController()
    next.gravityZenStateSelectionHandler = { [weak self] gravityZenState in
      if let scene = GameScene.loadScene(from: gravityZenState.gameState) {
        scene.scaleMode = .aspectFill


        scene.model.mode = gravityZenState.mode
        self?.gameScene = scene

//        self?.contentView.settingsView.realGravitySwitch.isOn = gravityZenState.isRealGravity

        let view = self?.contentView.skView
        view?.presentScene(scene)

        scene.updateSatellitesHandler = { [weak self] count in
          self?.contentView.satellitesCountLabel.text = "\(count)"
        }
        
        self?.dismiss(animated: true)
      }
    }

    let navigationController = UINavigationController(rootViewController: next)
    present(navigationController, animated: true)
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
    activity.completionWithItemsHandler = { _, _, _, _ in
      SKStoreReviewController.requestReview()
    }
    activity.popoverPresentationController?.sourceView = settingsView.shareImageButton
    self.present(activity, animated: true)
  }

  @objc func clear(_ sender: UIButton) {
    gameScene?.clear()
  }

//  @objc func fire(_ sender: UIButton) {
//    gameScene?.fire()
//  }

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