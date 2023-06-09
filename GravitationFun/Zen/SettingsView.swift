//  Created by Dominik Hauser on 26.12.21.
//  
//

import UIKit

class SettingsView: UIView {

  let starsKeyLabel: UILabel
  let starsSwitch: UISwitch

  let zoomKeyLabel: UILabel
  let zoomSwitch: UISwitch

  let gravityControl: UISegmentedControl

  let trailKeyLabel: UILabel
  let trailLengthControl: UISegmentedControl

  let trailThicknessControl: UISegmentedControl

  let colorControl: UISegmentedControl

//  let spawnControl: UISegmentedControl
  let backgroundColorKeyLabel: UILabel
  let backgroundColorControl: UISegmentedControl
  let backgroundColorDescriptionLabel: UILabel

  let loadButton: UIButton
  let saveButton: UIButton

  let tipJarButton: UIButton

  let shareImageButton: UIButton

  let randomButton: UIButton

  let clearButton: UIButton

  let showHideButton: UIButton

  override init(frame: CGRect) {

    let darkGray = UIColor(named: "darkGray")

    starsKeyLabel = UILabel()
    starsKeyLabel.text = "Stars"
    starsKeyLabel.textColor = .systemGray
    starsKeyLabel.font = .systemFont(ofSize: 13)

    starsSwitch = UISwitch()
    starsSwitch.isOn = true
    starsSwitch.onTintColor = darkGray

    zoomKeyLabel = UILabel()
    zoomKeyLabel.text = "Zoom buttons"
    zoomKeyLabel.textColor = .systemGray
    zoomKeyLabel.font = .systemFont(ofSize: 13)

    zoomSwitch = UISwitch()
    zoomSwitch.isOn = false
    zoomSwitch.accessibilityLabel = "Show zoom buttons"
    zoomSwitch.onTintColor = darkGray

    gravityControl = UISegmentedControl(items: ["Gravity", "Spirograph"])
    gravityControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.gray], for: .normal)
    gravityControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
    gravityControl.selectedSegmentTintColor = darkGray
    gravityControl.selectedSegmentIndex = 0

    trailKeyLabel = UILabel()
    trailKeyLabel.text = "Trail"
    trailKeyLabel.textColor = .systemGray
    trailKeyLabel.font = .systemFont(ofSize: 13)

    trailLengthControl = UISegmentedControl(items: ["none", "short", "long"])
    trailLengthControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.gray], for: .normal)
    trailLengthControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
    trailLengthControl.selectedSegmentTintColor = darkGray
    trailLengthControl.selectedSegmentIndex = 2

    trailThicknessControl = UISegmentedControl(items: ["thin", "normal", "thick"])
    trailThicknessControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.gray], for: .normal)
    trailThicknessControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
    trailThicknessControl.selectedSegmentTintColor = darkGray
    trailThicknessControl.selectedSegmentIndex = 1

    colorControl = UISegmentedControl(items: [UIImage(systemName: "paintpalette")!.withRenderingMode(.alwaysOriginal), UIImage(systemName: "paintpalette")!])
    colorControl.selectedSegmentTintColor = darkGray
    colorControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.gray], for: .normal)
    colorControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
    colorControl.selectedSegmentIndex = 0

    backgroundColorKeyLabel = UILabel()
    backgroundColorKeyLabel.text = "Background"
    backgroundColorKeyLabel.textColor = .systemGray
    backgroundColorKeyLabel.font = .systemFont(ofSize: 13)

    backgroundColorControl = UISegmentedControl(items: ["black", "gray", "white"])
    backgroundColorControl.selectedSegmentTintColor = darkGray
    backgroundColorControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.gray], for: .normal)
    backgroundColorControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
    backgroundColorControl.selectedSegmentIndex = 0
    backgroundColorControl.isEnabled = false

    backgroundColorDescriptionLabel = UILabel()
    backgroundColorDescriptionLabel.text = "Enabled after tip"
    backgroundColorDescriptionLabel.textColor = .systemGray
    backgroundColorDescriptionLabel.font = .systemFont(ofSize: 11)
    backgroundColorDescriptionLabel.textAlignment = .center

//    spawnControl = UISegmentedControl(items: ["manual", "automatic"])
//    spawnControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.gray], for: .normal)
//    spawnControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
//    spawnControl.selectedSegmentTintColor = darkGray
//    spawnControl.selectedSegmentIndex = 0

    loadButton = UIButton(configuration: .filled())
    loadButton.setTitle("Load", for: .normal)

    saveButton = UIButton(configuration: .filled())
    saveButton.setTitle("Save", for: .normal)

    tipJarButton = UIButton(configuration: .filled())
    tipJarButton.setTitle("Tip Jar", for: .normal)

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
    showHideButton.tintColor = .systemGray

    super.init(frame: frame)

    backgroundColor = .clear
    tintColor = darkGray

    let zoomStackView = UIStackView(arrangedSubviews: [zoomKeyLabel, zoomSwitch])
    zoomStackView.spacing = 20

    let starsStackView = UIStackView(arrangedSubviews: [starsKeyLabel, starsSwitch])
    starsStackView.spacing = 20

    let trailsStackView = UIStackView(arrangedSubviews: [trailKeyLabel, trailLengthControl, trailThicknessControl])
    trailsStackView.axis = .vertical
    trailsStackView.spacing = 5

    let backgroundColorStackView = UIStackView(arrangedSubviews: [backgroundColorKeyLabel, backgroundColorControl, backgroundColorDescriptionLabel])
    backgroundColorStackView.axis = .vertical
    backgroundColorStackView.spacing = 5

    let loadSaveStackView = UIStackView(arrangedSubviews: [loadButton, saveButton])
    loadSaveStackView.spacing = 5
    loadSaveStackView.distribution = .fillEqually

    let buttonStackView = UIStackView(arrangedSubviews: [clearButton, randomButton, shareImageButton])
    buttonStackView.spacing = 5
    buttonStackView.distribution = .fillEqually

    let settingsStackView = UIStackView(arrangedSubviews: [zoomStackView, starsStackView, gravityControl, trailsStackView, colorControl, backgroundColorStackView, loadSaveStackView, tipJarButton, buttonStackView])
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
    ])
  }

  required init?(coder: NSCoder) { fatalError() }
}
