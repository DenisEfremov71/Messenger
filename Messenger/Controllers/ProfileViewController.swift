//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Denis Efremov on 2024-01-25.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    let data = ["Log Out"]

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }

    // MARK: - Helpers

    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }

        let safeEmail = DatabaseManager.safeEmail(with: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/" + filename

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 200))
        headerView.backgroundColor = .link

        let imageView = UIImageView(frame: CGRect(x: (self.view.width - 150) / 2, y: 25, width: 150, height: 150))
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = imageView.width / 2
        imageView.layer.masksToBounds = true

        StorageManager.shared.downloadUrl(for: path) { [weak self] result in
            switch result {
            case .failure(let error):
                // TODO: - Add Error Handling
                print("DEBUG: Failed to get download URL: \(error.localizedDescription)")
            case .success(let url):
                self?.downloadProfileImage(imageView: imageView, url: url)
            }
        }

        headerView.addSubview(imageView)

        return headerView
    }

    func downloadProfileImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                // TODO: - Add Error Handling
                print("DEBUG: Failed to download image: \(error?.localizedDescription ?? "unknown error")")
                return
            }

            guard let image = UIImage(data: data) else {
                // TODO: - Add Error Handling
                print("DEBUG: Corrupted image data")
                return
            }

            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        .resume()
    }

}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let actionSheet = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .actionSheet
        )
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            guard let self = self else { return }

            // Log Out Facebook
            LoginManager().logOut()

            do {
                try Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false)
            } catch {
                // TODO: - Add Error Handling
                print("DEBUG: Error signing out = \(error.localizedDescription)")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(logOutAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
}
