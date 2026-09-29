
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

    var cartProduct: CartProduct?

    var product: Product?

    var sectionTitle: String?

    // Quantity
    private var cartQuantity: Int = 1

    // MARK: - Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        setupUI()

        // --------------------------------------------------
        // Product opened from Cart
        // --------------------------------------------------

        if let cartProduct = cartProduct {

            cartQuantity =
                cartProduct.quantity

            showCartProductBasicData(
                cartProduct
            )

            fetchFullProductDetails(
                productID: cartProduct.id
            )

        }

        // --------------------------------------------------
        // Product opened normally
        // --------------------------------------------------

        else if let product = product {

            configureFullProduct(
                product
            )

        }

        else {

            print(
                "❌ Product and CartProduct are nil"
            )
        }

        updateLikeButton()

        // --------------------------------------------------
        // Payment Delegate
        // --------------------------------------------------

        RazorpayManager.shared.delegate =
            self
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {

        super.viewWillAppear(animated)

        updateLikeButton()

        RazorpayManager.shared.delegate =
            self
    }

    // MARK: - Setup UI

    private func setupUI() {

        titleLabel.numberOfLines = 0

        descriptionLabel.numberOfLines = 0

        warrantyLabel.numberOfLines = 0

        shippingLabel.numberOfLines = 0

        returnPolicyLabel.numberOfLines = 0

        tagsLabel.numberOfLines = 0

        productImageView.contentMode =
            .scaleAspectFit

        productImageView.clipsToBounds =
            true

        // --------------------------------------------------
        // Like Button
        // --------------------------------------------------

        likeButton.setTitle(
            "",
            for: .normal
        )

        likeButton.tintColor =
            .systemPink

        // --------------------------------------------------
        // Order Button
        // --------------------------------------------------

        order_NowBTN.setTitle(
            "Order Now",
            for: .normal
        )

        order_NowBTN.isEnabled =
            true

        order_NowBTN.alpha =
            1.0
    }

    // MARK: - Cart Product Basic Data

    private func showCartProductBasicData(
        _ cartProduct: CartProduct
    ) {

        brandLabel.text =
            "Loading..."

        titleLabel.text =
            cartProduct.title

        priceLabel.text =
            String(
                format: "₹%.2f",
                cartProduct.price
            )

        ratingLabel.text =
            ""

        discountLabel.text =
            ""

        descriptionLabel.text =
            "Loading product details..."

        stockStatusLabel.text =
            ""

        warrantyLabel.text =
            ""

        shippingLabel.text =
            ""

        returnPolicyLabel.text =
            ""

        skuLabel.text =
            "Product ID: \(cartProduct.id)"

        dimensionsLabel.text =
            ""

        weightLabel.text =
            ""

        minOrderQuantityLabel.text =
            "Quantity: \(cartProduct.quantity)"

        tagsLabel.text =
            ""

        // --------------------------------------------------
        // Cart Thumbnail
        // --------------------------------------------------

        if let thumbnail =
            cartProduct.thumbnail,

           !thumbnail.isEmpty,

           let imageURL =
            URL(string: thumbnail) {

            productImageView.kf.setImage(
                with: imageURL,
                placeholder:
                    UIImage(named: "placeholder")
            )
        }
    }

    // MARK: - Fetch Full Product

    private func fetchFullProductDetails(
        productID: Int
    ) {

        print(
            "Fetching product ID:",
            productID
        )

        let urlString =
            "https://dummyjson.com/products/\(productID)"

        guard let url =
            URL(string: urlString) else {

            print(
                "❌ Invalid API URL"
            )

            return
        }

        var request =
            URLRequest(url: url)

        request.httpMethod =
            "GET"

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        URLSession.shared.dataTask(
            with: request
        ) {
            [weak self] data,
            response,
            error in

            guard let self =
                self else {

                return
            }

            // --------------------------------------------------
            // Error
            // --------------------------------------------------

            if let error = error {

                print(
                    "❌ API Error:",
                    error.localizedDescription
                )

                return
            }

            // --------------------------------------------------
            // Data
            // --------------------------------------------------

            guard let data =
                data else {

                print(
                    "❌ No API data"
                )

                return
            }

            // --------------------------------------------------
            // Decode
            // --------------------------------------------------

            do {

                let decoder =
                    JSONDecoder()

                let fetchedProduct =
                    try decoder.decode(
                        Product.self,
                        from: data
                    )

                print(
                    "✅ Full product fetched:",
                    fetchedProduct.title
                )

                DispatchQueue.main.async {

                    self.product =
                        fetchedProduct

                    self.configureFullProduct(
                        fetchedProduct
                    )

                    self.updateLikeButton()
                }

            } catch {

                print(
                    "❌ Product Decode Error:",
                    error.localizedDescription
                )

                if let responseString =
                    String(
                        data: data,
                        encoding: .utf8
                    ) {

                    print(
                        responseString
                    )
                }
            }

        }.resume()
    }

    // MARK: - Configure Full Product

    private func configureFullProduct(
        _ product: Product
    ) {

        // --------------------------------------------------
        // Brand
        // --------------------------------------------------

        brandLabel.text =
            product.brand

        // --------------------------------------------------
        // Title
        // --------------------------------------------------

        titleLabel.text =
            product.title

        // --------------------------------------------------
        // Price
        // --------------------------------------------------

        priceLabel.text =
            String(
                format: "₹%.2f",
                product.price
            )

        // --------------------------------------------------
        // Rating
        // --------------------------------------------------

        ratingLabel.text =
            "⭐ \(product.rating)"

        // --------------------------------------------------
        // Discount
        // --------------------------------------------------

        discountLabel.text =
            "\(product.discountPercentage)% OFF"

        // --------------------------------------------------
        // Description
        // --------------------------------------------------

        descriptionLabel.text =
            product.description

        // --------------------------------------------------
        // Availability
        // --------------------------------------------------

        stockStatusLabel.text =
            product.availabilityStatus

        // --------------------------------------------------
        // Warranty
        // --------------------------------------------------

        warrantyLabel.text =
            product.warrantyInformation

        // --------------------------------------------------
        // Shipping
        // --------------------------------------------------

        shippingLabel.text =
            product.shippingInformation

        // --------------------------------------------------
        // Return
        // --------------------------------------------------

        returnPolicyLabel.text =
            product.returnPolicy

        // --------------------------------------------------
        // SKU
        // --------------------------------------------------

        skuLabel.text =
            "SKU: \(product.sku)"

        // --------------------------------------------------
        // Dimensions
        // --------------------------------------------------

        dimensionsLabel.text = """

        W: \(product.dimensions.width)
        H: \(product.dimensions.height)
        D: \(product.dimensions.depth)

        """

        // --------------------------------------------------
        // Weight
        // --------------------------------------------------

        weightLabel.text =
            "\(product.weight) g"

        // --------------------------------------------------
        // Quantity
        // --------------------------------------------------

        if cartProduct != nil {

            minOrderQuantityLabel.text =
                "Quantity: \(cartQuantity)"

        } else {

            minOrderQuantityLabel.text =
                "Minimum Order: \(product.minimumOrderQuantity)"
        }

        // --------------------------------------------------
        // Tags
        // --------------------------------------------------

        tagsLabel.text =
            product.tags.joined(
                separator: ", "
            )

        // --------------------------------------------------
        // Image
        // --------------------------------------------------

        if let imageURL =
            URL(string: product.thumbnail) {

            productImageView.kf.setImage(
                with: imageURL,
                placeholder:
                    UIImage(named: "placeholder")
            )
        }
    }

    // MARK: - Update Like Button

    private func updateLikeButton() {

        // --------------------------------------------------
        // Get Product ID
        // --------------------------------------------------

        let productID: Int?

        if let product = product {

            productID =
                product.id

        } else if let cartProduct =
                    cartProduct {

            productID =
                cartProduct.id

        } else {

            productID =
                nil
        }

        guard let productID =
            productID else {

            return
        }

        // --------------------------------------------------
        // Check SQLite
        // --------------------------------------------------

        let isLiked =
            DatabaseManager.shared.isProductInCart(
                productID: productID
            )

        // --------------------------------------------------
        // Heart
        // --------------------------------------------------

        if isLiked {

            likeButton.setImage(
                UIImage(
                    systemName:
                        "heart.fill"
                ),
                for: .normal
            )

        } else {

            likeButton.setImage(
                UIImage(
                    systemName:
                        "heart"
                ),
                for: .normal
            )
        }

        likeButton.tintColor =
            .systemPink

        likeButton.setTitle(
            "",
            for: .normal
        )
    }

    // MARK: - Like Button Action

    @IBAction func likeButtonTapped(
        _ sender: UIButton
    ) {

        guard let product =
            product else {

            print(
                "❌ Product is still loading"
            )

            showAlert(
                title: "Please Wait",
                message:
                    "Product details are still loading."
            )

            return
        }

        let database =
            DatabaseManager.shared

        let isAlreadyLiked =
            database.isProductInCart(
                productID:
                    product.id
            )

        // --------------------------------------------------
        // Remove
        // --------------------------------------------------

        if isAlreadyLiked {

            print(
                "🗑 Removing product"
            )

            database.deleteCartProduct(
                productID:
                    product.id
            )
        }

        // --------------------------------------------------
        // Add
        // --------------------------------------------------

        else {

            print(
                "❤️ Adding product"
            )

            let discountedPrice =
                product.price -
                (
                    product.price *
                    product.discountPercentage /
                    100
                )

            let newCartProduct =
                CartProduct(

                    id:
                        product.id,

                    title:
                        product.title,

                    price:
                        product.price,

                    quantity:
                        1,

                    total:
                        product.price,

                    discountPercentage:
                        product.discountPercentage,

                    discountedTotal:
                        discountedPrice,

                    thumbnail:
                        product.thumbnail
                )

            database.saveCartProduct(
                newCartProduct
            )
        }

        updateLikeButton()
    }

    // MARK: - Order Now

    @IBAction func order_Now_BTN(
        _ sender: Any
    ) {

        print(
            "========================================"
        )

        print(
            "ORDER NOW BUTTON CLICKED"
        )

        print(
            "========================================"
        )

        // --------------------------------------------------
        // Check Product
        // --------------------------------------------------

        guard let product =
            product else {

            print(
                "❌ Product is nil"
            )

            showAlert(
                title: "Error",
                message:
                    "Product information is not available."
            )

            return
        }

        // --------------------------------------------------
        // Quantity
        // --------------------------------------------------

        let quantity =
            cartProduct != nil
            ? cartQuantity
            : 1

        // --------------------------------------------------
        // Calculate Amount
        // --------------------------------------------------

        let amount =
            product.price *
            Double(quantity)

        guard amount > 0 else {

            showAlert(
                title: "Invalid Price",
                message:
                    "Product price is invalid."
            )

            return
        }

        print(
            "Product ID:",
            product.id
        )

        print(
            "Product:",
            product.title
        )

        print(
            "Price:",
            product.price
        )

        print(
            "Quantity:",
            quantity
        )

        print(
            "Total:",
            amount
        )

        // --------------------------------------------------
        // Check VC visibility
        // --------------------------------------------------

        guard viewIfLoaded?.window != nil else {

            showAlert(
                title: "Error",
                message:
                    "Payment screen is not ready."
            )

            return
        }

        // --------------------------------------------------
        // Set Delegate
        // --------------------------------------------------

        RazorpayManager.shared.delegate =
            self

        // --------------------------------------------------
        // Start Payment
        // --------------------------------------------------

        RazorpayManager.shared.startPayment(
            viewController: self,
            amount: amount,
            productName: product.title,
            product: product
        )
    }

    // MARK: - Alert

    private func showAlert(
        title: String,
        message: String
    ) {

        DispatchQueue.main.async {
            [weak self] in

            guard let self =
                self else {

                return
            }

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
                )
            )

            self.present(
                alert,
                animated:
                    true
            )
        }
    }
}

// MARK: - Razorpay Delegate

extension DetailViewController:
    RazorpayManagerDelegate {

    // MARK: Payment Success

    func razorpayPaymentSuccess(
        paymentID: String
    ) {

        print(
            "========================================"
        )

        print(
            "PAYMENT SUCCESS"
        )

        print(
            "Payment ID:",
            paymentID
        )

        print(
            "========================================"
        )

        showAlert(

            title:
                "Payment Successful",

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

        print(
            "========================================"
        )

        print(
            "PAYMENT FAILED"
        )

        print(
            "Error Code:",
            code
        )

        print(
            "Message:",
            message
        )

        print(
            "========================================"
        )

        showAlert(

            title:
                "Payment Failed",

            message:
                "\(message)\n\n" +
                "Error Code: \(code)"
        )
    }
}
