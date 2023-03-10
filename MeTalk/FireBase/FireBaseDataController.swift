//
//  FireBaseDataController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/12/19.
//

import Foundation
import Firebase
import FirebaseStorage
///DIプロトコル
protocol firebaseHostingProtocol {
    func FireStoreSignUpAuthRegister(callback: @escaping (FireBaseResult) -> Void)
    func FireStoreUserInfoRegister(callback: @escaping (FireBaseResult) -> Void,USER:ProfileUserData,uid:String)
}
///Firebase通信結果列挙型
enum FireBaseResult {
    case Success(String)
    case failure(Error)
}

///登録時ユーザーデータ構造体
struct ProfileUserData{
    let nickName:String
    let sex:Int
    let aboutMessage:String = "よろしくお願いします     ( ∩'-' )=͟͟͞͞⊃"
    let area:String = "未設定"
    let age:Int = 0
    let signUpFlg:String = "SignUp"
    let createdAt = FieldValue.serverTimestamp()
    let updatedAt = FieldValue.serverTimestamp()
}
///自身のユーザーサーバー処理
struct profileInitHosting:firebaseHostingProtocol{
    ///Fire Authにユーザー権限登録
    func FireStoreSignUpAuthRegister(callback: @escaping (FireBaseResult) -> Void) {
        ///匿名
        Auth.auth().signInAnonymously{ authResult, error in
            if let user = authResult?.user {
                callback(.Success(user.uid))
            } else {
                guard let error = error else {
                    print("FireStoreSignUpUserInfoRegister:ユーザー登録処理-原因不明")
                    ///強制終了
                    fatalError()
                }
                callback(.failure(error))
            }
        }
    }
    ///FireStoreにユーザー情報登録
    func FireStoreUserInfoRegister(callback: @escaping (FireBaseResult) -> Void,USER:ProfileUserData,uid:String){
        Firestore.firestore().collection("users").document(uid).setData([
            "nickname": USER.nickName,
            "Sex": USER.sex,
            "aboutMeMassage":USER.aboutMessage,
            "area":USER.area,
            "age":USER.age,
            "signUpFlg":USER.signUpFlg,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ],completion: { error in
            guard let error = error  else {
                callback(.Success("成功"))
                return
            }
            callback(.failure(error))
        })
    }
}

struct profileHosting {
    ///ユーザー情報取得
    func FireStoreProfileDataGetter(callback: @escaping  ([String:Any]?) -> Void,UID:String?) {
        guard let UID = UID else {
            print("UIDを確認できませんでした")
            return
        }
        let userDocuments = Firestore.firestore().collection("users").document(UID)
        userDocuments.getDocument{ (QuerySnapshot,err) in
            if err != nil {
                ///相手のトークリストに何らかの理由で存在しないORブロック変数がTrueはここにくる
                var failedUserInfo = ["UID":"Block"]
                callback(failedUserInfo)
            } else {
                let DICTIONARYSNAPSHOT = QuerySnapshot
                callback(DICTIONARYSNAPSHOT?.data())
            }
        }
    }
}


