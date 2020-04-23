//
//  ViewController.swift
//  SivireDemo
//
//  Created by Mario on 17/04/2020.
//  Copyright © 2020 Mario Iannotta. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(fakeRefresh), for: .valueChanged)
    }

    @objc private func fakeRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
}

