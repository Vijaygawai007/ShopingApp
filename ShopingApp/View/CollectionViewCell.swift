import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var productIMG: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var ratingLBL: UILabel!
    @IBOutlet weak var descriptionLBL: UILabel!

    
    // Product currently displayed in this cell
    var product: Product?

    // Send selected product to ViewController
    var likeProductAction: ((Product) -> Void)?
    @IBOutlet weak var likeButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()

        bgView.layer.borderWidth = 0.3
        bgView.layer.cornerRadius = 18
        bgView.layer.shadowOpacity = 0.5
        bgView.layer.shadowOffset.height = 12
        bgView.layer.shadowOffset.width = 12

        ratingLBL.textColor = .systemOrange
        likeButton.imageView?.image?.withTintColor(.systemPink)
        
    }

    @IBAction func likeProduct(_ sender: UIButton) {

        guard let product = product else {
            print("❌ Product not available")
            return
        }

        print("❤️ Like button tapped")
        print("Product ID:", product.id)
        print("Product Name:", product.title)
        // Send this exact product to ViewController
        likeProductAction?(product)
        sender.setImage(
                    UIImage(systemName: "heart.fill"),
                    for: .normal
                )
        sender.tintColor = .systemPink
    }
}
