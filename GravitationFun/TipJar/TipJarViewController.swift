//  Created by Dominik Hauser on 21.05.23.
//  Copyright © 2023 dasdom. All rights reserved.
//


import UIKit
import RevenueCat

class TipJarViewController: UITableViewController {

  var products: [StoreProduct] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Tip Jar"

    let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBackground]
    navigationController?.navigationBar.titleTextAttributes = textAttributes

    let darkGray = UIColor(named: "darkGray")

    view.tintColor = darkGray

    Purchases.shared.getProducts([
      "de.dasdom.GravitationFun.small_tip",
      "de.dasdom.GravitationFun.large_tip"
    ]) { [weak self] products in
      self?.products = products
      self?.tableView.reloadData()
    }

    tableView.register(TipJarCell.self, forCellReuseIdentifier: TipJarCell.identifier)

    tableView.backgroundColor = .init(white: 0.1, alpha: 1)

    navigationController?.navigationBar.tintColor = darkGray
    let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
    navigationItem.rightBarButtonItem = doneButton

    let restoreButton = UIBarButtonItem(title: "Restore", style: .done, target: self, action: #selector(restore))
    navigationItem.leftBarButtonItem = restoreButton
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return products.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let product = products[indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: TipJarCell.identifier, for: indexPath) as! TipJarCell

    cell.update(with: product)
    cell.backgroundColor = tableView.backgroundColor
    if nil == cell.button.target(forAction: #selector(purchase(_:)), withSender: cell.button) {
      cell.button.addTarget(self, action: #selector(purchase(_:)), for: .touchUpInside)
    }

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: - Actions
extension TipJarViewController {
  @objc func done(_ sender: UIBarButtonItem) {
    dismiss(animated: true)
  }

  @objc func restore(_ sender: UIButton) {
    Purchases.shared.restorePurchases { [weak self] customerInfo, error in
      if let error = error {
        self?.showAlert(message: error.localizedDescription)
      } else if customerInfo?.allPurchasedProductIdentifiers.isEmpty == true {
        self?.showAlert(message: "No purchases found.")
      } else {
        self?.dismiss(animated: true)
      }
    }
  }

  @objc func purchase(_ sender: UIButton) {
    let location = sender.convert(sender.bounds.origin, to: tableView)
    guard let indexPath = tableView.indexPathForRow(at: location) else {
      return
    }
    let product = products[indexPath.row]
    print("\(product.localizedTitle)")
    Task {
      do {
        _ = try await Purchases.shared.purchase(product: product)
        if let gameViewController = presentingViewController as? GameViewController {
          gameViewController.updateForPurchases()
        }
        showAlert(title: "Thank you!", message: "You are officially awesome!") {
          self.dismiss(animated: true)
        }
      } catch {
        print("\(#file), \(#line): \(error)")

        if let error = error as? RevenueCat.ErrorCode {
          switch error {
            case .purchaseNotAllowedError:
              showAlert(message: "Purchases not allowed on this device.")
            case .purchaseInvalidError:
              showAlert(message: "Purchase invalid, check payment source.")
            default:
              break
          }
        }
      }
    }
  }

  func showAlert(title: String = "Error", message: String, action: @escaping () -> Void = {}) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in action() }))
    present(alert, animated: true)
  }
}
