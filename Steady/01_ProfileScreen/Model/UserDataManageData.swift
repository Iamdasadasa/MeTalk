////
////  UserDataManage.swift
////  MeTalk
////
////  Created by KOJIRO MARUYAMA on 2022/02/14.
////
//
//import Foundation
//import Firebase
//import FirebaseStorage
//import RealmSwift
//
//struct UserDataManage{
//    let uid = Auth.auth().currentUser?.uid
//    let cloudDB = Firestore.firestore()
//    let storage = Storage.storage()
//    let host = "gs://metalk-f132e.appspot.com"
////    let ViewController:UIViewController
////    init(ViewController:UIViewController) {
////        self.ViewController = ViewController
////    }
//
////    ///匿名登録処理で登録したユーザー情報を返す& DB登録も初回は一緒にやる
////    func signInAnonymously(callback: @escaping (String?) -> Void,nickName:String?,SexNo:Int?) {
////        ///引数のデータがどちらかでもNilだった場合Return
////        guard let nickName = nickName,let SexNo  = SexNo else {
////            callback("ニックネームと性別が選択されていない可能性があります。正しく選択されているにも関わらずこのメッセージが表示される場合、開発者に問い合わせできます。")
////            return
////        }
////        ///匿名登録処理
////        Auth.auth().signInAnonymously { authResult, error in
////
////            ///匿名登録自体の失敗（Authentication）
////            guard let user = authResult?.user else {
////                callback("サーバー側で登録時エラーが発生しましたもう一度試してください。【Error Message】\(error?.localizedDescription)")
////                return
////            }
////
////            ///各登録処理（Cloud Firestore）
////            Firestore.firestore().collection("users").document(user.uid).setData([
////                "nickname": nickName,
////                "Sex": SexNo,
////                "aboutMeMassage":"よろしくお願いします     ( ∩'-' )=͟͟͞͞⊃",
////                "area":"未設定",
////                "age":0,
////                "signUpFlg":"SignUp",
////                "createdAt": FieldValue.serverTimestamp(),
////                "updatedAt": FieldValue.serverTimestamp()
////            ], completion: { error in
////                if let error = error {
////                    ///失敗した場合
////                    callback("サーバー側で登録時エラーが発生しましたもう一度試してください。【Error Message】\(error.localizedDescription)")
////                    return
////                } else {
////                    ///成功した場合遷移
////                    callback(nil)
////                }
////            })
////        }
////    }
//
//    ///サーバーに対して画像取得要求
//    /// - Parameters:
//    ///- UID: 自身のUID
//    ///- ChatDataManagedData.pastTimeGet() :初期時間
//    /// - Returns:
//    /// -imageStruct:取得したイメージ情報
//
//
//    ///自分ではないUser IDを基にイメージデータを取得してくる処理
//    /// - Parameters:
//    /// -anotherUserUID:呼び出し元が指定している画像が欲しい対象のUID
//    /// - callback:ユーザーIDを基に取得できるImage
//    /// - Returns:
//    ///- callback: Fire Baseから取得したイメージデータ
//    func contentOfFIRStorageGetAnotherUser(callback: @escaping (UIImage?) -> Void,UID:String?) {
//        guard let UID = UID else {
//            print("UIDが確認できませんでした")
//            return
//        }
//        ///Firebaseのストレージアクセス
//        storage.reference(forURL: host).child("profileImage").child("\(UID).jpeg")
//            .getData(maxSize: 1024 * 1024 * 10) { (data: Data?, error: Error?) in
//            ///ユーザーIDのプロフィール画像が取得できなかったらnilを返す
//            if error != nil {
//                callback(nil)
//                print(error?.localizedDescription)
//            }
//            ///ユーザーIDのプロフィール画像を設定していたらその画像を取得してリターン
//            if let imageData = data {
//                let image = UIImage(data: imageData)
//                callback(image)
//            }
//        }
//    }
//
//
//    ///ユーザーIDを基にイメージデータをアップロードして圧縮したファイルを返す処理
//    /// - Parameters:none
//    /// - Returns:
//    ///- callback: Fire Baseから取得したイメージデータ
//
//    ///サーバーに対してユーザーの情報取得
//    /// - Parameters:
//    ///- USERINFODATA.UID: 取得するユーザーUID
//    /// - Returns:
//    /// -document:取得したユーザー情報
//    func userInfoDataGet(callback: @escaping  ([String:Any]?) -> Void,UID:String?) {
//        guard let UID = UID else {
//            print("UIDを確認できませんでした")
//            return
//        }
//        ///非同期処理
//        let userDocuments = cloudDB.collection("users").document(UID)
//        userDocuments.getDocument{ (QuerySnapshot,err) in
//            if let error = err {
//                print("プロフィール情報の取得ができませんでした: \(err)")
//                ///相手のトークリストに何らかの理由で存在しないORブロック変数がTrueはここにくる
//                var failedUserInfo = ["UID":"Block"]
//                callback(failedUserInfo)
//            } else {
//                let DICTIONARYSNAPSHOT = QuerySnapshot
//                callback(DICTIONARYSNAPSHOT?.data())
//            }
//        }
//    }
//
//    //    ///データアップロード関数(コレクションは"Users")
//    //    /// - Parameters:
//    //    /// - userData: 一旦Anyで受け取り、判別処理の中でキャストしてから送信
//    //    /// - dataFlg: どのデータかを判断する 1="nickname",2="aboutMeMassage"
//    //    /// - callback:コールバック。エラーを返す。エラーにならなかったら返さない。
//    //    /// - Returns:
//    func userInfoDataUpload(userData:Any?,dataFlg:ModalItems,UID:String?,ViewController:UIViewController) {
//        ///ローカルデータ保存用インスタンス
//        let realm = try! Realm()
//        let localDBGetData = realm.objects(profileInfoLocal.self)
//
//        guard let UID = UID else {
//            print("UIDが確認できませんでした")
//            return
//        }
//
//        ///フラグによってアップデートする項目を仕分け
//        switch dataFlg {
//        case .nickName: ///ニックネーム及び更新日時
//            guard let userData = userData as? String else {
//                return
//            }
//            ///サーバーDB更新処理
//            Firestore.firestore().collection("users").document(UID).updateData(["nickname":userData])
//            Firestore.firestore().collection("users").document(UID).updateData(["updatedAt":FieldValue.serverTimestamp()])
//
//        case .aboutMe: ///ひとこと及び更新日時
//            guard let userData = userData as? String else {
//                return
//            }
//            ///サーバーDB更新処理
//            Firestore.firestore().collection("users").document(UID).updateData(["aboutMeMassage":userData])
//            Firestore.firestore().collection("users").document(UID).updateData(["updatedAt":FieldValue.serverTimestamp()])
//
//        case .Age: ///年齢及び更新日時
//            ///（年齢をIntに変換）
//            guard let AgeTypeString = userData as? String else {
//                print("年齢が取得もしくはキャストできませんでした")
//                return
//            }
//            guard let AgeTypeInt = Int(AgeTypeString) else {
//                print("年齢が取得もしくはキャストできませんでした")
//                return
//            }
//            ///サーバーDB更新処理
//            Firestore.firestore().collection("users").document(UID).updateData(["age":AgeTypeInt])
//            Firestore.firestore().collection("users").document(UID).updateData(["updatedAt":FieldValue.serverTimestamp()])
//
//        case .Area: ///出身地及び更新日時
//            guard let userData = userData as? String else {
//                return
//            }
//            ///サーバーDB更新処理
//            Firestore.firestore().collection("users").document(UID).updateData(["area":userData])
//            Firestore.firestore().collection("users").document(UID).updateData(["updatedAt":FieldValue.serverTimestamp()])
//
//        }
//    }
//
//    ///ブロックリスト登録処理
//    func blockListRegister(UID:String?) {
//        guard let UID = UID else {
//            print("UIDが確認できませんでした")
//            return
//        }
//        ///各登録処理（Cloud Firestore）
//        Firestore.firestore().collection("users").document(UID).collection("blockUser").document("  ここにブロックする相手のUID").setData([
//            "createdAt": FieldValue.serverTimestamp(),
//            "updatedAt": FieldValue.serverTimestamp()
//        ], completion: { error in
//            if let error = error {
//                ///失敗した場合
//                print(error.localizedDescription)
//                return
//            } else {
//                ///成功した場合遷移
////                callback(nil)
//            }
//        })
//    }
//    ///【非同期】トークユーザー情報取得関数(コレクションは"Users")
//    /// - Parameters:
//    /// - callback:コールバック関数。document.dataはFirebaseのユーザー1人分を返している
//    /// 　　　　　　（ニックネーム、性別等が含まれる）
//    /// - Returns:
////    func talkListTargetUserDataGet(callback: @escaping  (TalkListUserStruct) -> Void,UID1:String,UID2:String,selfViewController:UIViewController) {
////
////        ///ここでデータにアクセスしている（非同期処理）
////        let userDocuments = cloudDB.collection("users").document(UID1).collection("TalkUsersList").document(UID2)
////        userDocuments.getDocument(completion: { (querySnapshot, err) in
////            if let err = err {
////                print("Error getting documents: \(err)")
////            } else {
////                let DOCUMENTS = querySnapshot!
////                if let userNickname = DOCUMENTS["youNickname"] as? String,let UpdateDate = DOCUMENTS["UpdateAt"] as? Timestamp,let sendUID = DOCUMENTS["SendID"] as? String {
////                    var talkListTargetUserInfo:TalkListUserStruct = TalkListUserStruct(UID: UID2, userNickName: userNickname, profileImage: nil, UpdateDate: UpdateDate.dateValue(), NewMessage: DOCUMENTS["FirstMessage"] as? String ?? "", listend: true, sendUID: sendUID)
////                    talkListTargetUserInfo.blocked = DOCUMENTS["blocked"] as? Bool ?? false
////                    talkListTargetUserInfo.blocker = DOCUMENTS["blocker"] as? Bool ?? false
////                    callback(talkListTargetUserInfo)
////                } else {
////                    let alert = actionSheets(dicidedOrOkOnlyTitle: "申し訳ありませんがこのユーザーに異常が発生しました", message: "このユーザーにメッセージを送ることはできません。", buttonMessage: "OK")
////
////                    alert.okOnlyAction(callback: { result in
////                        switch result {
////                        case .one:
////                            return
////                        }
////                    }, SelfViewController: selfViewController)
////                    return
////                }
////
////            }
////        })
////
////    }
//
//    ///【非同期】トークユーザーリスト情報取得関数(コレクションは"Users")
//    /// - Parameters:
//    /// - callback:コールバック関数。document.dataはFirebaseのユーザーコレクション全体を返している
//    /// 　　　　　　（ニックネーム、性別等が含まれる）
//    /// - Returns:
//    func talkListUsersDataGet(callback: @escaping  ([TalkListUserStruct]) -> Void,UID:String?,argLatestTime:Date?,limitCount:Int) {
//        var latestTime:Date
//
//        if let argLatestTime = argLatestTime {
//            latestTime = argLatestTime
//        } else {
//            latestTime = Date()
//        }
//
//        guard let UID = UID else {
//            print("UIDが確認できませんでした")
//            return
//        }
//
//        ///ここでデータにアクセスしている（非同期処理）
//        let userDocuments = cloudDB.collection("users").document(UID).collection("TalkUsersList").whereField("UpdateAt", isGreaterThanOrEqualTo: latestTime)
//        userDocuments.getDocuments(){ (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                var UserListinfo:TalkListUserStruct
//                var callbackTalkListUsersMock:[TalkListUserStruct] = []
//
//                for talkUserinfo in querySnapshot!.documents {
//                    ///なぜか文頭にスペースが入ることがあるのでトリム処理
//                    let UID = talkUserinfo.documentID.trimmingCharacters(in: .whitespaces)
//                    ///更新日時のタイムスタンプをTimeStamp⇨Date型として受け取る
//                    guard let timeStamp = talkUserinfo["UpdateAt"] as? Timestamp else {
//                        print("更新日時が取得できませんでした。")
//                        return
//                    }
//                    let UpdateDate = timeStamp.dateValue()
//                    ///最新メッセージ
//                    guard let NewMessage = talkUserinfo["FirstMessage"] as? String else {
//                        print("最新メッセージが変換されませんでした。")
//                        return
//                    }
//                    ///送信者のUIDを確認
//                    guard let sendUID = talkUserinfo["SendID"] as? String else {
//                        print("送信者UID情報が取得できませんでした")
//                        return
//                    }
//
//                    ///ここでトークリストのユーザーID一覧を格納
//                    UserListinfo = TalkListUserStruct(UID: UID, userNickName: nil, profileImage: nil,UpdateDate:UpdateDate, NewMessage: NewMessage, listend: false, sendUID: sendUID)
//
//                    callbackTalkListUsersMock.append(UserListinfo)
//                }
//                callback(callbackTalkListUsersMock)
//            }
//        }
//    }
//    ///【非同期】ユーザーリスト情報取得関数
//    /// - Parameters:
//    /// - callback:コールバック関数。document.dataはFirebaseのユーザーコレクション全体を返している
//    /// 　　　　　　（ニックネーム、性別等が含まれる）
//    /// - Returns:
//    func userListInfoDataGet(callback: @escaping ([UserListStruct]) -> Void ,CountLimit:Int) {
//        ///ここでデータにアクセスしている（非同期処理）
//        ///.whereField("UpdateAt", isGreaterThanOrEqualTo: latestTime) これが時間のクエリ　参考
//        cloudDB.collection("users").limit(to: CountLimit).order(by: "updatedAt", descending: true).getDocuments(){ (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                var UserListinfo:UserListStruct
//                var callbackUserListMock:[UserListStruct] = []
//
//                for talkUserinfo in querySnapshot!.documents {
//                    ///なぜか文頭にスペースが入ることがあるのでトリム処理
//                    let UID = talkUserinfo.documentID.trimmingCharacters(in: .whitespaces)
//                    print(UID)
//                    guard let SEX = talkUserinfo["Sex"] as? Int else {
//                        print("ユーザー情報が取得できませんでした。（性別）")
//                        return
//                    }
//
//                    guard let ABOUTMESSAGE = talkUserinfo["aboutMeMassage"] as? String else {
//                        print("ユーザー情報が取得できませんでした。（メッセージ）")
//                        return
//                    }
//
//                    guard let AGE = talkUserinfo["age"] as? Int else {
//                        print("ユーザー情報が取得できませんでした。（年齢）")
//                        return
//                    }
//
//                    guard let AREA = talkUserinfo["area"] as? String else {
//                        print("ユーザー情報が取得できませんでした。（出身地）")
//                        return
//                    }
//
//                    ///更新日時のタイムスタンプをTimeStamp⇨Date型として受け取る
//                    guard let UPDATEDATE = talkUserinfo["updatedAt"] as? Timestamp else {
//                        print("更新日時が取得できませんでした。")
//                        return
//                    }
//                    let UPDATEDATEVALUE = UPDATEDATE.dateValue()
//
//                    guard let CREATEDAT = talkUserinfo["createdAt"] as? Timestamp else {
//                        print("作成日時が取得できませんでした。（ニックネーム）")
//                        return
//                    }
//                    let CREATEDATDATEVALUE = CREATEDAT.dateValue()
//
//                    guard let NICKNAME = talkUserinfo["nickname"] as? String else {
//                        print("更新日時が取得できませんでした。（ニックネーム）")
//                        return
//                    }
//
//
//
//                    ///ここでトークリストのユーザーID一覧を格納
//                    UserListinfo = UserListStruct(UID: UID, userNickName: NICKNAME, aboutMessage: ABOUTMESSAGE, Age: AGE, From: AREA, Sex: SEX, createdAt: CREATEDATDATEVALUE, updatedAt: UPDATEDATEVALUE)
//
//                    callbackUserListMock.append(UserListinfo)
//                }
//                callback(callbackUserListMock)
//            }
//        }
//    }
//
//    ///【非同期】ここにライクボタンを押下した際のデータ送信
//    /// - Parameters:
//    /// - callback:コールバック関数。
//    /// - Returns:
//    func LikeDataPushIncrement(YouUID:String,MEUID:String) {
//        ///ライクボタンを押下した相手のプロフィール情報のライク数をインクリメント
//        Firestore.firestore().collection("users").document(YouUID).setData(["likeIncrement":FieldValue.increment(1.0)],merge: true)
//
//    }
//
//    ///【非同期】ブロックユーザーリスト取得関数(コレクションは"Users")
//    /// - Parameters:
//    /// - callback:コールバック関数。document.dataはFirebaseのユーザーコレクション全体を返している
//    /// 　　　　　　（ニックネーム、性別等が含まれる）
//    /// - Returns:
//}
//
