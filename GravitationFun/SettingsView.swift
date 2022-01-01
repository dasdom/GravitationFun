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

  let soundKeyLabel: UILabel
  let soundSwitch: UISwitch

  let trailKeyLabel: UILabel
  let trailLengthControl: UISegmentedControl

  let colorControl: UISegmentedControl

  let typeControl: UISegmentedControl

  let shareImageButton: UIButton

  let randomButton: UIButton

  let clearButton: UIButton

  let showHideButton: UIButton

  override init(frame: CGRect) {

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

    zoomKeyLabel = UILabel()
    zoomKeyLabel.text = "Zoom buttons"
    zoomKeyLabel.textColor = .white
    zoomKeyLabel.font = .systemFont(ofSize: 13)

    zoomSwitch = UISwitch()
    zoomSwitch.isOn = false
    zoomSwitch.accessibilityLabel = "Show zoom buttons"

    soundKeyLabel = UILabel()
    soundKeyLabel.text = "Sound"
    soundKeyLabel.textColor = .white
    soundKeyLabel.font = .systemFont(ofSize: 13)
    
    soundSwitch = UISwitch()
    soundSwitch.isOn = true

    trailKeyLabel = UILabel()
    trailKeyLabel.text = "Trail length"
    trailKeyLabel.textColor = .white
    trailKeyLabel.font = .systemFont(ofSize: 13)

    trailLengthControl = UISegmentedControl(items: ["none", "short", "long"])
    trailLengthControl.backgroundColor = .gray
    trailLengthControl.selectedSegmentTintColor = .white
    trailLengthControl.selectedSegmentIndex = 2

    colorControl = UISegmentedControl(items: [UIImage(systemName: "paintpalette")!.withRenderingMode(.alwaysOriginal), UIImage(systemName: "paintpalette")!])
    colorControl.backgroundColor = .gray
    colorControl.selectedSegmentTintColor = .white
    colorControl.selectedSegmentIndex = 0

    typeControl = UISegmentedControl(items: [UIImage(systemName: "square")!, UIImage(systemName: "rectangle")!])
    typeControl.backgroundColor = .gray
    typeControl.selectedSegmentTintColor = .white
    typeControl.selectedSegmentIndex = 0
    typeControl.tintColor = .red

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

    super.init(frame: frame)

    backgroundColor = .clear

    let cutOffStackView = UIStackView(arrangedSubviews: [cutOffKeyLabel, cutOffValueLabel, cutOffStepper])
    cutOffStackView.spacing = 20

    let zoomStackView = UIStackView(arrangedSubviews: [zoomKeyLabel, zoomSwitch])
    zoomStackView.spacing = 20

    let starsStackView = UIStackView(arrangedSubviews: [starsKeyLabel, starsSwitch])
    starsStackView.spacing = 20

    let trailsStackView = UIStackView(arrangedSubviews: [trailKeyLabel, trailLengthControl])
    trailsStackView.axis = .vertical

    let soundStackView = UIStackView(arrangedSubviews: [soundKeyLabel, soundSwitch])

    let buttonStackView = UIStackView(arrangedSubviews: [clearButton, randomButton, shareImageButton])
    buttonStackView.spacing = 5
    buttonStackView.distribution = .fillEqually

    let settingsStackView = UIStackView(arrangedSubviews: [zoomStackView, starsStackView, soundStackView, trailsStackView, colorControl, typeControl, buttonStackView])
    settingsStackView.axis = .vertical
    settingsStackView.spacing = 20

    let stackView = UIStackView(arrangedSubviews: [settingsStackView, showHideButton])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 20

    addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),

      showHideButton.widthAnchor.constraint(equalToConstant: 30),

      cutOffValueLabel.widthAnchor.constraint(equalToConstant: 20),
    ])
  }

  required init?(coder: NSCoder) { fatalError() }
}
