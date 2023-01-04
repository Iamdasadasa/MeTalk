//
//  FireBaseDataController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/12/19.
//

import Foundation
import Firebase
import FirebaseStorage

///登録時ユーザーデータ構造体(初期値あり)
struct FireStoreRegistUserData{
    let nickName:String
    let sex:Int
    let aboutMessage:String = "よろしくお願いします     ( ∩'-' )=͟͟͞͞⊃"
    let area:String = "未設定"
    let age:Int = 0
    let signUpFlg:String = "SignUp"
    let createdAt = FieldValue.serverTimestamp()
    let updatedAt = FieldValue.serverTimestamp()
}

///Firebase通信結果列挙型
enum FireBaseResult {
    case Success(String)
    case failure(Error)
}

///Fire Authにユーザー権限登録
/// - Parameters:
///- USER: 型の指定されたユーザー情報
///
/// - Returns:
/// - callBackとしてエラー返却。
func FireStoreSignUpAuthRegister(callback: @escaping (FireBaseResult) -> Void) {
    ///FireStoreユーザー登録
    Auth.auth().signInAnonymously{ authResult, error in
        ///成功すれば、ユーザーUIDが取得可能
        if let user = authResult?.user {
            ///結果返却用のenumで返却
            callback(.Success(user.uid))
        } else {
        ///失敗した場合
            ///エラーが存在していないのに失敗した場合は強制終了
            guard let error = error else {
                print("FireStoreSignUpUserInfoRegister:ユーザー登録処理-原因不明")
                fatalError()
            }
            ///エラー返却
            callback(.failure(error))
        }
    }
}

///FireStoreにユーザー情報登録
/// - Parameters:
///- USER: 型の指定されたユーザー情報
/// - uid: ユーザー固有のID
func FireStoreUserInfoRegister(callback: @escaping (FireBaseResult) -> Void,USER:FireStoreRegistUserData,uid:String){
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
        ///エラー関数に異常がなければ成功返却
        guard let error = error  else {
            callback(.Success("成功"))
            return
        }
        ///エラー処理
        callback(.failure(error))
    })
}
