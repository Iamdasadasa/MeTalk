//
//  Singleton.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/06/16.
//

import Foundation
import FirebaseAuth
import UIKit

class myProfileSingleton {
    static let shared = myProfileSingleton() // 唯一のインスタンスを保持するプロパティ
    private init() {
        
    }
    
    func selfUIDGetter(UIViewController:UIViewController) -> String {
        guard let myuid = Auth.auth().currentUser?.uid else {
            createSheet(callback: {
                preconditionFailure()
            }, for: .Completion(title: "不正なユーザーの可能性があるため強制終了します"), SelfViewController: UIViewController)
            return ""
        }
        return myuid
    }
    
    
    func selfProfileGetter(callback:@escaping(ProfileInfoLocalObject) -> Void,UIViewController:UIViewController){
        guard let myuid = Auth.auth().currentUser?.uid else {
            createSheet(callback: {
                preconditionFailure()
            }, for: .Completion(title: "不正なユーザーの可能性があるため強制終了します"), SelfViewController: UIViewController)
            return
        }
        
        let LOCALDATA = localProfileDataStruct(UID: myuid)
        ///ローカルデータから自分のデータを取得してくる
        LOCALDATA.userProfileDatalocalGet { profileInfoLocal, result in
            ///ローカルに存在しない場合
            if result == .localNoting {
                createSheet(callback: {
                    preconditionFailure()
                }, for: .Completion(title: "不正なユーザーの可能性があるため強制終了します"), SelfViewController: UIViewController)
                return
            }
            ///ローカルに存在していた場合
            callback(profileInfoLocal)
        }
    }
}
