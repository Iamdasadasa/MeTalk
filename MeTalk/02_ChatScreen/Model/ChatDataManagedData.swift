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
    let MeUID = Auth.auth().currentUser?.uid
    let testYouUID:String = ""
    var databaseRef: DatabaseReference! = Database.database().reference()
    let cloudDB = Firestore.firestore()
    
    func writeMassageData(mockMassage:MockMessage?,text:String?) {
        if let message = text,let messageId = mockMassage?.messageId,let sender = mockMassage?.sender.senderId,let date = DateFormatt(date: mockMassage?.sentDate){
            let messageStructData:[String : Any] = ["message":message,"messageID":messageId,"sender":sender,"Date":date]
            databaseRef.child("Chat").child(MeUID!).childByAutoId().setValue(messageStructData)
        } else {
            return
        }
    }

    //    ///自身のUID返却関数
    //    /// - Parameters:
    //    /// Returns:UID
    func returnUID() ->String?{
        return MeUID
    }
    
    ///引数のメッセージの送信者が自分かどうかを判断
    func isFromCurrentSender(message: MessageType) -> Bool {
        return message.sender.senderId == MeUID
    }
    
    
    func DateFormatt(date:Date?) -> String?{
        let dateFormatter = DateFormatter()
        // フォーマット設定
        dateFormatter.dateFormat = "yyyy/MM/dd/HH:mm:ss"
        //dateFormatter.dateFormat = "yyyyMMddHHmmssSSS" // ミリ秒込み

        // ロケール設定（端末の暦設定に引きづられないようにする）
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        // タイムゾーン設定（端末設定によらず固定にしたい場合）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        // 変換
        let strDate = dateFormatter.string(from: Date())
        
        return strDate
    }
}


