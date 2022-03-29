//
//  NotificationController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/08.
//

import Foundation
import UIKit
import FloatingPanel
import Firebase


class ChatUserListViewController:UIViewController{
    ///インスタンス化(View)
    let ChatUserListTableView = GeneralTableView()
    ///インスタンス化(Model)
    let meInfo = UserDataManagedData()
    ///自身のユーザー情報格納変数
    var meInfoData:[String:Any]?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view = ChatUserListTableView
        self.view.backgroundColor = .black
        ChatUserListTableView.dataSource = self
        ChatUserListTableView.delegate = self
        ChatUserListTableView.allowsSelection = false
        ChatUserListTableView.register(chatUserListTableViewCell.self, forCellReuseIdentifier: "chatUserListTableViewCell")
        meInfo.userInfoDataGet(callback: { document in
            guard let document = document else {
                return
            }
            self.meInfoData = document
            self.ChatUserListTableView.allowsSelection = true
        }, UID: Auth.auth().currentUser?.uid)
        
        
        
    }

}

extension ChatUserListViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let menusectionitem = menuSectionItem(rawValue: section) else { return 0 }
        return menusectionitem.info.numberOfRowsInSection
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "chatUserListTableViewCell", for: indexPath ) as! chatUserListTableViewCell

      return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let MeUID = Auth.auth().currentUser?.uid
//        let userData = userInfo()
//        print(userData.nickName)

        
//       let chatViewController = ChatViewController(MeUID: <#T##String#>, YouUID: <#T##String#>)
    }
}
