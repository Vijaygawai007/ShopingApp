//
//  CartTableViewCell.swift
//  ShopingApp
//
//  Created by Vijay on 04/09/26.
//

import UIKit
import Kingfisher

class CartTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cartCardView: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var cartTitle: UILabel!
    @IBOutlet weak var cartPrice: UILabel!
    @IBOutlet weak var quentity : UILabel!
    @IBOutlet weak var DiscouontPercentage : UILabel!
    @IBOutlet weak var TotalDiscount: UILabel!

    override func awakeFromNib() {
            super.awakeFromNib()
        cartCardView.layer.cornerRadius = 10
        cartCardView.layer.borderWidth = 0.2
        cartCardView.layer.shadowOpacity = 0.4
        cartCardView.layer.shadowOffset = .init(width: 3, height: 3)
        }
  }
