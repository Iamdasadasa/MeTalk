//
//  Me2TalkUserListViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/02.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import Photos

class MeTalkProfileViewController:UIViewController{
    ///認証状態をリッスンする変数定義
    var handle:AuthStateDidChangeListenerHandle?
    ///UID格納変数
    var UID:String?
    ///カメラピッカーの定義
    let picker = UIImagePickerController()
    ///インスタンス化（View）
    let meTalkProfileView = MeTalkProfileView()
    ///インスタンス化（Model）
    let storage = Storage.storage()
    let host = "gs://metalk-f132e.appspot.com"
    
    override func viewDidLoad() {
        self.view = meTalkProfileView
        ///デリゲート委譲
        meTalkProfileView.delegate = self
    }
    ///※リスナーハンドラーを使用して画面が表示される前にUIDを取ってくる※
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            self.UID = user?.uid
            ///自身のプロフィール画像を取ってくる
            self.contentOfFIRStorage(callback: { image in
                self.meTalkProfileView.profileImageButton.setImage(image, for: .normal)
            })
        }
    }
    ///リスナーの破棄
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            Auth.auth().removeStateDidChangeListener(handle!)
        }
    
}

///※MeTalkProfileViewから受け取ったデリゲート処理※
extension MeTalkProfileViewController:MeTalkProfileViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    
    ///プロフィール画像タップ後の処理
    /// - Parameters:
    /// - Returns: none
    func profileImageButtonTappedDelegate() {
        picker.delegate = self
        ///強制的にアルバム
        picker.sourceType = .photoLibrary
        ///カメラピッカー表示
        self.present(picker, animated: true, completion: nil)
    }
    
    ///カメラピッカーでキャンセルを押下した際の処理（デリゲートなので自動で呼ばれる）
    /// - Parameters:
    ///- picker: UIImagePickerController
    /// - Returns: none
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        ///表示していたカメラピッカーViewを閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    
    ///カメラピッカーで写真が選択された際の処理（デリゲートなので自動で呼ばれる）
    /// - Parameters:
    ///- picker: UIImagePickerController
    ///- info: おそらく選択されたイメージ
    /// - Returns: none
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let pickerImage = info[.originalImage] as? UIImage{
            var UIimageView = UIImageView()
            UIimageView.image = pickerImage
            ///pickerImageを使用した処理
            ///プロフィールイメージ投稿Model
            guard let UID = UID else { return }
            let profileImageData = ProfileImageData(userUID: UID, profileImageView: UIimageView)
            profileImageData.uploadImage()
            
            ///カメラピッカーを表示して画像を送信した後にどうしてもこの処理を書きたい
            UIimageView = profileImageData.imageCompressionReturn()
            self.meTalkProfileView.profileImageButton.setImage(UIimageView.image, for: .normal)
            
            ///閉じる
            self.dismiss(animated: true, completion: nil)
        }
    }
    ///開発用　サインアウトボタンタップ時の挙動
    func signoutButtonTappedDelegate() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("SignOut Error: %@", signOutError)
        }
    }
}


extension MeTalkProfileViewController{
    ///カメラピッカーで写真が選択された際の処理（デリゲートなので自動で呼ばれる）
    /// - Parameters:none
    /// - Returns:
    ///- callback: Fire Baseから取得したイメージデータ
    func contentOfFIRStorage(callback: @escaping (UIImage?) -> Void) {
        guard let UID = self.UID else { return }
        ///Firebaseのストレージアクセス
        storage.reference(forURL: host).child("profileImage").child("\(UID).jpeg")
            .getData(maxSize: 1024 * 1024 * 10) { (data: Data?, error: Error?) in
            ///ユーザーIDのプロフィール画像を設定していなかったら初期画像を設定
            if error != nil {
                self.meTalkProfileView.profileImageButton.setImage(UIImage(named: "InitIMage"), for: .normal)
                print(error.debugDescription)
                return
            }
            ///ユーザーIDのプロフィール画像を設定していたらその画像を取得してリターン
            if let imageData = data {
                let image = UIImage(data: imageData)
                callback(image)
            }
        }
    }
    
}
