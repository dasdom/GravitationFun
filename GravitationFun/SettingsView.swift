//  Created by Dominik Hauser on 26.12.21.
//  
//

import UIKit

class SettingsView: UIView {

  let cutOffKeyLabel: UILabel
  let cutOffValueLabel: UILabel
  let cutOffStepper: UIStepper

  let starsKeyLabel: UILabel
  let starsSwitch: UISwitch

  let zoomKeyLabel: UILabel
  let zoomSwitch: UISwitch

  let canonKeyLabel: UILabel
  let canonSwitch: UISwitch

  let soundKeyLabel: UILabel
  let soundSwitch: UISwitch

  let trailKeyLabel: UILabel
  let trailLengthControl: UISegmentedControl

  let colorControl: UISegmentedControl

  let frictionKeyLabel: UILabel
  let frictionControl: UISegmentedControl

  let typeControl: UISegmentedControl

  let spawnControl: UISegmentedControl

  let shareImageButton: UIButton

  let randomButton: UIButton

  let clearButton: UIButton

  let showHideButton: UIButton

  override init(frame: CGRect) {

    let darkGray = UIColor(white: 0.3, alpha: 1)

    cutOffKeyLabel = UILabel()
    cutOffKeyLabel.text = "Gravity falloff:"
    cutOffKeyLabel.textColor = .white
    cutOffKeyLabel.font = .systemFont(ofSize: 13)

    cutOffValueLabel = UILabel()
    cutOffValueLabel.text = "-"
    cutOffValueLabel.textAlignment = .right
    cutOffValueLabel.textColor = .white
    cutOffValueLabel.font = .systemFont(ofSize: 13)

    cutOffStepper = UIStepper()
    cutOffStepper.minimumValue = 0.1
    cutOffStepper.maximumValue = 3.0
    cutOffStepper.stepValue = 0.1
    cutOffStepper.value = 1.0
    cutOffStepper.backgroundColor = .gray

    starsKeyLabel = UILabel()
    starsKeyLabel.text = "Stars"
    starsKeyLabel.textColor = .white
    starsKeyLabel.font = .systemFont(ofSize: 13)

    starsSwitch = UISwitch()
    starsSwitch.isOn = true
    starsSwitch.onTintColor = darkGray

    zoomKeyLabel = UILabel()
    zoomKeyLabel.text = "Zoom buttons"
    zoomKeyLabel.textColor = .white
    zoomKeyLabel.font = .systemFont(ofSize: 13)

    zoomSwitch = UISwitch()
    zoomSwitch.isOn = false
    zoomSwitch.accessibilityLabel = "Show zoom buttons"
    zoomSwitch.onTintColor = darkGray

    canonKeyLabel = UILabel()
    canonKeyLabel.text = "Canon"
    canonKeyLabel.textColor = .white
    canonKeyLabel.font = .systemFont(ofSize: 13)

    canonSwitch = UISwitch()
    canonSwitch.isOn = false
    canonSwitch.accessibilityLabel = "Activate canon"
    canonSwitch.onTintColor = darkGray

    soundKeyLabel = UILabel()
    soundKeyLabel.text = "Sound"
    soundKeyLabel.textColor = .white
    soundKeyLabel.font = .systemFont(ofSize: 13)
    
    soundSwitch = UISwitch()
    soundSwitch.isOn = true
    soundSwitch.onTintColor = darkGray

    trailKeyLabel = UILabel()
    trailKeyLabel.text = "Trail length"
    trailKeyLabel.textColor = .white
    trailKeyLabel.font = .systemFont(ofSize: 13)

    trailLengthControl = UISegmentedControl(items: ["none", "short", "long"])
    trailLengthControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.gray], for: .normal)
    trailLengthControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
    trailLengthControl.selectedSegmentTintColor = darkGray
    trailLengthControl.selectedSegmentIndex = 2

    frictionKeyLabel = UILabel()
    frictionKeyLabel.text = "Friction"
    frictionKeyLabel.textColor = .white
    frictionKeyLabel.font = .systemFont(ofSize: 13)

    frictionControl = UISegmentedControl(items: ["none", "weak", "strong"])
    frictionControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.gray], for: .normal)
    frictionControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
    frictionControl.selectedSegmentTintColor = darkGray
    frictionControl.selectedSegmentIndex = 0

    colorControl = UISegmentedControl(items: [UIImage(systemName: "paintpalette")!.withRenderingMode(.alwaysOriginal), UIImage(systemName: "paintpalette")!])
    colorControl.selectedSegmentTintColor = darkGray
    colorControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.gray], for: .normal)
    colorControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
    colorControl.selectedSegmentIndex = 0


    typeControl = UISegmentedControl(items: [UIImage(systemName: "square")!, UIImage(systemName: "rectangle")!])
//    typeControl.backgroundColor = .gray
    typeControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.gray], for: .normal)
    typeControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
    typeControl.selectedSegmentTintColor = darkGray
    typeControl.selectedSegmentIndex = 0

    spawnControl = UISegmentedControl(items: ["manual", "automatic"])
    spawnControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.gray], for: .normal)
    spawnControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
    spawnControl.selectedSegmentTintColor = darkGray
    spawnControl.selectedSegmentIndex = 0

    randomButton = UIButton(type: .system)
    randomButton.configuration = UIButton.Configuration.filled()
    randomButton.setImage(UIImage(systemName: "dice"), for: .normal)

    clearButton = UIButton(type: .system)
    clearButton.configuration = UIButton.Configuration.filled()
    clearButton.setImage(UIImage(systemName: "trash"), for: .normal)

    shareImageButton = UIButton(type: .system)
    shareImageButton.configuration = UIButton.Configuration.filled()
    shareImageButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)

    showHideButton = UIButton(type: .system)
    showHideButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
    showHideButton.tintColor = .white

    super.init(frame: frame)

    backgroundColor = .clear
    tintColor = darkGray

    let cutOffStackView = UIStackView(arrangedSubviews: [cutOffKeyLabel, cutOffValueLabel, cutOffStepper])
    cutOffStackView.spacing = 20

    let zoomStackView = UIStackView(arrangedSubviews: [zoomKeyLabel, zoomSwitch])
    zoomStackView.spacing = 20

    let canonStackView = UIStackView(arrangedSubviews: [canonKeyLabel, canonSwitch])
    canonStackView.spacing = 20

    let starsStackView = UIStackView(arrangedSubviews: [starsKeyLabel, starsSwitch])
    starsStackView.spacing = 20

    let soundStackView = UIStackView(arrangedSubviews: [soundKeyLabel, soundSwitch])

    let trailsStackView = UIStackView(arrangedSubviews: [trailKeyLabel, trailLengthControl])
    trailsStackView.axis = .vertical
    trailsStackView.spacing = 5

    let frictionStackView = UIStackView(arrangedSubviews: [frictionKeyLabel, frictionControl])
    frictionStackView.axis = .vertical
    frictionStackView.spacing = 5

    let buttonStackView = UIStackView(arrangedSubviews: [clearButton, randomButton, shareImageButton])
    buttonStackView.spacing = 5
    buttonStackView.distribution = .fillEqually

    let settingsStackView = UIStackView(arrangedSubviews: [zoomStackView, starsStackView, canonStackView, soundStackView, trailsStackView, frictionStackView, colorControl, typeControl, buttonStackView])
    settingsStackView.axis = .vertical
    settingsStackView.spacing = 20

    let showHideStackView = UIStackView(arrangedSubviews: [showHideButton])
    showHideStackView.alignment = .top

    let stackView = UIStackView(arrangedSubviews: [settingsStackView, showHideStackView])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 22

    addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),

      showHideButton.widthAnchor.constraint(equalToConstant: 44),
      showHideButton.heightAnchor.constraint(equalToConstant: 44),

      cutOffValueLabel.widthAnchor.constraint(equalToConstant: 20),
    ])
  }

  required init?(coder: NSCoder) { fatalError() }
}
