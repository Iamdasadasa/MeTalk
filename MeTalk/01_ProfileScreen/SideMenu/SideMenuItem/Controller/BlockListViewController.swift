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


class BlockListViewController:UIViewController{
    
    ///Barボタンの設定(NavigationBar)
    var backButtonItem: UIBarButtonItem! // Backボタン
    ///インスタンス化（View）
    let blockListTableView = UITableView()
    ///インスタンス化（Model）
    let CONTENTSGETTER = ContentsHostGetter()
    let CONTENTSSETTER = ContentsHostGetter()
    let PRLOFILEGETTER = ProfileHostGetter()
    let BLOCKLISTGETTER  = BlockHostGetterManager()
    let BLOCKHOSTSETTER = BlockHostSetterManager()
    let PROFILEIMAGEGETTER = ImageDataLocalGetterManager()
    let uid = Auth.auth().currentUser?.uid
    let TIMES = TIME()
    ///ブロックリストユーザーID格納配列
    var blockUsersArray:[RequiredProfileInfoLocalData] = [] {
        didSet {
            blockListTableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///Viewの適用
        self.view = blockListTableView
        self.view.backgroundColor = .white
        blockListTableView.dataSource = self
        blockListTableView.delegate = self
        blockListTableView.register(blockListTableViewCell.self, forCellReuseIdentifier: "BlockListTableViewCell")

        ///barボタン初期設定
        let barButtonArrowItem = barButtonItem(frame: .zero, BarButtonItemKind: .left)
        barButtonArrowItem.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        let customBarButtonItem = UIBarButtonItem(customView: barButtonArrowItem)
        self.navigationItem.leftBarButtonItem = customBarButtonItem
        navigationController?.navigationBar.barTintColor = UIColor.white
        ///タイトルラベル追加
        let titleLabel = UILabel()
        titleLabel.text = "ブロックリスト"
        titleLabel.textColor = UIColor.gray
        /// ナビゲーションバーのタイトルビューを設定
        self.navigationItem.titleView = titleLabel
        
        //ユーザー取得
        blockUserDataGetting()
        ///スワイプで前画面に戻れるようにする
        edghPanGestureSetting(selfVC: self, selfView: self.view,gestureDirection: .left)
    }
    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
     }

}

///TableView関連の処理
extension BlockListViewController:UITableViewDelegate,UITableViewDataSource{
    ///セクション数--ブロックユーザーの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockUsersArray.count
    }
    ///セルの高さ--固定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    ///セルの生成--ブロックユーザーの情報を取得してCELLオブジェクトに投入
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///対象セルインスタンス化
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockListTableViewCell", for: indexPath) as! blockListTableViewCell
        cell.delegate = self
    
        ///ブロックユーザーIDの配列から取得
        let blockProfile = blockUsersArray[indexPath.row]

        let Image = PROFILEIMAGEGETTER.getter(targetUID: blockProfile.Required_UID)
        //ニックネーム
        cell.UID = blockProfile.Required_UID
        cell.nickName = blockProfile.Required_NickName
        cell.blockUserNicknameLabel.text = blockProfile.Required_NickName
        cell.blockUserProfileImageView.image = Image?.profileImage

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func blockUserDataGetting() {
        BLOCKLISTGETTER.blockingUsersProfileGetter(callback: { array in
            guard let array = array else {
                return
            }
            self.blockUsersArray = array
        }, selfUID: uid!)
    }
    
}

extension BlockListViewController:blockListTableViewCellDelegate{

    func blockCanceldTapped(TARGETUID: String?, nickName: String?) {
        guard let UID = TARGETUID,let nickName = nickName else{
            createSheet(for: .Completion(title: "解除できませんでした。再度お試しください", {}), SelfViewController: self)
            return
        }
        
        BLOCKHOSTSETTER.blockingOperater(callback: { result in
            if result {
                createSheet(for: .Completion(title: "解除完了", {}), SelfViewController: self)
                //対象のセルを削除
                guard let index = self.blockUsersArray.firstIndex(where: { $0.Required_UID == TARGETUID }) else {
                    return
                }
                self.blockListTableView.beginUpdates()
                let indexPath = IndexPath(row: index, section: 0)
                self.blockUsersArray.remove(at: index)  // データソースから要素を削除
                self.blockListTableView.deleteRows(at: [indexPath], with: .automatic)
                self.blockListTableView.endUpdates()
                
                return
            } else {
                createSheet(for: .Completion(title: "解除できませんでした。再度お試しください", {}), SelfViewController: self)
                return
            }
        }, MyUID: uid!, targetUID: UID, block: false, nickname: nickName)
        
    }
}
