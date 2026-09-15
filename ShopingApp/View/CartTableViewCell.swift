//
//  CartTableViewCell.swift
//  ShopingApp
//
//  Created by Vijay on 04/09/26.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cartCardView: UIView!
    @IBOutlet weak var cartImage: UIImageView!
    @IBOutlet weak var cartTitle: UILabel!
    @IBOutlet weak var cartBrand: UILabel!
    @IBOutlet weak var cartDescription: UILabel!
    @IBOutlet weak var cartPrice: UILabel!
    @IBOutlet weak var cartRating: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cartCardView.layer.cornerRadius = 20
        cartCardView.layer.borderWidth = 0.3
        cartCardView.layer.shadowOpacity = 0.5
        cartCardView.layer.shadowOffset.height = 12
        cartCardView.layer.shadowOffset.width = 12
    }

}
