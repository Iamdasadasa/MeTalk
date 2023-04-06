//
//  FireBaseDataController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/12/19.
//

import Foundation
import Firebase
import FirebaseStorage

///DIプロトコル
protocol firebaseHostingProtocol {
    func FireStoreSignUpAuthRegister(callback: @escaping (FireBaseResult) -> Void)
    func FireStoreUserInfoRegister(callback: @escaping (FireBaseResult) -> Void,USER:ProfileUserData,uid:String)
}
///Firebase通信結果列挙型
enum FireBaseResult {
    case Success(String)
    case failure(Error)
}
///プロフィール初期値
let STR = {(CS:USERINFODEFAULTVALUE) -> String in
    return CS.StrObjec
}

let INT = {(CS:USERINFODEFAULTVALUE) -> Int in
    return CS.NumObjec
}

///登録時ユーザーデータ構造体
struct ProfileUserData{
    let nickName:String
    let sex:Int
    let aboutMessage:String = STR(.AboutMeMassage)
    let area:String = STR(.area)
    let age:Int = INT(.Age)
    let signUpFlg:String = "SignUp"
    let createdAt = FieldValue.serverTimestamp()
    let updatedAt = FieldValue.serverTimestamp()
}
///自身のユーザーサーバー処理
struct profileInitHosting:firebaseHostingProtocol{
    ///Fire Authにユーザー権限登録
    func FireStoreSignUpAuthRegister(callback: @escaping (FireBaseResult) -> Void) {
        ///匿名
        Auth.auth().signInAnonymously{ authResult, error in
            if let user = authResult?.user {
                callback(.Success(user.uid))
            } else {
                guard let error = error else {
                    print("FireStoreSignUpUserInfoRegister:ユーザー登録処理-原因不明")
                    ///強制終了
                    fatalError()
                }
                callback(.failure(error))
            }
        }
    }
    ///FireStoreにユーザー情報登録
    func FireStoreUserInfoRegister(callback: @escaping (FireBaseResult) -> Void,USER:ProfileUserData,uid:String){
        Firestore.firestore().collection("users").document(uid).setData([
            "nickname": USER.nickName,
            "Sex": USER.sex,
            "aboutMeMassage":USER.aboutMessage,
            "area":USER.area,
            "age":USER.age,
            "signUpFlg":USER.signUpFlg,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ],completion: { error in
            guard let error = error  else {
                callback(.Success("成功"))
                return
            }
            callback(.failure(error))
        })
    }
}

///アップデート種別列挙
enum updateKind{
    case nickName
    case age
    case aboutMe
    case area
    
    var dataObjectName: String {
        switch self {
        case .nickName:
            return "nickname"
        case .aboutMe:
            return "aboutMeMassage"
        case .age:
            return "age"
        case .area:
            return "area"
        }
    }
}

struct profileHosting {
    ///ユーザー情報取得
    func FireStoreProfileDataGetter(callback: @escaping  (profileInfoLocal,Error?) -> Void,UID:String) {
        let STR = {(CS:USERINFODEFAULTVALUE) -> String in
            return CS.StrObjec
        }
        let INT = {(CS:USERINFODEFAULTVALUE) -> Int in
            return CS.NumObjec
        }

        var PROFILEINFOLOCAL:profileInfoLocal = profileInfoLocal()
        PROFILEINFOLOCAL.lcl_NickName = STR(.NickName)
        PROFILEINFOLOCAL.lcl_AboutMeMassage = STR(.AboutMeMassage)
        PROFILEINFOLOCAL.lcl_Age = INT(.Age)
        PROFILEINFOLOCAL.lcl_Age = INT(.Age)
        PROFILEINFOLOCAL.lcl_Area = STR(.area)
        PROFILEINFOLOCAL.lcl_DateCreatedAt = Date()
        PROFILEINFOLOCAL.lcl_DateUpdatedAt = Date()
        
        let userDocuments = Firestore.firestore().collection("users").document(UID)
        userDocuments.getDocument{ (QuerySnapshot,err) in
            if err != nil {
                callback(PROFILEINFOLOCAL,err)
            } else {

                
                guard let QuerySnapshot = QuerySnapshot else {
                    callback(PROFILEINFOLOCAL,err)
                    return
                }
                
                guard let nickname = QuerySnapshot["nickname"] as? String else {
                    callback(PROFILEINFOLOCAL,err)
                    return
                }
                guard let aboutMeMassage = QuerySnapshot["aboutMeMassage"] as? String else {
                    callback(PROFILEINFOLOCAL,err)
                    return
                }
                guard let age = QuerySnapshot["age"] as? Int else {
                    callback(PROFILEINFOLOCAL,err)
                    return
                }
                guard let area = QuerySnapshot["area"] as? String else {
                    callback(PROFILEINFOLOCAL,err)
                    return
                }
                guard let Sex = QuerySnapshot["Sex"] as? Int else {
                    callback(PROFILEINFOLOCAL,err)
                    return
                }
                guard let createdAt = QuerySnapshot["createdAt"] as? Timestamp else {
                    callback(PROFILEINFOLOCAL,err)
                    return
                }
                guard let updatedAt = QuerySnapshot["updatedAt"] as? Timestamp else {
                    callback(PROFILEINFOLOCAL,err)
                    return
                }
                
                PROFILEINFOLOCAL.lcl_NickName = nickname
                PROFILEINFOLOCAL.lcl_AboutMeMassage = aboutMeMassage
                PROFILEINFOLOCAL.lcl_Age = age
                PROFILEINFOLOCAL.lcl_Area = area
                PROFILEINFOLOCAL.lcl_Sex = Sex
                PROFILEINFOLOCAL.lcl_DateCreatedAt = createdAt.dateValue()
                PROFILEINFOLOCAL.lcl_DateUpdatedAt = updatedAt.dateValue()
                
                callback(PROFILEINFOLOCAL,nil)
            }
        }
    }
    
    enum ERROR:Error {
        case err
    }
    
    func userDataUpdateManager(KIND:updateKind,Data:profileInfoLocal) -> Error? {
        let collectionPath = "users"
        let updateObjectName = "updatedAt"
        switch KIND {
        case .nickName:
            guard let nickName = Data.lcl_NickName else {
                return ERROR.err
            }
            Firestore.firestore().collection(collectionPath).document(Data.lcl_UID!).updateData([KIND.dataObjectName:nickName])
        case .aboutMe:
            guard let aboutMessage = Data.lcl_AboutMeMassage else {
                return ERROR.err
            }
            Firestore.firestore().collection(collectionPath).document(Data.lcl_UID!).updateData([KIND.dataObjectName:aboutMessage])
        case .age:
            Firestore.firestore().collection(collectionPath).document(Data.lcl_UID!).updateData([KIND.dataObjectName:Data.lcl_Age])
        case .area:
            guard let area = Data.lcl_Area else {
                return ERROR.err
            }
            Firestore.firestore().collection(collectionPath).document(Data.lcl_UID!).updateData([KIND.dataObjectName:area])
        }
        
        Firestore.firestore().collection(collectionPath).document(Data.lcl_UID!).updateData([updateObjectName:FieldValue.serverTimestamp()])
        return nil
    }
    
}
struct ContentsDatahosting {

    let STORAGE = Storage.storage()
    let host = "gs://metalk-f132e.appspot.com"
    
    func ImageDataGetter(callback: @escaping (ListUsersImageLocal,Error?) -> Void,UID:String,UpdateTime:Date) {
        let ImageObject = ListUsersImageLocal()
        ImageObject.lcl_ProfileImage = UIImage(named: "InitIMage")!
        ImageObject.lcl_UID = UID
        let TOOLS = TIME()
        ImageObject.lcl_UpdataDate = TOOLS.pastTimeGet()
        
        STORAGE.reference(forURL: host).child("profileImage").child("\(UID).jpeg").getMetadata {metadata, error in
            
            if error != nil {
                print("StorageのProfile画像取得の際にMetadataが取得できませんでした:\(error?.localizedDescription)")
                callback(ImageObject,error)
            }
            
            guard let metadata = metadata else {
                callback(ImageObject, nil)
                return
            }
            
            if metadata.updated! > UpdateTime {
                STORAGE.reference(forURL: host).child("profileImage").child("\(UID).jpeg")
                    .getData(maxSize: 1024 * 1024 * 10) { (data: Data?, error: Error?) in
                    ///ユーザーIDのプロフィール画像が取得できなかったらnilを返す
                    if error != nil {
                        callback(ImageObject, error)
                    }
                    ///ユーザーIDのプロフィール画像を設定していたらその画像を取得してリターン
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        ImageObject.lcl_UID = UID
                        ImageObject.lcl_ProfileImage = image!
                        ImageObject.lcl_UpdataDate = metadata.updated!
                        callback(ImageObject,nil)
                    }
                }
            }
        }
    }
}

struct TalkDataHostingManager {
    let cloudDB = Firestore.firestore()
    var databaseRef: DatabaseReference! = Database.database().reference()
    enum ERROR:Error {
        case err
    }
    
    enum MessageKind{
        case block
        case MyNew
        case MyExtra
        case YouNew
        case YouExtra
    }

    func talkListTargetUserDataGet(callback: @escaping  (ListUsersInfoLocal,Error?) -> Void,UID1:String,UID2:String) {
        var TARGETINFO = ListUsersInfoLocal()

        let userDocuments = cloudDB.collection("users").document(UID1).collection("TalkUsersList").document(UID2)
        userDocuments.getDocument(completion: { (querySnapshot, err) in
            if let err = err {
                callback(TARGETINFO,err)
            } else {
                let DOCUMENTS = querySnapshot!
                if let userNickname = DOCUMENTS["youNickname"] as? String,
                   let UpdateDate = DOCUMENTS["UpdateAt"] as? Timestamp,
                   let sendUID = DOCUMENTS["SendID"] as? String {
                    TARGETINFO.lcl_UID = UID2
                    TARGETINFO.lcl_UserNickName = userNickname
                    TARGETINFO.lcl_UpdateDate = UpdateDate.dateValue()
                    TARGETINFO.lcl_NewMessage = DOCUMENTS["FirstMessage"] as? String ?? ""
                    TARGETINFO.lcl_Listend = true
                    TARGETINFO.lcl_SendUID = sendUID
                    callback(TARGETINFO,nil)
                } else {
                    callback(TARGETINFO,ERROR.err)
                }
            }
        })
    }
    
    func newTalkUserListGetter(callback: @escaping ([profileInfoLocal],Error?) -> Void, getterCount:Int){
        cloudDB.collection("users").limit(to: getterCount).order(by: "updatedAt", descending: true).getDocuments(){ (querySnapshot, err) in
            var USERLIST:[profileInfoLocal] = []
            if let err = err {
                callback([profileInfoLocal()],err)
                return
            }
            for USER in querySnapshot!.documents {
                var USERINFO:profileInfoLocal = profileInfoLocal()
                let UID = USER.documentID.trimmingCharacters(in: .whitespaces)
                guard let SEX = USER["Sex"] as? Int,
                      let ABOUTMESSAGE = USER["aboutMeMassage"] as? String,
                      let AGE = USER["age"] as? Int,
                      let AREA = USER["area"] as? String,
                      let UPDATEDATE = USER["updatedAt"] as? Timestamp,
                      let CREATEDAT = USER["createdAt"] as? Timestamp,
                      let NICKNAME = USER["nickname"] as? String else {
                        callback([profileInfoLocal()],err)
                        return
                }
                let UPDATEDATEVALUE = UPDATEDATE.dateValue()
                let CREATEDATDATEVALUE = CREATEDAT.dateValue()
                USERINFO.lcl_UID = UID
                USERINFO.lcl_Sex = SEX
                USERINFO.lcl_AboutMeMassage = ABOUTMESSAGE
                USERINFO.lcl_Area = AREA
                USERINFO.lcl_NickName = NICKNAME
                USERINFO.lcl_Age = AGE
                USERINFO.lcl_DateUpdatedAt = UPDATEDATEVALUE
                USERINFO.lcl_DateCreatedAt = CREATEDATDATEVALUE
                
                USERLIST.append(USERINFO)
            }
            callback(USERLIST, nil)
        }
    }
    
    func LikeDataPushIncrement(TargetUID:String) {
        ///ライクボタンを押下した相手のプロフィール情報のライク数をインクリメント
        Firestore.firestore().collection("users").document(TargetUID).setData(["likeIncrement":FieldValue.increment(1.0)],merge: true)
    }
    
    func likePushing(message:String,messageId:String,sender:String,Date:Date,roomID:String){
        let TIMETOOLS = TimeTools()
        let date = TIMETOOLS.dateToStringFormatt(date: Date, formatFlg: .YMDHMS)
        let messageStructData:[String : Any] = ["message":message,"messageID":messageId,"sender":sender,"Date":date,"listend":false,"LikeButtonFLAG":true]
            databaseRef.child("Chat").child(roomID).childByAutoId().setValue(messageStructData)
    }
    
    func blockHosting(meUID:String,targetUID:String,blocker:Bool) {
        ///ブロック登録(相手に自分がブロックしている情報を)
        Firestore.firestore().collection("users").document(targetUID).collection("TalkUsersList").document(meUID).setData(["blocked":blocker], merge: true)
        ///ブロック登録(自分に相手のブロック情報を)
        Firestore.firestore().collection("users").document(meUID).collection("TalkUsersList").document(targetUID).setData(["blocker":blocker], merge: true)
    }
    
    func writeMessageData(mockMessage:MockMessage?,text:String?,roomID:String) -> ERROR? {
        let date = {(DateTime:Date) in
            let TOOLS = TimeTools()
            return TOOLS.dateToStringFormatt(date: DateTime, formatFlg: .YMDHMS)
        }
        
        guard let message = text,
              let messageId = mockMessage?.messageId,
              let sender = mockMessage?.sender.senderId,
              let dateValue = mockMessage?.sentDate else {
                return .err
              }
        let messageData:[String:Any] = [
            "message":message,
            "messageID":messageId,
            "sender":sender,
            "Date":date(dateValue),
            "listend":false
        ]
        databaseRef.child("Chat").child(roomID).childByAutoId().setValue(messageData)
        return nil
    }

    
    func talkListUserAuthUIDCreate(UID1:String,UID2:String,
                 message:String,sender:String,nickName1:String,nickName2:String,like:Bool,blocked:Bool){
        var TargetListUID:String
        var TargetDocuUID:String
        var frtCollectionPath:String = "users"
        var scdCollectionPath:String = "TalkUsersList"
        var data:[String:Any] = [ "UpdateAt":FieldValue.serverTimestamp(),
                              "FirstMessage":message,
                              "SendID":sender,
                              "meNickname":nickName1,
                              "youNickname":nickName2]
        
        var kindDeceid = {(KIND:MessageKind,TLU:String,TDU:String) in
            switch KIND {
            case .block,.MyExtra:
                if like {
                 data.updateValue(like, forKey: "likeButtonFLAG")
                }
            case .MyNew:
                if !like {
                 data.updateValue(FieldValue.serverTimestamp(), forKey: "createdAt")
                } else {
                 data.updateValue(FieldValue.serverTimestamp(), forKey: "createdAt")
                 data.updateValue(like, forKey: "likeButtonFLAG")
                }
            case .YouNew:
                data.updateValue(nickName2, forKey: "meNickname")
                data.updateValue(nickName1, forKey: "youNickname")
                if !like {
                data.updateValue(FieldValue.serverTimestamp(), forKey: "createdAt")
                } else {
                data.updateValue(FieldValue.serverTimestamp(), forKey: "createdAt")
                data.updateValue(like, forKey: "likeButtonFLAG")
                }
            case .YouExtra:
                data.updateValue(nickName2, forKey: "meNickname")
                data.updateValue(nickName1, forKey: "youNickname")
                if like {
                 data.updateValue(like, forKey: "likeButtonFLAG")
                }
            }
            Firestore.firestore().collection(frtCollectionPath).document(TLU).collection(scdCollectionPath).document(TDU).setData(data,merge: true)
        }
        
        TargetListUID = UID1
        TargetDocuUID = UID2
        
        if blocked {
            kindDeceid(.block,TargetListUID,TargetDocuUID)
            return
        }
        
        cloudDB.collection(frtCollectionPath).document(TargetListUID).collection(scdCollectionPath).document(TargetDocuUID).getDocument(completion: { (document,err) in
            if let document = document,document.exists {
                kindDeceid(.MyExtra,TargetListUID,TargetDocuUID)
            } else {
                kindDeceid(.MyNew,TargetListUID,TargetDocuUID)
            }
        })
        
        TargetListUID = UID2
        TargetDocuUID = UID1
        
        cloudDB.collection(frtCollectionPath).document(TargetListUID).collection(scdCollectionPath).document(TargetDocuUID).getDocument(completion: { (document,err) in
            if let document = document,document.exists {
                kindDeceid(.YouExtra,TargetListUID,TargetDocuUID)
            } else {
                kindDeceid(.YouNew,TargetListUID,TargetDocuUID)
            }
        })
     }

}
