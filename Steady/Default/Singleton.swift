//
//  Singleton.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/06/16.
//

import Foundation
import FirebaseAuth
import UIKit
import Firebase
import FirebaseFunctions

// プロフィールの取得共通シングルトン
class myProfileSingleton {
    ///++変数・クロージャー++//
    static let shared = myProfileSingleton()    // 唯一のインスタンスを保持するプロパティ
    /// 自身の端末保存されているUID取得
    /// - Parameter UIViewController: 呼び出し元のViewController
    /// - Returns: UID
    func selfUIDGetter() -> String? {
        guard let myuid = Auth.auth().currentUser?.uid else {
            return nil
        }
        return myuid
    }
    ///自身の情報全体を取得
    /// - Parameters:
    ///   - callback: 自身のプロフィール情報
    ///   - UIViewController: 呼び出し元のViewController
    func selfProfileGetter(selfUID:String) -> ProfileInfoLocalObject?{
        ///自身の端末UIDで自身の情報をローカルから取得
        let localselfProfileObj = TargetProfileLocalDataGetterManager(targetUID: selfUID)
        guard let localselfProfile = localselfProfileObj.getter() else {
            return nil
        }
        
        return localselfProfile
    }
}

class searchAPIKeySingleton {
    static let shared = searchAPIKeySingleton() // 唯一のインスタンスを保持するプロパティ
        
    // Cloud Functionsを呼び出すメソッドの定義
    func generateSecuredApiKey(callback: @escaping (String,String,String) -> Void) {
        lazy var functions = Functions.functions()
        functions.httpsCallable("generateSecuredApi").call { result, error in
          if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
              let code = FunctionsErrorCode(rawValue: error.code)
              let message = error.localizedDescription
              let details = error.userInfo[FunctionsErrorDetailsKey]
                callback("ERROR", "code\(FunctionsErrorCode(rawValue: error.code))message;\(error.localizedDescription);details\(error.userInfo[FunctionsErrorDetailsKey])", "ERROR")
            }
          }
            if let data = result?.data as? [String: Any],
               let apiKeyObject = data["data"] as? [String: Any],
               let apiKey = apiKeyObject["ApiKey"] as? String,
               let appID = apiKeyObject["AppID"] as? String,
               let version = apiKeyObject["version"] as? String
            {
                callback(apiKey,appID,version)
            }
        }
    }
}

class ADSInfoSingleton {
    static let shared = ADSInfoSingleton() // 唯一のインスタンスを保持するプロパティ
    
    var bannerAdUnitID = ""
    var interstitialAdUnitID = ""
}
