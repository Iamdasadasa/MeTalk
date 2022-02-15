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
    
    //    ///四つの変更項目のどれかが押されたら起動する
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
    
}
