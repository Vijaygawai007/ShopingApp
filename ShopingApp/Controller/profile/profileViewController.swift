//
//  profileViewController.swift
//  ShopingApp
//
//  Created by Vijay on 22/09/26.
//

import UIKit
import Supabase
import Kingfisher

@MainActor
class profileViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var profileBG_View: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

//    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!


    // MARK: - Properties

    private var userProfile: Profile?

    private var isFetchingProfile = false


    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        profileBG_View.layer.cornerRadius = 30
        profileBG_View.layer.shadowOpacity = 10
        logoutButton.layer.shadowOffset = CGSize(width: 7, height: 7)
        setupUI()
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        fetchUserProfile()
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Make profile image circular
        profileImageView.layer.cornerRadius =
            profileImageView.bounds.height / 2

        profileImageView.clipsToBounds = true
    }


    // MARK: - UI Setup

    private func setupUI() {

        // Profile image
        profileImageView.image = UIImage(
            systemName: "person.circle.fill"
        )

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true


        // Labels
        nameLabel.text = ""
        mobileLabel.text = ""
        emailLabel.text = ""
        addressLabel.text = ""


        // Buttons
//        editProfileButton.layer.cornerRadius = 8
        logoutButton.layer.cornerRadius = 8
    }


    // MARK: - Fetch User Profile

    private func fetchUserProfile() {

        // Prevent multiple API calls at the same time
        if isFetchingProfile {
            return
        }

        isFetchingProfile = true


        Task {

            defer {
                isFetchingProfile = false
            }


            do {

                // -----------------------------------------
                // 1. Get currently logged-in Supabase user
                // -----------------------------------------

                let user = try await
                    SupabaseManager.shared.client.auth.user()

                print("===================================")
                print("Logged In User")
                print("User ID: \(user.id)")
                print("Email: \(user.email ?? "No Email")")
                print("===================================")


                // -----------------------------------------
                // 2. Fetch profile from profiles table
                // -----------------------------------------

                let profile: Profile = try await
                    SupabaseManager.shared.client
                    .from("profiles")
                    .select()
                    .eq(
                        "id",
                        value: user.id.uuidString
                    )
                    .single()
                    .execute()
                    .value


                print("===================================")
                print("Profile Fetched Successfully")
                print("Name: \(profile.fullName)")
                print("Email: \(profile.email)")
                print("Phone: \(profile.phone)")
                print("Address: \(profile.address ?? "No Address")")
                print("Profile Image: \(profile.profileImage ?? "No Image")")
                print("===================================")


                // Save profile
                userProfile = profile


                // Update UI
                displayProfile(profile)


            } catch {

                print("===================================")
                print("❌ PROFILE FETCH ERROR")
                print(error)
                print(error.localizedDescription)
                print("===================================")


                showAlert(
                    title: "Profile Error",
                    message: error.localizedDescription
                )
            }
        }
    }


    // MARK: - Display Profile

    private func displayProfile(_ profile: Profile) {

        // Full Name
        if profile.fullName.isEmpty {

            nameLabel.text = "No Name"

        } else {

            nameLabel.text = profile.fullName
        }


        // Mobile
        if profile.phone.isEmpty {

            mobileLabel.text = "No Mobile Number"

        } else {

            mobileLabel.text = profile.phone
        }


        // Email
        if profile.email.isEmpty {

            emailLabel.text = "No Email"

        } else {

            emailLabel.text = profile.email
        }


        // Address
        if let address = profile.address,
           !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            addressLabel.text = address

        } else {

            addressLabel.text = "Add Address"
        }


        // Profile Image
        loadProfileImage(profile)
    }


    // MARK: - Load Profile Image

    private func loadProfileImage(_ profile: Profile) {

        let defaultImage = UIImage(
            systemName: "person.circle.fill"
        )


        guard let imageString = profile.profileImage,
              !imageString.trimmingCharacters(
                in: .whitespacesAndNewlines
              ).isEmpty,
              let imageURL = URL(
                string: imageString
              ) else {

            profileImageView.image = defaultImage

            return
        }


        profileImageView.kf.setImage(
            with: imageURL,
            placeholder: defaultImage,
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
    }


    // MARK: - Edit Profile

    @IBAction func editProfileButtonTapped(
        _ sender: UIButton
    ) {

        guard let profile = userProfile else {

            showAlert(
                title: "Please Wait",
                message: "Profile information is still loading."
            )

            return
        }


        showEditProfileAlert(profile: profile)
    }


    // MARK: - Edit Profile Alert

    private func showEditProfileAlert(
        profile: Profile
    ) {

        let alert = UIAlertController(
            title: "Edit Profile",
            message: "Update your profile details",
            preferredStyle: .alert
        )


        // -----------------------------------------
        // Full Name
        // -----------------------------------------

        alert.addTextField { textField in

            textField.placeholder = "Full Name"
            textField.text = profile.fullName
            textField.autocapitalizationType = .words
        }


        // -----------------------------------------
        // Mobile Number
        // -----------------------------------------

        alert.addTextField { textField in

            textField.placeholder = "Mobile Number"
            textField.text = profile.phone
            textField.keyboardType = .phonePad
        }


        // -----------------------------------------
        // Address
        // -----------------------------------------

        alert.addTextField { textField in

            textField.placeholder = "Address"
            textField.text = profile.address ?? ""
            textField.autocapitalizationType = .sentences
        }


        // -----------------------------------------
        // Cancel
        // -----------------------------------------

        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )


        // -----------------------------------------
        // Save
        // -----------------------------------------

        alert.addAction(
            UIAlertAction(
                title: "Save",
                style: .default
            ) { [weak self, weak alert] _ in

                guard let self = self,
                      let alert = alert else {
                    return
                }


                let name =
                    alert.textFields?[0].text?
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ) ?? ""


                let phone =
                    alert.textFields?[1].text?
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ) ?? ""


                let address =
                    alert.textFields?[2].text?
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ) ?? ""


                // Validate name
                if name.isEmpty {

                    self.showAlert(
                        title: "Invalid Name",
                        message: "Please enter your full name."
                    )

                    return
                }


                // Validate phone
                if phone.isEmpty {

                    self.showAlert(
                        title: "Invalid Mobile",
                        message: "Please enter your mobile number."
                    )

                    return
                }


                // Update Supabase
                self.updateProfile(
                    name: name,
                    phone: phone,
                    address: address
                )
            }
        )


        present(
            alert,
            animated: true
        )
    }


    // MARK: - Update Profile

    private func updateProfile(
        name: String,
        phone: String,
        address: String
    ) {

        Task {

            do {

                // Get logged-in user
                let user = try await
                    SupabaseManager.shared.client.auth.user()


                // Model used for update
                let profileUpdate = ProfileUpdate(
                    fullName: name,
                    phone: phone,
                    address: address.isEmpty
                        ? nil
                        : address
                )


                // Update profiles table
                try await
                    SupabaseManager.shared.client
                    .from("profiles")
                    .update(profileUpdate)
                    .eq(
                        "id",
                        value: user.id.uuidString
                    )
                    .execute()


                print("===================================")
                print("✅ PROFILE UPDATED")
                print("Name: \(name)")
                print("Phone: \(phone)")
                print("Address: \(address)")
                print("===================================")


                showAlert(
                    title: "Success",
                    message: "Profile updated successfully."
                ) { [weak self] in

                    self?.fetchUserProfile()
                }


            } catch {

                print("===================================")
                print("❌ PROFILE UPDATE ERROR")
                print(error)
                print(error.localizedDescription)
                print("===================================")


                showAlert(
                    title: "Update Failed",
                    message: error.localizedDescription
                )
            }
        }
    }


    // MARK: - Logout

    @IBAction func logoutButtonTapped(
        _ sender: UIButton
    ) {

        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )


        // Cancel
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )


        // Logout
        alert.addAction(
            UIAlertAction(
                title: "Logout",
                style: .destructive
            ) { [weak self] _ in

                self?.logoutUser()
            }
        )


        present(
            alert,
            animated: true
        )
    }


    // MARK: - Logout User

    private func logoutUser() {

        Task {

            do {

                try await
                    SupabaseManager.shared.client.auth.signOut()


                print("===================================")
                print("✅ USER LOGGED OUT")
                print("===================================")


                goToLoginScreen()


            } catch {

                print("===================================")
                print("❌ LOGOUT ERROR")
                print(error.localizedDescription)
                print("===================================")


                showAlert(
                    title: "Logout Failed",
                    message: error.localizedDescription
                )
            }
        }
    }


    // MARK: - Go To Login Screen

    private func goToLoginScreen() {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )


        guard let loginVC =
                storyboard.instantiateViewController(
                    withIdentifier: "LoginViewController"
                ) as? LoginViewController else {

            print(
                "❌ LoginViewController not found. " +
                "Check Storyboard ID."
            )

            return
        }


        let navigationController =
            UINavigationController(
                rootViewController: loginVC
            )


        navigationController.modalPresentationStyle =
            .fullScreen


        if let windowScene =
            UIApplication.shared.connectedScenes
                .compactMap({
                    $0 as? UIWindowScene
                })
                .first(where: {
                    $0.activationState == .foregroundActive
                }),
           let window =
            windowScene.windows.first(where: {
                $0.isKeyWindow
            }) {

            window.rootViewController =
                navigationController

            window.makeKeyAndVisible()
        }
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
}


// MARK: - Profile Update Model

struct ProfileUpdate: Encodable {

    let fullName: String
    let phone: String
    let address: String?

    enum CodingKeys: String, CodingKey {

        case fullName = "full_name"
        case phone
        case address
    }
}
