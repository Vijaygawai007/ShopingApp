//
//  RazorpayManager.swift
//  ShopingApp
//
//  Created by Vijay on 18/09/26.
//

import UIKit
import Razorpay

// MARK: - Razorpay Manager Delegate

protocol RazorpayManagerDelegate: AnyObject {
    
    func razorpayPaymentSuccess(
        paymentID: String
    )
    
    func razorpayPaymentFailed(
        code: Int32,
        message: String
    )
}

// MARK: - Razorpay Manager

final class RazorpayManager: NSObject {
    
    // MARK: - Singleton
    
    static let shared = RazorpayManager()
    
    
    // MARK: - Razorpay
    
    private var razorpay: RazorpayCheckout?
    
    
    // MARK: - Delegate
    
    weak var delegate: RazorpayManagerDelegate?
    
    
    // MARK: - Payment State
    
    private var isPaymentInProgress = false
    
    
    // MARK: - Purchased Product
    
    // Product that is being paid for
    private var purchasedProduct: Product?
    
    
    // MARK: - Private Init
    
    private override init() {
        super.init()
    }
    
    
    // MARK: - Start Payment
    
    func startPayment(
        viewController: UIViewController,
        amount: Double,
        productName: String,
        product: Product
    ) {
        
        print("")
        print("========================================")
        print("          RAZORPAY START")
        print("========================================")
        
        print("Product ID:", product.id)
        print("Product:", product.title)
        print("Amount:", amount)
        
        
        // ------------------------------------------------
        // 1. Store Product
        // ------------------------------------------------
        
        purchasedProduct = product
        
        
        // ------------------------------------------------
        // 2. Get Razorpay Test Key
        // ------------------------------------------------
        
        let keyID = payment().test_key2
        
        
        print(
            "Razorpay Key Available:",
            !keyID.isEmpty
        )
        
        
        // ------------------------------------------------
        // 3. Validate Key
        // ------------------------------------------------
        
        guard !keyID.isEmpty else {
            
            print("❌ Razorpay Key is empty")
            
            purchasedProduct = nil
            
            delegate?.razorpayPaymentFailed(
                code: -100,
                message: "Razorpay test key is missing."
            )
            
            return
        }
        
        
        // ------------------------------------------------
        // 4. Validate Amount
        // ------------------------------------------------
        
        guard amount > 0 else {
            
            print("❌ Invalid payment amount")
            
            purchasedProduct = nil
            
            delegate?.razorpayPaymentFailed(
                code: -101,
                message: "Payment amount must be greater than zero."
            )
            
            return
        }
        
        
        // ------------------------------------------------
        // 5. Prevent Multiple Payments
        // ------------------------------------------------
        
        guard !isPaymentInProgress else {
            
            print("⚠️ Payment is already in progress.")
            
            return
        }
        
        
        // ------------------------------------------------
        // 6. Check View Controller
        // ------------------------------------------------
        
        guard viewController.isViewLoaded,
              viewController.view.window != nil else {
            
            print("❌ ViewController is not visible.")
            
            purchasedProduct = nil
            
            delegate?.razorpayPaymentFailed(
                code: -102,
                message: "Unable to open payment screen."
            )
            
            return
        }
        
        
        // ------------------------------------------------
        // 7. Convert INR to Paise
        // ------------------------------------------------
        
        let amountInPaise = Int(
            (amount * 100).rounded()
        )
        
        
        print(
            "Amount in Paise:",
            amountInPaise
        )
        
        
        // ------------------------------------------------
        // 8. Create Razorpay Checkout
        // ------------------------------------------------
        
        razorpay = RazorpayCheckout.initWithKey(
            keyID,
            andDelegate: self
        )
        
        
        print("✅ RazorpayCheckout created")
        
        
        // ------------------------------------------------
        // 9. Set Payment State
        // ------------------------------------------------
        
        isPaymentInProgress = true
        
        
        // ------------------------------------------------
        // 10. Checkout Options
        // ------------------------------------------------
        
        let options: [String: Any] = [
            
            "key": keyID,
            
            "amount": amountInPaise,
            
            "currency": "INR",
            
            "name": "ShopingApp",
            
            "description": productName,
            
            "prefill": [
                "name": "Vijay Gawai",
                "email": "test@example.com",
                "contact": "9999999999"
            ],
            
            "theme": [
                "color": "#E30B"
            ]
        ]
        
        
        print("")
        print("========================================")
        print("Opening Razorpay Checkout...")
        print("========================================")
        
        
        // ------------------------------------------------
        // 11. Open Checkout
        // ------------------------------------------------
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else {
                return
            }
            
            
            guard viewController.isViewLoaded,
                  viewController.view.window != nil else {
                
                print("❌ ViewController became detached.")
                
                self.isPaymentInProgress = false
                self.razorpay = nil
                self.purchasedProduct = nil
                
                self.delegate?.razorpayPaymentFailed(
                    code: -103,
                    message: "Payment screen could not be opened."
                )
                
                return
            }
            
            
            self.razorpay?.open(options)
        }
    }
    
    
    // MARK: - Release Razorpay
    
    private func releaseRazorpay() {
        
        print("Releasing Razorpay instance...")
        
        isPaymentInProgress = false
        
        razorpay = nil
    }
    
    
    // MARK: - Payment Success Handler
    
    private func handlePaymentSuccess(
        paymentID: String
    ) {
        
        print("")
        print("========================================")
        print("       ✅ RAZORPAY PAYMENT SUCCESS")
        print("========================================")
        
        print(
            "Payment ID:",
            paymentID
        )
        
        
        // Send result to DetailViewController
        
        delegate?.razorpayPaymentSuccess(
            paymentID: paymentID
        )
        
        
        // Release Razorpay slightly later
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.5
        ) { [weak self] in
            
            self?.releaseRazorpay()
        }
    }
    
    
    // MARK: - Payment Error Handler
    
    private func handlePaymentError(
        code: Int32,
        message: String
    ) {
        
        print("")
        print("========================================")
        print("       ❌ RAZORPAY PAYMENT FAILED")
        print("========================================")
        
        print("Error Code:", code)
        print("Error Message:", message)
        
        
        // Payment failed.
        // Do NOT save the product into Orders.
        
        purchasedProduct = nil
        
        
        // Send result to DetailViewController
        
        delegate?.razorpayPaymentFailed(
            code: code,
            message: message
        )
        
        
        // Release Razorpay slightly later
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.5
        ) { [weak self] in
            
            self?.releaseRazorpay()
        }
    }
}


// MARK: - Razorpay Payment Completion

extension RazorpayManager: RazorpayPaymentCompletionProtocol {
    
    
    // MARK: - Payment Error
    
    func onPaymentError(
        _ code: Int32,
        description str: String
    ) {
        
        print("")
        print("========================================")
        print("❌ RAZORPAY ERROR CALLBACK")
        print("========================================")
        
        print("Code:", code)
        print("Description:", str)
        
        
        // Important:
        //
        // Do NOT present UIAlertController here.
        //
        // Razorpay's checkout controller may still
        // be disappearing from the screen.
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else {
                return
            }
            
            
            self.handlePaymentError(
                code: code,
                message: str
            )
        }
    }
    
    
    // MARK: - Payment Success
    
    func onPaymentSuccess(
        _ payment_id: String
    ) {
        
        print("")
        print("========================================")
        print("✅ RAZORPAY SUCCESS CALLBACK")
        print("========================================")
        
        print(
            "Payment ID:",
            payment_id
        )
        
        
        // ------------------------------------------------
        // SAVE PRODUCT ONLY AFTER PAYMENT SUCCESS
        // ------------------------------------------------
        
        guard let product = purchasedProduct else {
            
            print("❌ Payment succeeded but product was not found.")
            
            DispatchQueue.main.async { [weak self] in
                
                self?.handlePaymentSuccess(
                    paymentID: payment_id
                )
            }
            
            return
        }
        
        
        print("")
        print("========================================")
        print("💾 SAVING ORDER IN SQLITE")
        print("========================================")
        
        print("Product ID:", product.id)
        print("Product Name:", product.title)
        print("Product Price:", product.price)
        print("Payment ID:", payment_id)
        print("Thumbnail:", product.thumbnail)
        
        
        // Save purchased product into SQLite
        OrderSQLiteManager.shared.saveOrder(
            productID: product.id,
            productName: product.title,
            quantity: 1,
            price: product.price,
            paymentID: payment_id,
            thumbnail: product.thumbnail
        )
        
        
        print("========================================")
        print("✅ PRODUCT SAVED AS ORDER")
        print("========================================")
        
        
        // ------------------------------------------------
        // Send success result to ViewController
        // ------------------------------------------------
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else {
                return
            }
            
            
            self.handlePaymentSuccess(
                paymentID: payment_id
            )
        }
    }
}
