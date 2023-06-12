//
//  showUserListVoewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/06/08.
//

import Foundation
import UIKit
import Firebase
import RealmSwift
import CoreAudio

struct ImageDataHolder{
    var targetUID:String?
    var UIImage:UIImage?
}

class showUserListViewController:UIViewController,UINavigationControllerDelegate{
    ///インスタンス化(View)
    let CHATUSERLISTTABLEVIEW = UITableView()
    let UID = Auth.auth().currentUser?.uid
    
    let LOCALPROFILE:localProfileDataStruct
    let TALKDATAHOSTING:TalkDataHostingManager = TalkDataHostingManager()
    let CONTENTSHOSTING:ContentsDatahosting = ContentsDatahosting()
    var gettingDataCounter = 0
    var gettingDataCountKeeper = 0
    var LOCALUSERSPROFILEARRAY:[profileInfoLocal] = []
    var ImageDataArray:[ImageDataHolder] = []
    ///画像データ用のキャッシュ
    let cache = NSCache<NSString, UIImage>()
    
    init() {
        self.LOCALPROFILE = localProfileDataStruct(UID:UID!)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.view = CHATUSERLISTTABLEVIEW
        ///テーブルビューのデリゲート処理
        CHATUSERLISTTABLEVIEW.dataSource = self
        CHATUSERLISTTABLEVIEW.delegate = self
        
        ///セルの登録
        CHATUSERLISTTABLEVIEW.register(UserListTableViewCell.self, forCellReuseIdentifier: "UserListTableViewCell")
        ///ユーザー情報取得
        userDataServerGetting()
    }
    

}

extension showUserListViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(LOCALUSERSPROFILEARRAY.count)
        return LOCALUSERSPROFILEARRAY.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///セルのインスタンス化
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell", for: indexPath ) as! UserListTableViewCell
        ///cellのインデックス番号の箇所のユーザー情報格納
        let PROFILEINFOLOCAL = LOCALUSERSPROFILEARRAY[indexPath.row]
        ///ユーザーUID取得
        guard let TARGETCELLID = PROFILEINFOLOCAL.lcl_UID else {
            cell.nickNameSetCell(Item: "不明なユーザー")
            return cell
        }
        ///基本情報設定
        let profileCompleteCell = usersProfileSetting(cell: cell,LOCALUSERSPROFILE: PROFILEINFOLOCAL)
        ///プロフィール画像設定
        userProfileImageDataSetting(cell: cell,TARGETCELLID: TARGETCELLID)
        
        return profileCompleteCell
    }
    
    /// セルのプロフィール画像設定(非同期処理のためセル返却は行わない)
    /// - Parameters:
    ///   - cell: cellForRowAtで処理する対象のセル
    ///   - TARGETCELLID: cellForRowAtで処理する対象のユーザーUID
    func userProfileImageDataSetting(cell:UserListTableViewCell,TARGETCELLID:String) {
        ///キャッシュ用に変換したID
        let cacheID = NSString(string: TARGETCELLID)
        ///キャッシュ画像設定
        if let cacheImage = cache.object(forKey: cacheID) {
            cell.talkListUserProfileImageView.image = cacheImage
        } else {
            ///キャッシュに存在していなければサーバー取得
            let TOOL = TIME()
            ///画像サーバーに対して画像取得要求
            self.CONTENTSHOSTING.ImageDataGetter(callback: { Image, err in
                cell.talkListUserProfileImageView.image = Image.profileImage
                ///キャッシュに保存
                self.cache.setObject(Image.profileImage, forKey: cacheID)
            }, UID: TARGETCELLID, UpdateTime: TOOL.pastTimeGet())
        }
    }
    
    /// ユーザープロフィール
    /// - Parameters:
    ///   - cell: cellForRowAtで処理する対象のセル
    ///   - LOCALUSERSPROFILE: cellForRowAtで処理する対象のユーザー情報
    /// - Returns: 基本情報の設定が完了したセル
    func usersProfileSetting(cell:UserListTableViewCell,LOCALUSERSPROFILE:profileInfoLocal) -> UserListTableViewCell{
        cell.nickNameSetCell(Item: "\(LOCALUSERSPROFILE.lcl_NickName)")
        cell.celluserStruct?.lcl_UID = LOCALUSERSPROFILE.lcl_UID
        
        return cell
    }
}

extension showUserListViewController {
    func userDataServerGetting() {
        TALKDATAHOSTING.newTalkUserListGetter(callback: { gettingData, Err in
            self.gettingDataCountKeeper = gettingData.count
            ///エラー時の処理
            if let Err = Err{
                self.err()
                return
            }
            for data in gettingData {
                self.LOCALUSERSPROFILEARRAY.append(data)
            }
            self.CHATUSERLISTTABLEVIEW.reloadData()
            
        }, getterCount: 15)
    }
    
    func err() {
        
    }
    
}
