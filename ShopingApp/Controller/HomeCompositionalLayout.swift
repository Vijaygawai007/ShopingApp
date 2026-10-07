//
//  HomeCompositionalLayout.swift
//  ShopingApp
//
//  Created by Vijay on 04/10/26.
//

//
//  HomeCompositionalLayout.swift
//  ShopingApp
//

import UIKit

/// Defines the home collection view's section layouts.
enum HomeCompositionalLayout {

    static func create(
        sectionCount: @escaping () -> Int,
        onFeaturedPageChanged: @escaping (Int) -> Void
    ) -> UICollectionViewLayout {

        let layout =
            UICollectionViewCompositionalLayout {

                sectionIndex,
                layoutEnvironment
                -> NSCollectionLayoutSection? in

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
                            heightDimension: .absolute(200)
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
                        visibleItems,
                        point,
                        environment in

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
                            onFeaturedPageChanged(currentPage)
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
                            widthDimension: .absolute(110),
                            heightDimension: .absolute(40)
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

                guard productSectionIndex < sectionCount()
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
                        .absolute(250)

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




}
