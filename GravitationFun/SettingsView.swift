//  Created by Dominik Hauser on 26.12.21.
//  
//

import UIKit

class SettingsView: UIView {

  let cutOffKeyLabel: UILabel
  let cutOffValueLabel: UILabel
  let cutOffStepper: UIStepper

  let zoomKeyLabel: UILabel
  let zoomSwitch: UISwitch

  let trailKeyLabel: UILabel
  let trailLengthControl: UISegmentedControl

  let soundKeyLabel: UILabel
  let soundSwitch: UISwitch

  let typControl: UISegmentedControl

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

    zoomKeyLabel = UILabel()
    zoomKeyLabel.text = "Zoom buttons"
    zoomKeyLabel.textColor = .white
    zoomKeyLabel.font = .systemFont(ofSize: 13)

    zoomSwitch = UISwitch()
    zoomSwitch.isOn = false

    trailKeyLabel = UILabel()
    trailKeyLabel.text = "Trail length"
    trailKeyLabel.textColor = .white
    trailKeyLabel.font = .systemFont(ofSize: 13)

    trailLengthControl = UISegmentedControl(items: ["none", "short", "long"])
    trailLengthControl.backgroundColor = .gray
    trailLengthControl.selectedSegmentTintColor = .white
    trailLengthControl.selectedSegmentIndex = 2

    soundKeyLabel = UILabel()
    soundKeyLabel.text = "Sound"
    soundKeyLabel.textColor = .white
    soundKeyLabel.font = .systemFont(ofSize: 13)

    soundSwitch = UISwitch()
    soundSwitch.isOn = true

    typControl = UISegmentedControl(items: [UIImage(systemName: "square")!, UIImage(systemName: "rectangle")!])
    typControl.backgroundColor = .gray
    typControl.selectedSegmentTintColor = .white
    typControl.selectedSegmentIndex = 0

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

    backgroundColor = .init(white: 0.1, alpha: 1)

    let cutOffStackView = UIStackView(arrangedSubviews: [cutOffKeyLabel, cutOffValueLabel, cutOffStepper])
    cutOffStackView.spacing = 20

    let zoomStackView = UIStackView(arrangedSubviews: [zoomKeyLabel, zoomSwitch])
    zoomStackView.spacing = 20

    let trailsStackView = UIStackView(arrangedSubviews: [trailKeyLabel, trailLengthControl])
    trailsStackView.axis = .vertical

    let soundStackView = UIStackView(arrangedSubviews: [soundKeyLabel, soundSwitch])

    let buttonStackView = UIStackView(arrangedSubviews: [clearButton, randomButton, shareImageButton])
    buttonStackView.spacing = 5
    buttonStackView.distribution = .fillEqually

    let settingsStackView = UIStackView(arrangedSubviews: [zoomStackView, trailsStackView, soundStackView, typControl, buttonStackView])
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
