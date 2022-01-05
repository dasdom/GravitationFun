//  Created by Dominik Hauser on 28.12.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit
import SpriteKit

class GameView: UIView {

  let skView: SKView
  let settingsView: SettingsView
  var leadingSettingsConstraint: NSLayoutConstraint?
  let zoomStepper: UIStepper
  let zoomLabel: UILabel
  let zoomStackView: UIStackView
  let fastForwardButton: UIButton

  override init(frame: CGRect) {

    skView = SKView(frame: frame)
    skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    skView.isMultipleTouchEnabled = true

    settingsView = SettingsView()
    settingsView.translatesAutoresizingMaskIntoConstraints = false
    settingsView.cutOffStepper.value = 1.0

    zoomStepper = UIStepper()
    zoomStepper.minimumValue = 0.25
    zoomStepper.maximumValue = 1.25
    zoomStepper.stepValue = 0.25
    zoomStepper.value = 1.0
    zoomStepper.backgroundColor = .clear
    zoomStepper.setDecrementImage(UIImage(systemName: "minus.magnifyingglass"), for: .normal)
    zoomStepper.setIncrementImage(UIImage(systemName: "plus.magnifyingglass"), for: .normal)
    zoomStepper.tintColor = .white

    zoomLabel = UILabel()
    zoomLabel.font = .systemFont(ofSize: 13)
    zoomLabel.textColor = .white
    zoomLabel.textAlignment = .center

    zoomStackView = UIStackView(arrangedSubviews: [zoomLabel, zoomStepper])
    zoomStackView.translatesAutoresizingMaskIntoConstraints = false
    zoomStackView.spacing = 10
    zoomStackView.axis = .vertical
    zoomStackView.isHidden = true

    fastForwardButton = UIButton(type: .system)
    fastForwardButton.translatesAutoresizingMaskIntoConstraints = false
    fastForwardButton.setImage(UIImage(systemName: "forward"), for: .normal)
    fastForwardButton.tintColor = .white

    super.init(frame: frame)

    skView.ignoresSiblingOrder = true
    skView.preferredFramesPerSecond = UIScreen.main.maximumFramesPerSecond

//    skView.showsFPS = true
//    skView.showsNodeCount = true

    addSubview(skView)
    addSubview(settingsView)
    addSubview(zoomStackView)
    addSubview(fastForwardButton)

    let leadingSettingsConstraint = settingsView.showHideButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)

    NSLayoutConstraint.activate([
      settingsView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      leadingSettingsConstraint,

      zoomStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
      zoomStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),

      fastForwardButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
      fastForwardButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
      fastForwardButton.widthAnchor.constraint(equalToConstant: 44),
      fastForwardButton.heightAnchor.constraint(equalTo: fastForwardButton.widthAnchor),
    ])

    self.leadingSettingsConstraint = leadingSettingsConstraint
  }

  required init?(coder: NSCoder) { fatalError() }

  func toggleSettings() {
    let image: UIImage?

    guard let leadingSettingsConstraint = leadingSettingsConstraint else {
      return
    }

    let button = settingsView.showHideButton
    if leadingSettingsConstraint.constant > 21 {
      leadingSettingsConstraint.constant = 20
      image = UIImage(systemName: "chevron.right")
    } else {
      if let convertedOrigin = button.superview?.convert(button.frame.origin, to: settingsView) {
        leadingSettingsConstraint.constant = convertedOrigin.x + 8
        image = UIImage(systemName: "chevron.left")
      } else {
        image = nil
      }
    }
    UIView.animate(withDuration: 0.3) {
      self.layoutIfNeeded()
    } completion: { finished in
      button.setImage(image, for: .normal)
    }
  }

  func hideSettingsIfNeeded() {
    guard let leadingSettingsConstraint = leadingSettingsConstraint else {
      return
    }

    if leadingSettingsConstraint.constant > 1 {
      toggleSettings()
    }
  }
}


