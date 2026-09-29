
//  ViewController.swift
//  ShopingApp
//
//  Created by Vijay on 01/09/26.
//

import UIKit
import Alamofire
import Kingfisher

// MARK: - View Controller

class ViewController: UIViewController {

    static let shared = ViewController()

    // MARK: - Original Product Data

    var sections = [ProductSection]()

    // MARK: - Search Data

    private var filteredSections = [ProductSection]()

    private var isSearching: Bool {
        return !(search_TF.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    // MARK: - Notifications

    private var notifications: [String] = []

    private let notificationBadge = UILabel()

    // MARK: - Outlets

    @IBOutlet weak var productCollectionTable: UICollectionView!

    @IBOutlet weak var search_TF: UITextField!

    @IBOutlet weak var notification_Bell_BTN: UIButton!


    // MARK: - Page Control

    private var section0PageControl = UIPageControl()


    // MARK: - View Did Load

    override func viewDidLoad() {
        super.viewDidLoad()
        search_TF.layer.cornerRadius = 8
        search_TF.layer.borderWidth = .nan
        // Collection View
        productCollectionTable.delegate = self
        productCollectionTable.dataSource = self

        // -------------------------------------------------
        // MAIN COLLECTION VIEW
        // NORMAL VERTICAL SCROLLING
        // -------------------------------------------------
        productCollectionTable.alwaysBounceVertical = true
        productCollectionTable.isPagingEnabled = false
        productCollectionTable.alwaysBounceHorizontal = false
        productCollectionTable.showsVerticalScrollIndicator = false
        productCollectionTable.showsHorizontalScrollIndicator = false

        productCollectionTable.collectionViewLayout =
            createCompositionalLayout()


        // -------------------------------------------------
        // PRODUCT CELL
        // -------------------------------------------------

        let productNib = UINib(
            nibName: "CollectionViewCell",
            bundle: nil
        )

        productCollectionTable.register(
            productNib,
            forCellWithReuseIdentifier: "CollectionViewCell"
        )


        // -------------------------------------------------
        // CATEGORY CELL
        // -------------------------------------------------

        productCollectionTable.register(
            CategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: "CategoryCollectionViewCell"
        )


        // -------------------------------------------------
        // HEADER
        // -------------------------------------------------

        productCollectionTable.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind:
                UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeaderView"
        )


        // -------------------------------------------------
        // PAGE CONTROL FOOTER
        // -------------------------------------------------

        productCollectionTable.register(
            PageControlFooterView.self,
            forSupplementaryViewOfKind:
                UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "PageControlFooterView"
        )
        
        // -------------------------------------------------
        // SEARCH
        // -------------------------------------------------
        setupSearch()
        // -------------------------------------------------
        // NOTIFICATION
        // -------------------------------------------------

        setupNotificationBadge()
        updateNotificationBadge()

        // -------------------------------------------------
        // FETCH PRODUCTS
        // -------------------------------------------------
        fetchProducts()
    }


    // MARK: - View Will Appear

    override func viewWillAppear(
        _ animated: Bool
    ) {

        super.viewWillAppear(animated)

        // Refresh heart status
        productCollectionTable.reloadData()
        
        // Refresh notification badge
        updateNotificationBadge()
    }


    // MARK: - Search Setup

    private func setupSearch() {

        search_TF.delegate = self

        search_TF.addTarget(
            self,
            action: #selector(searchTextChanged),
            for: .editingChanged
        )

        search_TF.returnKeyType = .search

        search_TF.clearButtonMode = .whileEditing

        search_TF.placeholder = "Search products..."
    }


    // MARK: - Search Text Changed

    @objc private func searchTextChanged() {

        let text = (search_TF.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Empty search
        if text.isEmpty {

            filteredSections = sections

            productCollectionTable.reloadData()

            return
        }


        let searchText = text.lowercased()


        // -------------------------------------------------
        // SEARCH PRODUCTS
        // -------------------------------------------------

        filteredSections = sections.compactMap {

            section in

            let filteredProducts =
                section.products.filter {

                    product in

                    let title =
                        product.title.lowercased()

                    let description =
                        product.description.lowercased()

                    let category =
                        section.category.lowercased()

                    return title.contains(searchText)
                    || description.contains(searchText)
                    || category.contains(searchText)
                }


            // Do not show empty category
            guard !filteredProducts.isEmpty else {
                return nil
            }


            return ProductSection(
                category: section.category,
                products: filteredProducts
            )
        }


        productCollectionTable.reloadData()


        // Scroll to top after search
        if !filteredSections.isEmpty {

            let indexPath =
                IndexPath(
                    item: 0,
                    section: 0
                )

            DispatchQueue.main.async {

                if self.productCollectionTable.numberOfSections > 0,
                   self.productCollectionTable.numberOfItems(
                        inSection: 0
                   ) > 0 {

                    self.productCollectionTable.scrollToItem(
                        at: indexPath,
                        at: .top,
                        animated: false
                    )
                }
            }
        }
    }


    // MARK: - Search Clear

    private func clearSearch() {

        search_TF.text = ""

        filteredSections = sections

        productCollectionTable.reloadData()
    }


    // MARK: - Notification Badge Setup

    private func setupNotificationBadge() {

        notificationBadge.textAlignment = .center

        notificationBadge.font =
            UIFont.systemFont(
                ofSize: 10,
                weight: .bold
            )

        notificationBadge.textColor = .white

        notificationBadge.backgroundColor =
            .systemRed

        notificationBadge.layer.cornerRadius = 9

        notificationBadge.clipsToBounds = true

        notificationBadge.isHidden = true

        notificationBadge.translatesAutoresizingMaskIntoConstraints =
            false


        // Add badge on top of bell button

        notification_Bell_BTN.addSubview(
            notificationBadge
        )


        NSLayoutConstraint.activate([

            notificationBadge.topAnchor.constraint(
                equalTo:
                    notification_Bell_BTN.topAnchor,
                constant: -2
            ),

            notificationBadge.trailingAnchor.constraint(
                equalTo:
                    notification_Bell_BTN.trailingAnchor,
                constant: 2
            ),

            notificationBadge.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 18
            ),

            notificationBadge.heightAnchor.constraint(
                equalToConstant: 18
            )
        ])
    }


    // MARK: - Update Notification Badge

    private func updateNotificationBadge() {

        let count = notifications.count


        // -------------------------------------------------
        // NO NOTIFICATIONS
        // HIDE BADGE
        // -------------------------------------------------

        if count == 0 {

            notificationBadge.isHidden = true

            notificationBadge.text = ""

            return
        }


        // -------------------------------------------------
        // HAS NOTIFICATIONS
        // SHOW BADGE
        // -------------------------------------------------

        notificationBadge.isHidden = false


        if count > 99 {

            notificationBadge.text = "99+"

        } else {

            notificationBadge.text =
                "\(count)"
        }
    }


    // MARK: - Add Notification

    private func addNotification(
        _ message: String
    ) {

        notifications.append(message)

        updateNotificationBadge()
    }


    // MARK: - Bell Button

    @IBAction func notification_Bell_BTN(
        _ sender: Any
    ) {

        // -------------------------------------------------
        // NO NOTIFICATION
        // -------------------------------------------------

        if notifications.isEmpty {

            let alert =
                UIAlertController(
                    title: "Notifications",
                    message: "You don't have any new notifications.",
                    preferredStyle: .alert
                )

            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default
                )
            )

            present(
                alert,
                animated: true
            )

            return
        }


        // -------------------------------------------------
        // CREATE NOTIFICATION MESSAGE
        // -------------------------------------------------

        let message =
            notifications.joined(
                separator: "\n\n"
            )


        let alert =
            UIAlertController(
                title: "Notifications",
                message: message,
                preferredStyle: .alert
            )


        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )


        present(
            alert,
            animated: true
        )


        // -------------------------------------------------
        // CLEAR NOTIFICATIONS
        // -------------------------------------------------

        notifications.removeAll()

        updateNotificationBadge()
    }

    // MARK: - Compositional Layout

    private func createCompositionalLayout()
    -> UICollectionViewLayout {

        let layout =
            UICollectionViewCompositionalLayout {

                [weak self]
                sectionIndex,
                layoutEnvironment
                -> NSCollectionLayoutSection? in

                guard let self = self else {
                    return nil
                }

                // =====================================================
                // SECTION 0
                // FIRST PRODUCT CATEGORY
                // HORIZONTAL PAGING
                // =====================================================

                if sectionIndex == 0 {

                    let itemSize =
                        NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .fractionalHeight(1.0)
                        )

                    let item =
                        NSCollectionLayoutItem(
                            layoutSize: itemSize
                        )

                    let groupSize =
                        NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(0.90),
                            heightDimension: .absolute(220)
                        )

                    let group =
                        NSCollectionLayoutGroup.horizontal(
                            layoutSize: groupSize,
                            subitems: [item]
                        )

                    let section =
                        NSCollectionLayoutSection(
                            group: group
                        )

                    section.interGroupSpacing = 15

                    section.contentInsets =
                        NSDirectionalEdgeInsets(
                            top: 15,
                            leading: 15,
                            bottom: 5,
                            trailing: 15
                        )

                    // KEEP SECTION 0 HORIZONTAL PAGING
                    section.orthogonalScrollingBehavior = .groupPaging

                    // Page Control Footer

                    let footerSize =
                        NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(30)
                        )

                    let footer =
                        NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: footerSize,
                            elementKind:
                                UICollectionView.elementKindSectionFooter,
                            alignment: .bottom
                        )

                    section.boundarySupplementaryItems = [footer]

                    // Page Indicator

                    section.visibleItemsInvalidationHandler = {
                        [weak self]
                        visibleItems,
                        point,
                        environment in

                        guard let self = self else {
                            return
                        }

                        let productItems =
                            visibleItems.filter {
                                $0.representedElementCategory == .cell
                            }

                        guard !productItems.isEmpty else {
                            return
                        }

                        let currentItem =
                            productItems.min {
                                abs($0.frame.minX - point.x)
                                <
                                abs($1.frame.minX - point.x)
                            }

                        guard let currentItem = currentItem else {
                            return
                        }

                        let currentPage =
                            currentItem.indexPath.item

                        DispatchQueue.main.async {
                            self.section0PageControl.currentPage =
                                currentPage
                        }
                    }

                    return section
                }

                // =====================================================
                // SECTION 1
                // CATEGORIES
                // HORIZONTAL SCROLLING
                // =====================================================

                if sectionIndex == 1 {

                    let itemSize =
                        NSCollectionLayoutSize(
                            widthDimension: .absolute(130),
                            heightDimension: .absolute(70)
                        )

                    let item =
                        NSCollectionLayoutItem(
                            layoutSize: itemSize
                        )

                    let groupSize =
                        NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(70)
                        )

                    let group =
                        NSCollectionLayoutGroup.horizontal(
                            layoutSize: groupSize,
                            subitems: [item]
                        )

                    group.interItemSpacing = .fixed(12)

                    let section =
                        NSCollectionLayoutSection(
                            group: group
                        )

                    // KEEP CATEGORY HORIZONTAL
                    section.orthogonalScrollingBehavior = .continuous

                    section.contentInsets =
                        NSDirectionalEdgeInsets(
                            top: 5,
                            leading: 15,
                            bottom: 15,
                            trailing: 15
                        )

                    section.interGroupSpacing = 10

                    let headerSize =
                        NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(50)
                        )

                    let header =
                        NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: headerSize,
                            elementKind:
                                UICollectionView.elementKindSectionHeader,
                            alignment: .top
                        )

                    section.boundarySupplementaryItems = [header]

                    return section
                }

                // =====================================================
                // PRODUCT SECTIONS
                // =====================================================

                let productSectionIndex =
                    sectionIndex - 1

                let currentSections =
                    self.isSearching
                    ? self.filteredSections
                    : self.sections

                guard productSectionIndex <
                        currentSections.count
                else {
                    return nil
                }

                // =====================================================
                // SECTION TYPE
                // =====================================================

                let isVerticalSection: Bool

                let groupWidth: NSCollectionLayoutDimension
                let groupHeight: NSCollectionLayoutDimension

                let behavior:
                    UICollectionLayoutSectionOrthogonalScrollingBehavior

                // -----------------------------------------------------
                // SECTION 2
                // VERTICAL
                // -----------------------------------------------------

                if sectionIndex == 2 {

                    isVerticalSection = true

                    groupWidth =
                        .fractionalWidth(1.0)

                    groupHeight =
                        .absolute(260)

                    behavior = .none
                }

                // -----------------------------------------------------
                // SECTION 3
                // HORIZONTAL
                // -----------------------------------------------------

                else if sectionIndex == 3 {

                    isVerticalSection = false

                    groupWidth =
                        .fractionalWidth(0.90)

                    groupHeight =
                        .absolute(290)

                    behavior = .continuous
                }

                // -----------------------------------------------------
                // SECTION 4
                // VERTICAL
                // -----------------------------------------------------

                else if sectionIndex == 4 {

                    isVerticalSection = true

                    groupWidth =
                        .fractionalWidth(1.0)

                    groupHeight =
                        .absolute(270)

                    behavior = .none
                }

                // -----------------------------------------------------
                // SECTION 5+
                // HORIZONTAL
                // -----------------------------------------------------

                else {

                    isVerticalSection = false

                    groupWidth =
                        .fractionalWidth(0.45)

                    groupHeight =
                        .absolute(270)

                    behavior = .continuous
                }

                // =====================================================
                // PRODUCT ITEM
                // =====================================================

                let itemSize =
                    NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)
                    )

                let item =
                    NSCollectionLayoutItem(
                        layoutSize: itemSize
                    )

                // =====================================================
                // PRODUCT GROUP
                // =====================================================

                let groupSize =
                    NSCollectionLayoutSize(
                        widthDimension: groupWidth,
                        heightDimension: groupHeight
                    )

                let group: NSCollectionLayoutGroup

                if isVerticalSection {

                    // -------------------------------------------------
                    // VERTICAL SECTION
                    // 2 CARDS PER ROW
                    // -------------------------------------------------

                    group =
                        NSCollectionLayoutGroup.horizontal(
                            layoutSize: groupSize,
                            subitem: item,
                            count: 2
                        )

                    group.interItemSpacing = .fixed(15)

                } else {

                    // -------------------------------------------------
                    // HORIZONTAL SECTION
                    // 1 CARD
                    // -------------------------------------------------

                    group =
                        NSCollectionLayoutGroup.vertical(
                            layoutSize: groupSize,
                            subitems: [item]
                        )
                }

                let section =
                    NSCollectionLayoutSection(
                        group: group
                    )

                section.interGroupSpacing = 15

                section.contentInsets =
                    NSDirectionalEdgeInsets(
                        top: 15,
                        leading: 15,
                        bottom: 15,
                        trailing: 15
                    )

                // -----------------------------------------------------
                // IMPORTANT
                // -----------------------------------------------------
                //
                // .none = section participates in MAIN vertical scroll
                //
                // .continuous = section gets its own horizontal scroll
                //

                section.orthogonalScrollingBehavior =
                    behavior

                // =====================================================
                // HEADER
                // =====================================================

                let headerSize =
                    NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(50)
                    )

                let header =
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: headerSize,
                        elementKind:
                            UICollectionView.elementKindSectionHeader,
                        alignment: .top
                    )

                section.boundarySupplementaryItems = [header]

                return section
            }

        // =========================================================
        // MAIN COLLECTION VIEW
        // CONTINUOUS VERTICAL SCROLL
        // =========================================================

        layout.configuration.scrollDirection = .vertical

        return layout
    }



    // MARK: - API Parse

    func fetchProducts() {

        ProductViewModel.sharedInstance.ProductAPI {

            [weak self]
            success,
            failure in

            guard let self = self else {
                return
            }


            DispatchQueue.main.async {

                if let success = success {

                    let groupedDictionary =
                        Dictionary(
                            grouping:
                                success.products,
                            by: {
                                $0.category
                            }
                        )


                    self.sections =
                        groupedDictionary.map {

                            ProductSection(
                                category:
                                    $0.key,
                                products:
                                    $0.value
                            )
                        }


                    self.sections.sort {

                        $0.category <
                            $1.category
                    }


                    // Initially show all products

                    self.filteredSections =
                        self.sections


                    // Setup Page Control

                    let productCount =
                        self.sections.first?
                            .products.count ?? 0


                    self.section0PageControl.numberOfPages =
                        productCount


                    self.section0PageControl.currentPage =
                        0


                    self.productCollectionTable.reloadData()


                } else if let failure = failure {

                    print(
                        "Error:",
                        failure
                    )
                }
            }
        }
    }


    // MARK: - Add Product To Cart API

    private func addProductToCart(
        _ product: Product
    ) {

        print(
            "🛒 Adding product to cart via API"
        )

        print(
            "Product ID:",
            product.id
        )


        let userID = 1


        AddToCartViewModel.sharedInstance.addToCart(

            productID:
                product.id,

            userID:
                userID,

            quantity:
                1

        ) {

            [weak self]
            (
                response: AddToCartResponse?,
                error: String?
            ) in


            DispatchQueue.main.async {

                if let response = response {

                    print(
                        "✅ Product added to server cart. Cart ID:",
                        response.id
                    )


                    // -------------------------------------------------
                    // CREATE NOTIFICATION
                    // -------------------------------------------------

                    self?.addNotification(
                        "🛒 \(product.title) was added to your cart."
                    )


                } else {

                    print(
                        "❌ Add to cart API failed:",
                        error ?? "Unknown error"
                    )
                }
            }
        }
    }


    // MARK: - Update Heart

    private func updateHeart(
        for button: UIButton,
        productID: Int
    ) {

        let isLiked =
            DatabaseManager.shared.isProductInCart(
                productID:
                    productID
            )


        button.tintColor =
            .systemPink


        if isLiked {

            button.setImage(
                UIImage(
                    systemName:
                        "heart.fill"
                ),
                for:
                    .normal
            )

        } else {

            button.setImage(
                UIImage(
                    systemName:
                        "heart"
                ),
                for:
                    .normal
            )
        }


        button.setTitle(
            "",
            for:
                .normal
        )
    }
}


// MARK: - UICollectionView Delegate / DataSource

extension ViewController:
    UICollectionViewDelegate,
    UICollectionViewDataSource {


    // MARK: Number Of Sections

    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {

        let currentSections =
            isSearching
            ? filteredSections
            : sections


        guard !currentSections.isEmpty else {
            return 0
        }


        // Section 0 = first product category
        // Section 1 = categories
        // Section 2+ = product categories

        return currentSections.count + 1
    }


    // MARK: Number Of Items

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        let currentSections =
            isSearching
            ? filteredSections
            : sections


        // -------------------------------------------------
        // SECTION 0
        // -------------------------------------------------

        if section == 0 {

            return currentSections.first?
                .products.count ?? 0
        }


        // -------------------------------------------------
        // SECTION 1 = CATEGORIES
        // -------------------------------------------------

        if section == 1 {

            return currentSections.count
        }


        // -------------------------------------------------
        // SECTION 2+
        // -------------------------------------------------

        let productSectionIndex =
            section - 1


        guard productSectionIndex <
                currentSections.count
        else {
            return 0
        }


        return currentSections[
            productSectionIndex
        ].products.count
    }


    // MARK: - Select Item

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {

        let currentSections =
            isSearching
            ? filteredSections
            : sections


        // =====================================================
        // CATEGORY CLICK
        // =====================================================

        if indexPath.section == 1 {

            let categoryIndex =
                indexPath.item


            guard categoryIndex <
                    currentSections.count
            else {
                return
            }


            let targetSection:
                Int


            if categoryIndex == 0 {

                targetSection = 0

            } else {

                targetSection =
                    categoryIndex + 1
            }


            guard targetSection <
                    collectionView.numberOfSections
            else {
                return
            }


            if targetSection == 0 {

                let targetIndexPath =
                    IndexPath(
                        item: 0,
                        section: 0
                    )


                collectionView.scrollToItem(
                    at:
                        targetIndexPath,
                    at:
                        .centeredHorizontally,
                    animated:
                        true
                )

            } else {

                let targetIndexPath =
                    IndexPath(
                        item: 0,
                        section:
                            targetSection
                    )


                collectionView.scrollToItem(
                    at:
                        targetIndexPath,
                    at:
                        .top,
                    animated:
                        true
                )
            }


            return
        }


        // =====================================================
        // PRODUCT CLICK
        // =====================================================

        let productSectionIndex:
            Int


        if indexPath.section == 0 {

            productSectionIndex = 0

        } else {

            productSectionIndex =
                indexPath.section - 1
        }


        guard productSectionIndex <
                currentSections.count
        else {
            return
        }


        let currentSection =
            currentSections[
                productSectionIndex
            ]


        guard indexPath.item <
                currentSection.products.count
        else {
            return
        }


        let selectedProduct =
            currentSection.products[
                indexPath.item
            ]


        guard let detailVC =
                storyboard?
            .instantiateViewController(
                withIdentifier:
                    "DetailViewController"
            ) as?
            DetailViewController
        else {
            return
        }


        detailVC.product =
            selectedProduct


        detailVC.sectionTitle =
            currentSection.category


        navigationController?
            .pushViewController(
                detailVC,
                animated:
                    true
            )
    }


    // MARK: - Cell For Item

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {


        let currentSections =
            isSearching
            ? filteredSections
            : sections


        // =====================================================
        // SECTION 1 = CATEGORY CELL
        // =====================================================

        if indexPath.section == 1 {

            guard let cell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier:
                            "CategoryCollectionViewCell",
                        for:
                            indexPath
                    ) as?
                    CategoryCollectionViewCell
            else {
                return UICollectionViewCell()
            }


            let category =
                currentSections[
                    indexPath.item
                ].category


            cell.configure(
                title:
                    category.capitalized
            )


            return cell
        }


        // =====================================================
        // PRODUCT CELL
        // =====================================================

        guard let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier:
                        "CollectionViewCell",
                    for:
                        indexPath
                ) as?
                CollectionViewCell
        else {
            return UICollectionViewCell()
        }


        let productSectionIndex:
            Int


        if indexPath.section == 0 {

            productSectionIndex = 0

        } else {

            productSectionIndex =
                indexPath.section - 1
        }


        guard productSectionIndex <
                currentSections.count
        else {
            return cell
        }


        let product =
            currentSections[
                productSectionIndex
            ].products[
                indexPath.item
            ]


        cell.product =
            product


        // MARK: Product Data

        cell.titleLBL.text =
            product.title


        cell.ratingLBL.text =
            "₹\(product.price)"


        cell.descriptionLBL.text =
            "★★☆\(product.rating)"


        // MARK: Product Image

        if !product.thumbnail.isEmpty,
           let imageURL =
                URL(
                    string:
                        product.thumbnail
                ) {

            cell.productIMG.kf.setImage(
                with:
                    imageURL,
                placeholder:
                    UIImage(
                        systemName:
                            "photo"
                    )
            )

        } else {

            cell.productIMG.image =
                UIImage(
                    systemName:
                        "photo"
                )
        }


        cell.productIMG.clipsToBounds =
            true


        // MARK: Image Content Mode

        if indexPath.section == 0 ||
            indexPath.section == 2 ||
            indexPath.section == 4 {

            cell.productIMG.contentMode =
                .scaleAspectFit

        } else {

            cell.productIMG.contentMode =
                .scaleAspectFill
        }


        // MARK: Heart

        updateHeart(
            for:
                cell.likeButton,
            productID:
                product.id
        )


        // MARK: Like Button Action

        cell.likeProductAction = {

            [
                weak self,
                weak cell
            ]
            selectedProduct in


            guard let cell = cell else {
                return
            }


            let productID =
                selectedProduct.id


            let database =
                DatabaseManager.shared


            let isAlreadyInCart =
                database.isProductInCart(
                    productID:
                        productID
                )


            if isAlreadyInCart {

                // -------------------------------------------------
                // REMOVE
                // -------------------------------------------------

                database.deleteCartProduct(
                    productID:
                        productID
                )


                print(
                    "💔 Product removed from SQLite:",
                    selectedProduct.title
                )


            } else {

                // -------------------------------------------------
                // ADD
                // -------------------------------------------------

                let itemToSave =
                    CartProduct(

                        id:
                            selectedProduct.id,

                        title:
                            selectedProduct.title,

                        price:
                            selectedProduct.price,

                        quantity:
                            1,

                        total:
                            selectedProduct.price,

                        discountPercentage:
                            0.0,

                        discountedTotal:
                            0.0,

                        thumbnail:
                            selectedProduct.thumbnail
                    )


                database.saveCartProduct(
                    itemToSave
                )


                print(
                    "❤️ Product added to SQLite:",
                    selectedProduct.title
                )


                // -------------------------------------------------
                // ADD TO SERVER CART
                // -------------------------------------------------

                self?.addProductToCart(
                    selectedProduct
                )
            }


            // -------------------------------------------------
            // UPDATE HEART
            // -------------------------------------------------

            self?.updateHeart(
                for:
                    cell.likeButton,
                productID:
                    productID
            )
        }


        return cell
    }


    // MARK: - Supplementary Views

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {


        let currentSections =
            isSearching
            ? filteredSections
            : sections


        // =====================================================
        // SECTION 0 PAGE CONTROL
        // =====================================================

        if kind ==
            UICollectionView.elementKindSectionFooter {


            guard let footer =
                    collectionView
                .dequeueReusableSupplementaryView(
                    ofKind:
                        kind,
                    withReuseIdentifier:
                        "PageControlFooterView",
                    for:
                        indexPath
                ) as?
                PageControlFooterView
            else {
                return UICollectionReusableView()
            }


            if indexPath.section == 0 {

                footer.pageControl.numberOfPages =
                    currentSections.first?
                    .products.count ?? 0


                footer.pageControl.currentPage =
                    section0PageControl.currentPage


                section0PageControl =
                    footer.pageControl
            }


            return footer
        }


        // =====================================================
        // SECTION HEADER
        // =====================================================

        if kind ==
            UICollectionView.elementKindSectionHeader {


            guard let header =
                    collectionView
                .dequeueReusableSupplementaryView(
                    ofKind:
                        kind,
                    withReuseIdentifier:
                        "SectionHeaderView",
                    for:
                        indexPath
                ) as?
                SectionHeaderView
            else {
                return UICollectionReusableView()
            }


            // =================================================
            // SECTION 1 = CATEGORIES
            // =================================================

            if indexPath.section == 1 {

                header.titleLabel.text =
                    "Categories"


                header.seeMoreButton.isHidden =
                    true


                header.seeMoreAction =
                    nil


                return header
            }


            // =================================================
            // PRODUCT SECTIONS
            // =================================================

            let productSectionIndex:
                Int


            if indexPath.section == 0 {

                productSectionIndex = 0

            } else {

                productSectionIndex =
                    indexPath.section - 1
            }


            guard productSectionIndex <
                    currentSections.count
            else {
                return header
            }


            let currentSection =
                currentSections[
                    productSectionIndex
                ]


            header.titleLabel.text =
                currentSection
                .category
                .capitalized


            header.seeMoreButton.isHidden =
                false


            header.seeMoreAction = {

                [weak self] in


                guard let self = self else {
                    return
                }


                print(
                    "See More tapped for category:",
                    currentSection.category
                )


                let detailVC =
                    UIViewController()


                detailVC.view.backgroundColor =
                    .white


                detailVC.title =
                    currentSection
                    .category
                    .capitalized


                self.navigationController?
                    .pushViewController(
                        detailVC,
                        animated:
                            true
                    )
            }


            return header
        }


        return UICollectionReusableView()
    }
}


// MARK: - UITextFieldDelegate

extension ViewController:
    UITextFieldDelegate {

    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {

        textField.resignFirstResponder()

        return true
    }
}


// MARK: - Category Collection View Cell

class CategoryCollectionViewCell:
    UICollectionViewCell {

    private let categoryLabel =
        UILabel()


    override init(
        frame: CGRect
    ) {

        super.init(
            frame:
                frame
        )

        setupUI()
    }


    required init?(
        coder:
            NSCoder
    ) {

        super.init(
            coder:
                coder
        )

        setupUI()
    }


    private func setupUI() {

        contentView.backgroundColor =
            .systemGray6


        contentView.layer.cornerRadius =
            15


        contentView.layer.borderWidth =
            1


        contentView.layer.borderColor =
            UIColor.systemGray4.cgColor


        contentView.clipsToBounds =
            true


        categoryLabel.textAlignment =
            .center


        categoryLabel.font =
            UIFont.systemFont(
                ofSize:
                    16,
                weight:
                    .semibold
            )


        categoryLabel.textColor =
            .label


        categoryLabel.numberOfLines =
            2


        contentView.addSubview(
            categoryLabel
        )


        categoryLabel.translatesAutoresizingMaskIntoConstraints =
            false


        NSLayoutConstraint.activate([

            categoryLabel.leadingAnchor.constraint(
                equalTo:
                    contentView.leadingAnchor,
                constant:
                    8
            ),

            categoryLabel.trailingAnchor.constraint(
                equalTo:
                    contentView.trailingAnchor,
                constant:
                    -8
            ),

            categoryLabel.topAnchor.constraint(
                equalTo:
                    contentView.topAnchor,
                constant:
                    5
            ),

            categoryLabel.bottomAnchor.constraint(
                equalTo:
                    contentView.bottomAnchor,
                constant:
                    -5
            )
        ])
    }


    func configure(
        title:
            String
    ) {

        categoryLabel.text =
            title
    }


    override var isSelected:
        Bool {

        didSet {

            if isSelected {

                contentView.backgroundColor =
                    .systemBlue

                categoryLabel.textColor =
                    .white

            } else {

                contentView.backgroundColor =
                    .systemGray6

                categoryLabel.textColor =
                    .label
            }
        }
    }
}


// MARK: - Page Control Footer

class PageControlFooterView:
    UICollectionReusableView {

    let pageControl =
        UIPageControl()


    override init(
        frame:
            CGRect
    ) {

        super.init(
            frame:
                frame
        )

        setupUI()
    }


    required init?(
        coder:
            NSCoder
    ) {

        super.init(
            coder:
                coder
        )

        setupUI()
    }


    private func setupUI() {

        pageControl.currentPage =
            0


        pageControl.hidesForSinglePage =
            true


        pageControl.pageIndicatorTintColor =
            .systemGray3


        pageControl.currentPageIndicatorTintColor =
            .systemBlue


        pageControl.isUserInteractionEnabled =
            false


        addSubview(
            pageControl
        )


        pageControl.translatesAutoresizingMaskIntoConstraints =
            false


        NSLayoutConstraint.activate([

            pageControl.centerXAnchor.constraint(
                equalTo:
                    centerXAnchor
            ),

            pageControl.centerYAnchor.constraint(
                equalTo:
                    centerYAnchor
            )
        ])
    }
}


// MARK: - Reusable Header View

class SectionHeaderView:
    UICollectionReusableView {

    let titleLabel =
        UILabel()


    let seeMoreButton =
        UIButton(
            type:
                .system
        )


    var seeMoreAction:
        (() -> Void)?


    override init(
        frame:
            CGRect
    ) {

        super.init(
            frame:
                frame
        )


        addSubview(
            titleLabel
        )


        addSubview(
            seeMoreButton
        )


        titleLabel.translatesAutoresizingMaskIntoConstraints =
            false


        seeMoreButton.translatesAutoresizingMaskIntoConstraints =
            false


        titleLabel.font =
            UIFont.boldSystemFont(
                ofSize:
                    22
            )


        titleLabel.textColor =
            .black


        seeMoreButton.setTitle(
            "See More >>",
            for:
                .normal
        )


        seeMoreButton.titleLabel?.font =
            UIFont.systemFont(
                ofSize:
                    14,
                weight:
                    .semibold
            )


        seeMoreButton.setTitleColor(
            .systemBlue,
            for:
                .normal
        )


        seeMoreButton.addTarget(
            self,
            action:
                #selector(
                    seeMoreTapped
                ),
            for:
                .touchUpInside
        )


        NSLayoutConstraint.activate([

            titleLabel.leadingAnchor.constraint(
                equalTo:
                    leadingAnchor,
                constant:
                    15
            ),

            titleLabel.centerYAnchor.constraint(
                equalTo:
                    centerYAnchor
            ),

            seeMoreButton.trailingAnchor.constraint(
                equalTo:
                    trailingAnchor,
                constant:
                    -15
            ),

            seeMoreButton.centerYAnchor.constraint(
                equalTo:
                    centerYAnchor
            ),

            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo:
                    seeMoreButton.leadingAnchor,
                constant:
                    -10
            )
        ])
    }


    @objc private func seeMoreTapped() {

        seeMoreAction?()
    }


    required init?(
        coder:
            NSCoder
    ) {

        fatalError(
            "init(coder:) has not been implemented"
        )
    }
}
