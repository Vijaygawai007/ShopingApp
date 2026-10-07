
//
//  Onboarding_ViewController.swift
//  ShopingApp
//

import UIKit

final class Onboarding_ViewController: UIViewController {

    // MARK: - Data

    private let images = [
        "Shopping App Onboarding Carousel",
        "Shopping App Onboarding Carousel (2)",
        "Shopping App Onboarding Carousel (1)"
    ]

    private let titles = [
        "Shop Your Favourite Products",
        "Fast & Reliable Delivery",
        "Easy & Secure Shopping"
    ]

    private let subtitles = [
        "Find your favourite products easily.",
        "Fast & Reliable Delivery",
        "Easy & Secure Shopping"
    ]

    // MARK: - Outlets

    @IBOutlet private weak var boarding_Table: UICollectionView!

    // MARK: - Programmatic Page Control

    private let pageControl: UIPageControl = {

        let pageControl = UIPageControl()

        pageControl.translatesAutoresizingMaskIntoConstraints = false

        pageControl.numberOfPages = 0
        pageControl.currentPage = 0

        pageControl.currentPageIndicatorTintColor = .systemPink
        pageControl.pageIndicatorTintColor = .systemGray

        pageControl.hidesForSinglePage = true
        pageControl.isUserInteractionEnabled = true

        return pageControl
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupPageControl()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updatePageControl()
    }

    // MARK: - Collection View Setup

    private func setupCollectionView() {

        boarding_Table.delegate = self
        boarding_Table.dataSource = self

        boarding_Table.isPagingEnabled = true

        boarding_Table.showsHorizontalScrollIndicator = false
        boarding_Table.showsVerticalScrollIndicator = false

        boarding_Table.contentInset = .zero

        if let layout = boarding_Table.collectionViewLayout
            as? UICollectionViewFlowLayout {

            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
    }

    // MARK: - Page Control Setup

    private func setupPageControl() {

        // Add Page Control programmatically
        view.addSubview(pageControl)

        // Number of dots = number of collection view cells
        pageControl.numberOfPages = images.count

        pageControl.currentPage = 0

        // Position Page Control
        NSLayoutConstraint.activate([

            pageControl.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            pageControl.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            ),

            pageControl.heightAnchor.constraint(
                equalToConstant: 30
            ),

            pageControl.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 100
            )
        ])

        // Make sure Page Control is above Collection View
        view.bringSubviewToFront(pageControl)

        print("✅ Page Control created programmatically")
        print("✅ Number of pages: \(images.count)")
    }

    // MARK: - Update Page Control

    private func updatePageControl() {

        guard !images.isEmpty else {
            return
        }

        let pageWidth = boarding_Table.bounds.width

        guard pageWidth > 0 else {
            return
        }

        let currentPage = Int(
            round(
                boarding_Table.contentOffset.x / pageWidth
            )
        )

        let safePage = max(
            0,
            min(
                currentPage,
                images.count - 1
            )
        )

        if pageControl.currentPage != safePage {

            pageControl.currentPage = safePage
        }
    }

    // MARK: - Page Control Action

    @objc private func pageControlChanged(
        _ sender: UIPageControl
    ) {

        guard sender.currentPage >= 0,
              sender.currentPage < images.count else {
            return
        }

        let indexPath = IndexPath(
            item: sender.currentPage,
            section: 0
        )

        boarding_Table.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
    }

    // MARK: - Login Navigation

    private func navigateToLogin() {

        print("➡️ Opening LoginViewController")

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        guard let loginVC = storyboard.instantiateViewController(
            withIdentifier: "LoginViewController"
        ) as? LoginViewController else {

            print("❌ LoginViewController not found")
            print("❌ Check Storyboard ID: LoginViewController")

            return
        }

        guard let navigationController = navigationController else {

            print("❌ NavigationController not found")

            return
        }

        print("✅ Pushing LoginViewController")

        navigationController.pushViewController(
            loginVC,
            animated: true
        )
    }
}

// MARK: - Boarding Collection Cell Delegate

extension Onboarding_ViewController: BoardingCollectionViewCellDelegate {

    func didTapGetStarted() {

        print("✅ Get Started button tapped")

        navigateToLogin()
    }
}

// MARK: - UICollectionViewDataSource

extension Onboarding_ViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        return images.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "BoardingCollectionViewCell",
            for: indexPath
        ) as? BoardingCollectionViewCell else {

            return UICollectionViewCell()
        }

        // MARK: Image

        cell.boarding_IMG.image = UIImage(
            named: images[indexPath.item]
        )

        // MARK: Title

        cell.onBoardingLBL.text =
            titles[indexPath.item]

        // MARK: Subtitle

        cell.onBoarding_SubLBL.text =
            subtitles[indexPath.item]

        // MARK: Get Started Button

        let isLastPage =
            indexPath.item == images.count - 1

        cell.getStarted_BTN.isHidden =
            !isLastPage

        // MARK: Delegate

        cell.delegate = self

        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension Onboarding_ViewController {

    func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {

        updatePageControl()
    }

    func scrollViewDidEndDecelerating(
        _ scrollView: UIScrollView
    ) {

        updatePageControl()
    }

    func scrollViewDidEndScrollingAnimation(
        _ scrollView: UIScrollView
    ) {

        updatePageControl()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension Onboarding_ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        return collectionView.bounds.size
    }
}
