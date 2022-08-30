//
//  UserListLocal.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/06/22.
//

import Foundation
import Realm
import RealmSwift
//ユーザーの情報を保存するローカルオブジェクト
class ListUsersInfoLocal: Object{
    ///UIDはプライマリーキー
    @objc dynamic var UID:String?
    override static func primaryKey() -> String? {
        return "UID"
    }
    @objc dynamic var userNickName: String?
    @objc dynamic var NewMessage: String?
    @objc dynamic var upDateDate:Date?
    dynamic var listend:Bool?
    @objc dynamic var sendUID:String?
    
}
//ユーザーの画像情報を保存するローカルオブジェクト
class ListUsersImageLocal: Object{    ///UIDはプライマリーキー
    @objc dynamic var UID:String?
    override static func primaryKey() -> String? {
        return "UID"
    }
    @objc dynamic var profileImageURL:String?
    @objc dynamic var updataDate:Date?
}

///どこからでも呼び出し可能なUserDefaultsの画像パス生成関数
func userDefaultsImageDataPathCreate(UID:String) -> URL {
    ///受け取ったUIDで一意のファイルパスを生成
    let fileName = "\(UID)_profileimage.png"
    
    // ドキュメントディレクトリの「ファイルURL」（URL型）定義
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    ///一意のファイルパスを含んだUserDefaultsパスを生成
    documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(fileName)
    ///URL型のファイルパスを返す
    return documentDirectoryFileURL
    
}



