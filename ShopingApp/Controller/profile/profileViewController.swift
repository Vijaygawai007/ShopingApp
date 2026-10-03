//
//  profileViewController.swift
//  ShopingApp
//
//  Created by Vijay on 22/09/26.
//

import UIKit
import Supabase
import Kingfisher
import PhotosUI

@MainActor
class profileViewController:
    UIViewController,
    PHPickerViewControllerDelegate {

    // MARK: - Outlets

    @IBOutlet weak var address_card: UIView!
    @IBOutlet weak var info_card: UIView!
    @IBOutlet weak var profileBG_View: UIView!

    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!


    // MARK: - Properties

    private var userProfile: Profilee?

    private var isFetchingProfile = false
    private var isUploadingProfileImage = false


    // MARK: - Database Models

    private struct ProfileImageUpdate: Encodable {

        let profileImage: String

        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }


    private struct ProfileTextUpdate: Encodable {

        let fullName: String
        let phone: String
        let address: String

        enum CodingKeys: String, CodingKey {
            case fullName = "full_name"
            case phone
            case address
        }
    }


    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCards()
        setupUI()
    }


    override func viewDidAppear(
        _ animated: Bool
    ) {
        super.viewDidAppear(animated)

        guard !isUploadingProfileImage else {
            return
        }

        fetchUserProfile()
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        profileImageView.layer.cornerRadius =
            profileImageView.bounds.height / 2

        profileImageView.clipsToBounds = true
    }


    // MARK: - Card Setup

    private func setupCards() {

        profileImageView.layer.borderWidth = 2
        profileImageView.layer.shadowOffset = .init(width: 6, height: 6)

        info_card.layer.cornerRadius = 20
        info_card.layer.borderWidth = 0.2
        info_card.layer.shadowOpacity = 0.4

        address_card.layer.cornerRadius = 20
        address_card.layer.borderWidth = 0.2
        address_card.layer.shadowOpacity = 0.4

        profileBG_View.layer.cornerRadius = 20
        profileBG_View.layer.borderWidth = 0.2
        profileBG_View.layer.shadowOpacity = 0.4

        profileBG_View.layer.shadowOffset =
            CGSize(
                width: 3,
                height: 3
            )

        logoutButton.layer.shadowOffset =
            CGSize(
                width: 7,
                height: 7
            )
    }


    // MARK: - UI Setup

    private func setupUI() {

        profileImageView.image =
            UIImage(
                systemName:
                    "person.circle.fill"
            )

        profileImageView.contentMode =
            .scaleAspectFill

        profileImageView.clipsToBounds =
            true
       

        nameLabel.text = ""
        mobileLabel.text = ""
        emailLabel.text = ""
        addressLabel.text = ""

        editProfileButton.layer.cornerRadius = 8
        logoutButton.layer.cornerRadius = 8
    }


    // MARK: - Fetch User Profile

    private func fetchUserProfile() {

        guard !isFetchingProfile else {
            return
        }

        guard !isUploadingProfileImage else {
            return
        }

        isFetchingProfile = true

        Task {

            defer {
                isFetchingProfile = false
            }

            do {

                // =========================================
                // STEP 1 - CURRENT USER
                // =========================================

                let user =
                    try await
                    SupabaseManager.shared.client
                    .auth
                    .user()

                let userID =
                    user.id.uuidString


                print("")
                print("===================================")
                print("FETCH USER")
                print("User ID: \(userID)")
                print("Email: \(user.email ?? "No Email")")
                print("===================================")


                // =========================================
                // STEP 2 - PROFILE
                // =========================================

                let profile: Profilee =
                    try await
                    SupabaseManager.shared.client
                    .from("profiles")
                    .select()
                    .eq(
                        "id",
                        value:
                            userID
                    )
                    .single()
                    .execute()
                    .value


                print("")
                print("===================================")
                print("PROFILE FETCHED")
                print("Name: \(profile.fullName)")
                print("Phone: \(profile.phone)")
                print("Email: \(profile.email)")
                print(
                    "Address: \(profile.address ?? "No Address")"
                )
                print(
                    "Profile Image: " +
                    "\(profile.profileImage ?? "NULL")"
                )
                print("===================================")


                userProfile =
                    profile

                displayProfile(
                    profile
                )

            } catch {

                print("")
                print("===================================")
                print("❌ PROFILE FETCH ERROR")
                print(error)
                print(
                    error.localizedDescription
                )
                print("===================================")


                showAlert(
                    title:
                        "Profile Error",
                    message:
                        error.localizedDescription
                )
            }
        }
    }


    // MARK: - Display Profile

    private func displayProfile(
        _ profile: Profilee
    ) {

        // Name

        if profile.fullName.isEmpty {

            nameLabel.text =
                "No Name"

        } else {

            nameLabel.text =
                profile.fullName
        }


        // Phone

        if profile.phone.isEmpty {

            mobileLabel.text =
                "No Mobile Number"

        } else {

            mobileLabel.text =
                profile.phone
        }


        // Email

        if profile.email.isEmpty {

            emailLabel.text =
                "No Email"

        } else {

            emailLabel.text =
                profile.email
        }


        // Address

        if let address =
            profile.address,

           !address
            .trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )
            .isEmpty {

            addressLabel.text =
                address

        } else {

            addressLabel.text =
                "Add Address"
        }


        // Profile image

        loadProfileImage(
            profile
        )
    }


    // MARK: - Load Profile Image

    private func loadProfileImage(
        _ profile: Profilee
    ) {

        let defaultImage =
            UIImage(
                systemName:
                    "person.circle.fill"
            )


        guard
            let imageString =
                profile.profileImage,

            !imageString
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )
                .isEmpty,

            let imageURL =
                URL(
                    string:
                        imageString
                )
        else {

            print(
                "ℹ️ profile_image is NULL"
            )

            profileImageView.kf.cancelDownloadTask()

            profileImageView.image =
                defaultImage

            return
        }


        print("")
        print("===================================")
        print("LOADING PROFILE IMAGE")
        print(imageString)
        print("===================================")


        // Cancel previous image request.

        profileImageView.kf.cancelDownloadTask()


        // Force refresh because the same
        // USER_ID.jpg file is overwritten.

        profileImageView.kf.setImage(
            with:
                imageURL,
            placeholder:
                defaultImage,
            options: [

                .forceRefresh,

                .cacheOriginalImage,

                .transition(
                    .fade(0.2)
                )
            ]
        )
    }


    // MARK: - Edit Profile

    @IBAction func editProfileButtonTapped(
        _ sender: UIButton
    ) {

        guard
            let profile =
                userProfile
        else {

            showAlert(
                title:
                    "Please Wait",
                message:
                    "Profile information is still loading."
            )

            return
        }


        showEditProfileAlert(
            profile:
                profile
        )
    }


    // MARK: - Edit Profile Alert

    private func showEditProfileAlert(
        profile: Profilee
    ) {

        let alert =
            UIAlertController(
                title:
                    "Edit Profile",
                message:
                    "Update your profile details",
                preferredStyle:
                    .alert
            )


        // Name

        alert.addTextField { textField in

            textField.placeholder =
                "Full Name"

            textField.text =
                profile.fullName

            textField.autocapitalizationType =
                .words
        }


        // Phone

        alert.addTextField { textField in

            textField.placeholder =
                "Mobile Number"

            textField.text =
                profile.phone

            textField.keyboardType =
                .phonePad
        }


        // Address

        alert.addTextField { textField in

            textField.placeholder =
                "Address"

            textField.text =
                profile.address ?? ""

            textField.autocapitalizationType =
                .sentences
        }


        // Change Profile Picture

        alert.addAction(
            UIAlertAction(
                title:
                    "Change Profile Picture",
                style:
                    .default
            ) { [weak self] _ in

                DispatchQueue.main.async {

                    self?.openImagePicker()
                }
            }
        )


        // Cancel

        alert.addAction(
            UIAlertAction(
                title:
                    "Cancel",
                style:
                    .cancel
            )
        )


        // Save

        alert.addAction(
            UIAlertAction(
                title:
                    "Save",
                style:
                    .default
            ) { [weak self, weak alert] _ in

                guard
                    let self =
                        self,

                    let alert =
                        alert
                else {
                    return
                }


                let name =
                    alert
                    .textFields?[0]
                    .text?
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
                    ?? ""


                let phone =
                    alert
                    .textFields?[1]
                    .text?
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
                    ?? ""


                let address =
                    alert
                    .textFields?[2]
                    .text?
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
                    ?? ""


                guard !name.isEmpty else {

                    self.showAlert(
                        title:
                            "Invalid Name",
                        message:
                            "Please enter your full name."
                    )

                    return
                }


                guard !phone.isEmpty else {

                    self.showAlert(
                        title:
                            "Invalid Mobile",
                        message:
                            "Please enter your mobile number."
                    )

                    return
                }


                self.updateProfile(
                    name:
                        name,
                    phone:
                        phone,
                    address:
                        address
                )
            }
        )


        present(
            alert,
            animated:
                true
        )
    }


    // MARK: - Image Picker

    private func openImagePicker() {

        var configuration =
            PHPickerConfiguration(
                photoLibrary:
                    .shared()
            )

        configuration.filter =
            .images

        configuration.selectionLimit =
            1

        configuration.preferredAssetRepresentationMode =
            .current


        let picker =
            PHPickerViewController(
                configuration:
                    configuration
            )

        picker.delegate =
            self


        present(
            picker,
            animated:
                true
        )
    }


    // MARK: - PHPicker Delegate

    func picker(
        _ picker:
            PHPickerViewController,
        didFinishPicking results:
            [PHPickerResult]
    ) {

        picker.dismiss(
            animated:
                true
        )


        guard
            let result =
                results.first
        else {
            return
        }


        guard
            result.itemProvider
                .canLoadObject(
                    ofClass:
                        UIImage.self
                )
        else {

            showAlert(
                title:
                    "Image Error",
                message:
                    "This image cannot be selected."
            )

            return
        }


        result.itemProvider.loadObject(
            ofClass:
                UIImage.self
        ) { [weak self] object, error in

            guard
                let self =
                    self
            else {
                return
            }


            if let error =
                error {

                print(
                    "❌ IMAGE PICKER ERROR"
                )

                print(error)


                Task { @MainActor in

                    self.showAlert(
                        title:
                            "Image Error",
                        message:
                            error.localizedDescription
                    )
                }

                return
            }


            guard
                let image =
                    object as? UIImage
            else {

                Task { @MainActor in

                    self.showAlert(
                        title:
                            "Image Error",
                        message:
                            "Unable to read selected image."
                    )
                }

                return
            }


            Task { @MainActor in

                // Show image immediately.

                self.profileImageView.image =
                    image


                // Upload image.

                await self.uploadProfileImage(
                    image
                )
            }
        }
    }


    // MARK: - Resize Image

    private func resizeProfileImage(
        _ image: UIImage,
        maxDimension: CGFloat
    ) -> UIImage {

        let width =
            image.size.width

        let height =
            image.size.height


        guard
            width > maxDimension ||
            height > maxDimension
        else {

            return image
        }


        let scale =
            min(
                maxDimension / width,
                maxDimension / height
            )


        let newSize =
            CGSize(
                width:
                    width * scale,
                height:
                    height * scale
            )


        let renderer =
            UIGraphicsImageRenderer(
                size:
                    newSize
            )


        return renderer.image { _ in

            image.draw(
                in:
                    CGRect(
                        origin:
                            .zero,
                        size:
                            newSize
                    )
            )
        }
    }


    // MARK: - Prepare Image

    private func prepareProfileImage(
        _ image: UIImage
    ) -> Data? {

        let maximumBytes =
            500 * 1024


        var currentImage =
            resizeProfileImage(
                image,
                maxDimension:
                    1000
            )


        let qualities:
            [CGFloat] = [

                0.80,
                0.70,
                0.60,
                0.50,
                0.40,
                0.30,
                0.20
            ]


        // First compression.

        for quality in qualities {

            guard
                let data =
                    currentImage.jpegData(
                        compressionQuality:
                            quality
                    )
            else {
                continue
            }


            print(
                "JPEG Quality: \(quality)"
            )

            print(
                "JPEG Size: " +
                "\(data.count / 1024) KB"
            )


            if data.count <= maximumBytes {

                print(
                    "✅ IMAGE BELOW 500 KB"
                )

                return data
            }
        }


        // Reduce dimensions.

        var dimension:
            CGFloat = 800


        while dimension >= 300 {

            currentImage =
                resizeProfileImage(
                    image,
                    maxDimension:
                        dimension
                )


            for quality:
                CGFloat in
                [
                    0.50,
                    0.40,
                    0.30,
                    0.20
                ] {

                guard
                    let data =
                        currentImage.jpegData(
                            compressionQuality:
                                quality
                        )
                else {
                    continue
                }


                print(
                    "Dimension: \(dimension)"
                )

                print(
                    "Quality: \(quality)"
                )

                print(
                    "Size: " +
                    "\(data.count / 1024) KB"
                )


                if data.count <= maximumBytes {

                    print(
                        "✅ IMAGE BELOW 500 KB"
                    )

                    return data
                }
            }


            dimension -= 100
        }


        // Final fallback.

        currentImage =
            resizeProfileImage(
                image,
                maxDimension:
                    300
            )


        return currentImage.jpegData(
            compressionQuality:
                0.20
        )
    }


    // MARK: - Upload Profile Image

    private func uploadProfileImage(
        _ image: UIImage
    ) async {

        guard
            !isUploadingProfileImage
        else {

            print(
                "⚠️ IMAGE UPLOAD ALREADY RUNNING"
            )

            return
        }


        guard
            let imageData =
                prepareProfileImage(image)
        else {

            showAlert(
                title:
                    "Image Error",
                message:
                    "Unable to process selected image."
            )

            return
        }


        isUploadingProfileImage =
            true


        defer {

            isUploadingProfileImage =
                false
        }


        do {

            // =========================================
            // STEP 1 - GET USER
            // =========================================

            let user =
                try await
                SupabaseManager.shared.client
                .auth
                .user()


            let userID =
                user.id.uuidString


            print("")
            print("===================================")
            print("STEP 1 - CURRENT USER")
            print("User ID:")
            print(userID)
            print("===================================")


            // =========================================
            // STEP 2 - STORAGE FILE PATH
            // =========================================

            let filePath =
                "\(userID).jpg"


            print("")
            print("===================================")
            print("STEP 2 - STORAGE FILE")
            print(filePath)
            print("===================================")


            // =========================================
            // STEP 3 - UPLOAD TO STORAGE
            // =========================================

            print("")
            print("===================================")
            print("STEP 3 - STORAGE UPLOAD")
            print("Bucket: profile-images")
            print(
                "Size: \(imageData.count / 1024) KB"
            )
            print("===================================")


            try await
                SupabaseManager.shared.client
                .storage
                .from("profile-images")
                .upload(
                    filePath,
                    data:
                        imageData,
                    options:
                        FileOptions(
                            cacheControl:
                                "3600",
                            contentType:
                                "image/jpeg",
                            upsert:
                                true
                        )
                )


            print(
                "✅ STORAGE UPLOAD SUCCESS"
            )


            // =========================================
            // STEP 4 - GET PUBLIC URL
            // =========================================

            let publicURL =
                try
                SupabaseManager.shared.client
                .storage
                .from("profile-images")
                .getPublicURL(
                    path:
                        filePath
                )


            let imageURL =
                publicURL.absoluteString


            print("")
            print("===================================")
            print("STEP 4 - PUBLIC URL")
            print(imageURL)
            print("===================================")


            guard !imageURL.isEmpty else {

                throw NSError(
                    domain:
                        "ProfileImageError",
                    code:
                        1001,
                    userInfo:
                        [
                            NSLocalizedDescriptionKey:
                                "Supabase returned an empty image URL."
                        ]
                )
            }


            // =========================================
            // STEP 5 - UPDATE DATABASE
            // =========================================

            print("")
            print("===================================")
            print("STEP 5 - DATABASE UPDATE")
            print("Table: profiles")
            print("Column: profile_image")
            print("User ID: \(userID)")
            print("URL:")
            print(imageURL)
            print("===================================")


            let update =
                ProfileImageUpdate(
                    profileImage:
                        imageURL
                )


            // IMPORTANT:
            // .select().single() returns the updated row.
            // This confirms that the database actually
            // updated one profile.

            let savedProfile:
                Profilee =

                try await
                SupabaseManager.shared.client
                .from("profiles")
                .update(
                    update
                )
                .eq(
                    "id",
                    value:
                        userID
                )
                .select()
                .single()
                .execute()
                .value


            print("")
            print("===================================")
            print("✅ DATABASE UPDATE SUCCESS")
            print("===================================")

            print(
                "Saved profile_image:"
            )

            print(
                savedProfile.profileImage ?? "NULL"
            )

            print("===================================")


            // =========================================
            // STEP 6 - VERIFY VALUE
            // =========================================

            guard
                let savedURL =
                    savedProfile.profileImage,

                !savedURL
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
                    .isEmpty
            else {

                throw NSError(
                    domain:
                        "ProfileImageError",
                    code:
                        1002,
                    userInfo:
                        [
                            NSLocalizedDescriptionKey:
                                "The profile row was updated, but profile_image is NULL."
                        ]
                )
            }


            // =========================================
            // STEP 7 - SAVE LOCAL PROFILE
            // =========================================

            userProfile =
                savedProfile


            // =========================================
            // STEP 8 - SHOW SELECTED IMAGE
            // =========================================

            profileImageView.image =
                image


            // =========================================
            // STEP 9 - CLEAR KINGFISHER CACHE
            // =========================================

            if let url =
                URL(
                    string:
                        savedURL
                ) {

                let cacheKey =
                    url.absoluteString


                try await
                    KingfisherManager.shared
                    .cache
                    .removeImage(
                        forKey:
                            cacheKey
                    )
            }


            // =========================================
            // STEP 10 - FORCE REFRESH IMAGE
            // =========================================

            let separator =
                savedURL.contains("?")
                ? "&"
                : "?"


            let cacheBustingURL =
                savedURL
                + separator
                + "v="
                + String(
                    Int(
                        Date()
                            .timeIntervalSince1970
                    )
                )


            if let url =
                URL(
                    string:
                        cacheBustingURL
                ) {

                profileImageView.kf.cancelDownloadTask()

                profileImageView.kf.setImage(
                    with:
                        url,
                    placeholder:
                        image,
                    options: [

                        .forceRefresh,

                        .transition(
                            .fade(0.2)
                        )
                    ]
                )
            }


            // =========================================
            // SUCCESS
            // =========================================

            print("")
            print("===================================")
            print("🎉 PROFILE IMAGE COMPLETE")
            print("===================================")


            showAlert(
                title:
                    "Success",
                message:
                    "Profile picture saved successfully."
            )


        } catch {

            print("")
            print("===================================")
            print("❌ PROFILE IMAGE ERROR")
            print("===================================")

            print(error)

            print(
                "Description:"
            )

            print(
                error.localizedDescription
            )


            let nsError =
                error as NSError


            print(
                "Domain: \(nsError.domain)"
            )

            print(
                "Code: \(nsError.code)"
            )

            print(
                "UserInfo: \(nsError.userInfo)"
            )

            print("===================================")


            showAlert(
                title:
                    "Upload Failed",
                message:
                    error.localizedDescription
            )
        }
    }


    // MARK: - Update Profile Text

    private func updateProfile(
        name: String,
        phone: String,
        address: String
    ) {

        Task {

            do {

                let user =
                    try await
                    SupabaseManager.shared.client
                    .auth
                    .user()


                let userID =
                    user.id.uuidString


                let update =
                    ProfileTextUpdate(
                        fullName:
                            name,
                        phone:
                            phone,
                        address:
                            address
                    )


                // Use select().single()
                // so we know the row was actually updated.

                let updatedProfile:
                    Profilee =

                    try await
                    SupabaseManager.shared.client
                    .from("profiles")
                    .update(
                        update
                    )
                    .eq(
                        "id",
                        value:
                            userID
                    )
                    .select()
                    .single()
                    .execute()
                    .value


                userProfile =
                    updatedProfile


                displayProfile(
                    updatedProfile
                )


                print("")
                print("===================================")
                print("✅ PROFILE TEXT UPDATED")
                print("===================================")


                showAlert(
                    title:
                        "Success",
                    message:
                        "Profile updated successfully."
                )

            } catch {

                print("")
                print("===================================")
                print("❌ PROFILE UPDATE ERROR")
                print("===================================")

                print(error)

                print(
                    error.localizedDescription
                )

                print("===================================")


                showAlert(
                    title:
                        "Update Failed",
                    message:
                        error.localizedDescription
                )
            }
        }
    }


    // MARK: - Logout

    @IBAction func logoutButtonTapped(
        _ sender: UIButton
    ) {

        let alert =
            UIAlertController(
                title:
                    "Logout",
                message:
                    "Are you sure you want to logout?",
                preferredStyle:
                    .alert
            )


        alert.addAction(
            UIAlertAction(
                title:
                    "Cancel",
                style:
                    .cancel
            )
        )


        alert.addAction(
            UIAlertAction(
                title:
                    "Logout",
                style:
                    .destructive
            ) { [weak self] _ in

                self?.logoutUser()
            }
        )


        present(
            alert,
            animated:
                true
        )
    }


    // MARK: - Logout User

    private func logoutUser() {

        Task {

            do {

                try await
                    SupabaseManager.shared.client
                    .auth
                    .signOut()


                print("")
                print("===================================")
                print("✅ USER LOGGED OUT")
                print("===================================")


                goToLoginScreen()

            } catch {

                print("")
                print("===================================")
                print("❌ LOGOUT ERROR")
                print(
                    error.localizedDescription
                )
                print("===================================")


                showAlert(
                    title:
                        "Logout Failed",
                    message:
                        error.localizedDescription
                )
            }
        }
    }


    // MARK: - Go To Login Screen

    private func goToLoginScreen() {

        let storyboard =
            UIStoryboard(
                name:
                    "Main",
                bundle:
                    nil
            )


        guard
            let loginVC =
                storyboard
                .instantiateViewController(
                    withIdentifier:
                        "LoginViewController"
                )
                as? LoginViewController
        else {

            print(
                "❌ LoginViewController not found. " +
                "Check Storyboard ID."
            )

            return
        }


        let navigationController =
            UINavigationController(
                rootViewController:
                    loginVC
            )


        navigationController
            .modalPresentationStyle =
            .fullScreen


        if let windowScene =
            UIApplication.shared
            .connectedScenes
            .compactMap({
                $0 as? UIWindowScene
            })
            .first(
                where: {
                    $0.activationState ==
                        .foregroundActive
                }
            ),

           let window =
            windowScene.windows
            .first(
                where: {
                    $0.isKeyWindow
                }
            ) {

            window.rootViewController =
                navigationController

            window.makeKeyAndVisible()
        }
    }


    // MARK: - Alert

    private func showAlert(
        title: String,
        message: String,
        completion:
            (() -> Void)? = nil
    ) {

        let alert =
            UIAlertController(
                title:
                    title,
                message:
                    message,
                preferredStyle:
                    .alert
            )


        alert.addAction(
            UIAlertAction(
                title:
                    "OK",
                style:
                    .default
            ) { _ in

                completion?()
            }
        )


        present(
            alert,
            animated:
                true
        )
    }
}
