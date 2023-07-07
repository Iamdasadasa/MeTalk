//
//  HostingDataGetter.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/06/16.
//

import Foundation
import Firebase
import FirebaseStorage


///
//--------------------------------------------------
//--ユーザー初期登録--
//--------------------------------------------------
///
///DIプロトコル
protocol ProfileRegisterProtocol {
    func SignUpAuthRegister(callback: @escaping (HostingResult) -> Void)
    func UserInfoRegister(callback: @escaping (HostingResult) -> Void,USER:ProfileInfoLocalObject,uid:String)
}

///自身のユーザーサーバー処理
struct MyProfileSetterManager:ProfileRegisterProtocol{
    ///Fire Authにユーザー権限登録
    func SignUpAuthRegister(callback: @escaping (HostingResult) -> Void) {
        ///匿名
        Auth.auth().signInAnonymously{ authResult, error in
            if let user = authResult?.user {
                callback(.Success(user.uid))
            } else {
                guard let error = error else {
                    return
                }
                callback(.failure(error))
            }
        }
    }
    ///FireStoreにユーザー情報登録
    func UserInfoRegister(callback: @escaping (HostingResult) -> Void,USER:ProfileInfoLocalObject,uid:String){
        Firestore.firestore().collection("users").document(uid).setData([
            "nickname": USER.lcl_NickName,
            "Sex": USER.lcl_Sex,
            "aboutMeMassage":USER.lcl_AboutMeMassage,
            "area":USER.lcl_Area,
            "age":USER.lcl_Age,
            "signUpFlg":"SignUp",
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

///
//--------------------------------------------------
//--ユーザー情報更新--
//--------------------------------------------------
///
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

struct TargetProfileSetterManager {
    
    func userDataSetter(KIND:updateKind,Data:ProfileInfoLocalObject) -> Error? {
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
///
//--------------------------------------------------
//--画像データ関連--
//--------------------------------------------------
///
struct ContentsSetterManager {
    let STORAGE = Storage.storage()
    let host = "gs://metalk-f132e.appspot.com"
    
    func contentOfFIRStorageUpload (callback: @escaping (UIImage?) -> Void,UIimagedata:UIImageView,UID:String?) {
        guard let UID = UID else {
            print("UIDが確認できませんでした")
            return
        }
        //ストレージサーバのURLを取得
        let storage = Storage.storage().reference(forURL: "gs://metalk-f132e.appspot.com")
        
        // パス: あなた固有のURL/profileImage/{user.uid}.jpeg
        let imageRef = storage.child("profileImage").child("\(UID).jpeg")
        
        //保存したい画像のデータを変数として持つ
        var ProfileImageData: Data = Data()
        
        //プロフィール画像が存在すれば
        if UIimagedata.image != nil {
            //画像を圧縮
            ProfileImageData = (UIimagedata.image?.jpegData(compressionQuality: 0.01))!
        }
        ///imagedataに対してメタデータを付与する
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        //storageに画像を送信

        imageRef.putData(ProfileImageData, metadata: metadata) { (metaData, error) in
            ///画像送信に失敗したら
            if let error = error {
                //エラーであれば
                print(error.localizedDescription)
            ///画像送信に成功したら、圧縮済みのイメージを返す
            } else {
                callback(UIimagedata.image)
            }
        }
    }
}


///
//--------------------------------------------------
//--チャットリスト関連--
//--------------------------------------------------
///
struct ChatListSetterManager {
    var databaseRef: DatabaseReference! = Database.database().reference()
    
    func messageSetter(mockMessage:MockMessage?,text:String?,roomID:String) -> ERROR? {
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
}



///
//--------------------------------------------------
//--トークリスト一覧画面データ更新--
//--------------------------------------------------
///

struct TalkListSetterManager {
    let cloudDB = Firestore.firestore()
    var databaseRef: DatabaseReference! = Database.database().reference()
    
    ///非常に紛らわしいがライクを押下しているが更新するのはチャットデータ
    func likePushingChatDataSetter(callback:@escaping(_ Success:Bool) -> Void,message:String,messageId:String,sender:String,Date:Date,roomID:String,TargetUID:String){
        let TIMETOOLS = TimeTools()
        let date = TIMETOOLS.dateToStringFormatt(date: Date, formatFlg: .YMDHMS)
        let messageStructData:[String : Any] = ["message":message,"messageID":messageId,"sender":sender,"Date":date,"listend":false,"LikeButtonFLAG":true]
        databaseRef.child("Chat").child(roomID).childByAutoId().setValue(messageStructData) {
            error,refalence   in
            if let error = error {
                callback(false)
            } else {
                callback(true)
            }
        }
        ///相手のライク数をインクリメント
        LikeDataPushIncrement(TargetUID: TargetUID)
    }

    private func LikeDataPushIncrement(TargetUID:String) {
        ///ライクボタンを押下した相手のプロフィール情報のライク数をインクリメント
        Firestore.firestore().collection("users").document(TargetUID).setData(["likeIncrement":FieldValue.increment(1.0)],merge: true)
    }
    
    /// 相手と自分のトークリストデータを登録
    /// - Parameters:
    ///   - callback: 登録結果(相手と自分二回分のcallback発生)
    ///   - 他パラメータ割愛
    func talkListToUserInfoSetter(callback:@escaping(_ Success:Bool) -> Void, UID1:String,UID2:String,
                 message:String,sender:String,nickName1:String,nickName2:String,like:Bool,blocked:Bool){
        let frtCollectionPath:String = "users"
        let scdCollectionPath:String = "TalkUsersList"
        var data:[String:Any] = [ "UpdateAt":FieldValue.serverTimestamp(),
                              "FirstMessage":message,
                              "SendID":sender,
                              "meNickname":nickName1,
                              "youNickname":nickName2]
        
        var kindDeceid = {(KIND:setterKind,TLU:String,TDU:String) in
            switch KIND {
            case .block,.MyExtra:
                data.updateValue(nickName1, forKey: "meNickname")
                data.updateValue(nickName2, forKey: "youNickname")
                if like {
                 data.updateValue(like, forKey: "likeButtonFLAG")
                }
            case .MyNew:
                data.updateValue(nickName1, forKey: "meNickname")
                data.updateValue(nickName2, forKey: "youNickname")
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

            
            Firestore.firestore().collection(frtCollectionPath).document(TLU).collection(scdCollectionPath).document(TDU).setData(data,merge: true) {
                error in
                if let error = error {
                    callback(false)
                } else {
                    callback(true)
                }
            }
        }
        
        if blocked {
            kindDeceid(.block,UID1,UID2)
            return
        }
        
        cloudDB.collection(frtCollectionPath).document(UID1).collection(scdCollectionPath).document(UID2).getDocument(completion: { (document,err) in
            if let document = document,document.exists {
                kindDeceid(.MyExtra,UID1,UID2)
            } else {
                kindDeceid(.MyNew,UID1,UID2)
            }
        })
    
        
        cloudDB.collection(frtCollectionPath).document(UID2).collection(scdCollectionPath).document(UID1).getDocument(completion: { (document,err) in
            if let document = document,document.exists {
                kindDeceid(.YouExtra,UID2,UID1)
            } else {
                kindDeceid(.YouNew,UID2,UID1)
            }
        })
     }
}

///
//--------------------------------------------------
//--ブロック関連--
//--------------------------------------------------
///

struct BlockSetterManager {
    func blockOperater(MyUID:String,targetUID:String,blocker:Bool) {
        ///ブロック登録(相手に自分がブロックしている情報を)
        Firestore.firestore().collection("users").document(targetUID).collection("TalkUsersList").document(MyUID).setData(["blocked":blocker], merge: true)
        ///ブロック登録(自分に相手のブロック情報を)
        Firestore.firestore().collection("users").document(MyUID).collection("TalkUsersList").document(targetUID).setData(["blocker":blocker], merge: true)
    }
}

