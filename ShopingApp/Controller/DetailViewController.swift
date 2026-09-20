//
//  DetailViewController.swift
//  ShopingApp
//
//  Created by Vijay on 04/09/26.
//

import UIKit
import Kingfisher

// MARK: - Detail View Controller

class DetailViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var order_NowBTN: UIButton!

    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var stockStatusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var warrantyLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var returnPolicyLabel: UILabel!

    @IBOutlet weak var skuLabel: UILabel!
    @IBOutlet weak var dimensionsLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var minOrderQuantityLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!

    // MARK: - Like Button

    @IBOutlet weak var likeButton: UIButton!

    // MARK: - Product

    var product: Product?
    var sectionTitle: String?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        configureView()
        updateLikeButton()

        // Razorpay delegate
        RazorpayManager.shared.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateLikeButton()

        // Make sure delegate is set whenever screen appears
        RazorpayManager.shared.delegate = self
    }

    // MARK: - Setup UI

    private func setupUI() {

        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
        warrantyLabel.numberOfLines = 0
        shippingLabel.numberOfLines = 0
        returnPolicyLabel.numberOfLines = 0
        tagsLabel.numberOfLines = 0

        productImageView.contentMode = .scaleAspectFit
        productImageView.clipsToBounds = true

        // Like button

        likeButton.setTitle("", for: .normal)
        likeButton.tintColor = .systemPink

        // Order button

        order_NowBTN.setTitle("Order Now", for: .normal)
        order_NowBTN.isEnabled = true
        order_NowBTN.alpha = 1.0
    }

    // MARK: - Configure Product

    private func configureView() {

        guard let product = product else {

            print("❌ Product is nil")
            return
        }

        print("================================")
        print("DETAIL PRODUCT")
        print("ID:", product.id)
        print("Title:", product.title)
        print("Price:", product.price)
        print("================================")

        // Navigation title

        if let sectionTitle = sectionTitle {
            self.title = sectionTitle.capitalized
        }

        // MARK: Core Information

        brandLabel.text = product.brand ?? "Generic"

        titleLabel.text = product.title

        priceLabel.text = String(
            format: "$%.2f",
            product.price
        )

        discountLabel.text =
            "\(product.discountPercentage)% OFF"

        ratingLabel.text =
            "★ \(product.rating) / 5.0"

        descriptionLabel.text =
            product.description

        // MARK: Stock

        stockStatusLabel.text =
            "\(product.availabilityStatus) (\(product.stock) left)"

        stockStatusLabel.textColor =
            product.stock > 5
            ? .systemGreen
            : .systemRed

        // MARK: Policies

        warrantyLabel.text =
            "Warranty: \(product.warrantyInformation)"

        shippingLabel.text =
            "Shipping: \(product.shippingInformation)"

        returnPolicyLabel.text =
            "Return Policy: \(product.returnPolicy)"

        // MARK: Specifications

        skuLabel.text =
            "SKU: \(product.sku)"

        weightLabel.text =
            "Weight: \(product.weight)g"

        minOrderQuantityLabel.text =
            "Min Order: \(product.minimumOrderQuantity) unit(s)"

        let dimensions = product.dimensions

        dimensionsLabel.text = String(
            format: "Dimensions: %.1f x %.1f x %.1f cm",
            dimensions.width,
            dimensions.height,
            dimensions.depth
        )

        // MARK: Tags

        if !product.tags.isEmpty {

            tagsLabel.text =
                "Tags: " +
                product.tags
                    .map {
                        "#\($0)"
                    }
                    .joined(separator: " ")

        } else {

            tagsLabel.text = ""
        }

        // MARK: Product Image

        if !product.thumbnail.isEmpty,
           let imageURL = URL(string: product.thumbnail) {

            productImageView.kf.indicatorType = .activity

            productImageView.kf.setImage(
                with: imageURL,
                placeholder: UIImage(
                    systemName: "photo"
                )
            )

        } else {

            productImageView.image =
                UIImage(systemName: "photo")
        }
    }

    // MARK: - Update Like Button

    private func updateLikeButton() {

        guard let product = product else {
            return
        }

        let isLiked =
            DatabaseManager.shared.isProductInCart(
                productID: product.id
            )

        print("Product ID:", product.id)
        print("Is Liked:", isLiked)

        if isLiked {

            likeButton.setImage(
                UIImage(systemName: "heart.fill"),
                for: .normal
            )

        } else {

            likeButton.setImage(
                UIImage(systemName: "heart"),
                for: .normal
            )
        }

        likeButton.tintColor = .systemPink

        likeButton.setTitle(
            "",
            for: .normal
        )
    }

    // MARK: - Like Button Action

    @IBAction func likeButtonTapped(
        _ sender: UIButton
    ) {

        guard let product = product else {

            print("❌ Product is nil")
            return
        }

        let database =
            DatabaseManager.shared

        let isAlreadyLiked =
            database.isProductInCart(
                productID: product.id
            )

        if isAlreadyLiked {

            print("🗑 Removing product from cart")

            database.deleteCartProduct(
                productID: product.id
            )

        } else {

            print("❤️ Adding product to cart")

            let cartProduct = CartProduct(

                id: product.id,

                title: product.title,

                price: product.price,

                quantity: 1,

                total: product.price,

                discountPercentage: 0.0,

                discountedTotal: 0.0,

                thumbnail: product.thumbnail
            )

            database.saveCartProduct(
                cartProduct
            )
        }

        updateLikeButton()
    }

    // MARK: - Order Now Button

    @IBAction func order_Now_BTN(
        _ sender: Any
    ) {

        print("")
        print("========================================")
        print("        ORDER NOW BUTTON CLICKED")
        print("========================================")

        // -----------------------------------------
        // 1. Check Product
        // -----------------------------------------

        guard let product = product else {

            print("❌ Product is nil")

            showAlert(
                title: "Error",
                message: "Product information is not available."
            )

            return
        }

        print("Product ID:", product.id)
        print("Product Name:", product.title)
        print("Product Price:", product.price)

        // -----------------------------------------
        // 2. Get Product Price
        // -----------------------------------------

        let amount = product.price

        // -----------------------------------------
        // 3. Validate Price
        // -----------------------------------------

        guard amount > 0 else {

            print("❌ Invalid product price")

            showAlert(
                title: "Invalid Price",
                message: "Product price is invalid."
            )

            return
        }

        // -----------------------------------------
        // 4. Make Sure View Controller Is Visible
        // -----------------------------------------

        guard self.viewIfLoaded?.window != nil else {

            print("❌ DetailViewController is not visible")

            showAlert(
                title: "Error",
                message: "Payment screen is not ready."
            )

            return
        }

        // -----------------------------------------
        // 5. Set Razorpay Delegate
        // -----------------------------------------

        RazorpayManager.shared.delegate = self

        // -----------------------------------------
        // 6. Start Razorpay
        // -----------------------------------------

        print("🚀 Starting Razorpay...")
        print("Amount:", amount)
        print("Product:", product.title)

           // Start payment
           RazorpayManager.shared.startPayment(
               viewController: self,
               amount: amount,
               productName: product.title,
               product: product
           )

        print("========================================")
    }

    // MARK: - Alert

    private func showAlert(
        title: String,
        message: String
    ) {

        DispatchQueue.main.async { [weak self] in

            guard let self = self else {
                return
            }

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

            self.present(
                alert,
                animated: true
            )
        }
    }
}

// MARK: - RazorpayManagerDelegate

extension DetailViewController: RazorpayManagerDelegate {

    // MARK: Payment Success

    func razorpayPaymentSuccess(
        paymentID: String
    ) {

        print("")
        print("========================================")
        print("       PAYMENT SUCCESS")
        print("========================================")

        print("Payment ID:", paymentID)

        showAlert(

            title: "Payment Successful",

            message:
                "Your payment was successful.\n\n" +
                "Payment ID:\n\(paymentID)"
        )
    }

    // MARK: Payment Failed

    func razorpayPaymentFailed(
        code: Int32,
        message: String
    ) {

        print("")
        print("========================================")
        print("       PAYMENT FAILED")
        print("========================================")

        print("Error Code:", code)
        print("Message:", message)

        showAlert(

            title: "Payment Failed",

            message:
                "\(message)\n\n" +
                "Error Code: \(code)"
        )
    }
}
