//
//  showImageViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/04.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import Photos

class ShowImageViewController:UIViewController{
//    ///認証状態をリッスンする変数定義
//    var handle:AuthStateDidChangeListenerHandle?
//    ///UID格納変数
//    var UID:String?
    ///インスタンス化(Controller)
    var contentVC:UIViewController?
    ///インスタンス化（View）
    let showImageView = ShowImageView()
    ///インスタンス化（Model）
    let userDataManagedData = UserDataManage()
    let storage = Storage.storage()
    let host = "gs://metalk-f132e.appspot.com"
    let uid = Auth.auth().currentUser?.uid
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ///自身のプロフィール画像を取ってくる
        self.userDataManagedData.contentOfFIRStorageGet(callback: { imageStruct in
            ///Nilでない場合はコールバック関数で返ってきたイメージ画像をオブジェクトにセット
            if imageStruct.image != nil {
                self.showImageView.imageView.image = imageStruct.image
            ///コールバック関数でNilが返ってきたら初期画像を設定
            } else {
                self.showImageView.imageView.image = UIImage(named: "InitIMage")
            }
        }, UID: uid, UpdateTime: ChatDataManagedData.pastTimeGet())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        self.view = showImageView
    }
    
}
