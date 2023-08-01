//
//  HostingDataController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/06/16.
//

import Foundation
import Firebase
import FirebaseStorage
import AlgoliaSearchClient

///
//--------------------------------------------------
//--ユーザープロフィール取得--
//--------------------------------------------------
///

struct TargetProfileGetterManager {
    ///ユーザー情報取得
    func getter(callback: @escaping  (ProfileInfoLocalObject,Error?) -> Void,UID:String) {
        
        var PROFILEINFOLOCAL:ProfileInfoLocalObject = ProfileInfoLocalObject()
        
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
}

///
//--------------------------------------------------
//--画像データ取得--
//--------------------------------------------------
///
struct ContentsGetterManager {

    let STORAGE = Storage.storage()
    let host = "gs://metalk-f132e.appspot.com"
    
    func ImageDataGetter(callback: @escaping (ListUsersImageLocal,Error?) -> Void,UID:String,UpdateTime:Date) {
        let TIMETOOL = TIME()
        let CONTENTSLOCAL = ListUsersImageLocal()
        CONTENTSLOCAL.lcl_UID = UID
        CONTENTSLOCAL.lcl_UpdataDate = TIMETOOL.pastTimeGet()
        
        STORAGE.reference(forURL: host).child("profileImage").child("\(UID).jpeg").getMetadata {metadata, error in

            if error != nil {
                callback(CONTENTSLOCAL,error)
                return
            }
            
            guard let metadata = metadata else {
                callback(CONTENTSLOCAL, nil)
                return
            }
            
            if metadata.updated! > UpdateTime {
                STORAGE.reference(forURL: host).child("profileImage").child("\(UID).jpeg")
                    .getData(maxSize: 1024 * 1024 * 10) { (data: Data?, error: Error?) in
                    ///ユーザーIDのプロフィール画像が取得できなかったらnilを返す
                    if error != nil {
                        callback(CONTENTSLOCAL, error)
                        return
                    }
                    ///ユーザーIDのプロフィール画像を設定していたらその画像を取得してリターン
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        CONTENTSLOCAL.profileImage = image!

                        callback(CONTENTSLOCAL,nil)
                        return
                    }
                }
            }
        }
    }
}

///
//--------------------------------------------------
//--チャットリスト関連--
//--------------------------------------------------
///
struct ChatListGetterManager {
    let cloudDB = Firestore.firestore()
    var databaseRef: DatabaseReference! = Database.database().reference()
    
    func TargetUserInfoGetter(callback: @escaping  (ListUsersInfoLocal,Error?) -> Void,MYUID:String,UID2:String) {
        var TARGETINFO = ListUsersInfoLocal()

        let userDocuments = cloudDB.collection("users").document(MYUID).collection("TalkUsersList").document(UID2)
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
}

///
//--------------------------------------------------
//--トークリスト関連--
//--------------------------------------------------
///
///DI用プロトコル
protocol TalkListGetterManagerDI {
    func onlineUsersGetter(callback: @escaping ([ProfileInfoLocalObject],Error?) -> Void, latedTime:Date?,oneMinuteWithin:Bool,limitCount:Int)
}
///ユーザー取得時のフィルター
class QueryFilter {
    let COMVERTER = TimeTools()
    let cloudDB = Firestore.firestore()
    var fetchDocument:DocumentSnapshot?
    var scrollCounter:Int = 1
    let fixCount = 10
    var minAge: Int?
    var maxAge: Int?
    var gender: Int?
    var area: String?

    init(minAge: Int?, maxAge: Int?, gender: Int?, area: String?) {
        self.minAge = minAge
        self.maxAge = maxAge
        self.gender = gender
        self.area = area
    }
    
    func apply() -> Query {
        //FireStoreでIndexを貼った上で実行
        var BaseQuery = cloudDB.collection("users").order(by: "updatedAt", descending: true).limit(to: fixCount * scrollCounter)
        var filteredQuery = BaseQuery
        // 年齢範囲のフィルター
        if let minAge = minAge, let maxAge = maxAge {
            ///生年月日の桁数に変換
            let minYearToDate = AgeCalculator.convertDefaultYearOfBirth(targetYear: minAge, minOrMax: .min)
            let maxYearToDate =  AgeCalculator.convertDefaultYearOfBirth(targetYear: maxAge, minOrMax: .max)
            ///適用
            filteredQuery = filteredQuery.whereField("age", isGreaterThanOrEqualTo: maxYearToDate)
            filteredQuery = filteredQuery.whereField("age", isLessThanOrEqualTo: minYearToDate)
        }
        
        // 性別のフィルター
        if let gender = gender {
            filteredQuery = filteredQuery.whereField("Sex", isEqualTo: gender)
        }
        
        // 住まいのフィルター
        if let area = area {
            filteredQuery = filteredQuery.whereField("area", isEqualTo: area)
        }
        
        return filteredQuery
    }
}

class TalkListGetterManager{
    
    func onlineUsersDataGetter(callback: @escaping ([ProfileInfoLocalObject],Error?) -> Void,filter:QueryFilter) {

        filter.apply().getDocuments(){ (querySnapshot, err) in
            
            var USERLIST:[ProfileInfoLocalObject] = []
            if let err = err {
                callback([ProfileInfoLocalObject()],err)
                return
            }
            for USER in querySnapshot!.documents {
                if let USERINFO = self.dataMapping(HostData: USER){

                    USERLIST.append(USERINFO)
                }
            }
            
            callback(USERLIST, nil)
        }
    }
    
    ///Firebaseのデータを成形して格納後返却
    /// - Parameter HostData: Firebaseから取得してきたデータ
    /// - Returns: マッピング後のデータ
    func dataMapping(HostData:DocumentSnapshot) -> ProfileInfoLocalObject? {
        let USERINFO:ProfileInfoLocalObject = ProfileInfoLocalObject()
        let UID = HostData.documentID.trimmingCharacters(in: .whitespaces)
        if let SEX = HostData["Sex"] as? Int,
           let ABOUTMESSAGE = HostData["aboutMeMassage"] as? String,
           let AGE = HostData["age"] as? Int,
           let AREA = HostData["area"] as? String,
           let UPDATEDATE = HostData["updatedAt"] as? Timestamp,
           let CREATEDAT = HostData["createdAt"] as? Timestamp,
           let NICKNAME = HostData["nickname"] as? String {
        
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
            
            return USERINFO
        }
        return nil
    }
    
}



///
//--------------------------------------------------
//--ブロックリスト関連--
//--------------------------------------------------
///
struct BlockListGetterManager {
    let cloudDB = Firestore.firestore()
    var databaseRef: DatabaseReference! = Database.database().reference()
    func blockUserDataGet(callback: @escaping  ([String]) -> Void,UID:String?) {
        var blockUserList:[String] = []
        guard let UID = UID else {
            print("UIDが確認できませんでした")
            return
        }
        ///ここでデータにアクセスしている（非同期処理）
        let userDocuments = cloudDB.collection("users").document(UID).collection("blockUser")
        userDocuments.getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for blockuserinfo in querySnapshot!.documents {
                    ///ここでブロックリストのユーザーID一覧を格納
                    blockUserList.append(blockuserinfo.documentID)
                }
                callback(blockUserList)
            }
        }
    }

}

    
