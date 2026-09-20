import UIKit
import Kingfisher

class MyOrderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cards: UIView!
    @IBOutlet weak var orderIDLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var orderImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        orderImg.layer.cornerRadius = 8
        orderImg.clipsToBounds = true
        orderImg.contentMode = .scaleAspectFill
        cards.layer.cornerRadius = 10
        cards.layer.borderWidth = 0.2
        cards.layer.shadowOpacity = 0.4
        cards.layer.shadowOffset = .init(width: 3, height: 3)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        orderImg.kf.cancelDownloadTask()
        orderImg.image = nil
    }
    
    func configure(with order: Order) {
        
        orderIDLabel.text = "Order #\(order.orderID)"
        productNameLabel.text = order.productName
        quantityLabel.text = "Qty: \(order.quantity)"
        totalLabel.text = "₹\(String(format: "%.2f", order.total))"
        statusLabel.text = order.status
        
        if let url = URL(string: order.thumbnail) {
            orderImg.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo")
            )
        } else {
            orderImg.image = UIImage(systemName: "photo")
        }
    }
}
