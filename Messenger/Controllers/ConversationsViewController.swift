//
//  ViewController.swift
//  Messenger
//
//  Created by Denis Efremov on 2024-01-25.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    private var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log Out", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red

        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(logoutButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        validateAuth()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoutButton.frame = CGRect(
            x: 30,
            y: 30,
            width: view.width-60,
            height: 52
        )
    }

    // MARK: - Helpers

    @objc private func didTapLogoutButton() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: Successfully signed out")
            validateAuth(animated: true)
        } catch {
            print("DEBUG: Error signing out = \(error.localizedDescription)")
        }

    }

    private func validateAuth(animated: Bool = false) {
        if Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: animated)
        }
    }

}

