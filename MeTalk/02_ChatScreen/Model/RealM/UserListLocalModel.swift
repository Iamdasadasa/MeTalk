//
//  UserListLocal.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/06/22.
//

import Foundation
import Realm
import RealmSwift

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


