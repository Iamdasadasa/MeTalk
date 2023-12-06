//
//  profileSetting.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/09/04.
//

import Foundation
import UIKit
import RealmSwift
import Firebase
import MessageUI
//プロフィール初期設定
class profileSetting:UIViewController{
    //++変数宣言　クロージャー++//
    let mapping = profileSafeDataMapping()  ///データマッピング用構造体
    let REPORTHOSTINGGETTER = reportHostGetterManager()
    let REPORTHOSTINGSETTER = reportHostSetterManager()
    var selfUID:String{     ///自身のUID
        get{
            guard let selfUID = myProfileSingleton.shared.selfUIDGetter() else {
                createSheet(for: .Completion(title: "不正なユーザーの可能性があるため強制終了します。再登録してください。", {
                    preconditionFailure()
                }), SelfViewController: self)
                return ""
            }
            return selfUID
        }
    }
    var selfLocalProfile:ProfileInfoLocalObject? {  ///自身のローカル保存プロフィール
        get{
            guard let selfProfile = myProfileSingleton.shared.selfProfileGetter(selfUID: selfUID) else {
                return nil
            }
            return selfProfile
        }
    }
    
    var selfLocalImage:listUsersImageLocalObject? {
        get {
            let manager = ImageDataLocalGetterManager()
            guard let profileImageObject = manager.getter(targetUID: selfUID) else {
                return nil
            }
            return profileImageObject
        }
    }
    
    let loadingView = LogoShowLoadingView()    ///ローディング画面
    
    var COMPLAINTID:String = {
        return  String(Int.random(in: 100000000...999999999))
    }()
    lazy var failerAlert = {
        createSheet(for: .Completion(title: "再度行う場合は一度アプリを終了してください。", {
            preconditionFailure()
        }), SelfViewController: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = loadingView
    }
    
    override func viewDidLayoutSubviews() {
        //通報確認
        REPORTHOSTINGGETTER.waringOrFreezeConfirmGetter(callback: { report in
            if let report = report {
                if report == 1 {
                    createSheet(for: .Completion(title: "通報が確認されました。繰り返されると凍結となります。", {
                        //通報通知完了フラグ
                        self.REPORTHOSTINGSETTER.reportedNotificationCompletedSetter(UID:self.selfUID)
                            //画像取得処理へ
                            self.contensInfoProcess()
                    }), SelfViewController: self)
                } else if report == 2 {
                    createSheet(for: .Alert(title: "通報が確認されました。凍結処理となりあなたのアカウントは使用できません。", message: "異議や申し立てを行う場合は連絡してください。", buttonMessage: "連絡する", { result in
                        if result {
                            ///メール送信画面生成及び遷移
                            self.mailViewControllerSet()
                        } else {
                            self.loadingView.startLoading()
                            self.failerAlert()
                            return
                        }
                    }), SelfViewController: self)
                } else {
                    ///通報に該当しないフラグなら画像取得処理へ
                    self.contensInfoProcess()
                }
            } else {
                ///通報がなければ画像取得処理へ
                self.contensInfoProcess()
            }
        }, UID: selfUID)
    }

    //画像取得
    func contensInfoProcess() {
        ///自身の画像データ取得
        guard let LocalImageObject = self.selfLocalImage else {
        ///ローカルに存在しない場合は念の為Firebaseにも問い合わせ
            let contentsGetter = ContentsHostGetter()
            contentsGetter.MappingDataGetter(callback: { hostImageObject, err in
                if err != nil {
                    let basicImageObject = listUsersImageLocalObject()
                    basicImageObject.lcl_UID = self.selfUID
                    basicImageObject.lcl_UpdataDate = Date()
                    ///自身の情報取得処理
                    self.mainInfoDataGet(ImageObject: basicImageObject)
                } else {
                    ///自身の情報取得処理
                    self.mainInfoDataGet(ImageObject: hostImageObject)
                }
            }, UID: self.selfUID, UpdateTime: TIME().pastTimeGet())
            return
        }
        ///自身の情報取得処理
        mainInfoDataGet(ImageObject: LocalImageObject)
    }
    
    func mainInfoDataGet(ImageObject:listUsersImageLocalObject) {
        selfInfoDataGetting(callback: { SELFINFO in
            //安全なデータに変換
            self.mapping.USERLISTPROFILEMAPPING(callback: { safeData in
                ///管理者権限確認
                self.adminConfirm(SELFINFO: safeData, ImageLocalObject: ImageObject)

            }, PROFILEINFO: SELFINFO, VC: self)
        }, ImageObject: ImageObject)
    }
    
    
    ///自身のデータを取得
    /// - Parameter callback: RealmもしくはFirebaseから取得した自身のプリフィールデータ
    func selfInfoDataGetting(callback:@escaping(ProfileInfoLocalObject)-> Void,ImageObject:listUsersImageLocalObject) {
        let PROFILEHOSTING = ProfileHostGetter()    ///サーバーアクセスインスタンス
        ///ローカルをまず検索
        guard let LocalProfile = selfLocalProfile else {
            ///ない場合サーバーアクセス
            PROFILEHOSTING.mappingDataGetter(callback: { PROFILE, Err in
                
                if Err != nil {
                    self.ERRHandring_USERDATA(ImageObject: ImageObject)
                }
                self.PROFILEDATALOCALSET(PROFILEINFO: PROFILE)
                ///取得できたら返却（Firebase）
                callback(PROFILE)
            }, UID: selfUID)
            return
        }
        ///取得できたら返却（ローカル）
        callback(LocalProfile)
    }
    
    ///エラー時
    func ERRHandring_USERDATA(ImageObject:listUsersImageLocalObject) {
        createSheet(for: .Options(["リトライ","初期化して再登録"], { selectIndex in
            switch selectIndex {
            case 0:
                self.selfInfoDataGetting(callback: { SELFINFO in
                    self.mapping.USERLISTPROFILEMAPPING(callback: { safeData in
                        self.adminConfirm(SELFINFO: safeData, ImageLocalObject: ImageObject)
                    }, PROFILEINFO: SELFINFO, VC: self)
                }, ImageObject: ImageObject)
            case 1:
                self.mapping.signOut()
            default:
                return
            }
        }), SelfViewController: self)
    }
    
    ///ローカル保存
    /// - Parameter PROFILEINFO: 保存するためのRealmオブジェクト
    func PROFILEDATALOCALSET(PROFILEINFO:ProfileInfoLocalObject) {
        var LOCALPROFILESETTER = TargetProfileLocalDataSetterManager(updateProfile: PROFILEINFO)
        LOCALPROFILESETTER.commiting = true
    }
    ///管理者権限の確認
    func adminConfirm(SELFINFO:RequiredProfileInfoLocalData,ImageLocalObject:listUsersImageLocalObject) {
        let ADMINHOSTGETTER = adminHostGetterManager()
        ADMINHOSTGETTER.memberExists(callback: { result in
            //管理者権限を付与
            if result {
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "admin")
            } else {
            //存在していなければ管理者権限を剥奪。
                let defaults = UserDefaults.standard
                if defaults.bool(forKey: "admin") {
                    defaults.removeObject(forKey: "admin")
                }
            }
            ///メイン画面遷移
            self.goToNextScreen(SELFINFO: SELFINFO, ImageLocalObject: ImageLocalObject)
        }, UID: selfUID)
    }
    
    ///画面遷移
    /// - Parameter SELFINFO: 遷移先VCに渡すプロフィールデータ
    func goToNextScreen(SELFINFO:RequiredProfileInfoLocalData,ImageLocalObject:listUsersImageLocalObject) {
        let nextVC = MainTabBarController(SELFINFO: SELFINFO, ImageLocalObject: ImageLocalObject)
        self.loadingView.animateViewToCenter {
            nextVC.modalPresentationStyle = .fullScreen
            self.present(nextVC, animated: false)
        }
    }
}


//Realmプロフィールデータを安全な型にMappingする
struct profileSafeDataMapping {
    //++変数宣言　クロージャー++//
    let signOut = { () in   //サインアウト処理
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("SignOut Error: %@", signOutError)
        }
    }
    /// データを画面内で使用できる形にMapping(USERLIST)
    /// - Parameters:
    ///   - callback: nil無しの安全なプロフィールの型
    ///   - PROFILEINFO: Realm保存の型
    ///   - VC: 呼び出し元のViewController
    func USERLISTPROFILEMAPPING(callback:@escaping(RequiredProfileInfoLocalData)-> Void,
        PROFILEINFO:ProfileInfoLocalObject,VC:UIViewController){
        //++変数宣言　クロージャー++//
        
        let ERRMessage = {() in     //エラー時表示メッセージ
            createSheet(for: .Completion(title: "不正データが検出されました。再登録をお願いいたします。", {
                self.signOut()
                preconditionFailure() //強制退会
            }), SelfViewController: VC)
        }
        let defDataApplyMessage = {() in    //一部データ欠損注意時表示メッセージ
            createSheet(for: .Completion(title: "一部のデータが欠損していたために初期値を設定いたしました。", {}), SelfViewController: VC)
        }
        ///Nil、不正データバリデーションチェック
        guard let uid = PROFILEINFO.lcl_UID else {
            ERRMessage()
            return
        }
        guard let NickName = PROFILEINFO.lcl_NickName else {
            ERRMessage()
            return
        }
        guard let CreatedAt = PROFILEINFO.lcl_DateCreatedAt else {
            ERRMessage()
            return
        }
        guard let UpdatedAt = PROFILEINFO.lcl_DateUpdatedAt else {
            ERRMessage()
            return
        }
        if PROFILEINFO.lcl_NickName == "" {
            ERRMessage()
        }
        if PROFILEINFO.lcl_Age == 0  {
            ERRMessage()
        }
        if PROFILEINFO.lcl_UID == "" {
            ERRMessage()
        }
        if PROFILEINFO.lcl_Sex == 100  {
            ERRMessage()
        }
        ///初期値補正可能プロパティバリデーションチェック
        if let Message = PROFILEINFO.lcl_AboutMeMassage,let Area = PROFILEINFO.lcl_Area  {
            ///インスタンス化
            callback(RequiredProfileInfoLocalData(UID: uid, DateCreatedAt: CreatedAt, DateUpdatedAt: UpdatedAt, Sex: PROFILEINFO.lcl_Sex, AboutMeMassage: Message, NickName: NickName, Age: PROFILEINFO.lcl_Age, Area: Area))
        } else {
            ///メッセージとエリアに不備がある場合初期値で補う
            let Message:String =  USERINFODEFAULTVALUE.aboutMeMassage.value
            let Area:String = USERINFODEFAULTVALUE.area.value
            ///初期値データ含めたものをローカル保存
            
            ///インスタンス化
            callback(RequiredProfileInfoLocalData(UID: uid, DateCreatedAt: CreatedAt, DateUpdatedAt: UpdatedAt, Sex: PROFILEINFO.lcl_Sex, AboutMeMassage: Message, NickName: NickName, Age: PROFILEINFO.lcl_Age, Area: Area))
        }
    }
}

///異議申し立て時のメール送付処理
extension profileSetting:MFMailComposeViewControllerDelegate{

    func mailViewControllerSet(){
        let message01 = "=============="
        let message02 = "削除しないでください"
        let message03 = "申し立て識別ID; "
        let message04 = "\(COMPLAINTID)"
        let message05 = "【下記に申し立て内容を記載してください】"
        let messageBody = "\(message01)\n\(message02)\n\(message03)\(message04)\n\(message01)\n\(message05)\n"
        //メール送信が可能なら
        if MFMailComposeViewController.canSendMail() {
            //MFMailComposeVCのインスタンス
            let mail = MFMailComposeViewController()
            //MFMailComposeのデリゲート
            mail.mailComposeDelegate = self
            //送り先
            mail.setToRecipients(["penguin.inpuery@gmail.com"])
            //件名
            mail.setSubject("【penguin 凍結異議申し立て】")
            //メッセージ本文
            mail.setMessageBody(messageBody, isHTML: false)
            //メールを表示
            self.present(mail, animated: true, completion: nil)
        //メール送信が不可能なら
        } else {
            //アラートで通知
            createSheet(for: .Retry(title: "メールアカウントが存在しません"), SelfViewController: self)
        }
    }
    ///エラー処理
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            createSheet(for: .Completion(title: "送信に失敗しました。再度実行してください。", {
                self.failerAlert()
            }), SelfViewController: self)
        } else {
            switch result {
            case .cancelled:
                controller.dismiss(animated: true, completion: nil)
                //アラートで通知
                let alert = UIAlertController(title: "キャンセルされました", message: nil, preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "OK", style: .cancel)  {_ in 
                    self.failerAlert()
                }
                alert.addAction(dismiss)
                self.present(alert, animated: true, completion: nil)
                
            case .saved:
                controller.dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: "下書きが保存されました", message: nil, preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "OK", style: .cancel)  {_ in
                    self.failerAlert()
                }
                alert.addAction(dismiss)
                self.present(alert, animated: true, completion: nil)
            case .sent:
                controller.dismiss(animated: true, completion: nil)
                //データベースに申し立てID送付
                Firestore.firestore().collection("users").document(selfUID).updateData(["reportComplaintID":COMPLAINTID])
                let alert = UIAlertController(title: "送信が完了しました", message: nil, preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "OK", style: .cancel)  {_ in
                    self.failerAlert()
                }
                alert.addAction(dismiss)
                self.present(alert, animated: true, completion: nil)
            default:
                break
            }
        }
    }
    
}
