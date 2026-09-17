import UIKit

class CollectionViewCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var productIMG: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var ratingLBL: UILabel!
    @IBOutlet weak var descriptionLBL: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - Variables
    // Product currently displayed in this cell
    var product: Product?

    // Closure to send the selected product back to the ViewController
    var likeProductAction: ((Product) -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        // Style the background view
        bgView.layer.borderWidth = 0.3
        bgView.layer.cornerRadius = 18
        bgView.layer.shadowOpacity = 0.5
        bgView.layer.shadowOffset = CGSize(width: 2, height: 2) // Fixed shadow offset
        
        // Colors
        ratingLBL.textColor = .systemOrange
        likeButton.tintColor = .systemGray // Default color before it is liked
    }

    // MARK: - IBActions
    @IBAction func likeProduct(_ sender: UIButton) {

        // Safely unwrap the product
        guard let product = product else {
            print("❌ Product not available")
            return
        }

        print("❤️ Like button tapped")
        print("Product ID:", product.id)
        print("Product Name:", product.title)
        print("Product Thunbnail:",product.thumbnail)
        
        // 1. Send this exact product to the ViewController to save to SQLite
        likeProductAction?(product)
        
        // 2. Instantly update the button UI to show it was liked
        UIView.animate(withDuration: 0.2) {
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            sender.tintColor = .systemPink
        }
    }
}
