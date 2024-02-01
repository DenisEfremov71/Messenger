//
//  ViewController.swift
//  Messenger
//
//  Created by Denis Efremov on 2024-01-25.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    private let tableView: UITableView = {
        let tableView = UITableView()
        //tableView.register(<#T##nib: UINib?##UINib?#>, forCellReuseIdentifier: <#T##String#>)
        return tableView
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        validateAuth()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // MARK: - Helpers

    private func validateAuth() {
        if Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }

}

