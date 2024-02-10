//
//  LoginViewController.swift
//  Messenger
//
//  Created by Denis Efremov on 2024-01-25.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import GoogleSignIn
import GoogleSignInSwift
import JGProgressHUD

class LoginViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()

    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()

    private let googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        return button
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Register",
            style: .done,
            target: self,
            action: #selector(didTapRegister)
        )

        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(didTapGoogleSignInButon), for: .touchUpInside)

        emailField.delegate = self
        passwordField.delegate = self
        facebookLoginButton.delegate = self

        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleSignInButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds

        let size = scrollView.width/3
        imageView.frame = CGRect(
            x: (view.width-size)/2,
            y: 20,
            width: size,
            height: size
        )
        emailField.frame = CGRect(
            x: 30,
            y: imageView.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
        passwordField.frame = CGRect(
            x: 30,
            y: emailField.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
        loginButton.frame = CGRect(
            x: 30,
            y: passwordField.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
        facebookLoginButton.frame = CGRect(
            x: 30,
            y: loginButton.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
        googleSignInButton.frame = CGRect(
            x: 30,
            y: facebookLoginButton.bottom+10,
            width: scrollView.width-60,
            height: 52
        )
    }

    // MARK: - Helpers

    @objc private func didTapGoogleSignInButon() {

        // TODO: - Check if this is necessary
        //logoutCurrentUser()

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            guard result != nil, error == nil else {
                // TODO: - Add Error Handling
                print("DEBUG: Error signing in with Google = \(error?.localizedDescription ?? "no error")")
                return
            }
            guard let googleUser = result?.user,
                  let _ = googleUser.userID,
                  let email = googleUser.profile?.email,
                  let firstName = googleUser.profile?.givenName,
                  let lastName = googleUser.profile?.familyName,
                  let pictureUrl = googleUser.profile?.imageURL(withDimension: 200),
                  let idToken = googleUser.idToken else {
                // TODO: - Add Error Handling
                print("DEBUG: Error getting Google user info")
                return
            }

            UserDefaults.standard.set(email, forKey: "email")

            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    let user = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with: user) { success in
                        if success {

                            URLSession.shared.dataTask(with: pictureUrl) { data, _, error in
                                guard let data = data, error == nil else {
                                    // TODO: - Add Error Handling
                                    print("DEBUG: Failed to get Google profile image")
                                    return
                                }

                                // upload image
                                let filename = user.profilePictureFilename
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: filename) { result in
                                    switch result {
                                    case .failure(let error):
                                        // TODO: - Add Error Handling
                                        print("DEBUG: StorageManager failed to upload profile picture, error = \(error.localizedDescription)")
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profilePictureUrl")
                                        print("DEBUG: Profile picture download URL = \(downloadUrl)")
                                    }
                                }

                            }
                            .resume()

                        }
                    }
                }
            }

            let credentials = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: googleUser.accessToken.tokenString
            )

            Auth.auth().signIn(with: credentials) { [weak self] authDataResul, error in
                guard let self = self else { return }
                guard authDataResul != nil, error == nil else {
                    // TODO: - Add Error Handling
                    print("DEBUG: Facebook credential login failed, MFA may be needed")
                    return
                }

                print("DEBUG: Successfully logged user in")
                DispatchQueue.main.async {
                    self.navigationController?.dismiss(animated: true)
                }
            }
        }

    }

    @objc private func didTapLoginButton() {

        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()

        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }

        spinner.show(in: view)

        // Firebase Log In
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.spinner.dismiss()
            }

            guard let result = authResult, error == nil else {
                // TODO: - Add Error Handling
                print("DEBUG: Error logging in a user with email \(email). Error = \(error?.localizedDescription ?? "")")
                return
            }

            let user = result.user

            UserDefaults.standard.set(email, forKey: "email")

            print("DEBUG: Logged in user \(user)")
            DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: true)
            }
        }
    }

    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }

    func alertUserLoginError() {
        let alert = UIAlertController(title: "Invalid Log In Info", message: "Please enter all the information to log in.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            didTapLoginButton()
        }

        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        // no operation
    }
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            // TODO: - Add Error Handling
            print("DEBUG: User failed to log in with Facebook")
            return
        }

        let facebookRequest = FBSDKLoginKit.GraphRequest(
            graphPath: "me",
            parameters: ["fields" : "email, first_name, last_name, picture.type(large)"],
            tokenString: token,
            version: nil,
            httpMethod: .get
        )

        facebookRequest.start { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                // TODO: - Add Error Handling
                print("DEBUG: Failed to make Facebook graph request with error = \(error?.localizedDescription ?? "")")
                return
            }

            guard let firstName = result["first_name"] as? String, 
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String else {
                // TODO: - Add Error Handling
                print("DEBUG: Error retrieving user data from Facebook")
                return
            }

            UserDefaults.standard.set(email, forKey: "email")

            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    let user = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with: user) { success in
                        if success {

                            guard let url = URL(string: pictureUrl) else { return }

                            URLSession.shared.dataTask(with: url) { data, _, error in
                                guard let data = data, error == nil else {
                                    // TODO: - Add Error Handling
                                    print("DEBUG: Failed to get Facebook profile image")
                                    return
                                }

                                // upload image
                                let filename = user.profilePictureFilename
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: filename) { result in
                                    switch result {
                                    case .failure(let error):
                                        // TODO: - Add Error Handling
                                        print("DEBUG: StorageManager failed to upload profile picture, error = \(error.localizedDescription)")
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profilePictureUrl")
                                        print("DEBUG: Profile picture download URL = \(downloadUrl)")
                                    }
                                }

                            }
                            .resume()

                        }
                    }
                }
            }

            let credentials = FacebookAuthProvider.credential(withAccessToken: token)

            Auth.auth().signIn(with: credentials) { [weak self] authDataResul, error in
                guard let self = self else { return }
                guard authDataResul != nil, error == nil else {
                    // TODO: - Add Error Handling
                    print("DEBUG: Facebook credential login failed, MFA may be needed")
                    return
                }

                print("DEBUG: Successfully logged user in")
                DispatchQueue.main.async {
                    self.navigationController?.dismiss(animated: true)
                }
            }
        }
    }
}
