//
//  CartTableViewCell.swift
//  ShopingApp
//
//  Created by Vijay on 04/09/26.
//
//
//  CartTableViewCell.swift
//  ShopingApp
//

import UIKit
import Kingfisher

class CartTableViewCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var cartCardView: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var cartTitle: UILabel!
    @IBOutlet weak var cartPrice: UILabel!
    @IBOutlet weak var quentity: UILabel!
    @IBOutlet weak var DiscouontPercentage: UILabel!
//    @IBOutlet weak var stockLBL: UILabel!
    @IBOutlet weak var TotalDiscount: UILabel!
    @IBOutlet weak var qty_Steper: UIStepper!

    // MARK: - Quantity Callback

    var onQuantityChange: ((Int) -> Void)?

    // MARK: - Awake From Nib

    override func awakeFromNib() {
        super.awakeFromNib()

        // Card UI
        cartCardView.layer.cornerRadius = 20
        cartCardView.layer.borderWidth = 0.2
        cartCardView.layer.shadowOpacity = 0.4
        cartCardView.layer.shadowOffset =
            CGSize(width: 3, height: 3)

        // Stepper
        qty_Steper.minimumValue = 1
        qty_Steper.maximumValue = 99
        qty_Steper.stepValue = 1
    }

    // MARK: - Stepper Value Changed

    @IBAction func stepperValueChanged(
        _ sender: UIStepper
    ) {

        let newQty =
            Int(sender.value)

        // Update quantity label immediately
        quentity.text =
            "Qty: \(newQty)"

        // Send quantity to CartViewController
        onQuantityChange?(newQty)
    }

    // MARK: - Prepare For Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        onQuantityChange = nil

        qty_Steper.value = 1

        quentity.text = ""
    }
}
