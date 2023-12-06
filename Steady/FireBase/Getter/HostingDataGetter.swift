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
import MessageKit

///
//--------------------------------------------------
//--ユーザープロフィール取得--
//--------------------------------------------------
///

//プロフィール情報取得マネージャー//
struct ProfileHostGetter {
    ///ユーザー情報取得
    func mappingDataGetter(callback: @escaping  (ProfileInfoLocalObject,Error?) -> Void,UID:String) {
        let PROFILEINFOLOCAL = ProfileInfoLocalObject()     ///返却するローカルな型
        ///アクセス開始
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
                ///マッピング
                PROFILEINFOLOCAL.lcl_UID = UID
                PROFILEINFOLOCAL.lcl_NickName = nickname
                PROFILEINFOLOCAL.lcl_AboutMeMassage = aboutMeMassage
                PROFILEINFOLOCAL.lcl_Age = age
                PROFILEINFOLOCAL.lcl_Area = area
                PROFILEINFOLOCAL.lcl_Sex = Sex
                PROFILEINFOLOCAL.lcl_DateCreatedAt = createdAt.dateValue()
                PROFILEINFOLOCAL.lcl_DateUpdatedAt = updatedAt.dateValue()
                ///返却
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
//画像取得マネージャー//
struct ContentsHostGetter {
    let STORAGE = Storage.storage()     ///アクセス変数
    let host = "gs://metalk-f132e.appspot.com"  ///アクセス先
    ///画像データ情報取得
    func MappingDataGetter(callback: @escaping (listUsersImageLocalObject,Error?) -> Void,UID:String,UpdateTime:Date) {
        let TIMETOOL = TIME()       ///時間管理構造体
        let CONTENTSLOCAL = listUsersImageLocalObject()     ///返却するローカルな構造体
        CONTENTSLOCAL.lcl_UID = UID     ///ターゲットUID
        CONTENTSLOCAL.lcl_UpdataDate = TIMETOOL.pastTimeGet()       ///取得する基準の時間
        ///アクセス開始
        STORAGE.reference(forURL: host).child("profileImage").child("\(UID).jpeg").getMetadata {metadata, error in
            if error != nil {
                callback(CONTENTSLOCAL,error)
                return
            }
            ///存在しない場合nilで返却
            guard let metadata = metadata else {
                callback(CONTENTSLOCAL, nil)
                return
            }
            ///最新画像データに更新されていた場合
            if metadata.updated! > UpdateTime {
                STORAGE.reference(forURL: host).child("profileImage").child("\(UID).jpeg")
                    .getData(maxSize: 1024 * 1024 * 10) { (data: Data?, error: Error?) in
                    if error != nil {
                        callback(CONTENTSLOCAL, error)
                        return
                    }
                    ///画像返却
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
//--トークリスト関連--
//--------------------------------------------------
///
//リストユーザー情報取得マネージャー//
struct ListDataHostGetter {
    let cloudDB = Firestore.firestore()     ///アクセス変数
    var databaseRef = Database.database().reference()       //アクセス変数
    ///リストデータ情報取得
    func TargetUserInfoGetter(callback: @escaping  (listUsersInfoLocalObject,Error?) -> Void,MYUID:String,UID2:String) {
        let TARGETINFO = listUsersInfoLocalObject()     ///返却するローカルな型
        ///アクセス開始
        let userDocuments = cloudDB.collection("users").document(MYUID).collection("TalkUsersList").document(UID2)
        userDocuments.getDocument(completion: { (querySnapshot, err) in
            if let err = err {
                callback(TARGETINFO,err)
            } else {
                ///マッピング
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
//ユーザー取得時のフィルター
class QueryFilter {
    let COMVERTER = TimeTools()
    var scrollCounter:Int = 1
    var fixCount = 15
    var hitsPerPageCount:Int{
        get {
            return fixCount * scrollCounter
        }
    }
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
    
    func algoliaQuery() -> AlgoliaSearchClient.Query {
        var query = AlgoliaSearchClient.Query()
        ///取得数の適用
        query = query.set(\.hitsPerPage, to: hitsPerPageCount + 1)
        var filters: [String] = []
        // 年齢範囲のフィルター
        if let minAge = minAge, let maxAge = maxAge {
            let minYearToDate = AgeCalculator.convertDefaultYearOfBirth(targetYear: minAge, minOrMax: .min)
            let maxYearToDate = AgeCalculator.convertDefaultYearOfBirth(targetYear: maxAge, minOrMax: .max)
            filters.append("age >= \(maxYearToDate)")
            filters.append("age <= \(minYearToDate)")
        } else {
        //年齢フィルターがない場合は初期設定
            let minYearToDate = AgeCalculator.convertDefaultYearOfBirth(targetYear: 18, minOrMax: .min)
            let maxYearToDate = AgeCalculator.convertDefaultYearOfBirth(targetYear: 100, minOrMax: .max)
            filters.append("age >= \(maxYearToDate)")
            filters.append("age <= \(minYearToDate)")
        }

        // 性別のフィルター
        if let gender = gender {
            filters.append("Sex = \(gender)")
        }
//
//        // 住まいのフィルター
        if let area = area {
            filters.append("area:\(area)")
        }
        ///結合
        query.filters = filters.joined(separator: " AND ")
        return query
    }
}
//トークリストユーザー一覧の取得
//--Algoliaからの取得を実施--
class TalkListGetterManager{
    ///Jsonデータを扱いやすくするための格納構造体
    struct AlgoliaGuideData:Codable {
        var area:String
        var age:Int
        var Sex:Int
        var objectID:String
        var aboutMeMassage:String
        var likeIncrement:Int
        var nickname:String
        var formattedCreatedAt:Date {
            get {
                let epochSeconds = createdAt / 1000 // ミリ秒を秒に変換
                let date = Date(timeIntervalSince1970: TimeInterval(epochSeconds))
                return date
            }
        }
        var formattedUpdatedAt:Date{
            get {
                let epochSeconds = updatedAt / 1000 // ミリ秒を秒に変換
                let date = Date(timeIntervalSince1970: TimeInterval(epochSeconds))
                return date
            }
        }
        var updatedAt:Int
        var createdAt:Int
    }
    
    func userListDataFetching(callback: @escaping ([ProfileInfoLocalObject],Error?) -> Void,appID:String,apiKey:String,query:QueryFilter) {
        let APPID = ApplicationID(rawValue: appID)
        let APIKEY = APIKey(rawValue: apiKey)
        let client = SearchClient(appID: APPID, apiKey: APIKEY)
        let index = client.index(withName: "UserGetter_Update_Desc")
        

        index.search(query: query.algoliaQuery()) { result in
            switch result {
            ///成功した場合Algoliaからのデータを一つずつ回してJsonに変換後共通のデータ型配列に格納して返却
            case .success(let response):
                let guides = response.hits.compactMap { hit -> ProfileInfoLocalObject? in
                    
                    guard let ob = hit.object.object() else {
                        return nil
                    }
                    guard let dat = try? JSONSerialization.data(withJSONObject: ob) else {
                        return nil
                    }
                    guard let gui = try? JSONDecoder().decode(AlgoliaGuideData.self, from: dat)
                    else{
                        return nil
                    }

                    guard let object = hit.object.object(),
                          let data = try? JSONSerialization.data(withJSONObject: object),
                          let guide = try? JSONDecoder().decode(AlgoliaGuideData.self, from: data)
                    else { return nil }
                    //更新時間を最新に
                    updateTime()
                    return self.mappingData(guideData: guide)
                }
                ///guidesにデータが格納されるまで待機（同期処理）
                DispatchQueue.main.async {
                   callback(guides, nil)
                }
            ///取得に失敗した場合は空配列とエラーを返却
            case .failure(let error):
                callback([ProfileInfoLocalObject()],error)
                // TODO: Handle error.
            }
        }
    }
    
    ///Algoliaデータマッピング
    func mappingData(guideData:AlgoliaGuideData) -> ProfileInfoLocalObject? {
        let USERINFO:ProfileInfoLocalObject = ProfileInfoLocalObject()
        USERINFO.lcl_UID = guideData.objectID
        USERINFO.lcl_Sex = guideData.Sex
        USERINFO.lcl_AboutMeMassage = guideData.aboutMeMassage
        USERINFO.lcl_Area = guideData.area
        USERINFO.lcl_NickName = guideData.nickname
        USERINFO.lcl_Age = guideData.age
        USERINFO.lcl_DateUpdatedAt = guideData.formattedUpdatedAt
        USERINFO.lcl_DateCreatedAt = guideData.formattedCreatedAt
        return USERINFO
    }
    
}
///
//--------------------------------------------------
//--チャットユーザーリスト取得--
//--------------------------------------------------
///

class ChatListListenerManager {
    
    func chatUserListDataListener(callback: @escaping ([ChatInfoDataLocalObject],Error?) -> Void,UID:String,greaterThanDate:Date) {
        let db = Firestore.firestore() ///FireStore変数
        ///返却用ユーザー変数
        var ChatUserListLocalArray:[ChatInfoDataLocalObject] = []
        ///リスナー処理開始
        db.collection("users")
            .document(UID)
            .collection("TalkUsersList")
            .whereField("listend", isEqualTo: false)
            .order(by: "UpdateAt", descending: true)
            .addSnapshotListener { (document, err) in
                //配列初期化
                ChatUserListLocalArray = []
                ///エラーの場合返却
                if err != nil {
                    callback([],err)
                    return
                }
                
                guard let documentSnapshot = document else {
                    return
                }
                for chatListInfo in documentSnapshot.documents {
                    ///返却用ローカルデータ
                    let ChatListLocalData = ChatInfoDataLocalObject()
                    ///マッピング
                    ChatListLocalData.lcl_TargetUID = chatListInfo.documentID
                    ChatListLocalData.lcl_FirstMessage = chatListInfo["FirstMessage"] as? String
                    ChatListLocalData.lcl_SendID = chatListInfo["SendID"] as? String
                    let UpdateTimeStamp = chatListInfo["UpdateAt"] as? Timestamp
                    ChatListLocalData.lcl_DateUpdatedAt = UpdateTimeStamp?.dateValue()
                    let CreateTimeStamp = chatListInfo["createdAt"] as? Timestamp
                    ChatListLocalData.lcl_DateCreatedAt = CreateTimeStamp?.dateValue()
                    ChatListLocalData.lcl_likeButtonFLAG = chatListInfo["likeButtonFLAG"] as? Bool ?? false
                    ChatListLocalData.lcl_meNickname = chatListInfo["meNickname"] as? String
                    ChatListLocalData.lcl_youNickname = chatListInfo["youNickname"] as? String
                    ///配列に格納
                    ChatUserListLocalArray.append(ChatListLocalData)
                }
                ///データ返却
                callback(ChatUserListLocalArray,nil)
            }
    }
    
    ///リスナー格納用変数
    var CNMListener:ListenerRegistration?
    
    func checkNewMessage(callback: @escaping (Bool) -> Void,UID:String,greaterThanDate:Date) {
        let db = Firestore.firestore() ///FireStore変数
        let query = db.collection("users")
            .document(UID)
            .collection("TalkUsersList")
            .whereField("listend", isEqualTo: false)
            .whereField("SendID", isNotEqualTo: UID)
        ///リスナー処理開始
        CNMListener = query.addSnapshotListener { snapshot, err in
                if err != nil {
                    callback(false)
                }
                guard let snapshot = snapshot else {
                    callback(false)
                    return
                }
                if snapshot.documents.count != 0 {
                    print("タブのリスナーが起動して通知あり")
                    callback(true)
                }
            }
    }
    
    
    func checkNewMessageLisnterRemover() {
        CNMListener?.remove()
    }
    
}

///
//--------------------------------------------------
//--メッセージ取得--
//--------------------------------------------------
///
class ChatDataHostGetterManager {
    //通常のメッセージ取得
    func messageListenerManager(callback:@escaping ([MessageLocalObject]) -> Void,roomID:String,TIMETOOL:TimeTools) -> DatabaseHandle{
        let handle:DatabaseHandle = Database.database().reference().child("Chat").child(roomID).queryOrdered(byChild: "listend").queryEqual(toValue: false).observe(.value) { (snapshot: DataSnapshot) in
            if snapshot.children.allObjects as? [DataSnapshot] != nil  {
                callback(self.messageLocalDataSafeMapping(snapshot: snapshot, roomID: roomID, TIMETOOL: TIMETOOL))
            }
        }
        return handle
    }
    //管理者用のメッセージ取得
    func adminMessageListnerManager(callback:@escaping ([MessageLocalObject]) -> Void,roomID:String,TIMETOOL:TimeTools) {

        Database.database().reference().child("Chat").child(roomID).queryLimited(toLast: 30).observe(.value) { (snapshot: DataSnapshot) in
            if snapshot.children.allObjects as? [DataSnapshot] != nil  {
                callback(self.messageLocalDataSafeMapping(snapshot: snapshot, roomID: roomID, TIMETOOL: TIMETOOL))
            }
        }
    }
    
    private func messageLocalDataSafeMapping(snapshot:DataSnapshot,roomID:String,TIMETOOL:TimeTools) -> [MessageLocalObject] {
        var messageLocalObjectArray:[MessageLocalObject] = []
        let snapChildren = snapshot.children.allObjects as? [DataSnapshot]
        ///更新件数がない場合
        if snapChildren?.count == 0 {
            ///メッセージ追加
            return []
        } else {
            //Firebaseのメッセージ配列からメッセージを取得
            for snapChild in snapChildren! {
                ///それぞれのValue配列を取得
                if let postDict = snapChild.value as? [String: Any] {
                    var sentDataFR: Date {
                        get {
                            if postDict["Date"] != nil {
                                return TIMETOOL.stringToDateFormatte(date: postDict["Date"] as! String)
                            } else {
                                return Date()
                            }
                        }
                    }
                    let sentDate = sentDataFR
                    let likeButtonFLAG = postDict["LikeButtonFLAG"] as? Bool ?? false
                    
                    if let senderID = postDict["sender"] as? String,
                       let message = postDict["message"] as? String,
                       let messageID = postDict["messageID"] as? String{
                        
                        let messageLcl = MessageLocalObject()
                        messageLcl.lcl_Sender = senderID
                        messageLcl.lcl_Message = message
                        messageLcl.lcl_MessageID = messageID
                        messageLcl.lcl_RoomID = roomID
                        messageLcl.lcl_LikeButtonFLAG = likeButtonFLAG
                        messageLcl.lcl_Date = sentDate
                        messageLcl.lcl_Listend = true
                        messageLcl.lcl_ChildKey = snapChild.key
                        
                        messageLocalObjectArray.append(messageLcl)
                    }
                }
            }
            return messageLocalObjectArray
        }
    }
}

///
//--------------------------------------------------
//--ブロックリスト関連--
//--------------------------------------------------
///
enum BlockKind {
    case Meblocked
    case IBlocked
    case MeNone
    case INone
}
///ブロックユーザー用構造体
struct BlockUserObj{
    var KIND:BlockKind
    var UID:String
    init (KIND:BlockKind,UID:String) {
        self.KIND = KIND
        self.UID = UID
    }
}


struct BlockHostGetterManager {
    let cloudDB = Firestore.firestore()
    func blockUserListListener(callback: @escaping  ([BlockUserObj]) -> Void,UID:String) {

        ///ここでデータにアクセスしている（非同期処理）
        let userDocuments = cloudDB.collection("users").document(UID).collection("block")
        userDocuments.addSnapshotListener{ (querySnapshot, err) in
            var blockUserList:[BlockUserObj] = []
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for blockuserinfo in querySnapshot!.documents {
                    // ドキュメントが存在し、データを取得できた場合
                    if let IBlocked = blockuserinfo["IBlocked"] as? Bool {
                        if IBlocked {
                            var Obec = BlockUserObj(KIND: .IBlocked, UID: blockuserinfo.documentID)
                            ///ここでブロックリストのユーザーID一覧を格納
                            blockUserList.append(Obec)
                        }
                    }
                    if let MeBlocked = blockuserinfo["MeBlocked"] as? Bool  {
                        if MeBlocked {
                            var Obec = BlockUserObj(KIND: .Meblocked, UID: blockuserinfo.documentID)
                            ///ここでブロックリストのユーザーID一覧を格納
                            blockUserList.append(Obec)
                        }
                    }
                }
                callback(blockUserList)
            }
        }
    }
    
    ///ターゲットをブロックまたはブロックされているかを確認
    func targetBlockConfListener(callback:@escaping (BlockKind) -> Void,targetUID:String,selfUID:String) {
        let cloudDB = Firestore.firestore().collection("users").document(selfUID).collection("block").document(targetUID).addSnapshotListener { (document, error) in
            if let document = document, document.exists {
                // ドキュメントが存在し、データを取得できた場合
                if let IBlocked = document.data()?["IBlocked"] as? Bool {
                    if IBlocked {
                        // IBlocked が true の場合の処理
                        callback(.IBlocked)
                    } else {
                        // IBlocked が false の場合の処理
                        callback(.INone)
                    }
                } else {
                    callback(.INone)
                }
                if let MeBlocked = document.data()?["MeBlocked"] as? Bool  {
                    if MeBlocked {
                        // IBlocked が true の場合の処理
                        callback(.Meblocked)
                    } else {
                        // IBlocked が false の場合の処理
                        callback(.MeNone)
                    }
                } else {
                    callback(.MeNone)
                }
            } else {
                callback(.INone)
            }
        }
    }
    
    func blockingUsersProfileGetter(callback:@escaping([RequiredProfileInfoLocalData]?) -> Void,selfUID:String) {
        var REQUIREBLOCKINUSERSARRAY:[RequiredProfileInfoLocalData] = []
        let cloudDB = Firestore.firestore().collection("users").document(selfUID).collection("block").getDocuments { snapshot, err in
            //エラーの場合はnil返却
            if err != nil{
                callback(nil)
                return
            }
            
            guard let snapshot = snapshot else {
                callback(nil)
                return
            }
            
            for user in snapshot.documents {
                if let blocking = user["IBlocked"] as? Bool,let nickname = user["nickname"] as? String {
                    if blocking {
                        if let safeProfile = localExchangeSafedata(nickname: nickname, UID: user.documentID){
                            REQUIREBLOCKINUSERSARRAY.append(safeProfile)
                        }
                    }
                }
            }
            callback(REQUIREBLOCKINUSERSARRAY)
        }
    }
    
    private func localExchangeSafedata(nickname:String,UID:String) -> RequiredProfileInfoLocalData? {
        
        let safeData = RequiredProfileInfoLocalData(UID: UID, DateCreatedAt: Date(), DateUpdatedAt: Date(), Sex: 0, AboutMeMassage: "", NickName: nickname, Age: 0, Area: "")
        
        return safeData

    }
}

///
//--------------------------------------------------
//--通報関連--
//--------------------------------------------------
///

struct reportHostGetterManager {
    func reportMemberGetter(callback:@escaping ([RequiredReportMemberInfoLocalData]) -> Void) {
        var reportMemberArray:[RequiredReportMemberInfoLocalData] = []
        Firestore.firestore().collection("reportMember").whereField("reportingFlag", isEqualTo: false) .getDocuments { snapshot, err in
            if err != nil {
                callback(reportMemberArray)
            }
            
            guard let snapshot = snapshot else {
                callback(reportMemberArray)
                return
            }
            
            for memberData in snapshot.documents {
                ///データチェックで漏れたモノは追加しない。
                if let memberRequiredData = dataChecking(data: memberData) {
                    reportMemberArray.append(memberRequiredData)
                }
            }
            callback(reportMemberArray)
        }
    }
    
    private func dataChecking(data:QueryDocumentSnapshot) -> RequiredReportMemberInfoLocalData? {
        guard let detail = data["reportDetail"] as? String, let reportTime = data["reportTime"] as? Timestamp,let reportedUID = data["reportedUID"] as? String,let reportingUID = data["reportingUID"] as? String, let reportingFLAG = data["reportingFlag"] as? Bool, let roomID = data["roomID"] as? String else {
            return nil
        }
        var reportMemberInfo:RequiredReportMemberInfoLocalData = RequiredReportMemberInfoLocalData(ReportDetail: detail, reportTime: reportTime.dateValue(), reportingUID: reportingUID, reportedUID: reportedUID, reportingFlag: reportingFLAG, reportingRoomID: roomID, reportID: data.documentID)
        
        return reportMemberInfo
    }
    
    func waringOrFreezeConfirmGetter(callback:@escaping(Int?) ->Void ,UID:String) {
        Firestore.firestore().collection("users").document(UID).getDocument { document, err in
            if let err = err {
                callback(nil)
                return
            }
            guard let document = document, document.exists else {
                callback(nil)
                return
            }
            
            guard let data =  document.data() else {
                callback(nil)
                return
            }
            
            guard let reportDetail = data["reportFlag"] as? Int else {
                callback(nil)
                return
            }
            
            callback(reportDetail)
            
        }
    }
    
    ///通報用ユーザー情報取得
    func reportOnlyUserInfoDataGetter(callback: @escaping  (ProfileInfoLocalObject,Int?,Error?) -> Void,UID:String) {
        let PROFILEINFOLOCAL = ProfileInfoLocalObject()     ///返却するローカルな型
        ///アクセス開始
        let userDocuments = Firestore.firestore().collection("users").document(UID)
        userDocuments.getDocument{ (QuerySnapshot,err) in
            if err != nil {
                callback(PROFILEINFOLOCAL,0,err)
            } else {
                guard let QuerySnapshot = QuerySnapshot else {
                    callback(PROFILEINFOLOCAL,0,err)
                    return
                }
                guard let nickname = QuerySnapshot["nickname"] as? String else {
                    callback(PROFILEINFOLOCAL,0,err)
                    return
                }
                guard let aboutMeMassage = QuerySnapshot["aboutMeMassage"] as? String else {
                    callback(PROFILEINFOLOCAL,0,err)
                    return
                }
                guard let age = QuerySnapshot["age"] as? Int else {
                    callback(PROFILEINFOLOCAL,0,err)
                    return
                }
                guard let area = QuerySnapshot["area"] as? String else {
                    callback(PROFILEINFOLOCAL,0,err)
                    return
                }
                guard let Sex = QuerySnapshot["Sex"] as? Int else {
                    callback(PROFILEINFOLOCAL,0,err)
                    return
                }
                guard let createdAt = QuerySnapshot["createdAt"] as? Timestamp else {
                    callback(PROFILEINFOLOCAL,0,err)
                    return
                }
                guard let updatedAt = QuerySnapshot["updatedAt"] as? Timestamp else {
                    callback(PROFILEINFOLOCAL,0,err)
                    return
                }
                
                ///マッピング
                PROFILEINFOLOCAL.lcl_UID = UID
                PROFILEINFOLOCAL.lcl_NickName = nickname
                PROFILEINFOLOCAL.lcl_AboutMeMassage = aboutMeMassage
                PROFILEINFOLOCAL.lcl_Age = age
                PROFILEINFOLOCAL.lcl_Area = area
                PROFILEINFOLOCAL.lcl_Sex = Sex
                PROFILEINFOLOCAL.lcl_DateCreatedAt = createdAt.dateValue()
                PROFILEINFOLOCAL.lcl_DateUpdatedAt = updatedAt.dateValue()
                ///通報回数
                let reportCount = QuerySnapshot["reportCount"] as? Int ?? 0
                ///返却
                callback(PROFILEINFOLOCAL,reportCount,nil)
            }
        }
    }
    
}
    
///
//--------------------------------------------------
//--管理者権限関連--
//--------------------------------------------------
///

struct adminHostGetterManager {
    func passwordGetter(callback:@escaping(String) -> Void) {
        let cloudDB = Firestore.firestore().collection("admin").document("Info").getDocument(completion: { (document, error) in
            if error != nil {
                callback("Error")
            }
            
            if let document = document {
                if let password = document["pass"] as? String {
                    callback(password)
                }
            }
        })
    }
    
    func memberExists(callback:@escaping(Bool) -> Void,UID:String) {
        let cloudDB = Firestore.firestore().collection("admin").document(UID).getDocument(completion: { (document, error) in
            if err != nil {
                callback(false)
            }
            
            if let document = document,document.exists {
                callback(true)
            } else {
                callback(false)
            }
        })
    }
    
    func memberCountGetter(callback:@escaping(Int) -> Void) {
        Firestore.firestore().collection("users").getDocuments { snapshot, err in
            if err != nil {
                callback(0)
            }
            guard let count = snapshot?.documents.count else {
                callback(0)
                return
            }
            callback(count)
        }
    }
    
    func chatCountGetter(callback:@escaping(Int) -> Void) {
        Database.database().reference().child("Chat").observeSingleEvent(of: .value) { snapshot,err in
            
            if err != nil{
                callback(0)
            }
            if snapshot.exists() {
                callback(snapshot.children.allObjects.count)
            } else {
                callback(0)
            }
        }
    }
    
    func targetChatUserListDataGetter(callback: @escaping ([ChatInfoDataLocalObject],Error?) -> Void,UID:String,dammy:Bool) {
        var userListArray:[ChatInfoDataLocalObject] = []
        var db = Firestore.firestore().collection("users") ///FireStore変数
            db.document(UID).collection("TalkUsersList")
                .order(by: "UpdateAt", descending: true)
                .limit(to: 15)
                .getDocuments { (document, err) in
                ///エラーの場合返却
                if err != nil {
                    callback([],err)
                    return
                }
                guard let documentSnapshot = document else {
                    return
                }
                
                for doc in documentSnapshot.documents {
                    ///返却用ローカルデータ
                    let ChatListLocalData = ChatInfoDataLocalObject()
                    ///マッピング
                    ///メッセージ
                    ChatListLocalData.lcl_TargetUID = doc.documentID
                    ChatListLocalData.lcl_FirstMessage = doc["FirstMessage"] as? String
                    ChatListLocalData.lcl_SendID = doc["SendID"] as? String
                    let UpdateTimeStamp = doc["UpdateAt"] as? Timestamp
                    ChatListLocalData.lcl_DateUpdatedAt = UpdateTimeStamp?.dateValue()
                    let CreateTimeStamp = doc["createdAt"] as? Timestamp
                    ChatListLocalData.lcl_DateCreatedAt = CreateTimeStamp?.dateValue()
                    ChatListLocalData.lcl_likeButtonFLAG = doc["likeButtonFLAG"] as? Bool ?? false
                    ChatListLocalData.lcl_meNickname = doc["meNickname"] as? String
                    ChatListLocalData.lcl_youNickname = doc["youNickname"] as? String
                    
                    userListArray.append(ChatListLocalData)
                }
                
                ///データ返却
                callback(userListArray,nil)
            }
    }
    
    func dammyUsersListDataGetter(callback: @escaping  ([ProfileInfoLocalObject],Error?) -> Void) {
        var PROFILEINFOLOCALLIST:[ProfileInfoLocalObject] = []     ///返却するローカルな型
        ///アクセス開始
        let userDocuments = Firestore.firestore().collection("users").whereField("signUpFlg", isEqualTo: "Dammy")
        userDocuments.getDocuments{ (QuerySnapshot,err) in
            if err != nil {
                callback([],err)
            } else {
                guard let QuerySnapshot = QuerySnapshot else {
                    return
                }
                for data in QuerySnapshot.documents {
                    var LocalObject = ProfileInfoLocalObject()
                    guard let nickname = data["nickname"] as? String else {
                        return
                    }
                    guard let aboutMeMassage = data["aboutMeMassage"] as? String else {
                        return
                    }
                    guard let age = data["age"] as? Int else {
                        return
                    }
                    guard let area = data["area"] as? String else {
                        return
                    }
                    guard let Sex = data["Sex"] as? Int else {
                        return
                    }
                    guard let createdAt = data["createdAt"] as? Timestamp else {
                        return
                    }
                    guard let updatedAt = data["updatedAt"] as? Timestamp else {
                        return
                    }
                    print(nickname)
                    ///マッピング
                    LocalObject.lcl_UID = data.documentID
                    LocalObject.lcl_NickName = nickname
                    LocalObject.lcl_AboutMeMassage = aboutMeMassage
                    LocalObject.lcl_Age = age
                    LocalObject.lcl_Area = area
                    LocalObject.lcl_Sex = Sex
                    LocalObject.lcl_DateCreatedAt = createdAt.dateValue()
                    LocalObject.lcl_DateUpdatedAt = updatedAt.dateValue()
                    PROFILEINFOLOCALLIST.append(LocalObject)
                }
                
                
                ///返却
                callback(PROFILEINFOLOCALLIST,nil)
            }
        }
    }
    
}

