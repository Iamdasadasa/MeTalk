//
//  MainTabBarController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/02.
//

import Foundation
import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTab()
    }

    func setupTab() {
        let firstViewController = showUserListViewController(tabBarHeight: self.tabBar.frame.height)
        let UINavigationController_0 = UINavigationController(rootViewController: firstViewController)
        UINavigationController_0.modalPresentationStyle = .fullScreen
        UINavigationController_0.tabBarItem = UITabBarItem(title: "tab1", image: .none, tag: 0)

        let secondViewController = ChatUserListViewController()
        let UINavigationController_1 = UINavigationController(rootViewController: secondViewController)
        UINavigationController_1.modalPresentationStyle = .fullScreen
        UINavigationController_1.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
        
        let thirdViewController = ProfileViewController()
        thirdViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)

        viewControllers = [UINavigationController_0, UINavigationController_1, thirdViewController]
    }

}
