
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

    private var userProfile: Profile?

    private var isFetchingProfile = false

    private var isUploadingProfileImage = false


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

        info_card.layer.cornerRadius = 10
        info_card.layer.borderWidth = 0.2
        info_card.layer.shadowOpacity = 0.08

        address_card.layer.cornerRadius = 10
        address_card.layer.borderWidth = 0.2
        address_card.layer.shadowOpacity = 0.06

        profileBG_View.layer.cornerRadius = 40
        profileBG_View.layer.shadowOpacity = 0.10
        profileBG_View.layer.borderWidth = 5

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

        profileImageView.clipsToBounds = true

        nameLabel.text = ""
        mobileLabel.text = ""
        emailLabel.text = ""
        addressLabel.text = ""

        editProfileButton.layer.cornerRadius = 8
        logoutButton.layer.cornerRadius = 8
    }


    // MARK: - Fetch User Profile

    private func fetchUserProfile() {

        if isFetchingProfile {
            return
        }

        if isUploadingProfileImage {
            return
        }

        isFetchingProfile = true

        Task {

            defer {
                isFetchingProfile = false
            }

            do {

                // -----------------------------------------
                // Get logged-in user
                // -----------------------------------------

                let user =
                    try await
                    SupabaseManager.shared.client
                    .auth
                    .user()


                print("===================================")
                print("LOGGED IN USER")
                print("User ID: \(user.id)")
                print("Email: \(user.email ?? "No Email")")
                print("===================================")


                // -----------------------------------------
                // Fetch profile
                // -----------------------------------------

                let profile: Profile =
                    try await
                    SupabaseManager.shared.client
                    .from("profiles")
                    .select()
                    .eq(
                        "id",
                        value:
                            user.id.uuidString
                    )
                    .single()
                    .execute()
                    .value


                print("===================================")
                print("PROFILE FETCHED")
                print("Name: \(profile.fullName)")
                print("Phone: \(profile.phone)")
                print("Email: \(profile.email)")
                print(
                    "Address: \(profile.address ?? "No Address")"
                )
                print(
                    "Profile Image: \(profile.profileImage ?? "NULL")"
                )
                print("===================================")


                userProfile = profile

                displayProfile(profile)


            } catch {

                print("===================================")
                print("❌ PROFILE FETCH ERROR")
                print(error)
                print(error.localizedDescription)
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
        _ profile: Profile
    ) {

        // -----------------------------------------
        // Name
        // -----------------------------------------

        if profile.fullName.isEmpty {

            nameLabel.text =
                "No Name"

        } else {

            nameLabel.text =
                profile.fullName
        }


        // -----------------------------------------
        // Phone
        // -----------------------------------------

        if profile.phone.isEmpty {

            mobileLabel.text =
                "No Mobile Number"

        } else {

            mobileLabel.text =
                profile.phone
        }


        // -----------------------------------------
        // Email
        // -----------------------------------------

        if profile.email.isEmpty {

            emailLabel.text =
                "No Email"

        } else {

            emailLabel.text =
                profile.email
        }


        // -----------------------------------------
        // Address
        // -----------------------------------------

        if let address = profile.address,
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


        // -----------------------------------------
        // Profile Image
        // -----------------------------------------

        loadProfileImage(profile)
    }


    // MARK: - Load Profile Image

    private func loadProfileImage(
        _ profile: Profile
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
                "ℹ️ No profile image URL in database"
            )

            profileImageView.image =
                defaultImage

            return
        }


        print("===================================")
        print("LOADING PROFILE IMAGE")
        print(imageString)
        print("===================================")


        profileImageView.kf.setImage(
            with:
                imageURL,
            placeholder:
                defaultImage,
            options: [
                .transition(
                    .fade(0.2)
                ),
                .cacheOriginalImage
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
        profile: Profile
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


        // -----------------------------------------
        // Full Name
        // -----------------------------------------

        alert.addTextField { textField in

            textField.placeholder =
                "Full Name"

            textField.text =
                profile.fullName

            textField.autocapitalizationType =
                .words
        }


        // -----------------------------------------
        // Mobile
        // -----------------------------------------

        alert.addTextField { textField in

            textField.placeholder =
                "Mobile Number"

            textField.text =
                profile.phone

            textField.keyboardType =
                .phonePad
        }


        // -----------------------------------------
        // Address
        // -----------------------------------------

        alert.addTextField { textField in

            textField.placeholder =
                "Address"

            textField.text =
                profile.address ?? ""

            textField.autocapitalizationType =
                .sentences
        }


        // -----------------------------------------
        // Change Profile Picture
        // -----------------------------------------

        alert.addAction(
            UIAlertAction(
                title:
                    "Change Profile Picture",
                style:
                    .default
            ) { [weak self] _ in

                self?.openImagePicker()
            }
        )


        // -----------------------------------------
        // Cancel
        // -----------------------------------------

        alert.addAction(
            UIAlertAction(
                title:
                    "Cancel",
                style:
                    .cancel
            )
        )


        // -----------------------------------------
        // Save
        // -----------------------------------------

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
                    alert.textFields?[0].text?
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
                    ?? ""


                let phone =
                    alert.textFields?[1].text?
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
                    ?? ""


                let address =
                    alert.textFields?[2].text?
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
                    ?? ""


                // -----------------------------------------
                // Validate Name
                // -----------------------------------------

                if name.isEmpty {

                    self.showAlert(
                        title:
                            "Invalid Name",
                        message:
                            "Please enter your full name."
                    )

                    return
                }


                // -----------------------------------------
                // Validate Phone
                // -----------------------------------------

                if phone.isEmpty {

                    self.showAlert(
                        title:
                            "Invalid Mobile",
                        message:
                            "Please enter your mobile number."
                    )

                    return
                }


                // -----------------------------------------
                // Update Profile
                // -----------------------------------------

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

        // Avoid requesting unnecessary
        // original high-resolution data.

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

                // -----------------------------------------
                // Show image immediately
                // -----------------------------------------

                self.profileImageView.image =
                    image


                // -----------------------------------------
                // Upload image
                // -----------------------------------------

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

        let originalWidth =
            image.size.width

        let originalHeight =
            image.size.height


        guard
            originalWidth > maxDimension ||
            originalHeight > maxDimension
        else {

            return image
        }


        let scale =
            min(
                maxDimension / originalWidth,
                maxDimension / originalHeight
            )


        let newSize =
            CGSize(
                width:
                    originalWidth * scale,
                height:
                    originalHeight * scale
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


    // MARK: - Prepare Profile Image

    private func prepareProfileImage(
        _ image: UIImage
    ) -> Data? {

        // -----------------------------------------
        // Maximum upload size
        // -----------------------------------------

        let maximumBytes =
            500 * 1024


        // -----------------------------------------
        // Start with 1000px image
        // -----------------------------------------

        var currentImage =
            resizeProfileImage(
                image,
                maxDimension:
                    1000
            )


        // -----------------------------------------
        // Compression qualities
        // -----------------------------------------

        let compressionValues:
            [CGFloat] = [

                0.80,
                0.70,
                0.60,
                0.50,
                0.40,
                0.30,
                0.20
            ]


        // -----------------------------------------
        // Try compression first
        // -----------------------------------------

        for quality in compressionValues {

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
                "JPEG Size: \(data.count / 1024) KB"
            )


            if data.count <= maximumBytes {

                print(
                    "✅ IMAGE BELOW 500 KB"
                )

                return data
            }
        }


        // -----------------------------------------
        // Still too large.
        //
        // Reduce image dimensions gradually.
        // -----------------------------------------

        var currentDimension:
            CGFloat = 800


        while currentDimension >= 300 {

            currentImage =
                resizeProfileImage(
                    image,
                    maxDimension:
                        currentDimension
                )


            // Try several qualities again.

            for quality in
                [CGFloat(0.50),
                 CGFloat(0.40),
                 CGFloat(0.30),
                 CGFloat(0.20)] {

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
                    "Resize Dimension: \(currentDimension)"
                )

                print(
                    "JPEG Quality: \(quality)"
                )

                print(
                    "JPEG Size: \(data.count / 1024) KB"
                )


                if data.count <= maximumBytes {

                    print(
                        "✅ IMAGE BELOW 500 KB"
                    )

                    return data
                }
            }


            currentDimension -= 100
        }


        // -----------------------------------------
        // Final fallback.
        //
        // Use a small 300px image.
        // -----------------------------------------

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

        // -----------------------------------------
        // Prevent duplicate upload
        // -----------------------------------------

        guard !isUploadingProfileImage else {

            print(
                "⚠️ IMAGE UPLOAD ALREADY RUNNING"
            )

            return
        }


        // -----------------------------------------
        // Prepare image
        // -----------------------------------------

        guard
            let imageData =
                prepareProfileImage(
                    image
                )
        else {

            showAlert(
                title:
                    "Image Error",
                message:
                    "Unable to process selected image."
            )

            return
        }


        // -----------------------------------------
        // Mark upload as running
        // -----------------------------------------

        isUploadingProfileImage =
            true


        print("===================================")
        print("PREPARED PROFILE IMAGE")
        print(
            "Upload Size: \(imageData.count / 1024) KB"
        )
        print(
            "Upload Bytes: \(imageData.count)"
        )
        print("===================================")


        defer {

            isUploadingProfileImage =
                false
        }


        do {

            // -----------------------------------------
            // Get current user
            // -----------------------------------------

            let user =
                try await
                SupabaseManager.shared.client
                .auth
                .user()


            let userID =
                user.id.uuidString


            // -----------------------------------------
            // Storage file path
            // -----------------------------------------

            let filePath =
                "\(userID).jpg"


            print("===================================")
            print("PROFILE IMAGE UPLOAD")
            print("User ID: \(userID)")
            print("Bucket: profile-images")
            print("File Path: \(filePath)")
            print(
                "Data Size: \(imageData.count / 1024) KB"
            )
            print("===================================")


            // -----------------------------------------
            // Upload to Supabase Storage
            // -----------------------------------------

            try await
                SupabaseManager.shared.client
                .storage
                .from(
                    "profile-images"
                )
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
                "✅ IMAGE UPLOADED TO STORAGE"
            )


            // -----------------------------------------
            // Get public URL
            // -----------------------------------------

            let publicURL =
                try
                SupabaseManager.shared.client
                .storage
                .from(
                    "profile-images"
                )
                .getPublicURL(
                    path:
                        filePath
                )


            let imageURL =
                publicURL.absoluteString


            print("===================================")
            print("PUBLIC IMAGE URL")
            print(imageURL)
            print("===================================")


            // -----------------------------------------
            // Update profiles table
            // -----------------------------------------

            let updatedProfile:
                Profile =

                try await
                SupabaseManager.shared.client
                .from(
                    "profiles"
                )
                .update(
                    [
                        "profile_image":
                            imageURL
                    ]
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


            // -----------------------------------------
            // Verify database value
            // -----------------------------------------

            guard
                let savedURL =
                    updatedProfile.profileImage,

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
                        1001,
                    userInfo:
                        [
                            NSLocalizedDescriptionKey:
                                "The image uploaded successfully, but profile_image was not saved in the profiles table."
                        ]
                )
            }


            print("===================================")
            print("✅ DATABASE PROFILE UPDATED")
            print(
                "profile_image:"
            )
            print(savedURL)
            print("===================================")


            // -----------------------------------------
            // Update local model
            // -----------------------------------------

            userProfile =
                updatedProfile


            // -----------------------------------------
            // Show selected image
            // -----------------------------------------

            profileImageView.image =
                image


            // -----------------------------------------
            // Clear Kingfisher cache
            // -----------------------------------------

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


            // -----------------------------------------
            // Cache busting
            // -----------------------------------------

            let separator =
                savedURL.contains("?")
                ? "&"
                : "?"


            let cacheBustingURLString =
                savedURL
                + separator
                + "v="
                + String(
                    Int(
                        Date()
                            .timeIntervalSince1970
                    )
                )


            if let cacheBustingURL =
                URL(
                    string:
                        cacheBustingURLString
                ) {

                profileImageView.kf.setImage(
                    with:
                        cacheBustingURL,
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


            print("===================================")
            print(
                "✅ PROFILE IMAGE SAVED SUCCESSFULLY"
            )
            print("===================================")


            showAlert(
                title:
                    "Success",
                message:
                    "Profile picture saved successfully."
            )


        } catch {

            print("===================================")
            print(
                "❌ PROFILE IMAGE SAVE ERROR"
            )

            print(error)

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


    // MARK: - Update Profile

    private func updateProfile(
        name:
            String,
        phone:
            String,
        address:
            String
    ) {

        Task {

            do {

                // -----------------------------------------
                // Get current user
                // -----------------------------------------

                let user =
                    try await
                    SupabaseManager.shared.client
                    .auth
                    .user()


                let userID =
                    user.id.uuidString


                // -----------------------------------------
                // Prepare update data
                // -----------------------------------------

                var updateData:
                    [String: String] = [

                        "full_name":
                            name,

                        "phone":
                            phone
                    ]


                // -----------------------------------------
                // Address
                // -----------------------------------------

                if address.isEmpty {

                    updateData[
                        "address"
                    ] = ""

                } else {

                    updateData[
                        "address"
                    ] =
                        address
                }


                // -----------------------------------------
                // Update Supabase
                // -----------------------------------------

                try await
                    SupabaseManager.shared.client
                    .from(
                        "profiles"
                    )
                    .update(
                        updateData
                    )
                    .eq(
                        "id",
                        value:
                            userID
                    )
                    .execute()


                print("===================================")
                print(
                    "✅ PROFILE TEXT UPDATED"
                )

                print(
                    "Name: \(name)"
                )

                print(
                    "Phone: \(phone)"
                )

                print(
                    "Address: \(address)"
                )

                print("===================================")


                // -----------------------------------------
                // Reload profile
                // -----------------------------------------

                fetchUserProfile()


                showAlert(
                    title:
                        "Success",
                    message:
                        "Profile updated successfully."
                )


            } catch {

                print("===================================")
                print(
                    "❌ PROFILE UPDATE ERROR"
                )

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


                print(
                    "==================================="
                )

                print(
                    "✅ USER LOGGED OUT"
                )

                print(
                    "==================================="
                )


                goToLoginScreen()


            } catch {

                print(
                    "==================================="
                )

                print(
                    "❌ LOGOUT ERROR"
                )

                print(
                    error.localizedDescription
                )

                print(
                    "==================================="
                )


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
        title:
            String,
        message:
            String,
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
