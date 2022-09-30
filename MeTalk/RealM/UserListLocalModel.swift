//
//  UserListLocal.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/06/22.
//

import Foundation
import Realm
import RealmSwift
///リストユーザーの情報を保存するローカルオブジェクト
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
///プロフィールユーザー情報を保存するローカルオブジェクト
class profileInfoLocal: Object {
    ///UIDはプライマリーキー
    @objc dynamic var UID:String?
    override static func primaryKey() -> String? {
        return "UID"
    }
    
    @objc dynamic var createdAt: Date?
    @objc dynamic var updatedAt: Date?
    @objc dynamic var Sex: Int = 0
    @objc dynamic var aboutMeMassage: String = ""
    @objc dynamic var nickName: String?
    @objc dynamic var age: Int = 0
    @objc dynamic var area: String = "未設定"
    
}

///ユーザーの画像情報を保存するローカルオブジェクト
class ListUsersImageLocal: Object{    ///UIDはプライマリーキー
    @objc dynamic var UID:String?
    override static func primaryKey() -> String? {
        return "UID"
    }
    @objc dynamic var profileImageURL:String?
    @objc dynamic var updataDate:Date?
}

///メッセージ内容のローカルデータオブジェクト
class messageLocal: Object {

    @objc dynamic var messageID:String?
    override static func primaryKey() -> String? {
        return "messageID"
    }
    @objc dynamic var roomID:String?
    @objc dynamic var message:String = ""
    @objc dynamic var sender:String = ""
    @objc dynamic var Date:Date?
    @objc dynamic var listend:Bool = false
    
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

///ローカルDBのメッセージ内容を返却。
func localMessageDataGet(roomID:String) -> Results<messageLocal>{
    let REALM = try! Realm()
    let LOCALMESSAGEDATA = REALM.objects(messageLocal.self).sorted(byKeyPath: "Date",ascending: true)
    let PREDICATE = NSPredicate(format: "roomID == %@", roomID)
    let LOCALMASSAGE = LOCALMESSAGEDATA.filter(PREDICATE)
    
    return LOCALMASSAGE
}

///メッセージ内容をローカルDBに保存
func localMessageDataRegist(roomID:String,listend:Bool,message:String,sender:String,Date:Date,messageID:String){
    let REALM = try! Realm()
    ///生成用
    let MESSAGELOCAL = messageLocal()
    ///自前データ用
    let LOCALDBGETDATA = REALM.objects(messageLocal.self)
    ///最新データが既に保存してあった場合はリターン（トーク画面に入ると必ず最新データは取得する仕様のため両者が無送信で開き直した場合は発生する）
    let PREDICATE = NSPredicate(format: "messageID == %@", messageID)
    if let messageID = LOCALDBGETDATA.filter(PREDICATE).first{
        return
    }
    
    MESSAGELOCAL.roomID = roomID
    MESSAGELOCAL.message = message
    MESSAGELOCAL.sender = sender
    MESSAGELOCAL.Date = Date
    MESSAGELOCAL.messageID = messageID
    MESSAGELOCAL.listend = listend
    ///保存処理
    try! REALM.write{
        REALM.add(MESSAGELOCAL)
    }
    
    
}

///ローカルDBより自身のプロフィール情報を取得して辞書型で返却する
func userProfileDatalocalGet(callback: @escaping ([String:Any]) -> Void,UID:String) {
    ///ローカルDBをインスタンス化
    let REALM = try! Realm()
    let LOCALDBGETDATA = REALM.objects(profileInfoLocal.self)
    let PREDICATE = NSPredicate(format: "UID == %@", UID)
    ///プロフィール情報を保存する辞書型変数
    var profileData:[String:Any] = [:]
    ///自身のプロフィール情報を取得
    if let SELFPROFILEDATA = LOCALDBGETDATA.filter(PREDICATE).first{
        ///Firebaseの形式に合わせて辞書型で保存する
        profileData = [ "createdAt":SELFPROFILEDATA.createdAt,
                        "updatedAt":SELFPROFILEDATA.updatedAt,
                        "Sex":SELFPROFILEDATA.Sex,
                        "aboutMeMassage":SELFPROFILEDATA.aboutMeMassage,
                        "nickname":SELFPROFILEDATA.nickName,
                        "age":SELFPROFILEDATA.age,
                        "area":SELFPROFILEDATA.area
        ]
        
        ///初期設定で必要なニックネームが存在していない場合はサーバー問い合わせ
        guard let nickName = profileData["nickname"] as? String else {

            let USERDATAMANAGE = UserDataManage()
            USERDATAMANAGE.userInfoDataGet(callback: {document in
                guard let document = document else {
                    return
                }
                ///ローカルに保存
                userProfileLocalDataExtraRegist(Realm: REALM, UID: UID, nickname: document["nickname"] as? String, sex: document["Sex"] as? Int, aboutMassage: document["aboutMeMassage"] as? String, age: document["age"] as? Int, area: document["area"] as? String, createdAt: document["createdAt"] as? Date, updatedAt: document["updatedAt"] as? Date)
                ///返却(ローカルデータに不備のためサーバー情報返却)
                callback (document)
            }, UID: UID)
            return
        }
        ///返却(ローカルデータ)
        callback (profileData)
    } else {
        ///もしも自身のデータがローカルデータになければ差分条件無しでサーバーに問い合わせ
        let USERDATAMANAGE = UserDataManage()
        USERDATAMANAGE.userInfoDataGet(callback: {document in
            guard let document = document else {
                return
            }
            ///ローカルに保存
            userProfileLocalDataExtraRegist(Realm: REALM, UID: UID, nickname: document["nickname"] as? String, sex: document["Sex"] as? Int, aboutMassage: document["aboutMeMassage"] as? String, age: document["age"] as? Int, area: document["area"] as? String, createdAt: document["createdAt"] as? Date, updatedAt: document["updatedAt"] as? Date)
            ///返却(ローカルデータに自身のデータが見つからなかったため)
            callback (document)
        }, UID: UID)
    }
}


///ローカルDBへのユーザープロフィール新規データ保存（新規登録時のみ呼び出し）
/// - Parameters:
///- Realm: RealMインスタンス用実体
///- UID: ローカルDBに保存するUID
///- nickname:ローカルDBに保存するニックネーム
///- sex: ローカルDBに保存する性別
///- aboutMassage: ローカルDBに保存する紹介メッセージ
///- age: ローカルDBに保存する年齢
///- area: ローカルDBに保存する出身地
///- createdAt: ローカルDBに保存する作成日時
///- updatedAt: ローカルDBに保存する更新日時
func userProfileLocalDataRegist(Realm:Realm,UID:String,nickname:String?,sex:Int,aboutMassage:String?,age:Int?,area:String?,createdAt:Date?,updatedAt:Date?){
    ///REALMにてローカルDB生成
    let realm = Realm
    let profileInfoLocalObject = profileInfoLocal()
    ///構造体に合わせて各項目を入力（オプショナルバインディングしnilで渡された場合は初期値を反映）

    if let nickname = nickname {
        profileInfoLocalObject.nickName = nickname
    } else {
        profileInfoLocalObject.nickName = "名称未設定"
    }
    if let aboutMessage = aboutMassage {
        profileInfoLocalObject.aboutMeMassage = aboutMessage
    } else {
        profileInfoLocalObject.aboutMeMassage = ""
    }
    if let age = age {
        profileInfoLocalObject.age = age
    } else {
        profileInfoLocalObject.age = 99
    }
    if let area = area {
        profileInfoLocalObject.area = area
    } else {
        profileInfoLocalObject.area = "未設定"
    }
    if let createdAt = createdAt {
        profileInfoLocalObject.createdAt = createdAt
    } else {
        profileInfoLocalObject.createdAt = Date()
    }
    if let updatedAt = updatedAt {
        profileInfoLocalObject.updatedAt = updatedAt
    } else {
        profileInfoLocalObject.updatedAt = Date()
    }
    ///必ず値が入っているものは直接投入
    profileInfoLocalObject.UID = UID
    profileInfoLocalObject.Sex = sex
    ///ローカルDBに登録
    try! realm.write {
         realm.add(profileInfoLocalObject)
    }
}
    
    ///ローカルDBへのユーザープロフィール更新データ保存
/// - Parameters:
/// - 新規と同様なので略
func userProfileLocalDataExtraRegist(Realm:Realm,UID:String,nickname:String?,sex:Int?,aboutMassage:String?,age:Int?,area:String?,createdAt:Date?,updatedAt:Date?){
        ///REALMにてローカルDB生成
        let realm = Realm
        let localDBGetData = realm.objects(profileInfoLocal.self)
        // UIDで検索
        let UID = UID
        let predicate = NSPredicate(format: "UID == %@", UID)
        ///ローカルDB内に渡されたUIDが存在していなければ新規ローカル保存関数呼び出し
        guard let user = localDBGetData.filter(predicate).first else {
            userProfileLocalDataRegist(Realm: Realm, UID: UID, nickname: nickname, sex: sex ?? 0, aboutMassage: aboutMassage, age: age, area: area, createdAt: createdAt, updatedAt: updatedAt)
            return
        }
        // UID以外のデータを更新する
        do{
          try realm.write{
              if let nickname = nickname {
                  user.nickName = nickname
              } else {///値が入ってこない場合は何もしない
              }
              if let aboutMessage = aboutMassage {
                  user.aboutMeMassage = aboutMessage
              } else {///値が入ってこない場合は何もしない
              }
              if let age = age {
                  user.age = age
              } else {///値が入ってこない場合は何もしない
              }
              if let area = area {
                  user.area = area
              } else {///値が入ってこない場合は何もしない
              }
              if let createdAt = createdAt {
                  user.createdAt = createdAt
              } else {///値が入ってこない場合は何もしない
              }
              if let updatedAt = updatedAt {
                  user.updatedAt = updatedAt
              } else {///値が入ってこない場合は何もしない
              }
              if let sex = sex {
                  user.Sex = sex
              }
              
          }
        }catch {
          print("Error \(error)")
        }
    }


///ローカルDBへのリストユーザー新規データ保存
/// - Parameters:
///- Realm: RealMインスタンス用実体
///- UID: ローカルDBに保存するUID
///- usernickname:ローカルDBに保存するニックネーム
///- newMessage: ローカルDBに新規メッセージ
///- updateDate: ローカルDBに更新日時
///- listend: ローカルDBに保存する既読フラグ
///- SendUID: ローカルDBに送信者UID
func chatUserListInfoLocalDataRegist(Realm:Realm,UID:String,usernickname:String?,newMessage:String,updateDate:Date,listend:Bool,SendUID:String){
    ///REALMにてローカルDB生成
    let realm = Realm
    let UserListLocalObject = ListUsersInfoLocal()
    ///構造体に合わせて各項目を入力
    UserListLocalObject.UID = UID
    UserListLocalObject.userNickName = usernickname
    UserListLocalObject.NewMessage = newMessage
    UserListLocalObject.upDateDate = updateDate
    UserListLocalObject.listend = listend
    UserListLocalObject.sendUID = SendUID
    ///ローカルDBに登録
    try! realm.write {
         realm.add(UserListLocalObject)
    }
}

///ローカルDBへのリストユーザー更新データ保存
/// - Parameters:
/// - 新規と同様なので略
func chatUserListInfoLocalExstraRegist(Realm:Realm,UID:String,usernickname:String?,newMessage:String?,updateDate:Date?,listend:Bool?,SendUID:String?) -> Bool{
    ///REALMにてローカルDB生成
    let realm = Realm
    let localDBGetData = realm.objects(ListUsersInfoLocal.self)
    // UIDで検索
    let UID = UID
    let predicate = NSPredicate(format: "UID == %@", UID)
    ///ローカルDB内に渡されたUIDが存在していなければfalseを返す
    guard let user = localDBGetData.filter(predicate).first else {
        return false
    }
    // UID以外のデータを更新する（存在していない項目は何もしない）
    do{
      try realm.write{
          if let usernickname = usernickname {
              user.userNickName = usernickname
          }
          if let newMessage = newMessage {
              user.NewMessage = newMessage
          }
          if let updateDate = updateDate {
              user.upDateDate = updateDate
          }
          if let listend = listend {
              user.listend = listend
          }
          if let SendUID = SendUID {
              user.sendUID = SendUID
          }
      }
    }catch {
      print("Error \(error)")
    }
    ///登録後はTrueを返す
    return true
}

///ローカルDBに保存してあるトークリストユーザーデータの中で最新の時間を取得して返す
/// - Parameters:None
/// - RealM: ローカルDBの実体化
/// - Returns: None
/// - Date: 返却する時間
func chatUserListInfoLocalLastestTimeGet(Realm:Realm) -> Date{
    ///REALMにてローカルDB生成
    let realm = Realm
    let localDBGetData = realm.objects(ListUsersInfoLocal.self).sorted(byKeyPath: "upDateDate", ascending: false)

    let result = localDBGetData.first
//        もしも一件もローカルにデータが入っていなかった時はものすごい前の時間を設定して値を返す
    guard let result = result?.upDateDate else {
        return ChatDataManagedData.pastTimeGet()
    }
    return result
}

///ローカルDBにイメージを保存
/// - Parameters:None
/// - RealM: ローカルDBの実体化
/// - Returns: None
/// - Date: 返却する時間
func chatUserListLocalImageRegist(Realm:Realm,UID:String,profileImage:UIImage,updataDate:Date){
    ///REALMにてローカルDB生成
    let realm = Realm
    let localDBGetData = realm.objects(ListUsersImageLocal.self)
    //Realmのテーブルをインスタンス化
    let LISTUSERSIMAGELOCAL = ListUsersImageLocal()
    //UserDefaults のインスタンス生成
    let userDefaults = UserDefaults.standard
    //②保存するためのパスを作成する
    let documentDirectoryFileURL = userDefaultsImageDataPathCreate(UID: UID)
    // UIDで検索
    let UID = UID
    let predicate = NSPredicate(format: "UID == %@", UID)
    
    ///もしも既にUIDがローカルDBに存在していたらUID以外の情報を更新保存
    if let imageData = localDBGetData.filter(predicate).first{
        // UID以外のデータを更新する
        do{
          try realm.write{
              imageData.profileImageURL  = documentDirectoryFileURL.absoluteString
              imageData.updataDate = updataDate
          }
        }catch {
          print("Error \(error)")
        }
    ///存在していない場合新規なのでUIDも含め新規保存
    } else {
        
        do{
            try realm.write{
                LISTUSERSIMAGELOCAL.profileImageURL = documentDirectoryFileURL.absoluteString
                LISTUSERSIMAGELOCAL.updataDate = updataDate
                LISTUSERSIMAGELOCAL.UID = UID
            }
        }catch{
            print("画像の保存に失敗しました")
        }
        try! realm.write{realm.add(LISTUSERSIMAGELOCAL)}
        
    }
    

     //pngで保存する場合
    let pngImageData = profileImage.pngData()
     do {
         try pngImageData!.write(to: documentDirectoryFileURL)
         //②「Documents下のパス情報をUserDefaultsに保存する」
         userDefaults.set(documentDirectoryFileURL, forKey: "\(UID)_profileimage")
     } catch {
         //エラー処理
         print("エラー")
     }
}

///ローカルDBの画像情報取得
/// - Parameters:
/// - RealM: ローカルDBの実体化
/// - UID: 画像取得する対象のUID
/// - Returns:
/// - listUserImageStruct: 返却される画像情報
func chatUserListLocalImageInfoGet(Realm:Realm,UID:String) -> listUserImageStruct{

    let realm = Realm
    let localDBGetData = realm.objects(ListUsersImageLocal.self)
    
    // UIDで検索
    let UID = UID
    let predicate = NSPredicate(format: "UID == %@", UID)
    
    guard let imageData = localDBGetData.filter(predicate).first else {
        ///ローカルデータに入っていなかったら初期時間及び画像をNilで返却
        let newUserimageStruct = listUserImageStruct(UID: UID, UpdateDate: ChatDataManagedData.pastTimeGet(), UIimage: nil)
        return newUserimageStruct
    }

    ///URL型にキャスト
    let fileURL = userDefaultsImageDataPathCreate(UID: UID)
    ///パス型に変換
    let filePath = fileURL.path
    
    if FileManager.default.fileExists(atPath: filePath) {
       print(filePath)
    }
    
    let imageStrcut = listUserImageStruct(UID: UID, UpdateDate: imageData.updataDate!, UIimage: UIImage(contentsOfFile: filePath))
    
    return imageStrcut
    
}
