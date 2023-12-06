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
    @objc dynamic var lcl_ChildKey:String = ""
    @objc dynamic var lcl_Listend:Bool = false
    @objc dynamic var lcl_LikeButtonFLAG:Bool = false
    
    override static func primaryKey() -> String? {
        return "lcl_MessageID"
    }
}

struct MessageLocalSetterManager{
    ///暗号化したRealmを生成
    var realm:Realm = {
        let Database = acquireRealmDatabase()
        return Database.gettingDataBase()
    }()
    ///アップデートOr新規作成対象のメッセージ
    let Message:MessageLocalObject
    ///コミットするかどうかを必ず行う。
    var commiting:Bool = false {
        willSet {
            if newValue {
                do {
                    try realm.commitWrite()
                    // トランザクションのコミットに成功した場合の処理
                } catch let error {
                    // エラーが発生した場合の処理
                    print("エラーが発生しました: \(error)")
                }
            } else {
                realm.cancelWrite()
            }
        }
    }
    
    init(updateMessage:MessageLocalObject) {
        self.Message = updateMessage
        ///書き込みトランザクションを開始
        realm.beginWrite()
        ///追加されたメッセージをAdd
        realm.add(Message,update:.modified)
    }
}

struct MessageLocalGetterManager{
    ///暗号化したRealmを生成
    var realm:Realm = {
        let Database = acquireRealmDatabase()
        return Database.gettingDataBase()
    }()
    
    func getterMessage(loomId:String) -> (MessageLocalObject?,Bool) {
        let message = realm.object(ofType: MessageLocalObject.self, forPrimaryKey: loomId)
        guard let message = message else {
            return (nil,false)
        }
        return (message,true)
    }

    func Getter(loomId:String,desiredUpdateAtValue:Date?) -> [MessageLocalObject] {
        ///暗号化したRealmを生成
        var realm:Realm = {
            let Database = acquireRealmDatabase()
            return Database.gettingDataBase()
        }()
        
        var predicateFormat = "lcl_RoomID == %@"
        var predicateArguments: [Any] = [loomId]
        //Todo:１秒以内に二通送った場合は取得してくれない。メッセージIDも条件に噛ませる必要があるかも
        if let desiredUpdateAtValue = desiredUpdateAtValue {
            predicateFormat += " AND lcl_Date > %@"
            predicateArguments.append(desiredUpdateAtValue)
        }

        let PREDICATE = NSPredicate(format: predicateFormat, argumentArray: predicateArguments)

        let LOCALDBGETDATA = realm.objects(MessageLocalObject.self).filter(PREDICATE).sorted(byKeyPath: "lcl_Date", ascending: true)
        return Array(LOCALDBGETDATA)
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
        ///暗号化したRealmを生成
        var realm:Realm = {
            let Database = acquireRealmDatabase()
            return Database.gettingDataBase()
        }()
        let LOCALDBGETDATA = realm.objects(ProfileInfoLocalObject.self)
        let PREDICATE = NSPredicate(format: "\("lcl_UID")  == %@", self.targetUID)  
        let RESULTSPROFILE =  LOCALDBGETDATA.filter(PREDICATE).first
        return RESULTSPROFILE
    }
}

struct TargetProfileLocalDataSetterManager{
    ///暗号化したRealmを生成
    var realm:Realm = {
        let Database = acquireRealmDatabase()
        return Database.gettingDataBase()
    }()
    ///アップデートOr新規作成対象のメッセージ
    private let profile:ProfileInfoLocalObject
    ///コミットするかどうかを必ず行う。
    var commiting:Bool = false {
        willSet {
            if newValue {
                do {
                    try realm.commitWrite()
                    // トランザクションのコミットに成功した場合の処理
                } catch let error {
                    // エラーが発生した場合の処理
                    print("エラーが発生しました: \(error)")
                }
            } else {
                realm.cancelWrite()
            }
        }
    }
    
    init(updateProfile:ProfileInfoLocalObject) {
        self.profile = updateProfile
        ///書き込みトランザクションを開始
        realm.beginWrite()
        ///追加されたメッセージをAdd
        realm.add(profile,update:.modified)
    }
}

///チャットリストデータを保存するマネージドオブジェクト
class ChatInfoDataLocalObject: Object {
    @objc dynamic var lcl_TargetUID:String?
    override static func primaryKey() -> String? {
        return "lcl_TargetUID"
    }
    @objc dynamic var lcl_DateCreatedAt: Date?
    @objc dynamic var lcl_DateUpdatedAt: Date?
    @objc dynamic var lcl_FirstMessage: String?
    @objc dynamic var lcl_SendID: String?
    @objc dynamic var lcl_likeButtonFLAG: Bool = false
    @objc dynamic var lcl_meNickname: String?
    @objc dynamic var lcl_youNickname: String?
    @objc dynamic var lcl_nortificationIconFlag:Bool = false

}

struct ChatInfoLocalDataGetterManager{
    func AllGetter() -> [ChatInfoDataLocalObject] {
        ///暗号化したRealmを生成
        var realm:Realm = {
            let Database = acquireRealmDatabase()
            return Database.gettingDataBase()
        }()
        // ChatInfoDataLocalObject クラスのオブジェクトを UpdateDate プロパティで降順に並び替えて取得
        let LOCALDBGETDATA = realm.objects(ChatInfoDataLocalObject.self).sorted(byKeyPath: "lcl_DateUpdatedAt", ascending: false)
        return Array(LOCALDBGETDATA)
    }
}

struct ChatInfoDataSetterManager{
    ///暗号化したRealmを生成
    var realm:Realm = {
        let Database = acquireRealmDatabase()
        return Database.gettingDataBase()
    }()
    ///アップデートOr新規作成対象のメッセージ
    private let profile:ChatInfoDataLocalObject
    ///コミットするかどうかを必ず行う。
    var commiting:Bool = false {
        willSet {
            if newValue {
                do {
                    try realm.commitWrite()
                    // トランザクションのコミットに成功した場合の処理
                } catch let error {
                    // エラーが発生した場合の処理
                    print("エラーが発生しました: \(error)")
                }
            } else {
                realm.cancelWrite()
            }
        }
    }
    
    init(updateProfile:ChatInfoDataLocalObject) {
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
    @objc dynamic var lcl_MinAge:Int = 30001231
    @objc dynamic var lcl_MaxAge:Int = 19000101
    @objc dynamic var lcl_Gender: Int = 0
    @objc dynamic var lcl_Area: String = "未設定"
}

struct PerformSearchLocalDataGetterManager{
    func getter() -> PerformSearchLocalObject? {
        ///暗号化したRealmを生成
        var realm:Realm = {
            let Database = acquireRealmDatabase()
            return Database.gettingDataBase()
        }()
        let LOCALDBGETDATA = realm.objects(PerformSearchLocalObject.self)
        return LOCALDBGETDATA.first
    }
}

struct PerformSearchLocalDataSetterManager{
    ///暗号化したRealmを生成
    var realm:Realm = {
        let Database = acquireRealmDatabase()
        return Database.gettingDataBase()
    }()
    ///アップデートOr新規作成対象のメッセージ
    private let PerformSearch:PerformSearchLocalObject
    ///コミットするかどうかを必ず行う。
    var commiting:Bool = false {
        willSet {
            if newValue {
                do {
                    try realm.commitWrite()
                    // トランザクションのコミットに成功した場合の処理
                } catch let error {
                    // エラーが発生した場合の処理
                    print("エラーが発生しました: \(error)")
                }
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

/// 検索用APIKeyを格納するオブジェクト
class ApiKeyLocalObject: Object {
    @objc dynamic var primary:String = "Api"
    override static func primaryKey() -> String? {
        return "primary"
    }
    @objc dynamic var APIKey: String?
    @objc dynamic var appID: String?
    @objc dynamic var version: String?
}

struct ApiKeyDataLocalGetterManager{
    func getter() -> ApiKeyLocalObject? {
        ///暗号化したRealmを生成
        var realm:Realm = {
            let Database = acquireRealmDatabase()
            return Database.gettingDataBase()
        }()
        let LOCALDBGETDATA = realm.objects(ApiKeyLocalObject.self)
        return LOCALDBGETDATA.first
    }
}

struct ApiKeyDataLocalSetterManager{
    ///暗号化したRealmを生成
    var realm:Realm = {
        let Database = acquireRealmDatabase()
        return Database.gettingDataBase()
    }()
    ///アップデートOr新規作成対象のApiKey
    private let ApiKey:ApiKeyLocalObject
    ///コミットするかどうかを必ず行う。
    var commiting:Bool = false {
        willSet {
            if newValue {
                do {
                    try realm.commitWrite()
                    // トランザクションのコミットに成功した場合の処理
                } catch let error {
                    // エラーが発生した場合の処理
                    print("エラーが発生しました: \(error)")
                }
            } else {
                realm.cancelWrite()
            }
        }
    }
    ///新規作成
    init(newAddApiKey:ApiKeyLocalObject) {
        self.ApiKey = newAddApiKey
        ///書き込みトランザクションを開始
        realm.beginWrite()
        ///追加されてメッセージをAdd
        realm.add(ApiKey)
    }
    ///アップデート
    init(updateApiKey:ApiKeyLocalObject) {
        self.ApiKey = updateApiKey
        ///書き込みトランザクションを開始
        realm.beginWrite()
        ///追加されてメッセージをAdd
        realm.add(ApiKey,update:.modified)
    }
}

import UIKit
///ユーザーの画像情報を保存するローカルオブジェクト
class listUsersImageLocalObject: Object{
    @objc dynamic var lcl_UID:String?
    override static func primaryKey() -> String? {
        return "lcl_UID"
    }
    @objc dynamic var lcl_UpdataDate:Date?

    var profileImage:UIImage = UIImage(named: "defProfile")!
}

struct ImageDataLocalSetterManager {
    ///標準UserDefaults
    let userDefaults = UserDefaults.standard
    ///画像データ格納先のパス
    let createPathObeject = PathCreate()

    ///暗号化したRealmを生成
    var realm:Realm = {
        let Database = acquireRealmDatabase()
        return Database.gettingDataBase()
    }()
    ///アップデートOr新規作成対象のApiKey
    private let imageLocalData:listUsersImageLocalObject
    ///コミットするかどうかを必ず行う。
    var commiting:Bool = false {
        willSet {
            if newValue {
                do {
                    try realm.commitWrite()
                    // トランザクションのコミットに成功した場合の処理
                } catch let error {
                    // エラーが発生した場合の処理
                    print("エラーが発生しました: \(error)")
                }
            } else {
                realm.cancelWrite()
            }
        }
    }
    ///画像保存共通関数
    private func imageSave(Image:UIImage,targetUID:String) {
        let pngData = Image.pngData()
        let targetPath = createPathObeject.imagePathCreate(UID: targetUID)
        do {
            try pngData!.write(to: targetPath)
            userDefaults.set(targetPath, forKey: "\(targetUID)_profileimage")
        } catch {
            print("エラー")
        }
    }
    ///新規作成
    init(newImage:listUsersImageLocalObject) {
        self.imageLocalData = newImage
        ///書き込みトランザクションを開始
        realm.beginWrite()
        ///追加された画像情報をAdd
        realm.add(newImage)
        ///画像データ保存
        imageSave(Image: newImage.profileImage, targetUID: newImage.lcl_UID!)
    }
    ///アップデート
    init(updateImage:listUsersImageLocalObject) {
        self.imageLocalData = updateImage
        ///書き込みトランザクションを開始
        realm.beginWrite()
        ///追加された画像情報をAdd
        realm.add(updateImage,update:.modified)
        ///画像データ保存
        imageSave(Image: updateImage.profileImage, targetUID: updateImage.lcl_UID!)
    }
}

struct ImageDataLocalGetterManager {
    func getter(targetUID:String) -> listUsersImageLocalObject? {
        ///画像データ格納先のパス
        let createPathObeject = PathCreate()
        ///対象画像データのパス取得
        let targetPath = createPathObeject.imagePathCreate(UID: targetUID)
        ///暗号化したRealmを生成
        var realm:Realm = {
            let Database = acquireRealmDatabase()
            return Database.gettingDataBase()
        }()
        let LOCALDBGETDATA = realm.objects(listUsersImageLocalObject.self)
        ///画像データをUserDefaultsから取得
        let predicate = NSPredicate(format: "lcl_UID == %@", targetUID)
        if let LOCALIMAGEDATA = LOCALDBGETDATA.filter(predicate).first {
            ///存在していない場合はローカルオブジェクトの初期値を設定
            LOCALIMAGEDATA.profileImage = UIImage(contentsOfFile: targetPath.path) ?? LOCALIMAGEDATA.profileImage
            return LOCALIMAGEDATA
        }
        return nil
    }
}

///リストユーザーの情報を保存するローカルオブジェクト
class listUsersInfoLocalObject: Object{
    @objc dynamic var lcl_UID:String?
    override static func primaryKey() -> String? {
        return "lcl_UID"
    }
    @objc dynamic var lcl_UserNickName: String?
    @objc dynamic var lcl_NewMessage: String?
    @objc dynamic var lcl_UpdateDate:Date?
    @objc dynamic var lcl_Listend:Bool = false
    @objc dynamic var lcl_SendUID:String?
    @objc dynamic var lcl_BlockedFLAG:Bool = false
    @objc dynamic var lcl_BlockerFLAG:Bool = false
}
