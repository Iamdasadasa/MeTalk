//
//  UserDataManage.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/14.
//

import Foundation
import Firebase
import FirebaseStorage
import RealmSwift

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
                "aboutMeMassage":"よろしくお願いします     ( ∩'-' )=͟͟͞͞⊃",
                "area":"未設定",
                "age":0,
                "signUpFlg":"SignUp",
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
    func contentOfFIRStorageGet(callback: @escaping (listUserImageStruct) -> Void,UID:String?) {
        guard let UID = UID else {
            print("UIDが確認できませんでした")
            return
        }

        ///Firebaseのストレージアクセス
        storage.reference(forURL: host).child("profileImage").child("\(UID).jpeg")
            .getData(maxSize: 1024 * 1024 * 10) { (data: Data?, error: Error?) in
            ///ユーザーIDのプロフィール画像が取得できなかったらnilを返す
            if error != nil {
                let profileImageStruct = listUserImageStruct(UID: UID, UpdateDate: Date(), UIimage: nil)
                callback(profileImageStruct)
                print(error?.localizedDescription)
            }
            ///ユーザーIDのプロフィール画像を設定していたらその画像を取得してリターン
            if let imageData = data {
                
                let image = UIImage(data: imageData)
                
                ///さらにメタデータを取得
                storage.reference(forURL: host).child("profileImage").child("\(UID).jpeg").getMetadata { metadata, error in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                    
                    if let metadata = metadata {
                        let profileImageStruct = listUserImageStruct(UID: UID, UpdateDate: metadata.updated!, UIimage: image)
                        callback(profileImageStruct)
                    }
                    
                }

            }
        }
    }
    
    ///自分ではないUser IDを基にイメージデータを取得してくる処理
    /// - Parameters:
    /// -anotherUserUID:呼び出し元が指定している画像が欲しい対象のUID
    /// - callback:ユーザーIDを基に取得できるImage
    /// - Returns:
    ///- callback: Fire Baseから取得したイメージデータ
    func contentOfFIRStorageGetAnotherUser(callback: @escaping (UIImage?) -> Void,UID:String?) {
        guard let UID = UID else {
            print("UIDが確認できませんでした")
            return
        }
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
    func contentOfFIRStorageUpload (callback: @escaping (UIImage?) -> Void,UIimagedata:UIImageView,UID:String?) {
        guard let UID = UID else {
            print("UIDが確認できませんでした")
            return
        }
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
        ///imagedataに対してメタデータを付与する
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        //storageに画像を送信

        imageRef.putData(ProfileImageData, metadata: metadata) { (metaData, error) in
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
    //    /// - Parameters:UID　関数呼び出しのとき取得したいデータのUIDを渡す
    //    /// - callback:コールバック関数。document.dataはFirebaseのユーザーコレクション全体を返している
    //    /// 　　　　　　（ニックネーム、性別等が含まれる）
    //    /// - Returns:
        func userInfoDataGet(callback: @escaping  ([String:Any]?) -> Void,UID:String?) {
            guard let UID = UID else {
                print("UIDが確認できませんでした")
                return
            }
            ///ここでデータにアクセスしている（非同期処理）
            let userDocuments = cloudDB.collection("users").document(UID)
            ///getDocumentプロパティでコレクションデータからオブジェクトとしてデータを取得
            userDocuments.getDocument{ (documents,err) in
                if let document = documents, document.exists {
                    ///オブジェクトに対して.dataプロパティを使用して辞書型としてコールバック関数で返す
                    callback(document.data())
                } else {
                    print(err?.localizedDescription)
                }
            }
        }
    
    //    ///データアップロード関数(コレクションは"Users")
    //    /// - Parameters:
    //    /// - userData: 一旦Anyで受け取り、判別処理の中でキャストしてから送信
    //    /// - dataFlg: どのデータかを判断する 1="nickname",2="aboutMeMassage"
    //    /// - callback:コールバック。エラーを返す。エラーにならなかったら返さない。
    //    /// - Returns:
    func userInfoDataUpload(userData:Any?,dataFlg:Int?,UID:String?) {
        guard let UID = UID else {
            print("UIDが確認できませんでした")
            return
        }
        ///フラグによってアップデートする項目を仕分け
        switch dataFlg {
        case 1: ///ニックネーム及び更新日時
            guard let userData = userData as? String else {
                return
            }
            Firestore.firestore().collection("users").document(UID).updateData(["nickname":userData])
            Firestore.firestore().collection("users").document(UID).updateData(["updatedAt":FieldValue.serverTimestamp()])
//            DBRef.child("users/\(uid)").updateChildValues(["nickname":userData])
//            DBRef.child("users").updateChildValues(["updatedAt":FieldValue.serverTimestamp()])
        case 2: ///ひとこと及び更新日時
            guard let userData = userData as? String else {
                return
            }
            Firestore.firestore().collection("users").document(UID).updateData(["aboutMeMassage":userData])
            Firestore.firestore().collection("users").document(UID).updateData(["updatedAt":FieldValue.serverTimestamp()])
        case 3: ///年齢及び更新日時
            guard let userData = userData as? Int else {
                return
            }
            Firestore.firestore().collection("users").document(UID).updateData(["age":userData])
            Firestore.firestore().collection("users").document(UID).updateData(["updatedAt":FieldValue.serverTimestamp()])
        case 4: ///出身地及び更新日時
            guard let userData = userData as? String else {
                return
            }
            Firestore.firestore().collection("users").document(UID).updateData(["area":userData])
            Firestore.firestore().collection("users").document(UID).updateData(["updatedAt":FieldValue.serverTimestamp()])
        default:break
        }
    }
    
    ///ブロックリスト登録処理
    func blockListRegister(UID:String?) {
        guard let UID = UID else {
            print("UIDが確認できませんでした")
            return
        }
        ///各登録処理（Cloud Firestore）
        Firestore.firestore().collection("users").document(UID).collection("blockUser").document("  ここにブロックする相手のUID").setData([
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ], completion: { error in
            if let error = error {
                ///失敗した場合
                print(error.localizedDescription)
                return
            } else {
                ///成功した場合遷移
//                callback(nil)
            }
        })
    }
    ///【非同期】トークユーザーリスト及び自身の情報取得関数(コレクションは"Users")
    /// - Parameters:
    /// - callback:コールバック関数。document.dataはFirebaseのユーザーコレクション全体を返している
    /// 　　　　　　（ニックネーム、性別等が含まれる）
    /// - Returns:
    func talkListUsersDataGet(callback: @escaping  ([talkListUserStruct]) -> Void,UID:String?,argLatestTime:Date?,limitCount:Int) {
        var latestTime:Date
        
        if let argLatestTime = argLatestTime {
            latestTime = argLatestTime
        } else {
            latestTime = Date()
        }
        
        guard let UID = UID else {
            print("UIDが確認できませんでした")
            return
        }

        ///ここでデータにアクセスしている（非同期処理）
//        let userDocuments = cloudDB.collection("users").document(UID).collection("TalkUsersList").order(by: "UpdateAt",descending: true).limit(to: limitCount)
        let userDocuments = cloudDB.collection("users").document(UID).collection("TalkUsersList").whereField("UpdateAt", isGreaterThanOrEqualTo: latestTime)
        userDocuments.getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var UserListinfo:talkListUserStruct
                var callbackTalkListUsersMock:[talkListUserStruct] = []

                for talkUserinfo in querySnapshot!.documents {
                    ///なぜか文頭にスペースが入ることがあるのでトリム処理
                    let UID = talkUserinfo.documentID.trimmingCharacters(in: .whitespaces)
                    ///更新日時のタイムスタンプをTimeStamp⇨Date型として受け取る
                    guard let timeStamp = talkUserinfo["UpdateAt"] as? Timestamp else {
                        print("更新日時が取得できませんでした。")
                        return
                    }
                    let UpdateDate = timeStamp.dateValue()
                    ///最新メッセージ
                    guard let NewMessage = talkUserinfo["FirstMessage"] as? String else {
                        print("最新メッセージが変換されませんでした。")
                        return
                    }
                    ///送信者のUIDを確認
                    guard let sendUID = talkUserinfo["SendID"] as? String else {
                        print("送信者UID情報が取得できませんでした")
                        return
                    }
                    
                    ///ここでトークリストのユーザーID一覧を格納
                    UserListinfo = talkListUserStruct(UID: UID, userNickName: nil, profileImage: nil,UpdateDate:UpdateDate, NewMessage: NewMessage, listend: false, sendUID: sendUID)
                    callbackTalkListUsersMock.append(UserListinfo)
                }
                callback(callbackTalkListUsersMock)
            }
        }
    }
    
    
    ///【非同期】ブロックユーザーリスト取得関数(コレクションは"Users")
    /// - Parameters:
    /// - callback:コールバック関数。document.dataはFirebaseのユーザーコレクション全体を返している
    /// 　　　　　　（ニックネーム、性別等が含まれる）
    /// - Returns:
    func blockUserDataGet(callback: @escaping  ([String]) -> Void,UID:String?) {
        var blockUserList:[String] = []
        guard let UID = UID else {
            print("UIDが確認できませんでした")
            return
        }
        ///ここでデータにアクセスしている（非同期処理）
        let userDocuments = cloudDB.collection("users").document(UID).collection("blockUser")
        userDocuments.getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for blockuserinfo in querySnapshot!.documents {
                    ///ここでブロックリストのユーザーID一覧を格納
                    blockUserList.append(blockuserinfo.documentID)
                }
                callback(blockUserList)
            }
        }
    }
    
    

    ///
}

