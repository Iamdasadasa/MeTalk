//
//  UserDataManage.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/14.
//

import Foundation
import Firebase
import FirebaseStorage


struct UserDataManagedData{
    let uid = Auth.auth().currentUser?.uid
    let cloudDB = Firestore.firestore()
    let storage = Storage.storage()
    let host = "gs://metalk-f132e.appspot.com"
    var DBRef:DatabaseReference = Database.database().reference()
    
    ///匿名登録処理で登録したユーザー情報を返す& DB登録も初回は一緒にやる
    func signInAnonymously(callback: @escaping (String?) -> Void,nickName:String?,SexNo:Int?) {
        ///引数のデータがどちらかでもNilだった場合Return
        guard let nickName = nickName,let SexNo  = SexNo else {
            return
        }
        ///匿名登録処理
        Auth.auth().signInAnonymously { authResult, error in
            ///匿名登録自体の失敗（Authentication）
            guard let user = authResult?.user else {
                callback("ユーザー登録処理で失敗しました\(error?.localizedDescription)")
                return
            }
            ///各登録処理（Cloud Firestore）
            Firestore.firestore().collection("users").document(user.uid).setData([
                "nickname": nickName,
                "Sex": SexNo,
                "aboutMeMassage":"よろしくお願いします( ∩'-' )=͟͟͞͞⊃",
                "area":"未設定",
                "age":0,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ], completion: { error in
                if let error = error {
                    ///失敗した場合
                    callback("ユーザー情報の登録処理で失敗しました\(error.localizedDescription)")
                    return
                } else {
                    ///成功した場合遷移
                    callback(nil)
                }
            })
        }
    }
    
    ///ユーザーIDを基にイメージデータを取得してくる処理
    /// - Parameters:
    /// - callback:ユーザーIDを基に取得できるImage
    /// - Returns:
    ///- callback: Fire Baseから取得したイメージデータ
    func contentOfFIRStorageGet(callback: @escaping (UIImage?) -> Void) {
        guard let UID = uid else { return }
        ///Firebaseのストレージアクセス
        storage.reference(forURL: host).child("profileImage").child("\(UID).jpeg")
            .getData(maxSize: 1024 * 1024 * 10) { (data: Data?, error: Error?) in
            ///ユーザーIDのプロフィール画像が取得できなかったらnilを返す
            if error != nil {
                callback(nil)
                print(error?.localizedDescription)
            }
            ///ユーザーIDのプロフィール画像を設定していたらその画像を取得してリターン
            if let imageData = data {
                let image = UIImage(data: imageData)
                callback(image)
            }
        }
    }
    
    ///ユーザーIDを基にイメージデータをアップロードして圧縮したファイルを返す処理
    /// - Parameters:none
    /// - Returns:
    ///- callback: Fire Baseから取得したイメージデータ
    func contentOfFIRStorageUpload (callback: @escaping (UIImage?) -> Void,UIimagedata:UIImageView) {
            guard let UID = uid else { return }
            //ストレージサーバのURLを取得
            let storage = Storage.storage().reference(forURL: "gs://metalk-f132e.appspot.com")
            
            // パス: あなた固有のURL/profileImage/{user.uid}.jpeg
            let imageRef = storage.child("profileImage").child("\(UID).jpeg")
            
            //保存したい画像のデータを変数として持つ
            var ProfileImageData: Data = Data()
            
            //プロフィール画像が存在すれば
            if UIimagedata.image != nil {
                //画像を圧縮
                ProfileImageData = (UIimagedata.image?.jpegData(compressionQuality: 0.01))!
            }
            
            //storageに画像を送信

            imageRef.putData(ProfileImageData, metadata: nil) { (metaData, error) in
                ///画像送信に失敗したら
                if let error = error {
                    //エラーであれば
                    print(error.localizedDescription)
                ///画像送信に成功したら、圧縮済みのイメージを返す
                } else {
                    callback(UIimagedata.image)
                }
            }
        }
    
    ///Cloud Fire DBにデータを登録
    func userInfoDataDBRegister() {
        
    }
    
    //    ///データ取得関数(コレクションは"Users")
    //    /// - Parameters:
    //    /// - callback:コールバック関数。document.dataはFirebaseのユーザーコレクション全体を返している
    //    /// 　　　　　　（ニックネーム、性別等が含まれる）
    //    /// - Returns:
        func userInfoDataGet(callback: @escaping  ([String:Any]?) -> Void) {
            guard let uid = uid else {
            print("UIDの取得ができませんでした")
            return 
            }
            ///ここでデータにアクセスしている（非同期処理）
            let userDocuments = cloudDB.collection("users").document(uid)
            ///getDocumentプロパティでコレクションデータからオブジェクトとしてデータを取得
            userDocuments.getDocument{ (documents,err) in
                if let document = documents, document.exists {
                    ///オブジェクトに対して.dataプロパティを使用して辞書型としてコールバック関数で返す
                    callback(document.data())
                } else {
                    print("Document does not exist")
                }
            }
        }
    
    //    ///データアップロード関数(コレクションは"Users")
    //    /// - Parameters:
    //    /// - userData: 一旦Anyで受け取り、判別処理の中でキャストしてから送信
    //    /// - dataFlg: どのデータかを判断する 1="nickname",2="aboutMeMassage"
    //    /// - callback:コールバック。エラーを返す。エラーにならなかったら返さない。
    //    /// - Returns:
    func userInfoDataUpload(userData:Any?,dataFlg:Int?) {
        guard let uid = uid else {
        print("UIDの取得ができませんでした")
        return
        }
        
        guard let userData = userData as? String else {
            return
        }
        ///フラグによってアップデートする項目を仕分け
        switch dataFlg {
        case 1: ///ニックネーム及び更新日時
            print(userData)
            Firestore.firestore().collection("users").document(uid).updateData(["nickname":userData])
            Firestore.firestore().collection("users").document(uid).updateData(["updatedAt":FieldValue.serverTimestamp()])
//            DBRef.child("users/\(uid)").updateChildValues(["nickname":userData])
//            DBRef.child("users").updateChildValues(["updatedAt":FieldValue.serverTimestamp()])
        case 2: ///ひとこと及び更新日時
            Firestore.firestore().collection("users").document(uid).updateData(["aboutMeMassage":userData])
            Firestore.firestore().collection("users").document(uid).updateData(["updatedAt":FieldValue.serverTimestamp()])
        default:break
        }
    }
}



