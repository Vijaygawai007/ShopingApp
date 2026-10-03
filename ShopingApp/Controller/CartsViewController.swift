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

        setupTableView()
        fetchCart()
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)

        fetchCart()
    }

    // MARK: - Setup TableView

    private func setupTableView() {

        cartTable.delegate = self
        cartTable.dataSource = self

        cartTable.rowHeight =
            UITableView.automaticDimension

        cartTable.estimatedRowHeight = 200

        cartTable.showsVerticalScrollIndicator = false
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

        DispatchQueue.main.async { [weak self] in

            self?.cartTable.reloadData()
        }
    }

    // MARK: - Update Quantity

    private func updateQuantity(
        productID: Int,
        newQuantity: Int,
        cell: CartTableViewCell
    ) {

        // Minimum quantity = 1
        let quantity =
            max(1, newQuantity)

        // -----------------------------------------
        // Update SQLite
        // -----------------------------------------

        DatabaseManager.shared.updateCartQuantity(
            productID: productID,
            quantity: quantity
        )

        // -----------------------------------------
        // Find Product
        // -----------------------------------------

        guard let product =
                cartProducts.first(
                    where: {
                        $0.id == productID
                    }
                )
        else {
            return
        }

        // -----------------------------------------
        // Calculate New Total
        // -----------------------------------------

        let total =
            product.price *
            Double(quantity)

        // -----------------------------------------
        // Update Cell UI
        // -----------------------------------------

        cell.quentity.text =
            "Qty: \(quantity)"

        cell.cartPrice.text =
            "₹\(total)"

        print("--------------------------------")
        print("✅ QUANTITY UPDATED")
        print("🛒 Product ID:", productID)
        print("📦 Product:", product.title)
        print("📦 New Quantity:", quantity)
        print("💰 New Total:", total)
        print("--------------------------------")
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
                withIdentifier:
                    "CartTableViewCell",
                for: indexPath
            ) as! CartTableViewCell

        let product =
            cartProducts[indexPath.row]

        // MARK: - Title

        if product.title.isEmpty {

            cell.cartTitle.text = ""

        } else {

            cell.cartTitle.text =
                product.title
        }

        // MARK: - Quantity

        cell.quentity.text =
            "Qty: \(product.quantity)"

        // MARK: - Stepper Configuration

        cell.qty_Steper.minimumValue = 1

        cell.qty_Steper.maximumValue = 99

        cell.qty_Steper.stepValue = 1

        cell.qty_Steper.value =
            Double(product.quantity)

        // MARK: - Price

        let total =
            product.price *
            Double(product.quantity)

        if product.price > 0 {

            cell.cartPrice.text =
                "₹\(total)"

        } else {

            cell.cartPrice.text = "0"
        }

        // MARK: - Discount Percentage

        if let discount =
            product.discountPercentage,
           discount > 0 {

            cell.DiscouontPercentage.text =
                "\(discount)% OFF"

        } else {

            cell.DiscouontPercentage.text =
                "0%"
        }

        // MARK: - Discounted Total

        if let discountedTotal =
            product.discountedTotal,
           discountedTotal > 0 {

            cell.TotalDiscount.text =
                "₹\(discountedTotal)"

        } else {

            cell.TotalDiscount.text =
                "0%"
        }
        

        // MARK: - Quantity Changed

        cell.onQuantityChange =
            { [weak self, weak cell] newQuantity in

                guard let self = self,
                      let cell = cell
                else {
                    return
                }

                self.updateQuantity(
                    productID: product.id,
                    newQuantity: newQuantity,
                    cell: cell
                )
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

        // MARK: - Selection

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

        print(
            "➡️ Selected Cart Product"
        )

        print(
            "ID:",
            cartProduct.id
        )

        print(
            "Title:",
            cartProduct.title
        )

        print(
            "Price:",
            cartProduct.price
        )

        print(
            "Quantity:",
            cartProduct.quantity
        )

        // MARK: - Storyboard

        let storyboard =
            UIStoryboard(
                name: "Main",
                bundle: nil
            )

        guard let detailVC =
                storyboard.instantiateViewController(
                    withIdentifier:
                        "DetailViewController"
                ) as? DetailViewController
        else {

            print(
                "❌ DetailViewController not found."
            )

            print(
                "❌ Check Storyboard ID: DetailViewController"
            )

            return
        }

        // MARK: - Pass Cart Product

        detailVC.cartProduct =
            cartProduct

        // MARK: - Section

        detailVC.sectionTitle =
            "Cart"

        // MARK: - Navigate

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
                    height:
                        .greatestFiniteMagnitude
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
