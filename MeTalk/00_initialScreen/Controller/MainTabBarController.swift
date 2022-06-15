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
        let firstViewController = UserListViewController()
        firstViewController.tabBarItem = UITabBarItem(title: "tab1", image: .none, tag: 0)

        let secondViewController = ChatUserListViewController()
        let UINavigationController = UINavigationController(rootViewController: secondViewController)
        UINavigationController.modalPresentationStyle = .fullScreen
        UINavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
        
        let thirdViewController = ProfileViewController()
        thirdViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)

        viewControllers = [firstViewController, UINavigationController, thirdViewController]
    }

}
