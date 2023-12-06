//
//  HostingDataGetter.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/06/16.
//

import Foundation
import Firebase
import FirebaseStorage
import MessageKit


///
//--------------------------------------------------
//--ユーザー初期登録--
//--------------------------------------------------
///
///DIプロトコル
protocol ProfileRegisterProtocol {
    func signUpAuthRegister(callback: @escaping (HostingResult) -> Void)
    func userInfoRegister(callback: @escaping (HostingResult) -> Void,USER:ProfileInfoLocalObject,uid:String,signUpFlg:signUpFlg)
}
//登録ユーザー種別
enum signUpFlg:String {
    case general = "General"
    case dammy = "Dammy"
}
//初期ユーザー登録処理マネージャー
struct RegisterHostSetter:ProfileRegisterProtocol{
    ///Fire Authにユーザー権限登録
    func signUpAuthRegister(callback: @escaping (HostingResult) -> Void) {
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
    func userInfoRegister(callback: @escaping (HostingResult) -> Void,USER:ProfileInfoLocalObject,uid:String,signUpFlg:signUpFlg){
        Firestore.firestore().collection("users").document(uid).setData([
            "nickname": USER.lcl_NickName,
            "Sex": USER.lcl_Sex,
            "aboutMeMassage":USER.lcl_AboutMeMassage,
            "area":USER.lcl_Area,
            "age":USER.lcl_Age,
            "signUpFlg":signUpFlg.rawValue,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
            "likeIncrement":FieldValue.increment(0.0)
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
    case aboutMe
    case area
    
    var dataObjectName: String {
        switch self {
        case .nickName:
            return "nickname"
        case .aboutMe:
            return "aboutMeMassage"
        case .area:
            return "area"
        }
    }
}
//ユーザー情報保存マネージャー
struct ProfileHostSetter {
    ///それぞれのデータ情報を個別にサーバー保存
    func profileUpload(KIND:updateKind,Data:ProfileInfoLocalObject) -> Error? {
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
        case .area:
            guard let area = Data.lcl_Area else {
                return ERROR.err
            }
            Firestore.firestore().collection(collectionPath).document(Data.lcl_UID!).updateData([KIND.dataObjectName:area])
        }
        
        Firestore.firestore().collection(collectionPath).document(Data.lcl_UID!).updateData([updateObjectName:FieldValue.serverTimestamp()])
        //更新時間を最新に
        updateTime()
        return nil
    }
}
///
//--------------------------------------------------
//--画像データ関連--
//--------------------------------------------------
///
//画像データ保存マネージャー
struct ContentsHostSetter {
    let STORAGE = Storage.storage()     //アクセス変数
    let host = "gs://metalk-f132e.appspot.com"      //アクセス先
    //アクセス開始
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
        if let image = UIimagedata.image {
            //画像を圧縮
            guard let DATA = compressImageTo20KB(image) else {
                callback(nil)
                return
            }
            ProfileImageData = DATA
//            ProfileImageData = (UIimagedata.image?.jpegData(compressionQuality: 0.01))!
        }
        ///imagedataに対してメタデータを付与する
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        //storageに画像を送信
        imageRef.putData(ProfileImageData, metadata: metadata) { (metaData, error) in
            ///画像送信に失敗したら
            if let error = error {
                callback(nil)
            ///画像送信に成功したら、圧縮済みのイメージを返す
            } else {
                callback(UIimagedata.image)
                //更新時間を最新に
                updateTime()
            }
        }
    }
    //段階的に画像を100~200kb程度を目安に圧縮していく処理
    private func compressImageTo20KB(_ image: UIImage) -> Data? {
        var compression: CGFloat = 1.0
        let maxFileSize: CGFloat = 200 * 1024 // 200KB
        var compressionMag:CGFloat = 0.1

        var imageData = image.jpegData(compressionQuality: compression)

        while (imageData?.count ?? 0) > Int(maxFileSize){

            if compression > compressionMag + compressionMag  {
                compression -= compressionMag
                imageData = image.jpegData(compressionQuality: compression)
            } else {
                //クオリティを10/1にしても指定バイトまで圧縮されなかった場合は強硬手段でサイズを8/1ずつ強制的に下げていく
                var NewIMAGE = UIImage(data: imageData!)!
                NewIMAGE = NewIMAGE.resize(targetSize: CGSize(width: NewIMAGE.size.width / 5, height: NewIMAGE.size.height / 5))
                imageData = NewIMAGE.jpegData(compressionQuality: compression)

            }
        }

        return imageData
    }
    
}


///
//--------------------------------------------------
//--チャットデータ関連--
//--------------------------------------------------
///
//チャットデータ保存マネージャー
struct ChatDataHostSetterManager {
    var databaseRef = Database.database().reference()   //アクセス変数
    ///チャットデータ保存
    func messageUpload(callback:@escaping (Error?) -> Void ,Message:MessageType,text:String,roomID:String,Like:Bool,receiverID:String,senderNickname:String) -> ERROR? {
        
        let date = {(DateTime:Date) in
            let TOOLS = TimeTools()
            return TOOLS.dateToStringFormatt(date: DateTime, formatFlg: .YMDHMS)
        }
        
        let messageData:[String:Any] = [
            "message":text,
            "messageID":Message.messageId,
            "sender":Message.sender.senderId,
            "senderNickname":senderNickname,
            "receiverID":receiverID,
            "Date":date(Message.sentDate),
            "listend":false,
            "LikeButtonFLAG":Like
        ]
        
        databaseRef.child("Chat").child(roomID).childByAutoId().setValue(messageData) { (err,ref) in
            if let err = err{
                callback(err)
            } else {
                callback(nil)
            }
        }
        return nil
    }
    
    ///既読をつける
    func ProcessListendFetch(childKey:String,roomID:String) {
        Database.database().reference().child("Chat").child(roomID).child(childKey).updateChildValues(["listend":true])
        //更新時間を最新に
        updateTime()
    }
}
///
//--------------------------------------------------
//--リスト一覧画面データ更新--
//--------------------------------------------------
///
//リストユーザー情報取得マネージャー//
struct ListDataHostSetter {
    let cloudDB = Firestore.firestore()     ///アクセス変数
    var databaseRef = Database.database().reference()       ///アクセス変数

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
                                  "youNickname":nickName2,
                                  "likeButtonFLAG":like,
                                  "listend":false]
        let kindDeceid = {(KIND:setterKind) -> [String:Any] in
            switch KIND {
            case .Me:
                data.updateValue(nickName1, forKey: "meNickname")
                data.updateValue(nickName2, forKey: "youNickname")
                data.updateValue(like, forKey: "likeButtonFLAG")
                return data
            case .You:
                data.updateValue(nickName2, forKey: "meNickname")
                data.updateValue(nickName1, forKey: "youNickname")
                data.updateValue(like, forKey: "likeButtonFLAG")
                return data
            }
        }
        let db = Firestore.firestore()
        // トランザクションを開始
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                // 自分のメッセージリスト
                let myDocRef = Firestore.firestore().collection(frtCollectionPath).document(UID1).collection(scdCollectionPath).document(UID2)
                transaction.setData(kindDeceid(.Me), forDocument: myDocRef, merge: true)
                ///ブロックされていない場合のみ相手の情報も書き込み
                if !blocked {
                    // 相手のメッセージリスト
                    let targetDocRef = Firestore.firestore().collection(frtCollectionPath).document(UID2).collection(scdCollectionPath).document(UID1)
                    transaction.setData(kindDeceid(.You), forDocument: targetDocRef, merge: true)
                    
                    //もしライクデータだった場合相手のライク数にインクリメント
                    if like {
                        let targetLikeDocRef =
                        Firestore.firestore().collection("users").document(UID2)
                        transaction.setData(["likeIncrement":FieldValue.increment(1.0)], forDocument: targetLikeDocRef,merge: true)
                    }
                }
                return nil
            } catch (let fetchError as NSError) {
                // エラーが発生した場合、トランザクションを中断してロールバック
                errorPointer?.pointee = fetchError
                return nil
            }
        }) { (result, error) in
            if error != nil {
                // トランザクションが失敗した場合のエラーハンドリング
                callback(false)
            } else {
                callback(true)
                //更新時間を最新に
                updateTime()
            }
        }
    }

    func talkListNewMessageReaded(selfUID:String,targetUID:String) {
        let db = Firestore.firestore() ///FireStore変数
        db.collection("users")
            .document(selfUID)
            .collection("TalkUsersList")
            .document(targetUID)
            .updateData(["listend":true])
    }

}

///
//--------------------------------------------------
//--ブロック関連--
//--------------------------------------------------
///

struct BlockHostSetterManager {
    func blockingOperater(callback: @escaping(Bool) -> Void,MyUID:String,targetUID:String,block:Bool,nickname:String) {
        let db = Firestore.firestore()
        // トランザクションを開始
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                // ブロックした側の操作
                let myDocRef = db.collection("users").document(MyUID).collection("block").document(targetUID)
                transaction.setData(["IBlocked": block,"nickname":nickname], forDocument: myDocRef, merge: true)

                // ブロックされた側の操作
                let targetDocRef = db.collection("users").document(targetUID).collection("block").document(MyUID)
                transaction.setData(["MeBlocked": block], forDocument: targetDocRef, merge: true)

                return nil
            } catch (let fetchError as NSError) {
                // エラーが発生した場合、トランザクションを中断してロールバック
                errorPointer?.pointee = fetchError
                return nil
            }
        }) { (result, error) in
            if error != nil {
                // トランザクションが失敗した場合のエラーハンドリング
                callback(false)
            } else {
                callback(true)
            }
        }
    }
 }

///
//--------------------------------------------------
//--通報関連--
//--------------------------------------------------
///
enum ReportReason: String, CaseIterable {
    case spam = "スパム/業務的な宣伝"
    case sexualCommunication = "性的コミュニケーション"
    case harassment = "迷惑行為"
    case other = "その他"
}

struct reportHostSetterManager {
    func reportMemberSetter(callback:@escaping(Bool) -> Void,selfUID:String,targetUID:String,roomID:String,kind:ReportReason) {
        ///通報内容判断
        var reportDetail = ""
        switch kind {
        case .spam:
            reportDetail = kind.rawValue
        case .sexualCommunication:
            reportDetail = kind.rawValue
        case .harassment:
            reportDetail = kind.rawValue
        case .other:
            reportDetail = kind.rawValue
        }
        
        Firestore.firestore().collection("reportMember").addDocument(
            data: ["reportDetail":reportDetail,
             "roomID":roomID,
             "reportingUID":selfUID,
             "reportedUID":targetUID,
             "reportingFlag":false,
             "reportTime":FieldValue.serverTimestamp()]
        ) { error in
            if let error = error {
                // エラーが発生した場合の処理
                callback(false)
            } else {
                // 成功した場合の処理
                callback(true)
            }
        }
    }
    
    func reportMemberCompFlagSetter(callback:@escaping(Bool) -> Void,reportID:String) {
        Firestore.firestore().collection("reportMember").document(reportID).updateData(["reportingFlag":true]) {  error in
            if error != nil {
                callback(false)
            } else {
                callback(true)
            }
        }
    }
    
    func reportedNotificationCompletedSetter(UID:String) {
        Firestore.firestore().collection("users").document(UID).updateData(["reportFlag":0])
    }
    
    func reportExecuteSetter(callback:@escaping(Bool) -> Void,targetUID:String,flag:Int,reportID:String) {
        Firestore.firestore().runTransaction( { transaction, errPoint in
            do {
                //対象のユーザーに通報処理
                let executeDoc = Firestore.firestore().collection("users").document(targetUID)
                transaction.updateData(["reportFlag":flag,
                                        "reportCount":FieldValue.increment(1.0)], forDocument: executeDoc)
                //レポート一覧にて処理完了フラグ
                let completionDoc = Firestore.firestore().collection("reportMember").document(reportID)
                transaction.updateData( ["reportingFlag":true], forDocument: completionDoc)
                
                return nil
            } catch (let fetchError as NSError) {
                // エラーが発生した場合、トランザクションを中断してロールバック
                errPoint?.pointee = fetchError
                return nil
            }
        }) { (result, error) in
            if error != nil {
                // トランザクションが失敗した場合のエラーハンドリング
                callback(false)
            } else {
                callback(true)
            }
        }
    }
}

///
//--------------------------------------------------
//--管理者権限関連--
//--------------------------------------------------
///
///
struct adminHostSetterManager {
    
    struct dammyUserRequiredData {
        let profileImage:UIImage
        let nickName:String
        let aboutMe:String
        let area:String
        let birth:String
        let gender:Int
    }
    
    func memberUIDDeleate(UID:String) {
        Firestore.firestore().collection("admin").document(UID).delete()
    }
    
    func memberUIDSetter(UID:String,password:String) {
        Firestore.firestore().collection("admin").document(UID).setData([
            "accessPassword": password,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }

    func dammyUserUpdateTimeSetter(callback:@escaping(Bool) -> Void) {

        // Firestoreの参照
        let db = Firestore.firestore()
        // フィールドに合致するドキュメントを取得するクエリ
        let query = db.collection("users").whereField("signUpFlg", isEqualTo: "Dammy")

        // バッチ書き込みを初期化
        let batch = db.batch()

        // クエリに合致するドキュメントを取得し、更新をバッチに追加
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                callback(false)
            } else {
                for document in snapshot!.documents {
                    let docRef = db.collection("users").document(document.documentID)
                    batch.updateData(["updatedAt": Date()], forDocument: docRef)
                }

                // バッチ書き込みを実行
                batch.commit { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                        callback(false)
                    } else {
                        callback(true)
                    }
                }
            }
        }

    }
}
//更新時間を最新に
func updateTime() {
    var Singleton = myProfileSingleton()
    Firestore.firestore().collection("users").document(Singleton.selfUIDGetter()!).updateData(["updatedAt":Date()])
}

struct FCMTokenSetterManager {
    let collectionPath = "users"
    ///トークンを取得後にデータベースにセット
    func tokenSetter(callback:@escaping(Bool) -> Void,UID:String) {
        
        ///一旦ドキュメントを取ってくる
        Firestore.firestore().collection(collectionPath).document(UID).getDocument { document, err in
            guard let document = document else {
                ///ドキュメントの存在が確認できない場合Return（ここに入る事はない）
                return
            }
            guard let serverToken = document["FCMTokenID"] as? String,let TokenUpdateTime = document["TokenUpdate"] as? Timestamp else {
                ///トークンの存在が確認できなかったので更新
                tokenSetting(callback: { result in
                    callback(result)
                }, UID: UID)
                return
            }
            ///Tokenの更新が一ヶ月以内か
            if TimeCalculator.isMoreThanOneMonthAgo(from: TokenUpdateTime.dateValue()) {
                ///一ヶ月を過ぎているので更新
                tokenSetting(callback: { result in
                    callback(result)
                }, UID: UID)
            } else {
                ///トークンに問題無しのため何もせず返却
                callback(true)
            }
        }
    }
    
    private func tokenSetting(callback:@escaping(Bool) -> Void,UID:String) {
        ///トークンを取得
        Messaging.messaging().token { token, error in
            ///トークン取得に失敗
            if let error = error {
                callback(false)
            } else {
                if let token = token {
                    ///取得したトークンをFirebaseに保存
                    Firestore.firestore().collection(collectionPath).document(UID).updateData(["FCMTokenID":token,"TokenUpdate":Date()]) {  error in
                        if error != nil {
                          ///Firebaseに保存に失敗
                          callback(false)
                        } else {
                          ///Firebaseに保存に成功
                          callback(true)
                        }
                    }
                }
            }
        }
    }
    
}
