//
//  ATableViewController.swift
//  NoSwipeDeleteConflictPageVC
//
//  Created by songgeb on 2019/9/28.
//  Copyright © 2019 Songgeb. All rights reserved.
//

import UIKit

class ATableViewController: UITableViewController {
        
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(ATableViewCell.self, forCellReuseIdentifier: "reuseidentifier")
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseidentifier", for: indexPath)
    cell.textLabel?.text = "What a nice day!"

    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
  }
}
