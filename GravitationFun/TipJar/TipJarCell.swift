//  Created by Dominik Hauser on 21.05.23.
//  Copyright © 2023 dasdom. All rights reserved.
//


import UIKit
import RevenueCat

class TipJarCell: UITableViewCell {

  let titleLabel: UILabel
  let descriptionLabel: UILabel
  let button: UIButton

  static var identifier: String {
    return NSStringFromClass(self.self)
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

    titleLabel = UILabel()
    titleLabel.font = .preferredFont(forTextStyle: .title1)
    titleLabel.textAlignment = .center
    titleLabel.textColor = .white

    descriptionLabel = UILabel()
    descriptionLabel.font = .preferredFont(forTextStyle: .body)
    descriptionLabel.textAlignment = .center
    descriptionLabel.textColor = .white

    button = UIButton(configuration: .filled())

    let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, button])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 5

    super.init(style: style, reuseIdentifier: reuseIdentifier)

    contentView.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
    ])
  }

  required init?(coder: NSCoder) { fatalError() }
}

extension TipJarCell {
  func update(with product: StoreProduct) {
    titleLabel.text = product.localizedTitle
    descriptionLabel.text = product.localizedDescription
    button.setTitle(product.localizedPriceString, for: .normal)
  }
}
