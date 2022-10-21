//
//  ChatDataManagedData.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/18.
//

import Foundation
import Firebase
import FirebaseStorage
import MessageKit

struct ChatDataManagedData{
    private let formatter = DateFormatter()

    
    let MeUID = Auth.auth().currentUser?.uid
    var databaseRef: DatabaseReference! = Database.database().reference()
    let cloudDB = Firestore.firestore()
    ///データベース書き込み（メッセージ）
    func writeMassageData(mockMassage:MockMessage?,text:String?,roomID:String) {
        let date = ChatDataManagedData.dateToStringFormatt(date: mockMassage?.sentDate, formatFlg: 0)
        if let message = text,let messageId = mockMassage?.messageId,let sender = mockMassage?.sender.senderId{
            let messageStructData:[String : Any] = ["message":message,"messageID":messageId,"sender":sender,"Date":date,"listend":false]
            databaseRef.child("Chat").child(roomID).childByAutoId().setValue(messageStructData)
        } else {
            return
        }
    }
    ///ライクボタン情報送信
    func WriteLikeButtonInfo(message:String,messageId:String,sender:String,Date:Date,roomID:String){
        let date = ChatDataManagedData.dateToStringFormatt(date: Date, formatFlg: 0)
        let messageStructData:[String : Any] = ["message":message,"messageID":messageId,"sender":sender,"Date":date,"listend":false,"LikeButtonFLAG":true]
            databaseRef.child("Chat").child(roomID).childByAutoId().setValue(messageStructData)
    }
    
    ///相手のユーザー情報内に自分のUIDを投入し自分のユーザー情報内に相手のUIDを投入
    ///(ここは相手にメッセージを送信したタイミングもしくは相手をトーク一覧から発見して最初のトークを行う際に。。。かな。)
    func talkListUserAuthUIDCreate(UID1:String,UID2:String,NewMessage:String,meNickName:String,youNickname:String,LikeButtonFLAG:Bool){

        ///送信ボタンを押したときではなくランダムのユーザーリストから選んだ場合は
        ///自分のトークリストにのみ相手のUIDを登録するようにする（相手にメッセージを送っていないのに相手側にトークリストの画面に表示されることを防ぐため）
        ///自分のトークリスト情報に相手のUID情報を登録。
        cloudDB.collection("users").document(UID1).collection("TalkUsersList").document(UID2).getDocument(completion: { (document,err) in
            //既に存在していた場合
            if let document = document,document.exists {
                ///
                ///登録処理（Cloud Firestore）自分が送信したメッセージ情報を登録
                Firestore.firestore().collection("users").document(UID1).collection("TalkUsersList").document(UID2).setData(setDataCreate(CreateFLAG: 1, NewMessage: NewMessage, UID1: UID1, meNickName: meNickName, youNickname: youNickname, LikeButtonFLAG: LikeButtonFLAG), completion: { error in
                    if let error = error {
                        ///失敗した場合
                        print(error.localizedDescription)
                        return
                    }
                })
            //存在していない場合
            } else {
                ///各登録処理（Cloud Firestore）
                Firestore.firestore().collection("users").document(UID1).collection("TalkUsersList").document(UID2).setData(setDataCreate(CreateFLAG: 2, NewMessage: NewMessage, UID1: UID1, meNickName: meNickName, youNickname: youNickname, LikeButtonFLAG: LikeButtonFLAG), completion: { error in
                    if let error = error {
                        ///失敗した場合
                        print(error.localizedDescription)
                        return
                    }
                })
            }
        })
        ///相手のトークリスト情報に自分のUIDを登録
        cloudDB.collection("users").document(UID2).collection("TalkUsersList").document(UID1).getDocument(completion: { (document,err) in
            ///既に存在していた場合
            if let document = document,document.exists {
                ///各登録処理（Cloud Firestore）登録処理（Cloud Firestore）自分が送信したメッセージ情報を登録
                Firestore.firestore().collection("users").document(UID2).collection("TalkUsersList").document(UID1).setData(setDataCreate(CreateFLAG: 3, NewMessage: NewMessage, UID1: UID1, meNickName: meNickName, youNickname: youNickname, LikeButtonFLAG: LikeButtonFLAG), completion: { error in
                    if let error = error {
                        ///失敗した場合
                        print(error.localizedDescription)
                        return
                    }
                })
            ///存在していない場合
            } else {
                ///各登録処理（Cloud Firestore）
                Firestore.firestore().collection("users").document(UID2).collection("TalkUsersList").document(UID1).setData(setDataCreate(CreateFLAG: 4, NewMessage: NewMessage, UID1: UID1, meNickName: meNickName, youNickname: youNickname, LikeButtonFLAG: LikeButtonFLAG), completion: { error in
                    if let error = error {
                        ///失敗した場合
                        print(error.localizedDescription)
                        return
                    }
                })
            }
        })        
    }
    
    private func setDataCreate(CreateFLAG:Int,NewMessage:String,UID1:String,meNickName:String,youNickname:String,LikeButtonFLAG:Bool) -> [String:Any]{
        if CreateFLAG == 1 {
            if !LikeButtonFLAG {
                return [
                    "UpdateAt": FieldValue.serverTimestamp(),
                    "FirstMessage":NewMessage,
                    "SendID":UID1,
                    "meNickname":meNickName,
                    "youNickname":youNickname
                ]
            } else {
                return [
                    "UpdateAt": FieldValue.serverTimestamp(),
                    "FirstMessage":NewMessage,
                    "SendID":UID1,
                    "meNickname":meNickName,
                    "youNickname":youNickname,
                    "likeButtonFLAG":LikeButtonFLAG
                ]
            }

        } else if CreateFLAG == 2 {
            if !LikeButtonFLAG {
                return [
                    "createdAt": FieldValue.serverTimestamp(),
                    "UpdateAt": FieldValue.serverTimestamp(),
                    "FirstMessage":NewMessage,
                    "SendID":UID1,
                    "meNickname":meNickName,
                    "youNickname":youNickname
                ]
            } else {
                return [
                    "createdAt": FieldValue.serverTimestamp(),
                    "UpdateAt": FieldValue.serverTimestamp(),
                    "FirstMessage":NewMessage,
                    "SendID":UID1,
                    "meNickname":meNickName,
                    "youNickname":youNickname,
                    "likeButtonFLAG":LikeButtonFLAG
                ]
            }
            
        } else if CreateFLAG == 3 {
            if !LikeButtonFLAG {
                return [
                    "UpdateAt": FieldValue.serverTimestamp(),
                    "FirstMessage":NewMessage,
                    "SendID":UID1,
                    ///相手の方に書き込み場合は逆転させる
                    "meNickname":youNickname,
                    "youNickname":meNickName
                ]
            } else {
                return [
                    "UpdateAt": FieldValue.serverTimestamp(),
                    "FirstMessage":NewMessage,
                    "SendID":UID1,
                    ///相手の方に書き込み場合は逆転させる
                    "meNickname":youNickname,
                    "youNickname":meNickName,
                    "likeButtonFLAG":LikeButtonFLAG
                ]
            }

        } else if CreateFLAG == 4 {
            if !LikeButtonFLAG {
                return [
                    "createdAt": FieldValue.serverTimestamp(),
                    "UpdateAt": FieldValue.serverTimestamp(),
                    "FirstMessage":NewMessage,
                    "SendID":UID1,
                    ///相手の方に書き込み場合は逆転させる
                    "meNickname":youNickname,
                    "youNickname":meNickName
                ]
            } else {
                return [
                    "createdAt": FieldValue.serverTimestamp(),
                    "UpdateAt": FieldValue.serverTimestamp(),
                    "FirstMessage":NewMessage,
                    "SendID":UID1,
                    ///相手の方に書き込み場合は逆転させる
                    "meNickname":youNickname,
                    "youNickname":meNickName,
                    "likeButtonFLAG":LikeButtonFLAG
                ]
            }

        } else {
            ///ここにくることはない
            return [
                "NOTDATE":NewMessage
            ]
        }
    }
    
    //    ///自身のUID返却関数
    //    /// - Parameters:
    //    /// Returns:UID
    func returnUID() ->String?{
        return MeUID
    }
    
    

    
    ///ChatのルームIDを生成する
    func ChatRoomID(UID1:String,UID2:String) -> String{
        let array = [UID1,UID2]
        let sortArray = array.sorted()
        let roomID:String = sortArray[0] + "_" + sortArray[1]
        return roomID
    }
}

///時間管理
extension ChatDataManagedData {
    
    ///過去時間を持ってくる関数(インスタンス化なしで呼び出し可能)
    static func pastTimeGet() -> Date{
        
        let calendar = Calendar(identifier: .gregorian)
        let date = Date()
        let modifiedDate = calendar.date(byAdding: .day, value: -10000, to: date)!
        
        return modifiedDate
        
    }

    // MARK: - Methods

    public func string(from date: Date) -> String {
        configureDateFormatter(for: date)
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    public func attributedString(from date: Date, with attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let dateString = string(from: date)
        return NSAttributedString(string: dateString, attributes: attributes)
    }

    public func configureDateFormatter(for date: Date) {
        switch true {
        case Calendar.current.isDateInToday(date) || Calendar.current.isDateInYesterday(date):
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .short
            formatter.timeStyle = .none
        default:
//            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy/MM/dd"
        }
    }
    
    ///Date⇨String
    static func dateToStringFormatt(date:Date?,formatFlg:Int) -> String{
        guard let date = date else {
            print("日付変換に失敗しました。")
            return "0000/00/00"
        }
        let dateFormatter = DateFormatter()

        // フォーマット設定
        switch formatFlg{
        case 1:
            dateFormatter.dateFormat = "HH:mm"
        default:
            dateFormatter.dateFormat = "yyyy/MM/dd/HH:mm:ss"
        }
        //dateFormatter.dateFormat = "yyyyMMddHHmmssSSS" // ミリ秒込み

        // ロケール設定（端末の暦設定に引きづられないようにする）
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        // タイムゾーン設定（端末設定によらず固定にしたい場合）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        // 変換
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    ///String⇨Date
    static func stringToDateFormatte(date:String) -> Date{
        // Date ⇔ Stringの相互変換をしてくれるすごい人
        let dateFormatter = DateFormatter()
        // フォーマット設定
        dateFormatter.dateFormat = "yyyy/MM/dd/HH:mm:ss"
        //dateFormatter.dateFormat = "yyyyMMddHHmmssSSS" // ミリ秒込み

        // ロケール設定（端末の暦設定に引きづられないようにする）
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        // タイムゾーン設定（端末設定によらず、どこの地域の時間帯なのかを指定する）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        //dateFormatter.timeZone = TimeZone(identifier: "Etc/GMT") // 世界標準時

        // 変換
        let date = dateFormatter.date(from: date)

        return date!
    }
}
