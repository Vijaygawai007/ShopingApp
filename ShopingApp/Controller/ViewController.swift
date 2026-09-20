//
//  ViewController.swift
//  ShopingApp
//
//  Created by Vijay on 01/09/26.
//

import UIKit
import Alamofire
import Kingfisher

struct ProductSection {
    let category: String
    var products: [Product]
}

class ViewController: UIViewController {
    
    static let shared = ViewController()
    var sections = [ProductSection]()
    
    @IBOutlet weak var productCollectionTable: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productCollectionTable.delegate = self
        productCollectionTable.dataSource = self
        
        productCollectionTable.collectionViewLayout = createCompositionalLayout()
        
        let nib = UINib(
            nibName: "CollectionViewCell",
            bundle: nil
        )
        
        productCollectionTable.register(
            nib,
            forCellWithReuseIdentifier: "CollectionViewCell"
        )
        
        productCollectionTable.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeaderView"
        )
        
        fetchProducts()
    }
    
    // MARK: - View Will Appear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh heart status from SQLite
        productCollectionTable.reloadData()
    }
    
    // MARK: - Compositional Layout
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout {
            [weak self] sectionIndex, layoutEnvironment
            -> NSCollectionLayoutSection? in
            
            guard self != nil else {
                return nil
            }
            
            var groupWidth: NSCollectionLayoutDimension
            var groupHeight: NSCollectionLayoutDimension
            var orthogonalBehavior:
                UICollectionLayoutSectionOrthogonalScrollingBehavior
            
            var isVerticalScrolling = false
            
            if sectionIndex == 0 {
                
                groupWidth = .fractionalWidth(0.90)
                groupHeight = .absolute(220)
                orthogonalBehavior = .groupPaging
                
            } else if sectionIndex == 1 {
                
                groupWidth = .fractionalWidth(1.0)
                groupHeight = .absolute(260)
                orthogonalBehavior = .none
                isVerticalScrolling = true
                
            } else if sectionIndex == 2 {
                
                groupWidth = .fractionalWidth(1.0)
                groupHeight = .absolute(260)
                orthogonalBehavior = .none
                isVerticalScrolling = true
                
            } else if sectionIndex == 3 {
                
                groupWidth = .fractionalWidth(0.90)
                groupHeight = .absolute(290)
                orthogonalBehavior = .continuous
                
            } else {
                
                groupWidth = .fractionalWidth(0.45)
                groupHeight = .absolute(270)
                orthogonalBehavior = .continuous
            }
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            
            let item = NSCollectionLayoutItem(
                layoutSize: itemSize
            )
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: groupWidth,
                heightDimension: groupHeight
            )
            
            let group: NSCollectionLayoutGroup
            
            if isVerticalScrolling {
                
                group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitem: item,
                    count: 2
                )
                
                group.interItemSpacing = .fixed(15)
                
            } else {
                
                group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
            }
            
            let section = NSCollectionLayoutSection(
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
            
            section.orthogonalScrollingBehavior =
                orthogonalBehavior
            
            let headerSize = NSCollectionLayoutSize(
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
        
        return layout
    }
    
    // MARK: - API Parse
    
    func fetchProducts() {
        
        ProductViewModel.sharedInstance.ProductAPI {
            [weak self] success, failure in
            
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                
                if let success = success {
                    
                    let groupedDictionary =
                        Dictionary(
                            grouping: success.products,
                            by: { $0.category }
                        )
                    
                    self.sections =
                        groupedDictionary.map {
                            ProductSection(
                                category: $0.key,
                                products: $0.value
                            )
                        }
                    
                    self.sections.sort {
                        $0.category < $1.category
                    }
                    
                    self.productCollectionTable.reloadData()
                    
                } else if let failure = failure {
                    
                    print("Error:", failure)
                }
            }
        }
    }
    
    // MARK: - Add Product To Cart API
    
    private func addProductToCart(_ product: Product) {
        
        print("🛒 Adding product to cart via API")
        print("Product ID:", product.id)
        
        let userID = 1
        
        AddToCartViewModel.sharedInstance.addToCart(
            productID: product.id,
            userID: userID,
            quantity: 1,
            completionHandler: {
                [weak self]
                (response: AddToCartResponse?, error: String?) in
                
                DispatchQueue.main.async {
                    
                    if let response = response {
                        
                        print(
                            "✅ Product added to server cart. Cart ID:",
                            response.id
                        )
                        
                    } else {
                        
                        print(
                            "❌ Add to cart API failed:",
                            error ?? "Unknown error"
                        )
                    }
                }
            }
        )
    }
    
    // MARK: - Update Heart
    
    private func updateHeart(
        for button: UIButton,
        productID: Int
    ) {
        
        let isLiked =
            DatabaseManager.shared.isProductInCart(
                productID: productID
            )
        
        button.tintColor = .systemPink
        
        if isLiked {
            
            button.setImage(
                UIImage(systemName: "heart.fill"),
                for: .normal
            )
            
        } else {
            
            button.setImage(
                UIImage(systemName: "heart"),
                for: .normal
            )
        }
        
        button.setTitle("", for: .normal)
    }
}

// MARK: - UICollectionView

extension ViewController:
    UICollectionViewDelegate,
    UICollectionViewDataSource {
    
    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        
        return sections.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        return sections[section].products.count
    }
    
    // MARK: - Select Product
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        let currentSection =
            sections[indexPath.section]
        
        let selectedProduct =
            currentSection.products[indexPath.item]
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        
        detailVC.product = selectedProduct
        detailVC.sectionTitle = currentSection.category
        
        navigationController?.pushViewController(detailVC,animated: true)}
    
    // MARK: - Cell For Item
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "CollectionViewCell",
                    for: indexPath
                ) as? CollectionViewCell else {
            
            return UICollectionViewCell()
        }
        
        let product =
            sections[indexPath.section].products[indexPath.item]
        
        cell.product = product
        
        // MARK: Product Data
        
        cell.titleLBL.text = product.title
        
        cell.ratingLBL.text =
            "$\(product.price)"
        
        cell.descriptionLBL.text =
            product.description
        
        // MARK: Product Image
        
        if !product.thumbnail.isEmpty,
           let imageURL =
            URL(string: product.thumbnail) {
            
            cell.productIMG.kf.setImage(
                with: imageURL,
                placeholder: UIImage(systemName: "photo")
            )
            
        } else {
            
            cell.productIMG.image =
                UIImage(systemName: "photo")
        }
        
        cell.productIMG.clipsToBounds = true
        
        // MARK: Image Content Mode
        
        if indexPath.section == 0 ||
            indexPath.section == 1 ||
            indexPath.section == 2 {
            
            cell.productIMG.contentMode =
                .scaleAspectFit
            
        } else {
            
            cell.productIMG.contentMode =
                .scaleAspectFill
        }
        
        // MARK: - IMPORTANT
        // Set heart every time cell is reused
        
        updateHeart(
            for: cell.likeButton,
            productID: product.id
        )
        
        // MARK: - LIKE BUTTON ACTION
        
        cell.likeProductAction = {
            [weak self, weak cell]
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
                    productID: productID
                )
            
            if isAlreadyInCart {
                
                // MARK: REMOVE
                
                database.deleteCartProduct(
                    productID: productID
                )
                
                print(
                    "💔 Product removed from SQLite:",
                    selectedProduct.title
                )
                
            } else {
                
                // MARK: ADD
                
                let itemToSave =
                    CartProduct(
                        id: selectedProduct.id,
                        title: selectedProduct.title,
                        price: selectedProduct.price,
                        quantity: 1,
                        total: selectedProduct.price,
                        discountPercentage: 0.0,
                        discountedTotal: 0.0,
                        thumbnail: selectedProduct.thumbnail
                    )
                
                database.saveCartProduct(
                    itemToSave
                )
                
                print(
                    "❤️ Product added to SQLite:",
                    selectedProduct.title
                )
                
                // Add to server cart
                self?.addProductToCart(
                    selectedProduct
                )
            }
            
            // MARK: Update Heart
            
            self?.updateHeart(
                for: cell.likeButton,
                productID: productID
            )
        }
        
        return cell
    }
    
    // MARK: - Section Header
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        if kind ==
            UICollectionView.elementKindSectionHeader {
            
            guard let header =
                    collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: "SectionHeaderView",
                        for: indexPath
                    ) as? SectionHeaderView else {
                
                return UICollectionReusableView()
            }
            
            let currentSection =
                sections[indexPath.section]
            
            header.titleLabel.text =
                currentSection.category.capitalized
            
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
                    currentSection.category.capitalized
                
                self.navigationController?.pushViewController(
                    detailVC,
                    animated: true
                )
            }
            
            return header
        }
        
        return UICollectionReusableView()
    }
}

// MARK: - Reusable Header View

class SectionHeaderView: UICollectionReusableView {
    
    let titleLabel = UILabel()
    let seeMoreButton = UIButton(type: .system)
    
    var seeMoreAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(seeMoreButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        seeMoreButton.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font =
            UIFont.boldSystemFont(ofSize: 22)
        
        titleLabel.textColor =
            .black
        
        seeMoreButton.setTitle(
            "See More >>",
            for: .normal
        )
        
        seeMoreButton.titleLabel?.font =
            UIFont.systemFont(
                ofSize: 14,
                weight: .semibold
            )
        
        seeMoreButton.setTitleColor(
            .systemBlue,
            for: .normal
        )
        
        seeMoreButton.addTarget(
            self,
            action: #selector(seeMoreTapped),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 15
            ),
            
            titleLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),
            
            seeMoreButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -15
            ),
            
            seeMoreButton.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),
            
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo:
                    seeMoreButton.leadingAnchor,
                constant: -10
            )
        ])
    }
    
    @objc private func seeMoreTapped() {
        seeMoreAction?()
    }
    
    required init?(coder: NSCoder) {
        fatalError(
            "init(coder:) has not been implemented"
        )
    }
}
