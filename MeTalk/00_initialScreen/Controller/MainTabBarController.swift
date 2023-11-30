//
//  MainTabBarController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/02.
//

import Foundation
import UIKit

final class MainTabBarController: UITabBarController{

    let SELFINFO:RequiredProfileInfoLocalData
    let IMAGEOBJECT:listUsersImageLocalObject
    let messageChekingHostGetter = ChatListListenerManager()
    var secondVC:UIViewController?
    init(SELFINFO: RequiredProfileInfoLocalData,ImageLocalObject:listUsersImageLocalObject) {
        self.SELFINFO = SELFINFO
        self.IMAGEOBJECT = ImageLocalObject
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTab()
    }

    func setupTab() {
        ///選択されていない時（デフォルト）の画像
        let nonSelectedTabImage01 = UIImage().tabBarImageCreate(KIND: .nonSelectedTalk)
        let nonSelectedTabImage02 = UIImage().tabBarImageCreate(KIND: .nonSelectedCHAT)
        let nonSelectedTabImage03 = UIImage().tabBarImageCreate(KIND: .nonSelectedPROFILE)
        ///タブに設定する画像
        let SelectedtabImage01 = UIImage().tabBarImageCreate(KIND: .selectedTalk)
        let SelectedtabImage02 = UIImage().tabBarImageCreate(KIND: .selectedCHAT)
        let SelectedtabImage03 = UIImage().tabBarImageCreate(KIND: .selectedPROFILE)

        
        let firstViewController = showUserListViewController(tabBarHeight: self.tabBar.frame.height, SELFINFO: SELFINFO)
        let UINavigationController_0 = UINavigationController(rootViewController: firstViewController)
        UINavigationController_0.modalPresentationStyle = .fullScreen
        UINavigationController_0.tabBarItem = UITabBarItem(title: "", image: nonSelectedTabImage01, tag: 0)
        
        let secondViewController = ChatUserListViewController(tabBarHeight: self.tabBar.frame.height, SELFINFO: SELFINFO)
        ///delegate適用
        secondViewController.delegate = self
        checkNewMessage(secondVC: secondViewController)
        
        let UINavigationController_1 = UINavigationController(rootViewController: secondViewController)
        UINavigationController_1.modalPresentationStyle = .fullScreen
        UINavigationController_1.tabBarItem = UITabBarItem(title: "", image: nonSelectedTabImage02, tag: 1)
        //変数に格納
        secondVC = UINavigationController_1
        
        let thirdViewController = ProfileViewController(TARGETINFO: SELFINFO, SELFINFO: SELFINFO, TARGETIMAGE: nil)
        thirdViewController.tabBarItem = UITabBarItem(title: "", image: nonSelectedTabImage03, tag: 2)
        
        ///背景色変更
        self.tabBar.barTintColor = UIColor.white
        ///選択中の色の画像設定
        UINavigationController_0.tabBarItem.selectedImage = SelectedtabImage01
        UINavigationController_1.tabBarItem.selectedImage = SelectedtabImage02
        thirdViewController.tabBarItem.selectedImage = SelectedtabImage03
        
        viewControllers = [UINavigationController_0, UINavigationController_1, thirdViewController]
    }

}


extension MainTabBarController:ChatUserListVCForMeinTabBarVCDelegate {
    func listnerDelegate(SelectedChatVC:Bool) {
        tabBarNortificationIconSet(SelectedChatVC: SelectedChatVC)
        ///起動時のメッセージチェックのリスナーを破棄する
        messageChekingHostGetter.checkNewMessageLisnterRemover()
    }

    func tabBarNortificationIconSet(SelectedChatVC:Bool) {
        guard self.viewControllers != nil else {
            return
        }
        
        var selectedViewController:UIViewController? {
            get {
                return self.selectedViewController
            }
        }
        
        if SelectedChatVC {
            let image1 = UIImage().tabBarImageCreate(KIND: .selectedCHAT)
            let image2 = UIImage().tabBarImageCreate(KIND: .nonSelectedCHAT)
            secondVC?.tabBarItem.selectedImage = image1
            secondVC?.tabBarItem.image = image2
            return
        }
        
        guard let selectedViewController = selectedViewController else {
            let image = UIImage().tabBarImageCreate(KIND: .nonSelectedChatNortification)
            secondVC?.tabBarItem.selectedImage = image
            return
        }
        
        if selectedViewController.tabBarItem.tag == secondVC?.tabBarItem.tag {
            let image = UIImage().tabBarImageCreate(KIND: .selectedCHAT)
            secondVC?.tabBarItem.selectedImage = image
        } else {
            let image = UIImage().tabBarImageCreate(KIND: .nonSelectedChatNortification)
            secondVC?.tabBarItem.image = image
        }
    }
    
    func checkNewMessage(secondVC:ChatUserListViewController) {
        
        messageChekingHostGetter.checkNewMessage(callback: { result in
            if result {
                self.tabBarNortificationIconSet(SelectedChatVC: false)
            }
        }, UID: SELFINFO.Required_UID, greaterThanDate: secondVC.greaterThanOrEqualTime)
    }
    
}
