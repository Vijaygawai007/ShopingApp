
//
//  RegisterViewController.swift
//  ShopingApp
//
//  Created by Vijay on 22/09/26.
//

import UIKit
import Supabase

class RegisterViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var full_NameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phone_NumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirm_passwordTextField: UITextField!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
    }
    
    // MARK: - Setup TextFields
    
    private func setupTextFields() {
        
        // Full Name
        setupLeftIcon(
            textField: full_NameTextField,
            systemName: "person"
        )
        
        // Email
        setupLeftIcon(
            textField: emailTextField,
            systemName: "envelope"
        )
        
        // Phone
        setupLeftIcon(
            textField: phone_NumberTextField,
            systemName: "phone"
        )
        
        // Password
        setupLeftIcon(
            textField: passwordTextField,
            systemName: "lock"
        )
        
        addPasswordToggleButton(
            to: passwordTextField,
            action: #selector(passwordEyeButtonTapped)
        )
        
        // Confirm Password
        setupLeftIcon(
            textField: confirm_passwordTextField,
            systemName: "lock"
        )
        
        addPasswordToggleButton(
            to: confirm_passwordTextField,
            action: #selector(confirmPasswordEyeButtonTapped)
        )
        
        // Keyboard settings
        
        full_NameTextField.autocapitalizationType = .words
        full_NameTextField.autocorrectionType = .no
        full_NameTextField.borderStyle = .roundedRect
        
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.borderStyle = .roundedRect
        
        phone_NumberTextField.keyboardType = .phonePad
        phone_NumberTextField.borderStyle = .roundedRect
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        
        confirm_passwordTextField.isSecureTextEntry = true
        confirm_passwordTextField.borderStyle = .roundedRect
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
        
        let containerView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 45,
                height: 22
            )
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
            width: 24,
            height: 24
        )
        
        // Move eye icon slightly to the left
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
    
    // MARK: - Password Eye Button Action
    
    @objc private func passwordEyeButtonTapped() {
        
        passwordTextField.isSecureTextEntry.toggle()
        
        updateEyeIcon(
            for: passwordTextField
        )
    }
    
    // MARK: - Confirm Password Eye Button Action
    
    @objc private func confirmPasswordEyeButtonTapped() {
        
        confirm_passwordTextField.isSecureTextEntry.toggle()
        
        updateEyeIcon(
            for: confirm_passwordTextField
        )
    }
    
    // MARK: - Update Eye Icon
    
    private func updateEyeIcon(
        for textField: UITextField
    ) {
        
        guard let containerView = textField.rightView,
              let button = containerView.subviews.first(
                where: { $0 is UIButton }
              ) as? UIButton
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
    
    // MARK: - Register Button
    
    @IBAction func registerButtonTapped(
        _ sender: UIButton
    ) {
        
        // MARK: Get Values
        
        guard let fname = full_NameTextField.text?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
              
                let email = emailTextField.text?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
              
                let phone = phone_NumberTextField.text?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
              
                let password = passwordTextField.text,
              
                let confPass = confirm_passwordTextField.text
                
        else {
            
            showAlert(
                title: "Error",
                message: "Please enter all information."
            )
            
            return
        }
        
        // MARK: Full Name Validation
        
        guard !fname.isEmpty else {
            
            showAlert(
                title: "Missing Name",
                message: "Please enter your full name."
            )
            
            return
        }
        
        // MARK: Email Validation
        
        guard !email.isEmpty else {
            
            showAlert(
                title: "Missing Email",
                message: "Please enter your email address."
            )
            
            return
        }
        
        guard isValidEmail(email) else {
            
            showAlert(
                title: "Invalid Email",
                message: "Please enter a valid email address."
            )
            
            return
        }
        
        // MARK: Phone Validation
        
        guard !phone.isEmpty else {
            
            showAlert(
                title: "Missing Phone",
                message: "Please enter your phone number."
            )
            
            return
        }
        
        guard phone.count >= 10 else {
            
            showAlert(
                title: "Invalid Phone",
                message: "Please enter a valid phone number."
            )
            
            return
        }
        
        // MARK: Password Validation
        
        guard !password.isEmpty else {
            
            showAlert(
                title: "Missing Password",
                message: "Please enter a password."
            )
            
            return
        }
        
        guard password.count >= 6 else {
            
            showAlert(
                title: "Weak Password",
                message: "Password must contain at least 6 characters."
            )
            
            return
        }
        
        // MARK: Confirm Password
        
        guard !confPass.isEmpty else {
            
            showAlert(
                title: "Confirm Password",
                message: "Please confirm your password."
            )
            
            return
        }
        
        guard password == confPass else {
            
            showAlert(
                title: "Password Mismatch",
                message: "Password and confirm password do not match."
            )
            
            return
        }
        
        // MARK: Disable Register Button
        
        sender.isEnabled = false
        
        // MARK: Supabase Registration
        
        Task {
            
            do {
                
                // =====================================================
                // STEP 1: CREATE AUTH USER
                // =====================================================
                
                let response = try await
                SupabaseManager.shared.client.auth.signUp(
                    email: email,
                    password: password
                )
                
                let user = response.user
                
                print("====================================")
                print("AUTH USER CREATED")
                print("User ID:", user.id)
                print("Email:", user.email ?? "")
                print("====================================")
                
                // =====================================================
                // STEP 2: CREATE PROFILE
                // =====================================================
                
                let profile = Profile(
                    id: user.id,
                    fullName: fname,
                    email: email,
                    phone: phone
                )
                
                print("====================================")
                print("INSERTING PROFILE")
                print("ID:", profile.id)
                print("Name:", profile.fullName)
                print("Email:", profile.email)
                print("Phone:", profile.phone)
                print("====================================")
                
                try await SupabaseManager.shared.client
                    .from("profiles")
                    .insert(profile)
                    .execute()
                
                // =====================================================
                // STEP 3: PROFILE SUCCESS
                // =====================================================
                
                print("====================================")
                print("PROFILE ROW CREATED SUCCESSFULLY")
                print("====================================")
                
                await MainActor.run {
                    
                    sender.isEnabled = true
                    
                    self.showAlert(
                        title: "Registration Successful",
                        message: "Your account and profile have been created successfully."
                    ) { [weak self] in
                        
                        self?.navigationController?
                            .popViewController(
                                animated: true
                            )
                    }
                }
                
            } catch {
                
                // =====================================================
                // ERROR
                // =====================================================
                
                print("====================================")
                print("REGISTRATION ERROR")
                print(error)
                print("ERROR DESCRIPTION:")
                print(error.localizedDescription)
                print("====================================")
                
                await MainActor.run {
                    
                    sender.isEnabled = true
                    
                    self.showAlert(
                        title: "Registration Failed",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }
    
    // MARK: - Email Validation
    
    private func isValidEmail(
        _ email: String
    ) -> Bool {
        
        let emailRegex =
        "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        return NSPredicate(
            format: "SELF MATCHES %@",
            emailRegex
        ).evaluate(
            with: email
        )
    }
    
    // MARK: - Alert
    
    private func showAlert(
        title: String,
        message: String,
        completion: (() -> Void)? = nil
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
            ) { _ in
                
                completion?()
            }
        )
        
        present(
            alert,
            animated: true
        )
    }
    
    // MARK: - Login Button
    
    @IBAction func loginBTN(
        _ sender: Any
    ){
        
        let storyboard1 = UIStoryboard(
            name: "Main",
            bundle: nil
        )
        
        
        guard let forgetVC =
                storyboard1.instantiateViewController(
                    withIdentifier:
                        "LoginViewController"
                ) as? LoginViewController
        else {
            
            print(
                "❌ LoginViewController not found."
            )
            
            print(
                "Check Storyboard ID: LoginViewController"
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
    }
