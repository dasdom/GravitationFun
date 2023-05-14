//  Created by Dominik Hauser on 14.05.23.
//  Copyright © 2023 dasdom. All rights reserved.
//


import UIKit

class ZenStatesViewController: UITableViewController {

  var gravityZenStates: [GravityZenState] = []
  var gravityZenStateSelectionHandler: ((GravityZenState) -> Void)?
  let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Saved Gravity Zen States"

    let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBackground]
    navigationController?.navigationBar.titleTextAttributes = textAttributes

    do {
      let data = try Data(contentsOf: FileManager.default.sceneStatesURL)
      let gravityZenStates = try JSONDecoder().decode([GravityZenState].self, from: data)
      self.gravityZenStates = gravityZenStates.reversed()
    } catch {
      print("\(#file), \(#line): \(error)")
      gravityZenStates = []
    }

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    tableView.backgroundColor = .secondaryLabel
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return gravityZenStates.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

    let gravityZenState = gravityZenStates[indexPath.row]
    let image = UIImage(data: gravityZenState.imageData)

    var config = cell.defaultContentConfiguration()
    config.image = image
    config.text = dateFormatter.string(from: gravityZenState.date)
    config.imageProperties.maximumSize = .init(width: 160, height: 120)
    config.textProperties.color = .systemBackground
    cell.contentConfiguration = config
    cell.backgroundColor = .secondaryLabel

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let gravityZenState = gravityZenStates[indexPath.row]
    gravityZenStateSelectionHandler?(gravityZenState)
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      gravityZenStates.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)

      do {
        let data = try JSONEncoder().encode(gravityZenStates)
        try data.write(to: FileManager.default.sceneStatesURL)
      } catch {
        print("\(#file), \(#line): \(error)")
      }
    }
  }
}
