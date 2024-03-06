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
        
        ///FCMトークン（通知用トークン）の更新
        let TokenSetterManager = nortificationSetterManager()
        TokenSetterManager.tokenSetter(callback: { result in
            if result {
                self.setupTab()
            } else {
                createSheet(for: .Completion(title: "初期処理に失敗しました。通知が行えません(エラー:通知トークン取得不可)", {
                    self.setupTab()
                    return
                }), SelfViewController: self)
            }

        }, UID: SELFINFO.Required_UID)
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
        
        //一つ目のタブ
        let firstViewController = showUserListViewController(tabBarHeight: self.tabBar.frame.height, SELFINFO: SELFINFO)
        let firstUINavivationContoroller = UINavigationController(rootViewController: firstViewController)
        firstUINavivationContoroller.modalPresentationStyle = .fullScreen
        firstUINavivationContoroller.tabBarItem = UITabBarItem(title: "", image: nonSelectedTabImage01, tag: 0)
        
        //二つ目のタブ
        let secondViewController = ChatUserListViewController(tabBarHeight: self.tabBar.frame.height, SELFINFO: SELFINFO)
        ///delegate適用
        secondViewController.delegate = self
        ///リストに関してはここでセットアップ処理として開始する
        secondViewController.setUp()
        let secondUINavigationController = UINavigationController(rootViewController: secondViewController)
        secondUINavigationController.modalPresentationStyle = .fullScreen
        secondUINavigationController.tabBarItem = UITabBarItem(title: "", image: nonSelectedTabImage02, tag: 1)
        ///変数に格納
        secondVC = secondUINavigationController
        
        //三つ目のタブ
        let thirdViewControllerViewController = PublicRoomChatListViewController(tabBarHeight: self.tabBar.frame.height, SELFINFO: SELFINFO)
        let thirdUINavivationContoroller = UINavigationController(rootViewController: thirdViewControllerViewController)
        thirdUINavivationContoroller.modalPresentationStyle = .fullScreen
        thirdUINavivationContoroller.tabBarItem = UITabBarItem(title: "", image: nonSelectedTabImage01, tag: 2)
        
        //四つ目のタブ
        let fourthViewController = ProfileViewController(TARGETINFO: SELFINFO, SELFINFO: SELFINFO, TARGETIMAGE: nil)
        fourthViewController.tabBarItem = UITabBarItem(title: "", image: nonSelectedTabImage03, tag: 3)
        
        ///背景色変更
        self.tabBar.barTintColor = UIColor.white
        ///選択中の色の画像設定
        firstUINavivationContoroller.tabBarItem.selectedImage = SelectedtabImage01
        secondUINavigationController.tabBarItem.selectedImage = SelectedtabImage02
        fourthViewController.tabBarItem.selectedImage = SelectedtabImage03
        
        viewControllers = [firstUINavivationContoroller, secondUINavigationController,thirdUINavivationContoroller, fourthViewController]
    }

}


extension MainTabBarController:ChatUserListVCForMeinTabBarVCDelegate {
    func listnerDelegate(SelectedChatVC:Bool) {
        tabBarNortificationIconSet(SelectedChatVC: SelectedChatVC)
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
    
}
