
//
//  resetViewController.swift
//  ShopingApp
//
//  Created by Vijay on 24/09/26.
//

import UIKit
import Supabase

class resetViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEmailTextField()
    }
    
    
    // MARK: - Setup Email TextField
    
    private func setupEmailTextField() {
        
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.borderStyle = .roundedRect
        
        // Rounded TextField
        emailTextField.layer.cornerRadius = 12
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Prevent text from touching rounded corners
        emailTextField.clipsToBounds = true
        
        // Background
        emailTextField.backgroundColor = .systemBackground
        
        setupEmailIcon()
    }
    
    
    // MARK: - Email Icon
    
    private func setupEmailIcon() {
        
        let imageView = UIImageView()
        
        imageView.image = UIImage(
            systemName: "envelope"
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
        
        emailTextField.leftView = containerView
        emailTextField.leftViewMode = .always
    }
    
    
    // MARK: - Send Reset Link
    
    @IBAction func resetPasswordButtonTapped(
        _ sender: UIButton
    ) {
        
        guard let email = emailTextField.text?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        else {
            
            showAlert(
                title: "Error",
                message: "Please enter your email address."
            )
            
            return
        }
        
        
        // Check Empty Email
        
        guard !email.isEmpty else {
            
            showAlert(
                title: "Missing Email",
                message: "Please enter your email address."
            )
            
            return
        }
        
        
        // Validate Email
        
        guard isValidEmail(email) else {
            
            showAlert(
                title: "Invalid Email",
                message: "Please enter a valid email address."
            )
            
            return
        }
        
        
        // Disable Button
        
        sender.isEnabled = false
        
        
        Task {
            
            do {
                
                // MARK: - Supabase Password Reset
                
                try await SupabaseManager.shared.client.auth
                    .resetPasswordForEmail(email)
                
                
                print(
                    "Password reset link sent to:",
                    email
                )
                
                
                await MainActor.run {
                    
                    sender.isEnabled = true
                    
                    showAlert(
                        title: "Reset Link Sent",
                        message: "A password reset link has been sent to your email address."
                    )
                }
                
            } catch {
                
                print(
                    "Password reset error:",
                    error.localizedDescription
                )
                
                
                await MainActor.run {
                    
                    sender.isEnabled = true
                    
                    showAlert(
                        title: "Reset Failed",
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
    
    
    // MARK: - Back To Login
    
    @IBAction func back_To_LoginBTN(
        _ sender: Any
    ) {
        
        guard let navigationController = navigationController else {
            return
        }
        
        
        // Find LoginViewController in navigation stack
        
        if let loginViewController = navigationController.viewControllers.first(
            where: { $0 is LoginViewController }
        ) {
            
            navigationController.popToViewController(
                loginViewController,
                animated: true
            )
            
        } else {
            
            // If LoginViewController is not found,
            // simply go back one screen.
            
            navigationController.popViewController(
                animated: true
            )
        }
    }
}
