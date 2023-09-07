//
//  RealMKeyChain.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/08/09.
//

import Foundation

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
