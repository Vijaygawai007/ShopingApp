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
    
    // MARK: - Received Data
    var product: Product?
    var sectionTitle: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureView()
    }
    
    private func setupUI() {
        // Allow multi-line wrapping for long descriptions and policy texts
        titleLabel?.numberOfLines = 0
        descriptionLabel?.numberOfLines = 0
        warrantyLabel?.numberOfLines = 0
        shippingLabel?.numberOfLines = 0
        returnPolicyLabel?.numberOfLines = 0
        tagsLabel?.numberOfLines = 0
        
        // Prevent image distortion
        productImageView?.contentMode = .scaleAspectFit
        productImageView?.clipsToBounds = true
    }
    
    private func configureView() {
        if let sectionTitle = sectionTitle {
            self.title = sectionTitle.capitalized
        }
        
        guard let product = product else { return }
        
        // MARK: 1. Core Information
        brandLabel?.text = product.brand ?? "Generic"
        titleLabel?.text = product.title
        priceLabel?.text = String(format: "$%.2f", product.price)
        discountLabel?.text = "\(product.discountPercentage)% OFF"
        ratingLabel?.text = "★ \(product.rating) / 5.0"
        descriptionLabel?.text = product.description
        
        // Stock & Availability status color coding
        stockStatusLabel?.text = "\(product.availabilityStatus) (\(product.stock) left)"
        stockStatusLabel?.textColor = product.stock > 5 ? .systemGreen : .systemRed
        
        // MARK: 2. Policies & Delivery
        warrantyLabel?.text = "Warranty: \(product.warrantyInformation)"
        shippingLabel?.text = "Shipping: \(product.shippingInformation)"
        returnPolicyLabel?.text = "Return Policy: \(product.returnPolicy)"
        
        // MARK: 3. Specifications
        skuLabel?.text = "SKU: \(product.sku)"
        weightLabel?.text = "Weight: \(product.weight)g"
        minOrderQuantityLabel?.text = "Min Order: \(product.minimumOrderQuantity) unit(s)"
        
        let d = product.dimensions
        dimensionsLabel?.text = String(format: "Dimensions: %.1f x %.1f x %.1f cm", d.width, d.height, d.depth)
        
        if !product.tags.isEmpty {
            tagsLabel?.text = "Tags: " + product.tags.map { "#\($0)" }.joined(separator: " ")
        } else {
            tagsLabel?.text = nil
        }
        
        // MARK: 4. Image Loading
        if let imageURL = URL(string: product.thumbnail) {
            productImageView?.kf.indicatorType = .activity
            productImageView?.kf.setImage(
                with: imageURL,
                placeholder: UIImage(systemName: "photo")
            )
        }
    }
}
