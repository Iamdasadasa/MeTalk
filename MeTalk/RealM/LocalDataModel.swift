//
//  LocalDataSetter.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/06/23.
//

import Foundation
import RealmSwift

/// メッセージの内容を保存するマネージドオブジェクト
class MessageLocalObject:Object {
    @objc dynamic var lcl_RoomID:String?
    @objc dynamic var lcl_MessageID:String?
    @objc dynamic var lcl_Message:String?
    @objc dynamic var lcl_Sender:String?
    @objc dynamic var lcl_Date:Date?
    @objc dynamic var lcl_Listend:Bool = false
    @objc dynamic var lcl_LikeButtonFLAG:Bool = false
    
    override static func primaryKey() -> String? {
        return "lcl_MessageID"
    }
}

struct MessageLocalSetterManager{
    let realm = try! Realm()
    ///アップデートOr新規作成対象のメッセージ
    let Message:MessageLocalObject
    ///コミットするかどうかを必ず行う。
    var commiting:Bool = false {
        willSet {
            if newValue {
                try! realm.commitWrite()
            } else {
                realm.cancelWrite()
            }
        }
    }
    
    init(updateMessage:MessageLocalObject) {
        self.Message = updateMessage
        ///書き込みトランザクションを開始
        realm.beginWrite()
        ///追加されてメッセージをAdd
        realm.add(Message,update:.modified)
    }
}

struct MessageLocalGetterManager{
    private let realm = try! Realm()
    private let Message:MessageLocalObject
    
    func getterMessage(loomId:String) -> (MessageLocalObject?,Bool) {
        let message = realm.object(ofType: MessageLocalObject.self, forPrimaryKey: loomId)
        guard let message = message else {
            return (nil,false)
        }
        return (message,true)
    }
}
/// プロフィールの内容を保存するマネージドオブジェクト
class ProfileInfoLocalObject: Object {
    @objc dynamic var lcl_UID:String?
    override static func primaryKey() -> String? {
        return "lcl_UID"
    }
    @objc dynamic var lcl_DateCreatedAt: Date?
    @objc dynamic var lcl_DateUpdatedAt: Date?
    @objc dynamic var lcl_Sex: Int = 100
    @objc dynamic var lcl_AboutMeMassage: String?
    @objc dynamic var lcl_NickName: String?
    @objc dynamic var lcl_Age: Int = 0
    @objc dynamic var lcl_Area: String?
    @objc dynamic var lcl_LikeButtonPushedFLAG:Bool = false
    @objc dynamic var lcl_LikeButtonPushedDate:Date?

}

struct TargetProfileLocalDataGetterManager{
    var targetUID:String
    init(targetUID:String) {
        self.targetUID = targetUID
    }
    func getter() -> ProfileInfoLocalObject? {
        let REALM = try! Realm()
        let LOCALDBGETDATA = REALM.objects(ProfileInfoLocalObject.self)
        let PREDICATE = NSPredicate(format: "\("lcl_UID")  == %@", self.targetUID)
        let RESULTSPROFILE =  LOCALDBGETDATA.filter(PREDICATE).first
        return RESULTSPROFILE
    }
}

struct TargetProfileLocalDataSetterManager{
    private let realm = try! Realm()
    ///アップデートOr新規作成対象のメッセージ
    private let profile:ProfileInfoLocalObject
    ///コミットするかどうかを必ず行う。
    var commiting:Bool = false {
        willSet {
            if newValue {
                try! realm.commitWrite()
            } else {
                realm.cancelWrite()
            }
        }
    }
    
    init(updateProfile:ProfileInfoLocalObject) {
        self.profile = updateProfile
        ///書き込みトランザクションを開始
        realm.beginWrite()
        ///追加されてメッセージをAdd
        realm.add(profile,update:.modified)
    }
}

///検索条件を保存するマネージドオブジェクト
class PerformSearchLocalObject: Object {
    @objc dynamic var primaryValue:String = "SearchPerform"
    override static func primaryKey() -> String {
        return "primaryValue"
    }
    @objc dynamic var lcl_MinAge:Int = 18
    @objc dynamic var lcl_MaxAge:Int = 100
    @objc dynamic var lcl_Gender: Int = 0
    @objc dynamic var lcl_Area: String = "選択しない"
}

struct PerformSearchLocalDataGetterManager{
    func getter() -> PerformSearchLocalObject? {
        let REALM = try! Realm()
        let LOCALDBGETDATA = REALM.objects(PerformSearchLocalObject.self)
        return LOCALDBGETDATA.first
    }
}

struct PerformSearchLocalDataSetterManager{
    private let realm = try! Realm()
    ///アップデートOr新規作成対象のメッセージ
    private let PerformSearch:PerformSearchLocalObject
    ///コミットするかどうかを必ず行う。
    var commiting:Bool = false {
        willSet {
            if newValue {
                try! realm.commitWrite()
            } else {
                realm.cancelWrite()
            }
        }
    }
    ///新規作成
    init(newAddPerformSearch:PerformSearchLocalObject) {
        self.PerformSearch = newAddPerformSearch
        ///書き込みトランザクションを開始
        realm.beginWrite()
        ///追加されてメッセージをAdd
        realm.add(PerformSearch)
    }
    ///アップデート
    init(updatePerformSearch:PerformSearchLocalObject) {
        self.PerformSearch = updatePerformSearch
        ///書き込みトランザクションを開始
        realm.beginWrite()
        ///追加されてメッセージをAdd
        realm.add(PerformSearch,update:.modified)
    }
}
