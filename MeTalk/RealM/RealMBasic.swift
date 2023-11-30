//
//  RealMKeyChain.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/08/09.
//

import Foundation
import RealmSwift
import UIKit

struct RealmKeyChain{
    ///キーチェーンの生成または取得
    func getKey() -> Data{
        ///一意のIDのキーチェーン
        let keyChainIdentiFier = "realmKeychainForAlgoliaValue"
        let keyChainIdentiFierData = keyChainIdentiFier.data(using: String.Encoding.utf8,allowLossyConversion: false)!
        ///既に暗号化キーが保存されているかの確認クエリ
        var query:[NSString:AnyObject] = [
            kSecClass:kSecClassKey,
            kSecAttrApplicationTag:keyChainIdentiFierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecReturnData: true as AnyObject
        ]
        ///キーチェーンから保存していた暗号化キーを取り出す
        var dataTypeRef:AnyObject?
        var status = withUnsafeMutablePointer(to: &dataTypeRef) {
            SecItemCopyMatching(query as CFDictionary,UnsafeMutablePointer($0))}
        if status == errSecSuccess {
            let data = dataTypeRef as! Data
            return data
        }
        
        ///キーチェーンに暗号化データが存在していない場合
        let keydata = NSMutableData(length: 64)!
        let result = SecRandomCopyBytes(kSecRandomDefault, 64, keydata.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
        assert(result == 0,"乱数に生成に失敗")
        ///キーチェーンに保存するクエリ生成
        query = [
            kSecClass:kSecClassKey,
            kSecAttrApplicationTag:keyChainIdentiFierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecValueData: keydata
        ]
        
        ///キーチェーンに暗号化キーを追加
        status = SecItemAdd(query as CFDictionary, nil)
        assert(status == errSecSuccess,"保存に失敗")
        if status != errSecSuccess {
            print(keydata)
        }
        return keydata as Data
    }
}

struct acquireRealmDatabase{
    func gettingDataBase() -> Realm{
        ///暗号化キーの取得
        let key = {
            let KEYCHAIN = RealmKeyChain()
            return KEYCHAIN.getKey()
        }()
        ///暗号化したRealmを生成
        var realm:Realm {
            get{
                let config = Realm.Configuration(encryptionKey: key)
                return try! Realm(configuration: config)
            }
        }
        return realm
    }
}

class realmMapping {
    /// ローカルデータ更新時のUpdate用オブジェクトに既存オブジェクトをマッピング
    /// - Parameters:
    ///   - unManagedObject: Realmに保村されていないアンマネージドオブジェクト
    ///   - managedObject: Realmに保存済みのマネージドオブジェクト
    /// - Returns: トランザクションに影響しない更新対象となるアンマネージドオブジェクト
    static func updateObjectMapping(unManagedObject:ProfileInfoLocalObject,managedObject:RequiredProfileInfoLocalData)-> ProfileInfoLocalObject{
        unManagedObject.lcl_UID = managedObject.Required_UID
        unManagedObject.lcl_DateCreatedAt = managedObject.Required_DateCreatedAt
        unManagedObject.lcl_DateUpdatedAt = managedObject.Required_DateUpdatedAt
        unManagedObject.lcl_Sex = managedObject.Required_Sex
        unManagedObject.lcl_AboutMeMassage = managedObject.Required_AboutMeMassage
        unManagedObject.lcl_NickName = managedObject.Required_NickName
        unManagedObject.lcl_Age = managedObject.Required_Age
        unManagedObject.lcl_Area = managedObject.Required_Area
        
        return unManagedObject
    }
    
    ///安全なプロフィールデータにマッピング
    static func profileDataMapping(PROFILE:ProfileInfoLocalObject,VC:UIViewController) ->RequiredProfileInfoLocalData? {
        guard let UID = PROFILE.lcl_UID,
              let CreatedAt = PROFILE.lcl_DateCreatedAt,
              let UpdatedAt = PROFILE.lcl_DateUpdatedAt,
              let aboutMessage = PROFILE.lcl_AboutMeMassage,
              let nickName = PROFILE.lcl_NickName,
              let area = PROFILE.lcl_Area else{
                createSheet(for: .Completion(title: "不正なユーザーのためメッセージできません", {
                    
                }), SelfViewController: VC)
                return nil
              }
        ///安全な型にインスタンス化
        let RequiredProfileInfo = RequiredProfileInfoLocalData(UID: UID, DateCreatedAt: CreatedAt, DateUpdatedAt: UpdatedAt, Sex: PROFILE.lcl_Sex, AboutMeMassage: aboutMessage, NickName: nickName, Age: PROFILE.lcl_Age, Area: area)
        ///ローカルからライク情報だけ取得
        let LocalProfile = TargetProfileLocalDataGetterManager(targetUID: UID)
        let pushedDate = LocalProfile.getter()?.lcl_LikeButtonPushedDate
        let pushedFlag = LocalProfile.getter()?.lcl_LikeButtonPushedFLAG
        //ライク情報セット
        RequiredProfileInfo.Required_LikeButtonPushedDate = pushedDate
            
        return RequiredProfileInfo
                
    }
}
