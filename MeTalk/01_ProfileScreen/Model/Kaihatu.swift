//
//  Kaihatu.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/04/18.
//


import Foundation
import Firebase
import FirebaseStorage


struct kaihatutouroku{
    let uid = Auth.auth().currentUser?.uid
    let cloudDB = Firestore.firestore()
    let storage = Storage.storage()
    let host = "gs://metalk-f132e.appspot.com"
    var DBRef:DatabaseReference = Database.database().reference()

    ///匿名登録処理で登録したユーザー情報を返す& DB登録も初回は一緒にやる
    func tesutotairyou(callback: @escaping (String?) -> Void,nickName:String?,SexNo:Int?,ramdomString:String,jibunUID:String) {
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
            Firestore.firestore().collection("users").document(ramdomString).setData([
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
        
        cloudDB.collection("users").document(jibunUID).collection("TalkUsersList").document(ramdomString).getDocument(completion: { (document,err) in
            if let document = document,document.exists {
                return
            } else {
                ///各登録処理（Cloud Firestore）
                Firestore.firestore().collection("users").document(jibunUID).collection("TalkUsersList").document(ramdomString).setData([
                    "createdAt": FieldValue.serverTimestamp()
                ], completion: { error in
                    if let error = error {
                        ///失敗した場合
                        print(error.localizedDescription)
                        return
                    }
                })
            }
        })
        
    }
}
