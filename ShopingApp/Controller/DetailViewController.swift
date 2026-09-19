//
//  DetailViewController.swift
//  ShopingApp
//
//  Created by Vijay on 04/09/26.
//

import UIKit
import Kingfisher

class DetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
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
    }
    
    
    deinit {
        
        // Remove delegate when this ViewController is destroyed
        if RazorpayManager.shared.delegate === self {
            RazorpayManager.shared.delegate = nil
        }
        
        print("DetailViewController deinitialized")
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
        
        
        // MARK: Like Button
        
        likeButton.setTitle("", for: .normal)
        likeButton.tintColor = .systemPink
        
        
        // MARK: Order Button
        
        order_NowBTN.setTitle(
            "Order Now",
            for: .normal
        )
    }
    
    
    // MARK: - Configure Product
    
    private func configureView() {
        
        guard let product = product else {
            
            print("❌ Product is nil")
            return
        }
        
        
        // MARK: Navigation Title
        
        if let sectionTitle = sectionTitle {
            
            self.title = sectionTitle.capitalized
        }
        
        
        // MARK: Core Information
        
        brandLabel.text =
            product.brand ?? "Generic"
        
        
        titleLabel.text =
            product.title
        
        
        // Razorpay is using INR
        priceLabel.text = String(
            format: "₹%.2f",
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
        
        
        if product.stock > 5 {
            
            stockStatusLabel.textColor =
                .systemGreen
            
        } else {
            
            stockStatusLabel.textColor =
                .systemRed
        }
        
        
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
                    .map { "#\($0)" }
                    .joined(separator: " ")
            
        } else {
            
            tagsLabel.text = ""
        }
        
        
        // MARK: Product Image
        
        if !product.thumbnail.isEmpty,
           let imageURL = URL(
                string: product.thumbnail
           ) {
            
            productImageView.kf.indicatorType =
                .activity
            
            
            productImageView.kf.setImage(
                with: imageURL,
                placeholder: UIImage(
                    systemName: "photo"
                )
            )
            
        } else {
            
            productImageView.image =
                UIImage(
                    systemName: "photo"
                )
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
        
        
        print(
            "Product ID:",
            product.id
        )
        
        
        print(
            "Is Liked:",
            isLiked
        )
        
        
        if isLiked {
            
            likeButton.setImage(
                UIImage(
                    systemName: "heart.fill"
                ),
                for: .normal
            )
            
        } else {
            
            likeButton.setImage(
                UIImage(
                    systemName: "heart"
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
        
        guard let product = product else {
            return
        }
        
        
        let database =
            DatabaseManager.shared
        
        
        let isAlreadyLiked =
            database.isProductInCart(
                productID: product.id
            )
        
        
        // MARK: Remove Product
        
        if isAlreadyLiked {
            
            database.deleteCartProduct(
                productID: product.id
            )
            
            
            print(
                "🗑 Product removed from cart:",
                product.id
            )
            
        }
        
        // MARK: Add Product
        
        else {
            
            let cartProduct =
                CartProduct(
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
            
            
            print(
                "❤️ Product added to cart:",
                product.id
            )
        }
        
        
        updateLikeButton()
    }
    
    
    // MARK: - Order Now Button
    
    @IBAction func order_Now_BTN(
        _ sender: Any
    ) {
        
        // ------------------------------------------------
        // 1. Get Product
        // ------------------------------------------------
        
        guard let product = product else {
            
            showAlert(
                title: "Error",
                message: "Product information is not available."
            )
            
            return
        }
        
        
        // ------------------------------------------------
        // 2. Get Product Price
        // ------------------------------------------------
        
        let amount =
            product.price
        
        
        print("================================")
        print("🛒 ORDER NOW CLICKED")
        print("Product:", product.title)
        print("Product ID:", product.id)
        print("Price:", amount)
        print("================================")
        
        
        // ------------------------------------------------
        // 3. Validate Price
        // ------------------------------------------------
        
        guard amount > 0 else {
            
            showAlert(
                title: "Invalid Price",
                message: "Product price must be greater than zero."
            )
            
            return
        }
        
        
        // ------------------------------------------------
        // 4. Check ViewController is Visible
        // ------------------------------------------------
        
        guard isViewLoaded,
              view.window != nil else {
            
            print("❌ DetailViewController is not visible")
            
            return
        }
        
        
        // ------------------------------------------------
        // 5. Start Razorpay Payment
        // ------------------------------------------------
        
        RazorpayManager.shared.startPayment(
            viewController: self,
            amount: amount,
            productName: product.title
        )
    }
    
    
    // MARK: - Payment Success
    
    private func handlePaymentSuccess(
        paymentID: String
    ) {
        
        print("================================")
        print("✅ PAYMENT SUCCESS")
        print("Payment ID:", paymentID)
        print("================================")
        
        
        // Wait until Razorpay's checkout controller
        // has finished dismissing.
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.5
        ) { [weak self] in
            
            guard let self = self else {
                return
            }
            
            
            // Make sure this ViewController is still visible.
            
            guard self.isViewLoaded,
                  self.view.window != nil else {
                
                print(
                    "⚠️ DetailViewController is no longer visible."
                )
                
                return
            }
            
            
            self.showAlert(
                title: "Payment Successful",
                message: "Payment ID:\n\(paymentID)"
            )
        }
    }
    
    
    // MARK: - Payment Failure
    
    private func handlePaymentFailure(
        code: Int32,
        message: String
    ) {
        
        print("================================")
        print("❌ PAYMENT FAILED")
        print("Code:", code)
        print("Reason:", message)
        print("================================")
        
        
        // Wait until Razorpay's checkout controller
        // has finished dismissing.
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.5
        ) { [weak self] in
            
            guard let self = self else {
                return
            }
            
            
            // Make sure this ViewController is still visible.
            
            guard self.isViewLoaded,
                  self.view.window != nil else {
                
                print(
                    "⚠️ DetailViewController is no longer visible."
                )
                
                return
            }
            
            
            self.showAlert(
                title: "Payment Failed",
                message: "Code: \(code)\n\(message)"
            )
        }
    }
    
    
    // MARK: - Alert
    
    private func showAlert(
        title: String,
        message: String
    ) {
        
        // Prevent presenting an alert from a detached
        // ViewController.
        
        guard isViewLoaded,
              view.window != nil else {
            
            print(
                "⚠️ Cannot present alert. ViewController is not visible."
            )
            
            return
        }
        
        
        // If another controller is already being presented,
        // avoid presenting another alert on top of it.
        
        if presentedViewController != nil {
            
            print(
                "⚠️ Another ViewController is already presented."
            )
            
            return
        }
        
        
        let alert =
            UIAlertController(
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


// MARK: - RazorpayManagerDelegate

extension DetailViewController: RazorpayManagerDelegate {
    
    
    func razorpayPaymentSuccess(
        paymentID: String
    ) {
        
        handlePaymentSuccess(
            paymentID: paymentID
        )
    }
    
    
    func razorpayPaymentFailed(
        code: Int32,
        message: String
    ) {
        
        handlePaymentFailure(
            code: code,
            message: message
        )
    }
}
