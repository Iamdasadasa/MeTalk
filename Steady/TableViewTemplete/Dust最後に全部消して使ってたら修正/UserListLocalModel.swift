////
////  UserListLocal.swift
////  MeTalk
////
////  Created by KOJIRO MARUYAMA on 2022/06/22.
////
//
//import Foundation
//import Realm
//import RealmSwift
//import Firebase
//import UIKit
//
//
//
/////リストユーザーの情報を保存するローカルオブジェクト
//class ListUsersInfoLocal: Object{
//    @objc dynamic var lcl_UID:String?
//    override static func primaryKey() -> String? {
//        return "lcl_UID"
//    }
//    @objc dynamic var lcl_UserNickName: String?
//    @objc dynamic var lcl_NewMessage: String?
//    @objc dynamic var lcl_UpdateDate:Date?
//    @objc dynamic var lcl_Listend:Bool = false
//    @objc dynamic var lcl_SendUID:String?
//    @objc dynamic var lcl_BlockedFLAG:Bool = false
//    @objc dynamic var lcl_BlockerFLAG:Bool = false
//}
/////プロフィールユーザー情報を保存するローカルオブジェクト
//class profileInfoLocal: Object {
//    @objc dynamic var lcl_UID:String?
//    override static func primaryKey() -> String? {
//        return "lcl_UID"
//    }
//    @objc dynamic var lcl_DateCreatedAt: Date?
//    @objc dynamic var lcl_DateUpdatedAt: Date?
//    @objc dynamic var lcl_Sex: Int = 100
//    @objc dynamic var lcl_AboutMeMassage: String?
//    @objc dynamic var lcl_NickName: String?
//    @objc dynamic var lcl_Age: Int = 0
//    @objc dynamic var lcl_Area: String?
//    @objc dynamic var lcl_LikeButtonPushedFLAG:Bool = false
//    @objc dynamic var lcl_LikeButtonPushedDate:Date?
//    enum ERROR {
//        case err
//    }
//    func dateBinding(dateVaule:Date?) -> (Date,ERROR?) {
//        guard let dateVaule = dateVaule else {
//            return (Date(),.err)
//        }
//        return (dateVaule,nil)
//    }
//
//    func strBinding(strVaule:String?) -> (String,ERROR?) {
//        guard let strVaule = strVaule else {
//            return ("",.err)
//        }
//        return (strVaule,nil)
//    }
//
//    func intBinding(intVaule:Int?) -> (Int,ERROR?) {
//        guard let intVaule = intVaule else {
//            return (101,.err)
//        }
//        return (intVaule,nil)
//    }
//}
//
/////ユーザーの画像情報を保存するローカルオブジェクト
//class ListUsersImageLocal: Object{
//    @objc dynamic var lcl_UID:String?
//    override static func primaryKey() -> String? {
//        return "lcl_UID"
//    }
//    @objc dynamic var lcl_ProfileImageURL:String?
//    @objc dynamic var lcl_UpdataDate:Date?
//
//    var profileImage:UIImage = UIImage(named: "InitIMage")!
//
//}
/////メッセージ内容のローカルデータオブジェクト
//class messageLocal: Object {
//    @objc dynamic var lcl_MessageID:String?
//    override static func primaryKey() -> String? {
//        return "lcl_MessageID"
//    }
//    @objc dynamic var lcl_RoomID:String?
//    @objc dynamic var lcl_Message:String?
//    @objc dynamic var lcl_Sender:String?
//    @objc dynamic var lcl_Date:Date?
//    @objc dynamic var lcl_Listend:Bool = false
//    @objc dynamic var lcl_LikeButtonFLAG:Bool = false
//}
//
//struct localUserToolsStruct {
//    ///UserDefaultsの画像パス生成関数
//    func userDefaultsImageDataPathCreate(UID:String) -> URL {
//        let fileName = "\(UID)_profileimage.png"
//        var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(fileName)
//
//        return documentDirectoryFileURL
//    }
//}
//
//struct localTalkDataStruct {
//    ///暗号化したRealmを生成
//    private var realm:Realm = {
//        let Database = acquireRealmDatabase()
//        return Database.gettingDataBase()
//    }()
//    ///オブジェクト物理名管理
//    let lcl_MessageID:String = "lcl_MessageID"
//    let lcl_RoomID:String = "lcl_RoomID"
//    let lcl_Message:String = "lcl_Message"
//    let lcl_Sender:String = "lcl_Sender"
//    let lcl_Date:String = "lcl_Date"
//    let lcl_Listend:String = "lcl_Listend"
//    let lcl_LikeButtonFLAG:String = "lcl_LikeButtonFLAG"
//
//    var roomID:String?
//    var updateobject:messageLocal?
//
//    init (roomID:String? = nil,
//          updateobject:messageLocal? = nil){
//        self.roomID = roomID
//        self.updateobject = updateobject
//    }
//
//    static private func defaultValueErrChecker(Value:String?) -> String {
//        guard let Value = Value else {
//            ///NULLのまま値が使用されようとしているために下記のFunctionの呼び出し元で正しい引数を使用していない関数を調査してください。
//            preconditionFailure("エラーCode101")
//        }
//        return Value
//    }
//
//    ///トークリスト情報を返却
//    func localTalkListDataGet() -> Results<ListUsersInfoLocal> {
//        let localDBGetData = realm.objects(ListUsersInfoLocal.self)
//        return localDBGetData
//    }
//    ///ローカルDBのメッセージ内容を返却。
//    func localMessageDataGet() -> Results<messageLocal>{
//        let LOCALMESSAGEDATA = realm.objects(messageLocal.self).sorted(byKeyPath: lcl_Date,ascending: true)
//        let PREDICATE = NSPredicate(format: "\(lcl_RoomID) == %@", localTalkDataStruct.defaultValueErrChecker(Value: self.roomID))
//        let LOCALMASSAGE = LOCALMESSAGEDATA.filter(PREDICATE)
//
//        return LOCALMASSAGE
//    }
//    ///メッセージ内容をローカルDBに保存
//    func localMessageDataRegist(){
//
//        guard let updateobject = updateobject else {
//            ///NULLのまま値が使用されようとしているために下記のFunctionの呼び出し元で正しい引数を使用していない関数を調査してください。
//            preconditionFailure("エラーCode102")
//        }
//
//        ///暗号化したRealmを生成
//        var realm:Realm = {
//            let Database = acquireRealmDatabase()
//            return Database.gettingDataBase()
//        }()
//        let LOCALDBGETDATA = realm.objects(messageLocal.self)
//        ///重複回避
//        let PREDICATE = NSPredicate(format: "\(lcl_MessageID) == %@", localTalkDataStruct.defaultValueErrChecker(Value: updateobject.lcl_MessageID))
//        if LOCALDBGETDATA.filter(PREDICATE).first != nil{
//            return
//        }
//
//        try! realm.write{
//            realm.add(updateobject)
//        }
//    }
//}
//
//
//struct localProfileDataStruct{
//    ///オブジェクト物理名管理
//    private let lcl_UID:String = "lcl_UID"
//    private let lcl_DateCreatedAt:String = "lcl_DateCreatedAt"
//    private let lcl_DateUpdatedAt:String = "lcl_DateUpdatedAt"
//    private let lcl_Sex:String = "lcl_Sex"
//    private let lcl_AboutMeMassage:String = "lcl_AboutMeMassage"
//    private let lcl_NickName:String = "lcl_NickName"
//    private let lcl_Age:String = "lcl_Age"
//    private let lcl_Area:String = "lcl_Area"
//    private let lcl_LikeButtonPushedFLAG:String = "lcl_LikeButtonPushedFLAG"
//    private let lcl_LikeButtonPushedDate:String = "lcl_LikeButtonPushedDate"
//
//    var updateObject:profileInfoLocal?
//    init(updateObject:profileInfoLocal? = nil,UID:String){
//        self.updateObject = updateObject
//        self.UID = UID
//    }
//
//    ///プロパティ
//    var UID:String
//    ///初期値有りイニシャライザ
//    init(
//        UID:String
//    ){
//        self.UID = UID
//    }
//    ///新規Or追加enum
//    enum registerKind {
//        case new
//        case extra
//    }
//    ///エラーカスタムEnum
//    enum customResults {
//        case localNoting
//    }
//
//    ///ローカルDBへのユーザープロフィール更新データ保存
//    func userProfileLocalDataExtraRegist() -> customResults?{
//        guard let updateObject = updateObject else {
//            ///NULLのまま値が使用されようとしているために下記のFunctionの呼び出し元で正しい引数を使用していない関数を調査してください。
//            preconditionFailure("エラーCode102")
//        }
//
//        ///暗号化したRealmを生成
//        var realm:Realm = {
//            let Database = acquireRealmDatabase()
//            return Database.gettingDataBase()
//        }()
//        let localDBGetData = realm.objects(profileInfoLocal.self)
//        let predicate = NSPredicate(format: "\(lcl_UID) == %@", self.UID)
//        ///ローカルDB内に渡されたUIDが存在していなければ新規ローカル保存関数呼び出し
//        if let user = localDBGetData.filter(predicate).first{
//            Register(profileObject: user, updateData: updateObject, REALM: realm,Kind: .extra)
//        } else {
//            var tempUser = profileInfoLocal()
//            Register(profileObject: tempUser, updateData: updateObject, REALM: realm,Kind: .new)
//            return .localNoting
//        }
//        return nil
//    }
//
//
//    ///登録処理
//    private func Register(profileObject:profileInfoLocal,updateData:profileInfoLocal,REALM:Realm,Kind:registerKind){
//
//        switch Kind {
//        case .new:
//            ///ローカルデータ保存
//            let profileInfoLocalObject = profileInfoLocal()
//            ///構造体に合わせて各項目を入力
//
//            profileInfoLocalObject.lcl_UID = UID
//            profileInfoLocalObject.lcl_NickName = updateData.lcl_NickName
//            profileInfoLocalObject.lcl_Sex = updateData.lcl_Sex
//            profileInfoLocalObject.lcl_AboutMeMassage = updateData.lcl_AboutMeMassage ?? USERINFODEFAULTVALUE.aboutMeMassage.value
//            profileInfoLocalObject.lcl_Age = updateData.lcl_Age
//            profileInfoLocalObject.lcl_Area = updateData.lcl_Area ?? USERINFODEFAULTVALUE.area.value
//            profileInfoLocalObject.lcl_DateCreatedAt = updateData.lcl_DateCreatedAt
//            profileInfoLocalObject.lcl_DateUpdatedAt = updateData.lcl_DateUpdatedAt
//            profileInfoLocalObject.lcl_LikeButtonPushedDate = updateData.lcl_LikeButtonPushedDate
//            profileInfoLocalObject.lcl_LikeButtonPushedFLAG = updateData.lcl_LikeButtonPushedFLAG
//            ///ローカルDBに登録
//            try! REALM.write {
//                REALM.add(profileInfoLocalObject)
//            }
//        case .extra:
//            do{
//                try REALM.write{
//                    if let nickname = updateData.lcl_NickName {
//                        profileObject.lcl_NickName = nickname
//                    }
//                    if let aboutMessage = updateData.lcl_AboutMeMassage {
//                        profileObject.lcl_AboutMeMassage = aboutMessage
//                    }
//                    if let area = updateData.lcl_Area {
//                        profileObject.lcl_Area = area
//                    }
//                    if let LikeButtonPushedDate = updateData.lcl_LikeButtonPushedDate {
//                        profileObject.lcl_LikeButtonPushedDate = LikeButtonPushedDate
//                    }
//                    if updateData.lcl_Sex != 100 {
//                        profileObject.lcl_Sex = updateData.lcl_Sex
//                    }
//                    if updateData.lcl_Age != 0 {
//                        profileObject.lcl_Age = updateData.lcl_Age
//                    }
//                    if let createdAt = updateData.lcl_DateCreatedAt {
//                        profileObject.lcl_DateCreatedAt = createdAt
//                    }
//                    if let updateAt = updateData.lcl_DateUpdatedAt {
//                        profileObject.lcl_DateUpdatedAt = updateAt
//                    }
//                    profileObject.lcl_LikeButtonPushedFLAG = updateData.lcl_LikeButtonPushedFLAG
//
//                }
//            }catch {
//                print("Error \(error)")
//            }
//        }
//    }
//
//    func userProfileDatalocalGet(callback: @escaping (ProfileInfoLocalObject,customResults?) -> Void){
//        ///暗号化したRealmを生成
//        var realm:Realm = {
//            let Database = acquireRealmDatabase()
//            return Database.gettingDataBase()
//        }()
//        let LOCALDBGETDATA = realm.objects(ProfileInfoLocalObject.self)
//        let PREDICATE = NSPredicate(format: "\(lcl_UID)  == %@", self.UID)
//        var PROFILEINFOLOCAL = ProfileInfoLocalObject()
//        ///ローカルに存在
//        guard let LocalProfileData = LOCALDBGETDATA.filter(PREDICATE).first else {
//            callback(PROFILEINFOLOCAL,.localNoting)
//            return
//        }
//        ///フラグ
//        enum errcheck {
//            case err
//            case succees
//        }
//        var flag:errcheck = .succees
//
//        switch flag {
//        case .succees:
//            callback(LocalProfileData,nil)
//        case .err:
//            callback(PROFILEINFOLOCAL,.localNoting)
//        }
//    }
//}
//
//struct localListUsersDataStruct {
//    ///暗号化したRealmを生成
//    var realm:Realm = {
//        let Database = acquireRealmDatabase()
//        return Database.gettingDataBase()
//    }()
//
//    ///エラーカスタムEnum
//    enum customResults {
//        case localNoting
//    }
//
//    func chatUserListInfoLocalDataRegist(USERLISTLOCALOBJECT:ListUsersInfoLocal) {
//        let localDBGetData = realm.objects(ListUsersInfoLocal.self)
//        let predicate = NSPredicate(format: "lcl_UID == %@", USERLISTLOCALOBJECT.lcl_UID!)
//
//        if let ExtraUser = localDBGetData.filter(predicate).first{
//            Register(NewUser: USERLISTLOCALOBJECT, ExtraUser: ExtraUser)
//        } else {
//            Register(NewUser: USERLISTLOCALOBJECT, ExtraUser: nil)
//        }
//    }
//
//    ///ローカルDBへのリストユーザー新規データ保存
//    private func Register(NewUser:ListUsersInfoLocal,ExtraUser:ListUsersInfoLocal?){
//        guard let ExtraUser = ExtraUser else {
//            try! realm.write {
//                realm.add(NewUser)
//            }
//            return
//        }
//        do{
//            try realm.write{
//                if let usernickname = NewUser.lcl_UserNickName {
//                    ExtraUser.lcl_UserNickName = usernickname
//                }
//
//                if let newMessage = NewUser.lcl_NewMessage {
//                    ExtraUser.lcl_NewMessage = newMessage
//                }
//                if let updateDate = NewUser.lcl_UpdateDate {
//                    ExtraUser.lcl_UpdateDate = updateDate
//                }
//                if let SendUID = NewUser.lcl_SendUID {
//                    ExtraUser.lcl_SendUID = SendUID
//                }
//                ExtraUser.lcl_BlockerFLAG = NewUser.lcl_BlockerFLAG
//                ExtraUser.lcl_BlockedFLAG = NewUser.lcl_BlockedFLAG
//                ExtraUser.lcl_Listend = NewUser.lcl_Listend
//                ExtraUser.lcl_BlockedFLAG = NewUser.lcl_BlockedFLAG
//            }
//        } catch {
//            print("Error \(error)")
//        }
//    }
//}
//
//struct localProfileContentsDataStruct {
//    ///ローカルDBにイメージを保存
//    func chatUserListLocalImageRegist(UID:String,profileImage:UIImage,updataDate:Date){
//        ///暗号化したRealmを生成
//        var realm:Realm = {
//            let Database = acquireRealmDatabase()
//            return Database.gettingDataBase()
//        }()
//        let localDBGetData = realm.objects(ListUsersImageLocal.self)
//        let LISTUSERSIMAGELOCAL = ListUsersImageLocal()
//        let userDefaults = UserDefaults.standard
//        let USERTOOLS = localUserToolsStruct()
//        let documentDirectoryFileURL = USERTOOLS.userDefaultsImageDataPathCreate(UID: UID)
//        let UID = UID
//        let predicate = NSPredicate(format: "lcl_UID == %@", UID)
//
//        ///もしも既にUIDがローカルDBに存在していたらUID以外の情報を更新保存
//        if let imageData = localDBGetData.filter(predicate).first{
//            // UID以外のデータを更新する
//            do{
//                try realm.write{
//                    imageData.lcl_ProfileImageURL  = documentDirectoryFileURL.absoluteString
//                    imageData.lcl_UpdataDate = updataDate
//                }
//            }catch {
//                print("Error \(error)")
//            }
//            ///存在していない場合新規なのでUIDも含め新規保存
//        } else {
//
//            do{
//                try realm.write{
//                    LISTUSERSIMAGELOCAL.lcl_ProfileImageURL = documentDirectoryFileURL.absoluteString
//                    LISTUSERSIMAGELOCAL.lcl_UpdataDate = updataDate
//                    LISTUSERSIMAGELOCAL.lcl_UID = UID
//                }
//            }catch{
//                print("画像の保存に失敗しました")
//            }
//            try! realm.write{realm.add(LISTUSERSIMAGELOCAL)}
//        }
//        //png保存
//        let pngImageData = profileImage.pngData()
//        do {
//            try pngImageData!.write(to: documentDirectoryFileURL)
//            userDefaults.set(documentDirectoryFileURL, forKey: "\(UID)_profileimage")
//        } catch {
//            print("エラー")
//        }
//    }

    ///ローカルDBの画像情報取得
//    func chatUserListLocalImageInfoGet(UID:String) -> ListUsersImageLocal{
//        ///暗号化したRealmを生成
//        var realm:Realm = {
//            let Database = acquireRealmDatabase()
//            return Database.gettingDataBase()
//        }()
//        let localDBGetData = realm.objects(ListUsersImageLocal.self)
//        let TOOLS = localUserToolsStruct()
//        let TIME = TIME()
//        let LISTUSERSIMAGELOCAL = ListUsersImageLocal()
//        let predicate = NSPredicate(format: "lcl_UID == %@", UID)
//
//        guard let imageData = localDBGetData.filter(predicate).first else {
//            ///ローカルデータに入っていなかったら初期時間及び画像をNilで返却
//            LISTUSERSIMAGELOCAL.lcl_UID = UID
//            LISTUSERSIMAGELOCAL.lcl_UpdataDate = TIME.pastTimeGet()
//            LISTUSERSIMAGELOCAL.profileImage = UIImage(named: "InitIMage")!
//            return LISTUSERSIMAGELOCAL
//        }
//        let fileURL = TOOLS.userDefaultsImageDataPathCreate(UID: UID)
//        let filePath = fileURL.path
//        LISTUSERSIMAGELOCAL.lcl_UID = imageData.lcl_UID
//        LISTUSERSIMAGELOCAL.lcl_UpdataDate = imageData.lcl_UpdataDate
//        LISTUSERSIMAGELOCAL.profileImage = UIImage(contentsOfFile: filePath) ?? UIImage(named: "InitIMage")!
//
//        return LISTUSERSIMAGELOCAL
//    }
//}
//
//
//    ///ローカルDBに保存してあるトークリストユーザーデータの中で最新の時間を取得して返す
//    func chatUserListInfoLocalLastestTimeGet() -> Date{
//        ///暗号化したRealmを生成
//        var realm:Realm = {
//            let Database = acquireRealmDatabase()
//            return Database.gettingDataBase()
//        }()
//        let localDBGetData = realm.objects(ListUsersInfoLocal.self).sorted(byKeyPath: "lcl_UpdateDate", ascending: false)
//        let result = localDBGetData.first
//        let TOOLS = TIME()
//        //        もしも一件もローカルにデータが入っていなかった時はものすごい前の時間を設定して値を返す
//        guard let result = result?.lcl_UpdateDate else {
//            return TOOLS.pastTimeGet()
//        }
//        return result
//    }
