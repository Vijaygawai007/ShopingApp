
//
//  BoardingCollectionViewCell.swift
//  ShopingApp
//

import UIKit

protocol BoardingCollectionViewCellDelegate: AnyObject {
    func didTapGetStarted()
}

class BoardingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var boarding_IMG: UIImageView!
    @IBOutlet weak var onBoardingLBL: UILabel!
    @IBOutlet weak var onBoarding_SubLBL: UILabel!
    @IBOutlet weak var getStarted_BTN: UIButton!

    weak var delegate: BoardingCollectionViewCellDelegate?

    @IBAction func getStartedBTN(_ sender: UIButton) {

        print("✅ Get Started tapped")

        delegate?.didTapGetStarted()
    }
}
