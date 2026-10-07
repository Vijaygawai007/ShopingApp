
//
//  LoginViewController.swift
//  ShopingApp
//
//  Created by Vijay on 22/09/26.
//

import UIKit
import Supabase

class LoginViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // Remember Me Button
    @IBOutlet weak var rememberMeButton: UIButton!


    // MARK: - UserDefaults

    private let rememberMeKey = "rememberMe"


    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.text = "gawaivijay481@gmail.com"
        passwordTextField.text = "Vijay@123"
        setupTextFields()
        setupRememberMeButton()
        loadRememberMeState()
    }


    // MARK: - Text Fields

    private func setupTextFields() {

        setupLeftIcon(
            textField: emailTextField,
            systemName: "envelope"
        )

        setupLeftIcon(
            textField: passwordTextField,
            systemName: "lock"
        )

        addPasswordToggleButton(
            to: passwordTextField,
            action: #selector(passwordEyeButtonTapped)
        )


        // -----------------------------------------
        // Email
        // -----------------------------------------

        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.spellCheckingType = .no
        emailTextField.borderStyle = .roundedRect


        // -----------------------------------------
        // Password
        // -----------------------------------------

        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
    }


    // MARK: - Left Icon

    private func setupLeftIcon(
        textField: UITextField,
        systemName: String
    ) {

        let imageView = UIImageView()

        imageView.image = UIImage(
            systemName: systemName
        )

        imageView.tintColor = .systemGray

        imageView.contentMode = .scaleAspectFit

        imageView.frame = CGRect(
            x: 0,
            y: 0,
            width: 22,
            height: 22
        )


        let containerView = UIView()

        containerView.frame = CGRect(
            x: 0,
            y: 0,
            width: 45,
            height: 22
        )


        imageView.center = containerView.center

        containerView.addSubview(imageView)


        textField.leftView = containerView

        textField.leftViewMode = .always
    }


    // MARK: - Password Eye Button

    private func addPasswordToggleButton(
        to textField: UITextField,
        action: Selector
    ) {

        let containerView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 55,
                height: 45
            )
        )


        let eyeButton = UIButton(
            type: .system
        )


        eyeButton.setImage(
            UIImage(
                systemName: "eye.slash"
            ),
            for: .normal
        )


        eyeButton.tintColor = .systemGray


        eyeButton.frame = CGRect(
            x: 0,
            y: 0,
            width: 45,
            height: 45
        )


        eyeButton.center = CGPoint(
            x: 20,
            y: containerView.bounds.midY
        )


        eyeButton.addTarget(
            self,
            action: action,
            for: .touchUpInside
        )


        containerView.addSubview(eyeButton)


        textField.rightView = containerView

        textField.rightViewMode = .always
    }


    // MARK: - Password Eye Action

    @objc private func passwordEyeButtonTapped() {

        passwordTextField.isSecureTextEntry.toggle()

        updateEyeIcon(
            for: passwordTextField
        )
    }


    // MARK: - Update Eye Icon

    private func updateEyeIcon(
        for textField: UITextField
    ) {

        guard
            let containerView = textField.rightView,
            let button = containerView.subviews
                .compactMap({ $0 as? UIButton })
                .first
        else {
            return
        }


        let imageName = textField.isSecureTextEntry
            ? "eye.slash"
            : "eye"


        button.setImage(
            UIImage(
                systemName: imageName
            ),
            for: .normal
        )
    }


    // MARK: - Remember Me Setup

    private func setupRememberMeButton() {

        rememberMeButton.setTitle(
            "Remember Me",
            for: .normal
        )

        rememberMeButton.setTitleColor(
            .systemBlue,
            for: .normal
        )

        rememberMeButton.titleLabel?.font = UIFont.systemFont(
            ofSize: 9
        )

        rememberMeButton.tintColor = .systemBlue

        rememberMeButton.contentHorizontalAlignment = .left

        updateRememberMeButton()
    }


    // MARK: - Load Remember Me State

    private func loadRememberMeState() {

        let isRemembered = UserDefaults.standard.bool(
            forKey: rememberMeKey
        )

        rememberMeButton.isSelected = isRemembered

        updateRememberMeButton()
    }


    // MARK: - Remember Me Button

    @IBAction func rememberMeButtonTapped(
        _ sender: UIButton
    ) {

        sender.isSelected.toggle()

        let isSelected = sender.isSelected

        UserDefaults.standard.set(
            isSelected,
            forKey: rememberMeKey
        )

        UserDefaults.standard.synchronize()

        updateRememberMeButton()
    }


    // MARK: - Update Remember Me UI

    private func updateRememberMeButton() {

        let imageName = rememberMeButton.isSelected
            ? "checkmark.square.fill"
            : "square"

        let image = UIImage(
            systemName: imageName
        )

        rememberMeButton.setImage(
            image,
            for: .normal
        )

//        rememberMeButton.tintColor = .none

        rememberMeButton.imageView?.contentMode = .scaleToFill
    }


    // MARK: - Login

    @IBAction func loginButtonTapped(
        _ sender: UIButton
    ) {

        // -----------------------------------------
        // Get Email
        // -----------------------------------------

        guard let email = emailTextField.text?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        else {

            showAlert(
                title: "Error",
                message: "Please enter your email."
            )

            return
        }


        // -----------------------------------------
        // Get Password
        // -----------------------------------------

        guard let password = passwordTextField.text
        else {

            showAlert(
                title: "Error",
                message: "Please enter your password."
            )

            return
        }


        // -----------------------------------------
        // Validate Email
        // -----------------------------------------

        guard !email.isEmpty else {

            showAlert(
                title: "Missing Email",
                message: "Please enter your email address."
            )

            return
        }


        // -----------------------------------------
        // Validate Password
        // -----------------------------------------

        guard !password.isEmpty else {

            showAlert(
                title: "Missing Password",
                message: "Please enter your password."
            )

            return
        }


        // -----------------------------------------
        // Basic Email Validation
        // -----------------------------------------

        guard email.contains("@"),
              email.contains(".")
        else {

            showAlert(
                title: "Invalid Email",
                message: "Please enter a valid email address."
            )

            return
        }


        // -----------------------------------------
        // Disable Login Button
        // -----------------------------------------
        // MARK: - Login
                sender.isEnabled = false

                Task {
                    do {
                        // REMOVED: Premature navigation code that was here
                        
                        let session = try await SupabaseManager.shared.client.auth.signIn(
                            email: email,
                            password: password
                        )

                        // Login Successful
                        print("================================")
                        print("✅ LOGIN SUCCESSFUL")
                        print("User ID: \(session.user.id)")
                        print("================================")

                        let rememberMe = rememberMeButton.isSelected
                        UserDefaults.standard.set(rememberMe, forKey: rememberMeKey)

                        await MainActor.run {
                            sender.isEnabled = true
                            openHomeScreen() // Navigate only upon success
                        }

                    } catch {
                        // Login Failed
                        print("================================")
                        print("❌ LOGIN FAILED")
                        print(error.localizedDescription)
                        print("================================")

                        await MainActor.run {
                            sender.isEnabled = true
                            showAlert(
                                title: "Login Failed",
                                message: error.localizedDescription
                            )
                        }
                    }
                }
            }
    
    // MARK: - Open Home Tab Bar

    private func openHomeScreen() {

        print("🚀 Opening Tab Bar")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let tabBarController = storyboard.instantiateViewController(
            withIdentifier: "tabbarViewController"
        ) as? UITabBarController else {

            print("❌ Tab Bar Controller not found")
            return
        }

        print("✅ Tab Bar instantiated")

        tabBarController.selectedIndex = 0
        tabBarController.modalPresentationStyle = .fullScreen

        present(
            tabBarController,
            animated: true
        ) {
            print("✅ Tab Bar presented")
        }
    }

    // MARK: - Sign Up

    @IBAction func signUpBTN(
        _ sender: UIButton
    ) {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )


        guard let registerVC =
                storyboard.instantiateViewController(
                    withIdentifier:
                        "RegisterViewController"
                ) as? RegisterViewController
        else {

            print(
                "❌ RegisterViewController not found."
            )

            print(
                "Check Storyboard ID: RegisterViewController"
            )

            return
        }


        registerVC.modalPresentationStyle =
            .fullScreen


        present(
            registerVC,
            animated: true
        )
    }


    // MARK: - Forgot Password

    @IBAction func forgetPASSBTN(
        _ sender: UIButton
    ) {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )


        guard let forgetVC =
                storyboard.instantiateViewController(
                    withIdentifier:
                        "resetViewController"
                ) as? resetViewController
        else {

            print(
                "❌ resetViewController not found."
            )

            print(
                "Check Storyboard ID: resetViewController"
            )

            return
        }


        forgetVC.modalPresentationStyle =
            .fullScreen


        present(
            forgetVC,
            animated: true
        )
    }


    // MARK: - Alert

    private func showAlert(
        title: String,
        message: String
    ) {

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )


        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )


        present(
            alert,
            animated: true
        )
    }
}

