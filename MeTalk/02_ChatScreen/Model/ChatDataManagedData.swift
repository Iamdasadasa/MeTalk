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
    
    func writeMassageData(mockMassage:MockMessage?,text:String?,roomID:String) {
        let date = ChatDataManagedData.dateToStringFormatt(date: mockMassage?.sentDate)
        if let message = text,let messageId = mockMassage?.messageId,let sender = mockMassage?.sender.senderId{
            let messageStructData:[String : Any] = ["message":message,"messageID":messageId,"sender":sender,"Date":date]
            databaseRef.child("Chat").child(roomID).childByAutoId().setValue(messageStructData)
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
    
    

    
    
    func ChatRoomID(UID1:String,UID2:String) -> String{
        let array = [UID1,UID2]
        let sortArray = array.sorted()
        let roomID:String = sortArray[0] + "_" + sortArray[1]
        return roomID
    }
    
}

///時間管理
extension ChatDataManagedData {

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
//        case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear):
//            formatter.dateFormat = "EEEE h:mm a"
//        case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year):
//            formatter.dateFormat = "E, d MMM, h:mm a"
        default:
//            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy/MM/dd"
        }
    }
    
    ///Date⇨String
    static func dateToStringFormatt(date:Date?) -> String{
        guard let date = date else {
            print("日付変換に失敗しました。")
            return "0000/00/00"
        }
        let dateFormatter = DateFormatter()

        // フォーマット設定
        dateFormatter.dateFormat = "yyyy/MM/dd/HH:mm:ss"
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
    ///
    static func sectionDateGroup(dateArray:[String],appendDate:String) -> (flg:Bool,resultArray:[String]){
        var trueDate:Bool = false
        var resultArray:[String] = dateArray
        let dayStr  = (appendDate as NSString).substring(to: 10)
        
        if !dateArray.contains(dayStr) {
            resultArray += [dayStr]
            trueDate = true
        }

        return (trueDate,resultArray)
    }
}
