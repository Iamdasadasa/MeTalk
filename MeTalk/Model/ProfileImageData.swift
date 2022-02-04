//
//  PrfileImageData.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/02.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
class ProfileImageData{
    
    init(userUID:String,profileImageView:UIImageView) {
        self.userUID = userUID
        self.profileImageView = profileImageView
    }
    
    let userUID:String
    let profileImageView:UIImageView
    
    func uploadImage () {
            //ストレージサーバのURLを取得
            let storage = Storage.storage().reference(forURL: "gs://metalk-f132e.appspot.com")
            
            // パス: あなた固有のURL/profileImage/{user.uid}.jpeg
            let imageRef = storage.child("profileImage").child("\(userUID).jpeg")
            
            //保存したい画像のデータを変数として持つ
            var ProfileImageData: Data = Data()
            
            //プロフィール画像が存在すれば
            if profileImageView.image != nil {
                
            //画像を圧縮
            ProfileImageData = (profileImageView.image?.jpegData(compressionQuality: 0.01))!
                
            }
            
            //storageに画像を送信
            imageRef.putData(ProfileImageData, metadata: nil) { (metaData, error) in
                
                //エラーであれば
                if error != nil {
                    
                    print(error.debugDescription)
                    return  //これより下にはいかないreturn
                    
                }
                
            }
            
        }
    
    func contentOfFIRStorage(callback: @escaping (UIImage?) -> Void) {
            let storage = Storage.storage()
            let host = "gs://metalk-f132e.appspot.com"
            storage.reference(forURL: host).child("profileImage").child("\(userUID).jpeg")
                .getData(maxSize: 1024 * 1024 * 10) { (data: Data?, error: Error?) in
                if error != nil {
                    callback(nil)
                    return
                }
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    callback(image)
                }
            }
    }
    
}
