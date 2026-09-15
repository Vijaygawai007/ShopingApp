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
        
        // 1. Apply the Compositional Layout to the Collection View
        productCollectionTable.collectionViewLayout = createCompositionalLayout()
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        productCollectionTable.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
        
        // Register the Header View
        productCollectionTable.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        
        fetchProducts()
    }
    
    // MARK: - Compositional Layout
    private func createCompositionalLayout() -> UICollectionViewLayout {
        // Use [weak self] so we can safely access our `sections` array if needed
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let _ = self else { return nil }
            
            // Layout configuration variables
            var groupWidth: NSCollectionLayoutDimension
            var groupHeight: NSCollectionLayoutDimension // <-- ADDED FOR DYNAMIC HEIGHT
            var orthogonalBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
            var isVerticalScrolling: Bool = false
            
            // 1. --- SECTION-WISE BEHAVIOR, WIDTH, & HEIGHT LOGIC ---
            if sectionIndex == 0 {
                // Section 0: Horizontal Scrolling
                groupWidth = .fractionalWidth(0.90)
                groupHeight = .absolute(220) // Reduced height for section 0
                orthogonalBehavior = .groupPaging
                
            } else if sectionIndex == 1 {
                // Section 1: Vertical Scrolling
                groupWidth = .fractionalWidth(1.0)
                groupHeight = .absolute(260) // Different height for section 1
                orthogonalBehavior = .none
                isVerticalScrolling = true
                
            } else if sectionIndex == 2 {
                // Section 2: Vertical Scrolling
                groupWidth = .fractionalWidth(1.0)
                groupHeight = .absolute(260) // Different height for section 2
                orthogonalBehavior = .none
                isVerticalScrolling = true
                
            } else if sectionIndex == 3 {
                // Section 3: Horizontal Scrolling
                groupWidth = .fractionalWidth(0.90)
                groupHeight = .absolute(290) // Smallest height for section 3
                orthogonalBehavior = .continuous
                
            } else {
                // All other sections: Default
                groupWidth = .fractionalWidth(0.45)
                groupHeight = .absolute(270) // Default height
                orthogonalBehavior = .continuous
                
            }
            
            // 2. Item Setup
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // 3. Group Setup (Apply the dynamic height here)
            let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth,
                                                   heightDimension: groupHeight) // <-- CHANGED
            let group: NSCollectionLayoutGroup
            
            if isVerticalScrolling {
                // If it's a vertical section, create a 2-column grid
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
                group.interItemSpacing = .fixed(15) // Space between the 2 columns
            } else {
                // If it's a horizontal section, behave normally
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            }
            
            // 4. Section Setup
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 15
            section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
            
            // Apply the scrolling behavior decided above
            section.orthogonalScrollingBehavior = orthogonalBehavior
            
            // 5. Header Setup
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        return layout
    }
    
    // MARK: - API Parse
    func fetchProducts() {
        ProductViewModel.sharedInstance.ProductAPI { [weak self] success, failure in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let success = success {
                    let groupedDictionary = Dictionary(grouping: success.products, by: { $0.category })
                    self.sections = groupedDictionary.map { ProductSection(category: $0.key, products: $0.value) }
                    self.sections.sort { $0.category < $1.category }
                    
                    self.productCollectionTable.reloadData()
                } else if let failure = failure {
                    print("Error:", failure)
                }
            }
        }
    }
    
    
    // MARK: - Add Product To Cart
    
    private func addProductToCart(_ product: Product) {
        
        print("🛒 Adding product to cart")
        print("Product ID:", product.id)
        print("Product Name:", product.title)
        
        let userID = 1
        
        addToCartViewModel.sharedInstance.addToCart(
            productID: product.id,
            userID: userID,
            quantity: 1
        ) { [weak self] response, error in
            
            DispatchQueue.main.async {
                
                if let response = response {
                    
                    print("✅ Product added to cart")
                    print("Cart ID:", response.id)
                    
//                    let alert = UIAlertController(
//                        title: "Added to Cart",
//                        message: "\(product.title) added successfully.",
//                        preferredStyle: .alert
//                    )
                    
//                    alert.addAction(
//                        UIAlertAction(
//                            title: "OK",
//                            style: .default
//                        )
//                    )
                    
//                    self?.present(alert, animated: true)
                    
                } else {
                    
                    print("❌ Add to cart failed")
                    print("Error:", error ?? "Unknown error")
                    
                    let alert = UIAlertController(
                        title: "Error",
                        message: error ?? "Unable to add product.",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: .default
                        )
                    )
                    
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}
// MARK: - UICollectionView Extension
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].products.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentSection = sections[indexPath.section]
            let selectedProduct = currentSection.products[indexPath.item]
            
            guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
                return
            }
            
            // Pass the selected product and section title
            detailVC.product = selectedProduct
            detailVC.sectionTitle = currentSection.category
            
            navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CollectionViewCell",
            for: indexPath
        ) as? CollectionViewCell else {
            return UICollectionViewCell()
        }

        let product = sections[indexPath.section].products[indexPath.item]

        // IMPORTANT:
        // Tell the cell which product it is displaying
        cell.product = product

        cell.titleLBL.text = product.title
        cell.ratingLBL.text = "$\(product.price)"
        cell.descriptionLBL.text = product.description

        if let imageURL = URL(string: product.thumbnail) {
            cell.productIMG.kf.setImage(with: imageURL)
        }

        cell.productIMG.clipsToBounds = true

        if indexPath.section == 0 {
            cell.productIMG.contentMode = .scaleAspectFit
        } else if indexPath.section == 1 {
            cell.productIMG.contentMode = .scaleAspectFit
        } else if indexPath.section == 2 {
            cell.productIMG.contentMode = .scaleAspectFit
        } else if indexPath.section == 3 {
            cell.productIMG.contentMode = .scaleAspectFill
        } else {
            cell.productIMG.contentMode = .scaleAspectFill
        }
        

        // IMPORTANT:
        // Remove old closure because cells are reused
        cell.likeProductAction = { [weak self] selectedProduct in

            guard let self = self else { return }

            self.addProductToCart(selectedProduct)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as? SectionHeaderView else {
                return UICollectionReusableView()
            }
            
            // Get the current section data
            let currentSection = sections[indexPath.section]
            header.titleLabel.text = currentSection.category.capitalized
            
            // Handle the See More button tap
            header.seeMoreAction = { [weak self] in
                guard let self = self else { return }
                
                print("See More tapped for category: \(currentSection.category)")
                
                // --- Navigation Action ---
                let detailVC = UIViewController()
                detailVC.view.backgroundColor = .white
                detailVC.title = currentSection.category.capitalized
                
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
            
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - Reusable Header View Class
class SectionHeaderView: UICollectionReusableView {
    let titleLabel = UILabel()
    let seeMoreButton = UIButton(type: .system)
    
    // Closure to handle button taps in the ViewController
    var seeMoreAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(seeMoreButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        seeMoreButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Title Label Styling
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = .black
        
        // See More Button Styling
        seeMoreButton.setTitle("See More >>", for: .normal)
        seeMoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        seeMoreButton.setTitleColor(.systemBlue, for: .normal)
        
        // Button Target
        seeMoreButton.addTarget(self, action: #selector(seeMoreTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // Title Label Constraints (Pinned to left)
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // See More Button Constraints (Pinned to right)
            seeMoreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            seeMoreButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Prevent title from overlapping the button if text is too long
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: seeMoreButton.leadingAnchor, constant: -10)
        ])
    }
    
    @objc private func seeMoreTapped() {
        seeMoreAction?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
