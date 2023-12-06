////
////  ChatDataManagedData.swift
////  MeTalk
////
////  Created by KOJIRO MARUYAMA on 2022/03/18.
////
//
//import Foundation
//import Firebase
//import FirebaseStorage
//import MessageKit
//
//struct subetehuyou{
//
//
//
//    let MeUID = Auth.auth().currentUser?.uid
//    var databaseRef: DatabaseReference! = Database.database().reference()
////    let cloudDB = Firestore.firestore()
    ///データベース書き込み（メッセージ）
//    func writeMassageData(mockMassage:MockMessage?,text:String?,roomID:String) {
//        let date = ChatDataManagedData.dateToStringFormatt(date: mockMassage?.sentDate, formatFlg: 0)
//        if let message = text,let messageId = mockMassage?.messageId,let sender = mockMassage?.sender.senderId{
//            let messageStructData:[String : Any] = ["message":message,"messageID":messageId,"sender":sender,"Date":date,"listend":false]
//            databaseRef.child("Chat").child(roomID).childByAutoId().setValue(messageStructData)
//        } else {
//            return
//        }
//    }
//    ///ライクボタン情報送信
//    func WriteLikeButtonInfo(message:String,messageId:String,sender:String,Date:Date,roomID:String){
//        let date = ChatDataManagedData.dateToStringFormatt(date: Date, formatFlg: 0)
//        let messageStructData:[String : Any] = ["message":message,"messageID":messageId,"sender":sender,"Date":date,"listend":false,"LikeButtonFLAG":true]
//            databaseRef.child("Chat").child(roomID).childByAutoId().setValue(messageStructData)
//    }
//
//    ///相手のユーザー情報内に自分のUIDを投入し自分のユーザー情報内に相手のUIDを投入
//    ///(ここは相手にメッセージを送信したタイミングもしくは相手をトーク一覧から発見して最初のトークを行う際に。。。かな。)
//    func talkListUserAuthUIDCreate(UID1:String,UID2:String,NewMessage:String,meNickName:String,youNickname:String,LikeButtonFLAG:Bool,blockedFlag:Int?){
//
//        ///ブロックされている場合は自身のデータ更新のみ行い終了
//        if let blockedFlag = blockedFlag {
//            ///登録処理（Cloud Firestore）自分が送信したメッセージ情報を登録
//            Firestore.firestore().collection("users").document(UID1).collection("TalkUsersList").document(UID2).setData(setDataCreate(CreateFLAG: 1, NewMessage: NewMessage, UID1: UID1, meNickName: meNickName, youNickname: youNickname, LikeButtonFLAG: LikeButtonFLAG), merge: true)
//            return
//        }
//
//        ///送信ボタンを押したときではなくランダムのユーザーリストから選んだ場合は
//        ///自分のトークリストにのみ相手のUIDを登録するようにする（相手にメッセージを送っていないのに相手側にトークリストの画面に表示されることを防ぐため）
//        ///自分のトークリスト情報に相手のUID情報を登録。
//        cloudDB.collection("users").document(UID1).collection("TalkUsersList").document(UID2).getDocument(completion: { (document,err) in
//            //既に存在していた場合
//            if let document = document,document.exists {
//                ///
//                ///登録処理（Cloud Firestore）自分が送信したメッセージ情報を登録
//                Firestore.firestore().collection("users").document(UID1).collection("TalkUsersList").document(UID2).setData(setDataCreate(CreateFLAG: 1, NewMessage: NewMessage, UID1: UID1, meNickName: meNickName, youNickname: youNickname, LikeButtonFLAG: LikeButtonFLAG), merge: true)
//                //存在していない場合
//            } else {
//                ///各登録処理（Cloud Firestore）
//                Firestore.firestore().collection("users").document(UID1).collection("TalkUsersList").document(UID2).setData(setDataCreate(CreateFLAG: 2, NewMessage: NewMessage, UID1: UID1, meNickName: meNickName, youNickname: youNickname, LikeButtonFLAG: LikeButtonFLAG), merge: true)
//            }
//        })
//        ///相手のトークリスト情報に自分のUIDを登録
//        cloudDB.collection("users").document(UID2).collection("TalkUsersList").document(UID1).getDocument(completion: { (document,err) in
//            ///既に存在していた場合
//            if let document = document,document.exists {
//                ///各登録処理（Cloud Firestore）登録処理（Cloud Firestore）自分が送信したメッセージ情報を登録
//                Firestore.firestore().collection("users").document(UID2).collection("TalkUsersList").document(UID1).setData(setDataCreate(CreateFLAG: 3, NewMessage: NewMessage, UID1: UID1, meNickName: meNickName, youNickname: youNickname, LikeButtonFLAG: LikeButtonFLAG), merge: true)
//                ///存在していない場合
//            } else {
//                ///各登録処理（Cloud Firestore）
//                Firestore.firestore().collection("users").document(UID2).collection("TalkUsersList").document(UID1).setData(setDataCreate(CreateFLAG: 4, NewMessage: NewMessage, UID1: UID1, meNickName: meNickName, youNickname: youNickname, LikeButtonFLAG: LikeButtonFLAG), merge: true)
//            }
//        })
//    }
//
//    private func setDataCreate(CreateFLAG:Int,NewMessage:String,UID1:String,meNickName:String,youNickname:String,LikeButtonFLAG:Bool) -> [String:Any]{
//        if CreateFLAG == 1 {
//            if !LikeButtonFLAG {
//                return [
//                    "UpdateAt": FieldValue.serverTimestamp(),
//                    "FirstMessage":NewMessage,
//                    "SendID":UID1,
//                    "meNickname":meNickName,
//                    "youNickname":youNickname
//                ]
//            } else {
//                return [
//                    "UpdateAt": FieldValue.serverTimestamp(),
//                    "FirstMessage":NewMessage,
//                    "SendID":UID1,
//                    "meNickname":meNickName,
//                    "youNickname":youNickname,
//                    "likeButtonFLAG":LikeButtonFLAG
//                ]
//            }
//
//        } else if CreateFLAG == 2 {
//            if !LikeButtonFLAG {
//                return [
//                    "createdAt": FieldValue.serverTimestamp(),
//                    "UpdateAt": FieldValue.serverTimestamp(),
//                    "FirstMessage":NewMessage,
//                    "SendID":UID1,
//                    "meNickname":meNickName,
//                    "youNickname":youNickname
//                ]
//            } else {
//                return [
//                    "createdAt": FieldValue.serverTimestamp(),
//                    "UpdateAt": FieldValue.serverTimestamp(),
//                    "FirstMessage":NewMessage,
//                    "SendID":UID1,
//                    "meNickname":meNickName,
//                    "youNickname":youNickname,
//                    "likeButtonFLAG":LikeButtonFLAG
//                ]
//            }
//
//        } else if CreateFLAG == 3 {
//            if !LikeButtonFLAG {
//                return [
//                    "UpdateAt": FieldValue.serverTimestamp(),
//                    "FirstMessage":NewMessage,
//                    "SendID":UID1,
//                    ///相手の方に書き込み場合は逆転させる
//                    "meNickname":youNickname,
//                    "youNickname":meNickName
//                ]
//            } else {
//                return [
//                    "UpdateAt": FieldValue.serverTimestamp(),
//                    "FirstMessage":NewMessage,
//                    "SendID":UID1,
//                    ///相手の方に書き込み場合は逆転させる
//                    "meNickname":youNickname,
//                    "youNickname":meNickName,
//                    "likeButtonFLAG":LikeButtonFLAG
//                ]
//            }
//
//        } else if CreateFLAG == 4 {
//            if !LikeButtonFLAG {
//                return [
//                    "createdAt": FieldValue.serverTimestamp(),
//                    "UpdateAt": FieldValue.serverTimestamp(),
//                    "FirstMessage":NewMessage,
//                    "SendID":UID1,
//                    ///相手の方に書き込み場合は逆転させる
//                    "meNickname":youNickname,
//                    "youNickname":meNickName
//                ]
//            } else {
//                return [
//                    "createdAt": FieldValue.serverTimestamp(),
//                    "UpdateAt": FieldValue.serverTimestamp(),
//                    "FirstMessage":NewMessage,
//                    "SendID":UID1,
//                    ///相手の方に書き込み場合は逆転させる
//                    "meNickname":youNickname,
//                    "youNickname":meNickName,
//                    "likeButtonFLAG":LikeButtonFLAG
//                ]
//            }
//
//        } else {
//            ///ここにくることはない
//            return [
//                "NOTDATE":NewMessage
//            ]
//        }
//    }
//
//    //    ///自身のUID返却関数
//    //    /// - Parameters:
//    //    /// Returns:UID
//    func returnUID() ->String?{
//        return MeUID
//    }
//
//
//
//
//
//}
//
/////時間管理
//extension ChatDataManagedData {
//
//    // MARK: - Methods
//
//}
