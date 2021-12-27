//  Created by Dominik Hauser on 26.12.21.
//  
//

import UIKit

class SettingsView: UIView {

  let cutOffKeyLabel: UILabel
  let cutOffValueLabel: UILabel
  let cutOffStepper: UIStepper

  let trailsKeyLabel: UILabel
  let trailsSwitch: UISwitch

  let soundKeyLabel: UILabel
  let soundSwitch: UISwitch

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

    trailsKeyLabel = UILabel()
    trailsKeyLabel.text = "Trails"
    trailsKeyLabel.textColor = .white
    trailsKeyLabel.font = .systemFont(ofSize: 13)

    trailsSwitch = UISwitch()
    trailsSwitch.isOn = true

    soundKeyLabel = UILabel()
    soundKeyLabel.text = "Sound"
    soundKeyLabel.textColor = .white
    soundKeyLabel.font = .systemFont(ofSize: 13)

    soundSwitch = UISwitch()
    soundSwitch.isOn = true

    clearButton = UIButton(type: .system)
    clearButton.configuration = UIButton.Configuration.filled()
    clearButton.setTitle("Clear", for: .normal)

    showHideButton = UIButton(type: .system)
    showHideButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)

    super.init(frame: frame)

    backgroundColor = .init(white: 0.1, alpha: 1)

    let cutOffStackView = UIStackView(arrangedSubviews: [cutOffKeyLabel, cutOffValueLabel, cutOffStepper])
    cutOffStackView.spacing = 20

    let trailsStackView = UIStackView(arrangedSubviews: [trailsKeyLabel, trailsSwitch])

    let soundStackView = UIStackView(arrangedSubviews: [soundKeyLabel, soundSwitch])

    let settingsStackView = UIStackView(arrangedSubviews: [cutOffStackView, trailsStackView, soundStackView, clearButton])
    settingsStackView.axis = .vertical
    settingsStackView.spacing = 10

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
