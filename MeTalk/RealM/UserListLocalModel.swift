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
    @objc dynamic var lcl_AboutMeMassage: String = ""
    @objc dynamic var lcl_NickName: String?
    @objc dynamic var lcl_Age: Int = 0
    @objc dynamic var lcl_Area: String = "未設定"
    @objc dynamic var lcl_LikeButtonPushedFLAG:Int = 0
    @objc dynamic var lcl_LikeButtonPushedDate:Date?
}

///ユーザーの画像情報を保存するローカルオブジェクト
class ListUsersImageLocal: Object{
    @objc dynamic var lcl_UID:String?
    override static func primaryKey() -> String? {
        return "lcl_UID"
    }
    @objc dynamic var lcl_ProfileImageURL:String?
    @objc dynamic var lcl_UpdataDate:Date?
}
///メッセージ内容のローカルデータオブジェクト
class messageLocal: Object {
    @objc dynamic var lcl_MessageID:String?
    override static func primaryKey() -> String? {
        return "lcl_MessageID"
    }
    @objc dynamic var lcl_RoomID:String?
    @objc dynamic var lcl_Message:String = ""
    @objc dynamic var lcl_Sender:String = ""
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

struct talKLocalDataStruct {
    let REALM = try! Realm()
    ///オブジェクト物理名管理
    let lcl_MessageID:String = "lcl_MessageID"
    let lcl_RoomID:String = "lcl_RoomID"
    let lcl_Message:String = "lcl_Message"
    let lcl_Sender:String = "lcl_Sender"
    let lcl_Date:String = "lcl_Date"
    let lcl_Listend:String = "lcl_Listend"
    let lcl_LikeButtonFLAG:String = "lcl_LikeButtonFLAG"
    ///ユーザー情報プロパティ
    var roomID:String
    var listend:Bool
    var message:String
    var sender:String
    var DateTime:Date
    var messageID:String
    var likeButtonFLAG:Bool
    
    init(roomID:String = talKLocalDataStruct.defaults()
         ,listend:Bool = false
         ,message:String = talKLocalDataStruct.defaults()
         ,sender:String = talKLocalDataStruct.defaults()
         ,DateTime:Date = Date()
         ,messageID:String = talKLocalDataStruct.defaults()
         ,likeButtonFLAG:Bool = false
    )
    {
        self.roomID = roomID
        self.listend = listend
        self.message = message
        self.sender = sender
        self.DateTime = DateTime
        self.messageID = messageID
        self.likeButtonFLAG = likeButtonFLAG
    }
    
    static func defaults() -> String {
        return "defaults"
    }
    
    static private func defaultValueErrChecker(Value:String) {
        if Value == "defaults" {
            ///初期値設定のまま値が使用されようとしているために下記のFunctionの呼び出し元で正しい引数を使用していない関数を調査してください。
            preconditionFailure("エラーCode101")
        }
    }
    
    
    ///トークリスト情報を返却
    func localTalkListDataGet() -> Results<ListUsersInfoLocal> {
        let localDBGetData = REALM.objects(ListUsersInfoLocal.self)
        return localDBGetData
    }
    ///ローカルDBのメッセージ内容を返却。
    func localMessageDataGet(roomID:String) -> Results<messageLocal>{
        let LOCALMESSAGEDATA = REALM.objects(messageLocal.self).sorted(byKeyPath: lcl_Date,ascending: true)
        let PREDICATE = NSPredicate(format: "\(lcl_RoomID) == %@", roomID)
        let LOCALMASSAGE = LOCALMESSAGEDATA.filter(PREDICATE)
        
        return LOCALMASSAGE
    }
    ///メッセージ内容をローカルDBに保存
    func localMessageDataRegist(){
        talKLocalDataStruct.defaultValueErrChecker(Value: self.roomID)
        talKLocalDataStruct.defaultValueErrChecker(Value: self.message)
        talKLocalDataStruct.defaultValueErrChecker(Value: self.sender)
        talKLocalDataStruct.defaultValueErrChecker(Value: self.messageID)

        let REALM = try! Realm()
        let MESSAGELOCAL = messageLocal()
        let LOCALDBGETDATA = REALM.objects(messageLocal.self)
        ///重複回避
        let PREDICATE = NSPredicate(format: "\(lcl_MessageID) == %@", messageID)
        if LOCALDBGETDATA.filter(PREDICATE).first != nil{
            return
        }
        
        MESSAGELOCAL.lcl_RoomID = self.roomID
        MESSAGELOCAL.lcl_Message = self.message
        MESSAGELOCAL.lcl_Sender = self.sender
        MESSAGELOCAL.lcl_Date = self.DateTime
        MESSAGELOCAL.lcl_MessageID = self.messageID
        MESSAGELOCAL.lcl_Listend = self.listend
        MESSAGELOCAL.lcl_LikeButtonFLAG = self.likeButtonFLAG

        try! REALM.write{
            REALM.add(MESSAGELOCAL)
        }
    }
}


ここから上記の構造体を参考にイニシャライザで初期値を設定して初期値で更新したり新規保存しようとしていたりしたら
エラー処理、イニシャライザは初期値があるので初期値がなくてもインスタンス化は可能。好きなプロパティのみで更新や保存ができる仕組みのプロフィールバージョンの構造体作成する








///返却種類カスタムenum
enum HostingManage {
    case hosting
    case unHosting
}
///自身のプロフィール情報を返却
func userProfileDatalocalGet(callback: @escaping ([String:Any]) -> Void,UID:String,hostiong:HostingManage,ViewController:UIViewController) {
    let REALM = try! Realm()
    let LOCALDBGETDATA = REALM.objects(profileInfoLocal.self)
    let PREDICATE = NSPredicate(format: "lcl_UID == %@", UID)
    var profileData:[String:Any] = [:]
    ///ローカルに存在
    if let SELFPROFILEDATA = LOCALDBGETDATA.filter(PREDICATE).first{
        profileData = [ "createdAt":SELFPROFILEDATA.lcl_DateCreatedAt,
                        "updatedAt":SELFPROFILEDATA.lcl_DateUpdatedAt,
                        "Sex":SELFPROFILEDATA.lcl_Sex,
                        "aboutMeMassage":SELFPROFILEDATA.lcl_AboutMeMassage,
                        "nickname":SELFPROFILEDATA.lcl_NickName,
                        "age":SELFPROFILEDATA.lcl_Age,
                        "area":SELFPROFILEDATA.lcl_Area,
                        "LikeButtonPushedDate":SELFPROFILEDATA.lcl_LikeButtonPushedDate,
                        "LikeButtonPushedFLAG":SELFPROFILEDATA.lcl_LikeButtonPushedFLAG
        ]
        ///サーバー通信が必要
        if hostiong == .hosting {
            guard let nickName = profileData["nickname"] as? String else {

                let USERDATAMANAGE = UserDataManage()
                USERDATAMANAGE.userInfoDataGet(callback: {document in
                    guard let document = document else {
                        return
                    }
                    userProfileLocalDataExtraRegist(
                        UID: UID,
                        nickname: document["nickname"] as? String,
                        sex: document["Sex"] as? Int,
                        aboutMassage: document["aboutMeMassage"] as? String,
                        age: document["age"] as? Int, area: document["area"] as? String,
                        createdAt: document["createdAt"] as? Date,
                        updatedAt: document["updatedAt"] as? Date, ViewController: ViewController
                    )

                    callback (document)

                }, UID: UID)
                return
            }
        }
        callback (profileData)
    ///ローカルに存在無し
    } else {
        if hostiong == .hosting {
            let USERDATAMANAGE = UserDataManage()
            USERDATAMANAGE.userInfoDataGet(callback: {document in
                guard let document = document else {
                    return
                }
                userProfileLocalDataExtraRegist(
                    UID: UID,
                    nickname: document["nickname"] as? String,
                    sex: document["Sex"] as? Int,
                    aboutMassage: document["aboutMeMassage"] as? String,
                    age: document["age"] as? Int, area: document["area"] as? String,
                    createdAt: document["createdAt"] as? Date,
                    updatedAt: document["updatedAt"] as? Date,
                    ViewController: ViewController
                )
                
                callback (document)

            }, UID: UID)
        }
    }
}


///ローカルDBへのユーザープロフィール新規データ保存
func userProfileLocalDataRegist(UID:String,nickname:String,sex:Int,aboutMassage:String,age:Int,area:String,createdAt:Date,updatedAt:Date){
    ///ローカルデータ保存
    let REALM = try! Realm()
    let profileInfoLocalObject = profileInfoLocal()
    ///構造体に合わせて各項目を入力
    profileInfoLocalObject.lcl_UID = UID
    profileInfoLocalObject.lcl_NickName = nickname
    profileInfoLocalObject.lcl_Sex = sex
    profileInfoLocalObject.lcl_AboutMeMassage = aboutMassage
    profileInfoLocalObject.lcl_Age = age
    profileInfoLocalObject.lcl_Area = area
    profileInfoLocalObject.lcl_DateCreatedAt = createdAt
    profileInfoLocalObject.lcl_DateUpdatedAt = updatedAt
    ///ローカルDBに登録
    try! REALM.write {
        REALM.add(profileInfoLocalObject)
    }
}
    
    ///ローカルDBへのユーザープロフィール更新データ保存
func userProfileLocalDataExtraRegist(UID:String,nickname:String?,sex:Int?,aboutMassage:String?,age:Int?,area:String?,createdAt:Date?,updatedAt:Date?,ViewController:UIViewController){
        let REALM = try! Realm()
        let localDBGetData = REALM.objects(profileInfoLocal.self)
        let UID = UID
        let USER:profileInfoLocal
        let predicate = NSPredicate(format: "lcl_UID == %@", UID)
        ///ローカルDB内に渡されたUIDが存在していなければ新規ローカル保存関数呼び出し
        if let user = localDBGetData.filter(predicate).first{
            USER = user
        } else {
            let PROFILEHOSTING = profileHosting()
            PROFILEHOSTING.FireStoreProfileDataGetter(callback: { data in
                data
            }, UID: UID)
        }
        // UID以外のデータを更新する
        do{
          try REALM.write{
              if let nickname = nickname {
                  USER.lcl_NickName = nickname
              }
              if let aboutMessage = aboutMassage {
                  USER.lcl_AboutMeMassage = aboutMessage
              }
              if let age = age {
                  USER.lcl_Age = age
              }
              if let area = area {
                  USER.lcl_Area = area
              }
              if let createdAt = createdAt {
                  USER.lcl_DateCreatedAt = createdAt
              }
              if let updatedAt = updatedAt {
                  USER.lcl_DateUpdatedAt = updatedAt
              }
              if let sex = sex {
                  USER.lcl_Sex = sex
              }
          }
        }catch {
          print("Error \(error)")
        }
    }


///ローカルDBへのリストユーザー新規データ保存
private func chatUserListInfoLocalDataRegist(UID:String,usernickname:String?,newMessage:String?,updateDate:Date?,listend:Bool?,SendUID:String?,blockedFLAG:Bool){
    let REALM = try! Realm()
    let UserListLocalObject = ListUsersInfoLocal()

    UserListLocalObject.lcl_UID = UID
    UserListLocalObject.lcl_UserNickName = usernickname
    UserListLocalObject.lcl_NewMessage = newMessage
    UserListLocalObject.lcl_UpdateDate = updateDate
    UserListLocalObject.lcl_Listend = listend ?? false
    UserListLocalObject.lcl_SendUID = SendUID
    UserListLocalObject.lcl_BlockedFLAG = blockedFLAG

    try! REALM.write {
         REALM.add(UserListLocalObject)
    }
}

///ローカルDBへのリストユーザー更新データ保存
func chatUserListInfoLocalExstraRegist(UID:String,usernickname:String?,newMessage:String?,updateDate:Date?,listend:Bool?,SendUID:String?,blockedFLAG:Bool){
    let REALM = try! Realm()
    let localDBGetData = REALM.objects(ListUsersInfoLocal.self)
    let UID = UID
    let predicate = NSPredicate(format: "lcl_UID == %@", UID)
    ///ローカルDB内に渡されたUIDが存在していなければ新規ローカル保存関数呼び出し
    guard let user = localDBGetData.filter(predicate).first else {
        chatUserListInfoLocalDataRegist(
            UID: UID,
            usernickname: usernickname,
            newMessage: newMessage,
            updateDate: Date(), listend: listend,
            SendUID: SendUID,
            blockedFLAG: blockedFLAG
        )
        return
    }
    // UID以外のデータを更新する（存在していない項目は何もしない）
    do{
      try REALM.write{
          if let usernickname = usernickname {
              user.lcl_UserNickName = usernickname
          }
          if let newMessage = newMessage {
              user.lcl_NewMessage = newMessage
          }
          if let updateDate = updateDate {
              user.lcl_UpdateDate = updateDate
          }
          if let listend = listend {
              user.lcl_Listend = listend
          }
          if let SendUID = SendUID {
              user.lcl_SendUID = SendUID
          }
          user.lcl_BlockedFLAG = blockedFLAG
      }
    }catch {
      print("Error \(error)")
    }
    return
}

///ローカルDBに保存してあるトークリストユーザーデータの中で最新の時間を取得して返す
func chatUserListInfoLocalLastestTimeGet() -> Date{
    let REALM = try! Realm()
    let localDBGetData = REALM.objects(ListUsersInfoLocal.self).sorted(byKeyPath: "lcl_UpdateDate", ascending: false)
    let result = localDBGetData.first
//        もしも一件もローカルにデータが入っていなかった時はものすごい前の時間を設定して値を返す
    guard let result = result?.lcl_UpdateDate else {
        return ChatDataManagedData.pastTimeGet()
    }
    return result
}

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
func chatUserListLocalImageInfoGet(UID:String) -> listUserImageStruct{
    let REALM = try! Realm()
    let localDBGetData = REALM.objects(ListUsersImageLocal.self)
    let UID = UID
    let USERTOOLS = localUserToolsStruct()
    let predicate = NSPredicate(format: "lcl_UID == %@", UID)
    
    guard let imageData = localDBGetData.filter(predicate).first else {
        ///ローカルデータに入っていなかったら初期時間及び画像をNilで返却
        let newUserimageStruct = listUserImageStruct(UID: UID, UpdateDate: ChatDataManagedData.pastTimeGet(), UIimage: nil)
        return newUserimageStruct
    }
    let fileURL = USERTOOLS.userDefaultsImageDataPathCreate(UID: UID)
    let filePath = fileURL.path
    if FileManager.default.fileExists(atPath: filePath) {
       print(filePath)
    }
    let imageStrcut = listUserImageStruct(UID: UID, UpdateDate: imageData.lcl_UpdataDate!, UIimage: UIImage(contentsOfFile: filePath))
    return imageStrcut
}

///ライクボタン押下時のローカルデータ保存および更新
func LikeUserDataRegist_Update(UID:String,nickname:String?,sex:Int?,aboutMassage:String?,age:Int?,area:String?,createdAt:Date?,updatedAt:Date?,LikeButtonPushedFLAG:Int,LikeButtonPushedDate:Date?,ViewController:UIViewController){
    let REALM = try! Realm()
    let localDBGetData = REALM.objects(profileInfoLocal.self)
    let UID = UID
    let predicate = NSPredicate(format: "lcl_UID == %@", UID)

    ///ローカルDB内に渡されたUIDが存在していなければ新規ローカル保存関数呼び出し
    guard let user = localDBGetData.filter(predicate).first else {
            userProfileLocalDataRegist(
                UID: UID,
                nickname: nickname ?? "名称未設定",
                sex: sex ?? 0,
                aboutMassage: aboutMassage ?? "よろしくお願いします     ( ∩'-' )=͟͟͞͞⊃",
                age: age ?? 18,
                area: area ?? "未設定",
                createdAt: createdAt ?? Date(),
                updatedAt: updatedAt ?? Date()
            )
        
        ///ここで今まさに新規登録したユーザーのLike送信情報だけ更新する
        let ExistUser = localDBGetData.filter(predicate).first
        do{
            try REALM.write{
                ExistUser?.lcl_LikeButtonPushedDate = LikeButtonPushedDate
                ExistUser?.lcl_LikeButtonPushedFLAG = LikeButtonPushedFLAG
            }
        } catch {
            print("Error \(error)")
        }
        return
    }
    ///ローカルDB内に渡されたUIDが存在していれば更新
    // Likeデータのみ更新する
    do{
        try REALM.write{
            user.lcl_LikeButtonPushedDate = LikeButtonPushedDate
            user.lcl_LikeButtonPushedFLAG = LikeButtonPushedFLAG
        }
    } catch {
        print("Error \(error)")
    }
}

///ブロック処理(相手と自分に登録)(フラグによって解除も登録も)
func blockUserRegist(UID1:String,UID2:String,blockerFLAG:Bool,nickname:String) {
    ///ブロック登録(相手に自分がブロックしている情報を)
    Firestore.firestore().collection("users").document(UID2).collection("TalkUsersList").document(UID1).setData(["blocked":blockerFLAG], merge: true)
    ///ブロック登録(自分に相手のブロック情報を)
    Firestore.firestore().collection("users").document(UID1).collection("TalkUsersList").document(UID2).setData(["blocker":blockerFLAG], merge: true)
    ///自分のローカルデータに相手のブロック情報登録
    blockUserDataRegist_Update(UID: UID2, blockerFLAG: blockerFLAG, nickname: nickname)
    
}

///ブロック登録時のローカルデータ保存および更新【blockUserRegistから呼び出すこと。】
 private func blockUserDataRegist_Update(UID:String,blockerFLAG:Bool,nickname:String){
    ///REALMにてローカルDB生成
    let realm = try! Realm()
    let localDBGetData = realm.objects(ListUsersInfoLocal.self)
    // UIDで検索
    let predicate = NSPredicate(format: "lcl_UID == %@", UID)
    ///ローカルDB内に渡されたUIDが存在していなければ新規ローカル保存関数呼び出し
    guard let user = localDBGetData.filter(predicate).first else {
        chatUserListInfoLocalExstraRegist(UID: UID, usernickname: nickname, newMessage: nil, updateDate: Date(), listend: nil, SendUID: nil, blockedFLAG: blockerFLAG)
        return
    }
    ///ローカルDB内に渡されたUIDが存在していれば更新
    // ブロック情報のみ更新する
    do{
        try realm.write{
            user.lcl_BlockerFLAG = blockerFLAG
        }
    } catch {
        print("Error \(error)")
    }
}
