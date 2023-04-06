//
//  UserListLocal.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/06/22.
//

import Foundation
import Realm
import RealmSwift
import Firebase

///ユーザー情報初期値
enum USERINFODEFAULTVALUE {
    case Sex
    case AboutMeMassage
    case NickName
    case Age
    case area
    
    var NumObjec:Int {
        switch self {
        case .Age:
            return 20
        case .Sex:
            return 0
        default :
            ///使用しては行けないCaseの値が渡されています。呼び出し元のコードを確認してAboutMeMassageかNickName、areaが選択されていたら修正してください。
            preconditionFailure("エラーCode301")
        }
    }
    
    var StrObjec:String {
        switch self {
        case .AboutMeMassage:
            return "よろしくお願いします     ( ∩'-' )=͟͟͞͞⊃"
        case .NickName:
            return "未設定"
        case .area:
            return "未設定"
        default :
            ///使用しては行けないCaseの値が渡されています。呼び出し元のコードを確認してAgeかSexが選択されていたら修正してください。
            preconditionFailure("エラーCode301")
        }
    }
}


///リストユーザーの情報を保存するローカルオブジェクト
class ListUsersInfoLocal: Object{
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
///プロフィールユーザー情報を保存するローカルオブジェクト
class profileInfoLocal: Object {
    @objc dynamic var lcl_UID:String?
    override static func primaryKey() -> String? {
        return "lcl_UID"
    }
    @objc dynamic var lcl_DateCreatedAt: Date?
    @objc dynamic var lcl_DateUpdatedAt: Date?
    @objc dynamic var lcl_Sex: Int = 0
    @objc dynamic var lcl_AboutMeMassage: String?
    @objc dynamic var lcl_NickName: String?
    @objc dynamic var lcl_Age: Int = 20
    @objc dynamic var lcl_Area: String?
    @objc dynamic var lcl_LikeButtonPushedFLAG:Bool = false
    @objc dynamic var lcl_LikeButtonPushedDate:Date?
    enum ERROR {
        case err
    }
    func dateBinding(dateVaule:Date?) -> (Date,ERROR?) {
        guard let dateVaule = dateVaule else {
            return (Date(),.err)
        }
        return (dateVaule,nil)
    }
    
    func strBinding(strVaule:String?) -> (String,ERROR?) {
        guard let strVaule = strVaule else {
            return ("",.err)
        }
        return (strVaule,nil)
    }
    
    func intBinding(intVaule:Int?) -> (Int,ERROR?) {
        guard let intVaule = intVaule else {
            return (101,.err)
        }
        return (intVaule,nil)
    }
    
}

///ユーザーの画像情報を保存するローカルオブジェクト
class ListUsersImageLocal: Object{
    @objc dynamic var lcl_UID:String?
    override static func primaryKey() -> String? {
        return "lcl_UID"
    }
    @objc dynamic var lcl_ProfileImageURL:String?
    @objc dynamic var lcl_UpdataDate:Date?
    @objc dynamic var lcl_ProfileImage:UIImage?
}
///メッセージ内容のローカルデータオブジェクト
class messageLocal: Object {
    @objc dynamic var lcl_MessageID:String?
    override static func primaryKey() -> String? {
        return "lcl_MessageID"
    }
    @objc dynamic var lcl_RoomID:String?
    @objc dynamic var lcl_Message:String?
    @objc dynamic var lcl_Sender:String?
    @objc dynamic var lcl_Date:Date?
    @objc dynamic var lcl_Listend:Bool = false
    @objc dynamic var lcl_LikeButtonFLAG:Bool = false
}

struct localUserToolsStruct {
    ///UserDefaultsの画像パス生成関数
    func userDefaultsImageDataPathCreate(UID:String) -> URL {
        let fileName = "\(UID)_profileimage.png"
        var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(fileName)
        
        return documentDirectoryFileURL
    }
}

struct localTalkDataStruct {
    let REALM = try! Realm()
    ///オブジェクト物理名管理
    let lcl_MessageID:String = "lcl_MessageID"
    let lcl_RoomID:String = "lcl_RoomID"
    let lcl_Message:String = "lcl_Message"
    let lcl_Sender:String = "lcl_Sender"
    let lcl_Date:String = "lcl_Date"
    let lcl_Listend:String = "lcl_Listend"
    let lcl_LikeButtonFLAG:String = "lcl_LikeButtonFLAG"
    
    var roomID:String?
    var updateobject:messageLocal?
    
    init (roomID:String? = nil,
          updateobject:messageLocal? = nil){
        self.roomID = roomID
        self.updateobject = updateobject
    }
    
    ///ユーザー情報プロパティ
//    var roomID:String?
//    var listend:Bool
//    var message:String?
//    var sender:String?
//    var DateTime:Date = Date()
//    var messageID:String?
//    var likeButtonFLAG:Bool
//
//    init(roomID:String? = nil
//         ,listend:Bool = false
//         ,message:String? = nil
//         ,sender:String? = nil
//         ,DateTime:Date = Date()
//         ,messageID:String? = nil
//         ,likeButtonFLAG:Bool = false
//    )
//    {
//        self.roomID = roomID
//        self.listend = listend
//        self.message = message
//        self.sender = sender
//        self.DateTime = DateTime
//        self.messageID = messageID
//        self.likeButtonFLAG = likeButtonFLAG
//    }
    
    static private func defaultValueErrChecker(Value:String?) -> String {
        guard let Value = Value else {
            ///NULLのまま値が使用されようとしているために下記のFunctionの呼び出し元で正しい引数を使用していない関数を調査してください。
            preconditionFailure("エラーCode101")
        }
        return Value
    }
    
    ///トークリスト情報を返却
    func localTalkListDataGet() -> Results<ListUsersInfoLocal> {
        let localDBGetData = REALM.objects(ListUsersInfoLocal.self)
        return localDBGetData
    }
    ///ローカルDBのメッセージ内容を返却。
    func localMessageDataGet() -> Results<messageLocal>{
        let LOCALMESSAGEDATA = REALM.objects(messageLocal.self).sorted(byKeyPath: lcl_Date,ascending: true)
        let PREDICATE = NSPredicate(format: "\(lcl_RoomID) == %@", localTalkDataStruct.defaultValueErrChecker(Value: self.roomID))
        let LOCALMASSAGE = LOCALMESSAGEDATA.filter(PREDICATE)
        
        return LOCALMASSAGE
    }
    ///メッセージ内容をローカルDBに保存
    func localMessageDataRegist(){
        
        guard let updateobject = updateobject else {
            ///NULLのまま値が使用されようとしているために下記のFunctionの呼び出し元で正しい引数を使用していない関数を調査してください。
            preconditionFailure("エラーCode102")
        }
        
        let REALM = try! Realm()
        let LOCALDBGETDATA = REALM.objects(messageLocal.self)
        ///重複回避
        let PREDICATE = NSPredicate(format: "\(lcl_MessageID) == %@", localTalkDataStruct.defaultValueErrChecker(Value: updateobject.lcl_MessageID))
        if LOCALDBGETDATA.filter(PREDICATE).first != nil{
            return
        }
        
//        MESSAGELOCAL.lcl_RoomID = localTalkDataStruct.defaultValueErrChecker(Value: self.roomID)
//        MESSAGELOCAL.lcl_Message = localTalkDataStruct.defaultValueErrChecker(Value: messageData.lcl_Message)
//        MESSAGELOCAL.lcl_Sender = localTalkDataStruct.defaultValueErrChecker(Value: messageData.lcl_Sender)
//        MESSAGELOCAL.lcl_Date = messageData.lcl_Date
//        MESSAGELOCAL.lcl_MessageID = localTalkDataStruct.defaultValueErrChecker(Value: messageData.lcl_MessageID)
//        MESSAGELOCAL.lcl_Listend = messageData.lcl_Listend
//        MESSAGELOCAL.lcl_LikeButtonFLAG = self.likeButtonFLAG

        try! REALM.write{
            REALM.add(updateobject)
        }
    }
}


struct localProfileDataStruct{
    ///オブジェクト物理名管理
    private let lcl_UID:String = "lcl_UID"
    private let lcl_DateCreatedAt:String = "lcl_DateCreatedAt"
    private let lcl_DateUpdatedAt:String = "lcl_DateUpdatedAt"
    private let lcl_Sex:String = "lcl_Sex"
    private let lcl_AboutMeMassage:String = "lcl_AboutMeMassage"
    private let lcl_NickName:String = "lcl_NickName"
    private let lcl_Age:String = "lcl_Age"
    private let lcl_Area:String = "lcl_Area"
    private let lcl_LikeButtonPushedFLAG:String = "lcl_LikeButtonPushedFLAG"
    private let lcl_LikeButtonPushedDate:String = "lcl_LikeButtonPushedDate"
    
    var updateObject:profileInfoLocal?
    init(updateObject:profileInfoLocal? = nil,UID:String){
        self.updateObject = updateObject
        self.UID = UID
    }
    
//    ///プロパティ
    var UID:String
//    var nickName:String?
//    var sex:Int?
//    var aboutMassage:String?
//    var age:Int?
//    var area:String?
//    var createdAt:Date
//    var updatedAt:Date
//    var LikeButtonPushedDate:Date?
//    var LikeButtonPushedFLAG:Bool
//    ///初期値有りイニシャライザ
    init(
        UID:String
    ){
        self.UID = UID
    }
//        nickName:String? = nil,
//        sex:Int? = nil,
//        aboutMessage:String? = nil,
//        age:Int? = nil,
//        area:String? = nil,
//        createdAt:Date = Date(),
//        updateAt:Date = Date(),
//        LikeButtonPushedDate:Date? = nil,
//        LikeButtonPushedFLAG:Bool = false
//    ) {
//        self.UID = UID
//        self.nickName = nickName
//        self.sex = sex
//        self.aboutMassage = aboutMessage
//        self.age = age
//        self.area = area
//        self.createdAt = createdAt
//        self.updatedAt = updateAt
//        self.LikeButtonPushedDate = LikeButtonPushedDate
//        self.LikeButtonPushedFLAG = LikeButtonPushedFLAG
//    }
    ///新規Or追加enum
    enum registerKind {
        case new
        case extra
    }
    ///エラーカスタムEnum
    enum customResults {
        case localNoting
    }
    
    ///ローカルDBへのユーザープロフィール更新データ保存
    func userProfileLocalDataExtraRegist() -> customResults?{
        guard let updateObject = updateObject else {
            ///NULLのまま値が使用されようとしているために下記のFunctionの呼び出し元で正しい引数を使用していない関数を調査してください。
            preconditionFailure("エラーCode102")
        }
        
        let REALM = try! Realm()
        let localDBGetData = REALM.objects(profileInfoLocal.self)
        let predicate = NSPredicate(format: "\(lcl_UID) == %@", self.UID)
        ///ローカルDB内に渡されたUIDが存在していなければ新規ローカル保存関数呼び出し
        if let user = localDBGetData.filter(predicate).first{
            Register(profileObject: user, updateData: updateObject, REALM: REALM,Kind: .extra)
        } else {
            var tempUser = profileInfoLocal()
            Register(profileObject: tempUser, updateData: updateObject, REALM: REALM,Kind: .new)
            return .localNoting
        }
        return nil
    }
    
    
    ///登録処理
    private func Register(profileObject:profileInfoLocal,updateData:profileInfoLocal,REALM:Realm,Kind:registerKind){
        var STR = {(CS:USERINFODEFAULTVALUE) -> String in
            return CS.StrObjec
        }
        var INT = {(CS:USERINFODEFAULTVALUE) -> Int in
            return CS.NumObjec
        }
        
        switch Kind {
        case .new:
            ///ローカルデータ保存
            let profileInfoLocalObject = profileInfoLocal()
            ///構造体に合わせて各項目を入力

            profileInfoLocalObject.lcl_UID = updateData.lcl_UID
            profileInfoLocalObject.lcl_NickName = updateData.lcl_NickName ?? STR(.NickName)
            profileInfoLocalObject.lcl_Sex = updateData.lcl_Sex
            profileInfoLocalObject.lcl_AboutMeMassage = updateData.lcl_AboutMeMassage ?? STR(.AboutMeMassage)
            profileInfoLocalObject.lcl_Age = updateData.lcl_Age
            profileInfoLocalObject.lcl_Area = updateData.lcl_Area ?? STR(.area)
            profileInfoLocalObject.lcl_DateCreatedAt = updateData.lcl_DateCreatedAt
            profileInfoLocalObject.lcl_DateUpdatedAt = updateData.lcl_DateUpdatedAt
            profileInfoLocalObject.lcl_LikeButtonPushedDate = updateData.lcl_LikeButtonPushedDate
            profileInfoLocalObject.lcl_LikeButtonPushedFLAG = updateData.lcl_LikeButtonPushedFLAG
            ///ローカルDBに登録
            try! REALM.write {
                REALM.add(profileInfoLocalObject)
            }
        case .extra:
            do{
                try REALM.write{
                    if let nickname = updateData.lcl_NickName {
                        profileObject.lcl_NickName = nickname
                    }
                    if let aboutMessage = updateData.lcl_AboutMeMassage {
                        profileObject.lcl_AboutMeMassage = aboutMessage
                    }
                    if let area = updateData.lcl_Area {
                        profileObject.lcl_Area = area
                    }
                    if let LikeButtonPushedDate = updateData.lcl_LikeButtonPushedDate {
                        profileObject.lcl_LikeButtonPushedDate = LikeButtonPushedDate
                    }
                    profileObject.lcl_Sex = updateData.lcl_Sex
                    profileObject.lcl_Age = updateData.lcl_Age
                    profileObject.lcl_LikeButtonPushedFLAG = updateData.lcl_LikeButtonPushedFLAG
                    profileObject.lcl_DateCreatedAt = updateData.lcl_DateCreatedAt
                    profileObject.lcl_DateUpdatedAt = updateData.lcl_DateUpdatedAt
                }
            }catch {
                print("Error \(error)")
            }
        }
    }
    
    func userProfileDatalocalGet(callback: @escaping (profileInfoLocal,customResults?) -> Void){
        guard let updateObject = updateObject else {
            ///NULLのまま値が使用されようとしているために下記のFunctionの呼び出し元で正しい引数を使用していない関数を調査してください。
            preconditionFailure("エラーCode102")
        }
        let REALM = try! Realm()
        let LOCALDBGETDATA = REALM.objects(profileInfoLocal.self)
        let PREDICATE = NSPredicate(format: "\(lcl_UID)  == %@", self.UID)
        var PROFILEINFOLOCAL = profileInfoLocal()
        ///ローカルに存在
        guard LOCALDBGETDATA.filter(PREDICATE).first != nil else {
            callback(PROFILEINFOLOCAL,.localNoting)
            return
        }
        
        if let SELFPROFILEDATA = LOCALDBGETDATA.filter(PREDICATE).first{
            PROFILEINFOLOCAL = SELFPROFILEDATA
            
            callback(PROFILEINFOLOCAL,nil)
            
        }
    }
}

struct localListUsersDataStruct {
    var REALM:Realm
    init(){
        self.REALM = try! Realm()
    }
    
    ///エラーカスタムEnum
    enum customResults {
        case localNoting
    }
    
    func chatUserListInfoLocalDataRegist(USERLISTLOCALOBJECT:ListUsersInfoLocal) {
        let localDBGetData = REALM.objects(ListUsersInfoLocal.self)
        let predicate = NSPredicate(format: "lcl_UID == %@", USERLISTLOCALOBJECT.lcl_UID!)

        if let ExtraUser = localDBGetData.filter(predicate).first{
            Register(NewUser: USERLISTLOCALOBJECT, ExtraUser: ExtraUser)
        } else {
            Register(NewUser: USERLISTLOCALOBJECT, ExtraUser: nil)
        }
    }
    
    ///ローカルDBへのリストユーザー新規データ保存
    private func Register(NewUser:ListUsersInfoLocal,ExtraUser:ListUsersInfoLocal?){
        guard let ExtraUser = ExtraUser else {
            try! REALM.write {
                REALM.add(NewUser)
            }
            return
        }
        do{
            try REALM.write{
                if let usernickname = NewUser.lcl_UserNickName {
                    ExtraUser.lcl_UserNickName = usernickname
                }
                
                if let newMessage = NewUser.lcl_NewMessage {
                    ExtraUser.lcl_NewMessage = newMessage
                }
                if let updateDate = NewUser.lcl_UpdateDate {
                    ExtraUser.lcl_UpdateDate = updateDate
                }
                if let SendUID = NewUser.lcl_SendUID {
                    ExtraUser.lcl_SendUID = SendUID
                }
                ExtraUser.lcl_BlockerFLAG = NewUser.lcl_BlockerFLAG
                ExtraUser.lcl_BlockedFLAG = NewUser.lcl_BlockedFLAG
                ExtraUser.lcl_Listend = NewUser.lcl_Listend
                ExtraUser.lcl_BlockedFLAG = NewUser.lcl_BlockedFLAG
            }
        } catch {
            print("Error \(error)")
        }
    }
}

struct localProfileContentsDataStruct {
    ///ローカルDBにイメージを保存
    func chatUserListLocalImageRegist(UID:String,profileImage:UIImage,updataDate:Date){
        let REALM = try! Realm()
        let localDBGetData = REALM.objects(ListUsersImageLocal.self)
        let LISTUSERSIMAGELOCAL = ListUsersImageLocal()
        let userDefaults = UserDefaults.standard
        let USERTOOLS = localUserToolsStruct()
        let documentDirectoryFileURL = USERTOOLS.userDefaultsImageDataPathCreate(UID: UID)
        let UID = UID
        let predicate = NSPredicate(format: "lcl_UID == %@", UID)
        
        ///もしも既にUIDがローカルDBに存在していたらUID以外の情報を更新保存
        if let imageData = localDBGetData.filter(predicate).first{
            // UID以外のデータを更新する
            do{
                try REALM.write{
                    imageData.lcl_ProfileImageURL  = documentDirectoryFileURL.absoluteString
                    imageData.lcl_UpdataDate = updataDate
                }
            }catch {
                print("Error \(error)")
            }
            ///存在していない場合新規なのでUIDも含め新規保存
        } else {
            
            do{
                try REALM.write{
                    LISTUSERSIMAGELOCAL.lcl_ProfileImageURL = documentDirectoryFileURL.absoluteString
                    LISTUSERSIMAGELOCAL.lcl_UpdataDate = updataDate
                    LISTUSERSIMAGELOCAL.lcl_UID = UID
                }
            }catch{
                print("画像の保存に失敗しました")
            }
            try! REALM.write{REALM.add(LISTUSERSIMAGELOCAL)}
        }
        //png保存
        let pngImageData = profileImage.pngData()
        do {
            try pngImageData!.write(to: documentDirectoryFileURL)
            userDefaults.set(documentDirectoryFileURL, forKey: "\(UID)_profileimage")
        } catch {
            print("エラー")
        }
    }
    
    ///ローカルDBの画像情報取得
    func chatUserListLocalImageInfoGet(UID:String) -> ListUsersImageLocal{
        let REALM = try! Realm()
        let localDBGetData = REALM.objects(ListUsersImageLocal.self)
        let TOOLS = localUserToolsStruct()
        let TIME = TIME()
        let LISTUSERSIMAGELOCAL = ListUsersImageLocal()
        let predicate = NSPredicate(format: "lcl_UID == %@", UID)
        
        guard let imageData = localDBGetData.filter(predicate).first else {
            ///ローカルデータに入っていなかったら初期時間及び画像をNilで返却
            LISTUSERSIMAGELOCAL.lcl_UID = UID
            LISTUSERSIMAGELOCAL.lcl_UpdataDate = TIME.pastTimeGet()
            LISTUSERSIMAGELOCAL.lcl_ProfileImage = nil
            return LISTUSERSIMAGELOCAL
        }
        let fileURL = TOOLS.userDefaultsImageDataPathCreate(UID: UID)
        let filePath = fileURL.path
        
        return imageData
    }
}

    /////プロフィール情報を返却
    //func userProfileDatalocalGet(callback: @escaping (Results<profileInfoLocal>) -> Void,UID:String,hostiong:HostingManage,ViewController:UIViewController) {
    //    let REALM = try! Realm()
    //    let LOCALDBGETDATA = REALM.objects(profileInfoLocal.self)
    //    let PREDICATE = NSPredicate(format: "lcl_UID == %@", UID)
    //    var profileData:profileInfoLocal
    //    ///ローカルに存在
    //    if let SELFPROFILEDATA = LOCALDBGETDATA.filter(PREDICATE).first{
    //        profileData = SELFPROFILEDATA
    ////        profileData = [ "createdAt":SELFPROFILEDATA.lcl_DateCreatedAt,
    ////                        "updatedAt":SELFPROFILEDATA.lcl_DateUpdatedAt,
    ////                        "Sex":SELFPROFILEDATA.lcl_Sex,
    ////                        "aboutMeMassage":SELFPROFILEDATA.lcl_AboutMeMassage,
    ////                        "nickname":SELFPROFILEDATA.lcl_NickName,
    ////                        "age":SELFPROFILEDATA.lcl_Age,
    ////                        "area":SELFPROFILEDATA.lcl_Area,
    ////                        "LikeButtonPushedDate":SELFPROFILEDATA.lcl_LikeButtonPushedDate,
    ////                        "LikeButtonPushedFLAG":SELFPROFILEDATA.lcl_LikeButtonPushedFLAG
    ////        ]
    //        ///サーバー通信が必要
    //        if hostiong == .hosting {
    //            guard let nickName = profileData["nickname"] as? String else {
    //
    //                let USERDATAMANAGE = UserDataManage()
    //                USERDATAMANAGE.userInfoDataGet(callback: {document in
    //                    guard let document = document else {
    //                        return
    //                    }
    //                    userProfileLocalDataExtraRegist(
    //                        UID: UID,
    //                        nickname: document["nickname"] as? String,
    //                        sex: document["Sex"] as? Int,
    //                        aboutMassage: document["aboutMeMassage"] as? String,
    //                        age: document["age"] as? Int, area: document["area"] as? String,
    //                        createdAt: document["createdAt"] as? Date,
    //                        updatedAt: document["updatedAt"] as? Date, ViewController: ViewController
    //                    )
    //
    //                    callback (document)
    //
    //                }, UID: UID)
    //                return
    //            }
    //        }
    //        callback (profileData)
    //    ///ローカルに存在無し
    //    } else {
    //        if hostiong == .hosting {
    //            let USERDATAMANAGE = UserDataManage()
    //            USERDATAMANAGE.userInfoDataGet(callback: {document in
    //                guard let document = document else {
    //                    return
    //                }
    //                userProfileLocalDataExtraRegist(
    //                    UID: UID,
    //                    nickname: document["nickname"] as? String,
    //                    sex: document["Sex"] as? Int,
    //                    aboutMassage: document["aboutMeMassage"] as? String,
    //                    age: document["age"] as? Int, area: document["area"] as? String,
    //                    createdAt: document["createdAt"] as? Date,
    //                    updatedAt: document["updatedAt"] as? Date,
    //                    ViewController: ViewController
    //                )
    //
    //                callback (document)
    //
    //            }, UID: UID)
    //        }
    //    }
    //}
    
    
    
//    ///ローカルDBへのユーザープロフィール新規データ保存
//    func userProfileLocalDataRegist(UID:String,nickname:String,sex:Int,aboutMassage:String,age:Int,area:String,createdAt:Date,updatedAt:Date){
//        ///ローカルデータ保存
//        let REALM = try! Realm()
//        let profileInfoLocalObject = profileInfoLocal()
//        ///構造体に合わせて各項目を入力
//        profileInfoLocalObject.lcl_UID = UID
//        profileInfoLocalObject.lcl_NickName = nickname
//        profileInfoLocalObject.lcl_Sex = sex
//        profileInfoLocalObject.lcl_AboutMeMassage = aboutMassage
//        profileInfoLocalObject.lcl_Age = age
//        profileInfoLocalObject.lcl_Area = area
//        profileInfoLocalObject.lcl_DateCreatedAt = createdAt
//        profileInfoLocalObject.lcl_DateUpdatedAt = updatedAt
//        ///ローカルDBに登録
//        try! REALM.write {
//            REALM.add(profileInfoLocalObject)
//        }
//    }
    
    
    
    

    
    ///ローカルDBに保存してあるトークリストユーザーデータの中で最新の時間を取得して返す
    func chatUserListInfoLocalLastestTimeGet() -> Date{
        let REALM = try! Realm()
        let localDBGetData = REALM.objects(ListUsersInfoLocal.self).sorted(byKeyPath: "lcl_UpdateDate", ascending: false)
        let result = localDBGetData.first
        let TOOLS = TIME()
        //        もしも一件もローカルにデータが入っていなかった時はものすごい前の時間を設定して値を返す
        guard let result = result?.lcl_UpdateDate else {
            return TOOLS.pastTimeGet()
        }
        return result
    }
    

    
    ///ライクボタン押下時のローカルデータ保存および更新
//    func LikeUserDataRegist_Update(UID:String,nickname:String?,sex:Int?,aboutMassage:String?,age:Int?,area:String?,createdAt:Date?,updatedAt:Date?,LikeButtonPushedFLAG:Int,LikeButtonPushedDate:Date?,ViewController:UIViewController){
//        let REALM = try! Realm()
//        let localDBGetData = REALM.objects(profileInfoLocal.self)
//        let UID = UID
//        let predicate = NSPredicate(format: "lcl_UID == %@", UID)
//
//        ///ローカルDB内に渡されたUIDが存在していなければ新規ローカル保存関数呼び出し
//        guard let user = localDBGetData.filter(predicate).first else {
//
//            userProfileLocalDataRegist(
//                UID: UID,
//                nickname: nickname ?? "名称未設定",
//                sex: sex ?? 0,
//                aboutMassage: aboutMassage ?? "よろしくお願いします     ( ∩'-' )=͟͟͞͞⊃",
//                age: age ?? 18,
//                area: area ?? "未設定",
//                createdAt: createdAt ?? Date(),
//                updatedAt: updatedAt ?? Date()
//            )
//
//            ///ここで今まさに新規登録したユーザーのLike送信情報だけ更新する
//            let ExistUser = localDBGetData.filter(predicate).first
//            do{
//                try REALM.write{
//                    ExistUser?.lcl_LikeButtonPushedDate = LikeButtonPushedDate
//                    ExistUser?.lcl_LikeButtonPushedFLAG = LikeButtonPushedFLAG
//                }
//            } catch {
//                print("Error \(error)")
//            }
//            return
//        }
//        ///ローカルDB内に渡されたUIDが存在していれば更新
//        // Likeデータのみ更新する
//        do{
//            try REALM.write{
//                user.lcl_LikeButtonPushedDate = LikeButtonPushedDate
//                user.lcl_LikeButtonPushedFLAG = LikeButtonPushedFLAG
//            }
//        } catch {
//            print("Error \(error)")
//        }
//    }
    
//    ///ブロック処理(相手と自分に登録)(フラグによって解除も登録も)
//    func blockUserRegist(UID1:String,UID2:String,blockerFLAG:Bool,nickname:String) {
//        ///ブロック登録(相手に自分がブロックしている情報を)
//        Firestore.firestore().collection("users").document(UID2).collection("TalkUsersList").document(UID1).setData(["blocked":blockerFLAG], merge: true)
//        ///ブロック登録(自分に相手のブロック情報を)
//        Firestore.firestore().collection("users").document(UID1).collection("TalkUsersList").document(UID2).setData(["blocker":blockerFLAG], merge: true)
//        ///自分のローカルデータに相手のブロック情報登録
//        blockUserDataRegist_Update(UID: UID2, blockerFLAG: blockerFLAG, nickname: nickname)
//        
//    }
    
    ///ブロック登録時のローカルデータ保存および更新【blockUserRegistから呼び出すこと。】
//    private func blockUserDataRegist_Update(UID:String,blockerFLAG:Bool,nickname:String){
//        ///REALMにてローカルDB生成
//        let realm = try! Realm()
//        let localDBGetData = realm.objects(ListUsersInfoLocal.self)
//        // UIDで検索
//        let predicate = NSPredicate(format: "lcl_UID == %@", UID)
//        ///ローカルDB内に渡されたUIDが存在していなければ新規ローカル保存関数呼び出し
//        guard let user = localDBGetData.filter(predicate).first else {
//            chatUserListInfoLocalExstraRegist(UID: UID, usernickname: nickname, newMessage: nil, updateDate: Date(), listend: nil, SendUID: nil, blockedFLAG: blockerFLAG)
//            return
//        }
//        ///ローカルDB内に渡されたUIDが存在していれば更新
//        // ブロック情報のみ更新する
//        do{
//            try realm.write{
//                user.lcl_BlockerFLAG = blockerFLAG
//            }
//        } catch {
//            print("Error \(error)")
//        }
//    }
