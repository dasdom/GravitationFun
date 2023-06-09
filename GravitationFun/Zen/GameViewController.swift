//  Created by Dominik Hauser on 22.12.21.
//  
//

import UIKit
import SpriteKit
import GameplayKit
import Combine
import StoreKit
import GravityLogic
import RevenueCat

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
    settingsView.showHideButton.addTarget(self, action: #selector(toggleSettings), for: .touchUpInside)
    settingsView.zoomSwitch.addTarget(self, action: #selector(toggleZoomButtons), for: .valueChanged)
    settingsView.starsSwitch.addTarget(self, action: #selector(toggleStars), for: .valueChanged)
    settingsView.gravityControl.addTarget(self, action: #selector(changeGravity), for: .valueChanged)
    settingsView.loadButton.addTarget(self, action: #selector(loadScene), for: .touchUpInside)
    settingsView.saveButton.addTarget(self, action: #selector(saveScene), for: .touchUpInside)
    settingsView.tipJarButton.addTarget(self, action: #selector(showTipJar), for: .touchUpInside)
    settingsView.shareImageButton.addTarget(self, action: #selector(shareImage), for: .touchUpInside)
    settingsView.randomButton.addTarget(self, action: #selector(random), for: .touchUpInside)
    settingsView.clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
    settingsView.colorControl.addTarget(self, action: #selector(changeColor), for: .valueChanged)
    settingsView.backgroundColorControl.addTarget(self, action: #selector(changeBackgroundColor), for: .valueChanged)
    settingsView.trailLengthControl.addTarget(self, action: #selector(changeTrailLength), for: .valueChanged)
    settingsView.trailThicknessControl.addTarget(self, action: #selector(changeTrailThickness), for: .valueChanged)

    contentView.zoomStepper.addTarget(self, action: #selector(zoomChanged), for: .valueChanged)
    contentView.fastForwardButton.addTarget(self, action: #selector(fastForwardTouchDown), for: .touchDown)
    contentView.fastForwardButton.addTarget(self, action: #selector(fastForwardTouchUp), for: .touchUpInside)
    contentView.fastForwardButton.addTarget(self, action: #selector(fastForwardTouchUp), for: .touchUpOutside)

    view = contentView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let view = self.contentView.skView
    let scene = GameScene()
    scene.scaleMode = .aspectFill

    scene.updateSatellitesHandler = { [weak self] _ in
      self?.updateCountLabel()
    }

    gameScene = scene

    view.presentScene(scene)

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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    random(contentView.settingsView.randomButton)

    updateForPurchases()
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

  func updateForPurchases() {
    Task {
      do {
        let customerInfo = try await Purchases.shared.customerInfo()
        print("ids: \(customerInfo.allPurchasedProductIdentifiers)")
        await MainActor.run {
          if false == customerInfo.allPurchasedProductIdentifiers.isEmpty {
            contentView.settingsView.backgroundColorControl.isEnabled = true
            contentView.settingsView.backgroundColorDescriptionLabel.isHidden = true
          }
        }
      } catch {
        print("\(#file), \(#line): \(error)")
      }
    }
  }
}

// MARK: - Actions
extension GameViewController {
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
    guard let gameScene = gameScene else {
      return
    }
    gameScene.physicsWorld.speed = 3
//    gameScene?.setTrailLength(to: .none)
    for satellite in gameScene.children.filter({ $0 is Satellite }) {
      for emitter in satellite.children where emitter is SKEmitterNode {
        guard let emitter = emitter as? SKEmitterNode else {
          return
        }
        emitter.particleBirthRate *= 3
      }
    }
  }

  @objc func fastForwardTouchUp(_ sender: UIButton) {
    guard let gameScene = gameScene else {
      return
    }
    gameScene.physicsWorld.speed = 1
//    let selectedTrailLengthIndex = contentView.settingsView.trailLengthControl.selectedSegmentIndex
//    guard let length = TrailLength(rawValue: selectedTrailLengthIndex) else {
//      return
//    }
//    gameScene?.setTrailLength(to: length)
    for satellite in gameScene.children.filter({ $0 is Satellite }) {
      for emitter in satellite.children where emitter is SKEmitterNode {
        guard let emitter = emitter as? SKEmitterNode else {
          return
        }
        emitter.particleBirthRate /= 3
      }
    }
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

  @objc func toggleSound(_ sender: UISwitch) {
    gameScene?.setSound(enabled: sender.isOn)

  }

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
        if scene.model.satelliteNodes.count > 10 {
          for satellite in scene.model.satelliteNodes.sorted(by: { abs(pow($0.position.y, 2) + pow($0.position.x, 2)) < abs(pow($1.position.y, 2) + pow($1.position.x, 2)) })[10...] {
            scene.model.remove(satellite, explosionIn: scene)
          }
        }
    }
    updateCountLabel()
  }

  @objc func changeColor(_ sender: UISegmentedControl) {
    guard let colorSetting = ColorSetting(rawValue: sender.selectedSegmentIndex) else {
      return
    }
    gameScene?.setColorSetting(colorSetting)
  }

  @objc func random(_ sender: UIButton) {
    guard let gameScene = gameScene else {
      return
    }
    gameScene.random()
  }

  func updateCountLabel() {
    guard let gameScene = gameScene else {
      return
    }
    let text: String
    let count = gameScene.model.satelliteNodes.count
    switch gameScene.model.mode {
      case .gravity:
        text = "\(count)"
      case .spirograph:
        text = "\(count)/10"
    }
    contentView.satellitesCountLabel.text = text
  }

  @objc func changeBackgroundColor(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
      case 0:
        contentView.skView.scene?.backgroundColor = .black
      case 1:
        contentView.skView.scene?.backgroundColor = .init(white: 0.1, alpha: 1)
      case 2:
        contentView.skView.scene?.backgroundColor = .white
      default:
        break
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

        let view = self?.contentView.skView
        view?.presentScene(scene)

        scene.updateSatellitesHandler = { [weak self] _ in
          self?.updateCountLabel()
        }
        
        self?.dismiss(animated: true)
      }
    }

    let navigationController = UINavigationController(rootViewController: next)
    present(navigationController, animated: true)
  }

  @objc func showTipJar(_ sender: UIButton) {
    let next = TipJarViewController()
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
    guard let scene = gameScene else {
      return
    }
    for (index, satellite) in scene.model.satelliteNodes.enumerated() {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.03 * Double(index)) {
        scene.model.remove(satellite, explosionIn: scene)
      }
    }
//    gameScene?.clear()
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  func getScreenshot(scene: SKScene) -> UIImage? {
    guard let view = scene.view else {
      return nil
    }

    let bounds = view.bounds

    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)

    view.drawHierarchy(in: bounds, afterScreenUpdates: true)

    let screenshotImage = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    return screenshotImage
  }
}
