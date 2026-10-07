//
//  SceneDelegate.swift
//  ShopingApp
//
//  Created by Vijay on 01/09/26.
//

import UIKit
import Supabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        guard let onboardingVC = storyboard.instantiateViewController(
            withIdentifier: "Onboarding_ViewController"
        ) as? Onboarding_ViewController else {

            print("❌ Onboarding_ViewController not found")
            return
        }

        let navigationController = UINavigationController(
            rootViewController: onboardingVC
        )

        navigationController.setNavigationBarHidden(
            true,
            animated: false
        )

        let window = UIWindow(
            windowScene: windowScene
        )

        window.rootViewController = navigationController

        self.window = window

        window.makeKeyAndVisible()

        print("✅ SceneDelegate loaded")
        print("✅ Onboarding is root")
    }
}
