//
//  tabbarViewController.swift
//  ShopingApp
//

import UIKit

class tabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("✅ TAB BAR LOADED")

        setupTabs()
    }

    private func setupTabs() {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        // MARK: - HOME

        guard let homeVC = storyboard.instantiateViewController(
            withIdentifier: "ViewController"
        ) as? ViewController else {

            print("❌ HOME FAILED")
            print("❌ Check Storyboard ID: ViewController")

            return
        }

        print("✅ HOME CREATED")

        let homeNavigationController =
            UINavigationController(
                rootViewController: homeVC
            )

        homeNavigationController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )


        // MARK: - CART

        guard let cartVC = storyboard.instantiateViewController(
            withIdentifier: "CartViewController"
        ) as? CartViewController else {

            print("❌ CART FAILED")
            print("❌ Check Storyboard ID: CartViewController")

            return
        }

        print("✅ CART CREATED")

        let cartNavigationController =
            UINavigationController(
                rootViewController: cartVC
            )

        cartNavigationController.tabBarItem = UITabBarItem(
            title: "Cart",
            image: UIImage(systemName: "cart"),
            selectedImage: UIImage(systemName: "cart.fill")
        )


        // MARK: - ORDERS

        guard let ordersVC = storyboard.instantiateViewController(
            withIdentifier: "MyOrders_ViewController"
        ) as? MyOrders_ViewController else {

            print("❌ ORDERS FAILED")
            print("❌ Check Storyboard ID: OrderViewController")
            print("❌ Check Class: MyOrders_ViewController")

            return
        }

        print("✅ ORDERS CREATED")

        let ordersNavigationController =
            UINavigationController(
                rootViewController: ordersVC
            )

        ordersNavigationController.tabBarItem = UITabBarItem(
            title: "Orders",
            image: UIImage(systemName: "bag"),
            selectedImage: UIImage(systemName: "bag.fill")
        )


        // MARK: - PROFILE

        guard let profileVC = storyboard.instantiateViewController(
            withIdentifier: "profileViewController"
        ) as? profileViewController else {

            print("❌ PROFILE FAILED")
            print("❌ Check Storyboard ID: profileViewController")

            return
        }

        print("✅ PROFILE CREATED")

        let profileNavigationController =
            UINavigationController(
                rootViewController: profileVC
            )

        profileNavigationController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )


        // MARK: - SET TABS

        viewControllers = [
            homeNavigationController,
            cartNavigationController,
            ordersNavigationController,
            profileNavigationController
        ]

        selectedIndex = 0

        print("================================")
        print("✅ ALL 4 TABS CONFIGURED")
        print("================================")
    }
}
