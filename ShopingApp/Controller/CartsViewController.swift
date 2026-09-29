
//
//  CartsViewController.swift
//  ShopingApp
//
//  Created by Vijay on 16/09/26.
//

import UIKit
import Kingfisher
import Alamofire

class CartViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var cartTable: UITableView!

    // MARK: - Variables

    var cartProducts: [CartProduct] = []

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        cartTable.delegate = self
        cartTable.dataSource = self

        cartTable.rowHeight = UITableView.automaticDimension
        cartTable.showsVerticalScrollIndicator = false

        fetchCart()
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)

        fetchCart()
    }

    // MARK: - Fetch Cart

    func fetchCart() {

        cartProducts =
            DatabaseManager.shared.fetchCartProducts()

        print(
            "🛒 SQLite Cart Count:",
            cartProducts.count
        )

        for product in cartProducts {

            print(
                "📦 ID:",
                product.id
            )

            print(
                "📦 Title:",
                product.title
            )

            print(
                "📦 Price:",
                product.price
            )

            print(
                "📦 Quantity:",
                product.quantity
            )

            print(
                "🖼️ Thumbnail:",
                product.thumbnail ?? "nil"
            )
        }

        DispatchQueue.main.async {

            self.cartTable.reloadData()
        }
    }
}

// MARK: - UITableView Delegate & DataSource

extension CartViewController:
    UITableViewDelegate,
    UITableViewDataSource {

    // MARK: - Number Of Rows

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return cartProducts.count
    }

    // MARK: - Cell For Row

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "CartTableViewCell",
                for: indexPath
            ) as! CartTableViewCell

        let product =
            cartProducts[indexPath.row]

        // MARK: - Title

        if !product.title.isEmpty {

            cell.cartTitle.text =
                product.title

        } else {

            cell.cartTitle.text = ""
        }

        // MARK: - Price

        if product.price > 0 {

            cell.cartPrice.text =
                "₹\(product.price)"

        } else {

            cell.cartPrice.text = ""
        }

        // MARK: - Quantity

        if product.quantity > 0 {

            cell.quentity.text =
                "Qty: \(product.quantity)"

        } else {

            cell.quentity.text = ""
        }

        // MARK: - Thumbnail

        cell.thumbnail.image =
            UIImage(systemName: "photo")

        if let thumbnail =
            product.thumbnail,
           !thumbnail.isEmpty,
           let url =
            URL(string: thumbnail) {

            cell.thumbnail.kf.setImage(
                with: url,
                placeholder:
                    UIImage(systemName: "photo")
            )
        }

        cell.selectionStyle = .none

        return cell
    }

    // MARK: - Did Select Row

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        let cartProduct =
            cartProducts[indexPath.row]

        print("➡️ Selected Cart Product")
        print("ID:", cartProduct.id)
        print("Title:", cartProduct.title)
        print("Price:", cartProduct.price)

        // -----------------------------------------
        // Storyboard
        // -----------------------------------------

        let storyboard =
            UIStoryboard(
                name: "Main",
                bundle: nil
            )

        guard let detailVC =
                storyboard.instantiateViewController(
                    withIdentifier: "DetailViewController"
                ) as? DetailViewController
        else {

            print("❌ DetailViewController not found.")
            print("❌ Check Storyboard ID: DetailViewController")

            return
        }

        // -----------------------------------------
        // Pass Cart Product
        // -----------------------------------------

        detailVC.cartProduct = cartProduct

        // -----------------------------------------
        // Section
        // -----------------------------------------

        detailVC.sectionTitle = "Cart"

        // -----------------------------------------
        // Navigate
        // -----------------------------------------

        if let navigationController =
            self.navigationController {

            navigationController.pushViewController(
                detailVC,
                animated: true
            )

        } else {

            detailVC.modalPresentationStyle =
                .fullScreen

            present(
                detailVC,
                animated: true
            )
        }
    }


    // MARK: - Row Height

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        let product =
            cartProducts[indexPath.row]

        let title =
            product.title

        let width =
            tableView.frame.width - 150

        let titleHeight =
            title.boundingRect(
                with: CGSize(
                    width: width,
                    height: .greatestFiniteMagnitude
                ),
                options: [
                    .usesLineFragmentOrigin,
                    .usesFontLeading
                ],
                attributes: [
                    .font:
                        UIFont.systemFont(
                            ofSize: 17
                        )
                ],
                context: nil
            ).height

        let height =
            max(
                200,
                titleHeight + 80
            )

        return height
    }
}
