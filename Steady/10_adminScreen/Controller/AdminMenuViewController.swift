//
//  adminMenuViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/10/18.
//

import Foundation
import UIKit

class AdminMenuViewController:UIViewController {
    ///Barボタンの設定(NavigationBar)
    var backButtonItem: UIBarButtonItem! // Backボタン
    
    var ADMINMENUCOUNTETSCOUNTGETTER = adminHostGetterManager()
    var PROFILEHOSTGETTER = ProfileHostGetter()
    var ADMINHOSTSETTER = adminHostSetterManager()
    var adminMenuView = AdminMenuView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///barボタン初期設定
        backButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem
        
        view = adminMenuView
        adminMenuView.delegate = self
        viewCounterSetUp()
    }
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
     }
    
    func viewCounterSetUp() {
        ///現在のメンバー数合計を取得
        ADMINMENUCOUNTETSCOUNTGETTER.memberCountGetter { count in
            
            if let baseTXT = self.adminMenuView.subscribeLabel.text {
                self.adminMenuView.subscribeLabel.numberOfLines = 0
                self.adminMenuView.subscribeLabel.text = "\(baseTXT)\n\(count)人"
            }
        }
        
        ///総チャットルーム数合計を取得
        ADMINMENUCOUNTETSCOUNTGETTER.chatCountGetter { count in
            if let baseTXT = self.adminMenuView.totalChatLabel.text {
                self.adminMenuView.totalChatLabel.numberOfLines = 0
                self.adminMenuView.totalChatLabel.text = "\(baseTXT)\n\(count)件"
            }

        }
    }
}
//Viewのボタンデリゲート
extension AdminMenuViewController:AdminMenuProtocol{
    
    func violationConfirmButtontappedAction() {
        let reportMemberTableViewController = ReportMemberTableViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(reportMemberTableViewController, animated: true)
    }
    
    func chatConfirmButtontappedAction() {
        
        PROFILEHOSTGETTER.mappingDataGetter(callback: { PROFILE, err in
            if err != nil {
                createSheet(for: .Completion(title: "UID取得時にエラーが発生しました。確認してください。", {}), SelfViewController: self)
                return
            }
            
            guard let safeProfile = realmMapping.profileDataMapping(PROFILE: PROFILE, VC: self) else {
                createSheet(for: .Completion(title: "安全なデータに変換できませんでした。", {}), SelfViewController: self)
                return
            }
            
            let tculCV = TargetChatUserListViewController(tabBarHeight: 0.0, SELFINFO: safeProfile, SELFIMAGEOBJECT: listUsersImageLocalObject(), dammyUserListFlag: false)
             self.navigationController?.pushViewController(tculCV, animated: true)

        }, UID: self.adminMenuView.UIDInputTxtField.text ?? "")

    }
    
    func createProfileButtontappedAction() {
        let tculCV =  AdminDammyProfileCreateViewController()
         self.navigationController?.pushViewController(tculCV, animated: true)
       
        return
    }
    
    func dammyChatButtontappedAction() {
        let dammySelf = RequiredProfileInfoLocalData(UID: "Yd7MNepBxzSc0p7bpp3LjcwSl1h2", DateCreatedAt: Date(), DateUpdatedAt: Date(), Sex: 1, AboutMeMassage: "", NickName: "", Age: 1, Area: "")
        let VC = AdminRegstedDammyUsersViewController(tabBarHeight: 0.0, SELFINFO:dammySelf )
        self.navigationController?.pushViewController(VC, animated: true)
        return
    }
    
    func dammyUserUpdateTimeReset() {
        ADMINHOSTSETTER.dammyUserUpdateTimeSetter { result in
            if result {
                createSheet(for: .Completion(title: "更新時間を最新にしました。", {}), SelfViewController: self)
            } else {
                createSheet(for: .Retry(title: "更新時間を最新にできませんでした。"), SelfViewController: self)
            }
        }
    }
}

