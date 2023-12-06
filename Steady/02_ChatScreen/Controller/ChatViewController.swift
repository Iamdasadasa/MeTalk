//
//  ChatViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/09/12.
//

import Foundation
import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase
import FloatingPanel

protocol ChatViewControllerForChatListViewControllerDelegate:AnyObject {
    func newImageSettingDelegate(UID:String,targetImage:UIImage)
}


class ChatViewController:MessagesViewController{

    weak var delegate:ChatViewControllerForChatListViewControllerDelegate?
    let selfProfile:RequiredProfileInfoLocalData    ///自身のプロフィール
    let targetProfile:RequiredProfileInfoLocalData  ///相手のプロフィール
    var targetProfileImage:UIImage
    var newTargetProfileImage:UIImage?
    var selfProfileImage:UIImage
    
    let CONTENTSHOSTGETTER = ContentsHostGetter()   ///コンテンツ取得インスタンス(FIREBASE)
    let CHATDATAHOSTGETTER = ChatDataHostGetterManager()
    let CHATDATAHOSTSETTER = ChatDataHostSetterManager()
    let MESSAGELOCALGETTER = MessageLocalGetterManager()
    let BLOCLHOSTGETTER = BlockHostGetterManager() ///ブロック情報を取得するインスタンス
    let BLOCKHOSTSETTER = BlockHostSetterManager()  ///ブロック情報をセットするインスタンス
    let TALKLISTSETTER = ListDataHostSetter()

    let loadingView = LOADING(loadingView: LoadingView(), BackClear: true)  ///画面ロードビュー
    let ROOMIDMANAGER = chatTools() ///ルームID生成インスタンス
    let TIMETOOL = TimeTools()  ///時間関連ツールインスタンス
    let PASTTIME = TIME()   ///時間関連ツールインスタンス
    var messageArray:[MessageType] = [] ///メッセージを格納する配列
    var DateGrouping:[String] = []  ///時間グルーピング用配列
    let databaseRef: DatabaseReference! = Database.database().reference()   //DBインスタンス
    let REPORT_FPC = FloatingPanelController()  ///通報表示用VC
    private var handle: DatabaseHandle? ///リスナーハンドラ
    var navigationBarHeight:CGFloat {
        get {
            guard let navigationController = navigationController else {
                return 44
            }
            return navigationController.navigationBar.frame.size.height
        }
    }
    
    lazy var menuBarButtonItem: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "userMenu"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: navigationBarHeight).isActive = true
        button.addTarget(self, action: #selector(menuBarButtonTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    var BLOCKED:BlockKind = .MeNone   ///ブロックされているか
    var BLOCKING:BlockKind = .INone {    ///ブロックしているか
        willSet {
            if newValue == .IBlocked {
                //ブロックしている場合はオブザーバーをRemove
                if handle != nil {
                    Database.database().reference().child("Chat").child(roomID).removeAllObservers()
                }
                blockingLayout(Enable: true)
            } else {
                blockingLayout(Enable: false)
            }
        }
    }
    var blockText:String {
        get {
            if BLOCKING == .IBlocked {
                return "ブロック解除"
            } else {
                return "ブロック"
            }
        }
    }
    var roomID:String { ///チャット相手との一意ID
        get {
            return ROOMIDMANAGER.roomIDCreate(UID1: selfProfile.Required_UID, UID2: targetProfile.Required_UID)
        }
    }
    var reloadData:Bool = true {
        willSet {
            if newValue {
                self.becomeFirstResponder()
                // messagesCollectionViewをリロード
                self.messagesCollectionView.reloadData()
                // 一番下までスクロールする
                self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
            }
        }
    }
    
    init (selfProfile:RequiredProfileInfoLocalData,targetProfile:RequiredProfileInfoLocalData,SELFPROFILEIMAGE:UIImage,TARGETPROFILEIMAGE:UIImage) {
        self.selfProfile = selfProfile
        self.targetProfile = targetProfile
        self.selfProfileImage = SELFPROFILEIMAGE
        self.targetProfileImage = TARGETPROFILEIMAGE
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///初期のデリゲート設定
        initSetting()
        ///ナビゲーションバーの設定
        navigationBarSetUp()
        ///スワイプで前画面に戻れるようにする
        edghPanGestureSetting(selfVC: self, selfView: self.view,gestureDirection: .left)
        ///初回メッセージ取得(ローカル)
        self.localMessageGetting()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ///相手をブロック中かの確認
        targetBlockingConf()
        navigationItem.rightBarButtonItem = menuBarButtonItem
        ///Firebase通信（最新画像）
        CONTENTSHOSTGETTER.MappingDataGetter(callback: {OBJECT, err in
            ///ローカルに保存
            var LOCALCONTENTSSETTER = ImageDataLocalSetterManager(updateImage: OBJECT)
            LOCALCONTENTSSETTER.commiting = true
            ///最新画像変数に格納
            self.newTargetProfileImage = OBJECT.profileImage
            
        }, UID: targetProfile.Required_UID, UpdateTime:PASTTIME.pastTimeGet())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData = true
    }
    
    //viewが表示されなくなる直前に呼び出されるメソッド
    override func viewWillDisappear(_ animated: Bool) {
        if let handle = handle {
            databaseRef.child("chats").removeObserver(withHandle: handle)
        }
    }
}

///EXTENSION[メッセージ関連]
extension ChatViewController:MessagesDataSource {
    var currentSender: MessageKit.SenderType {
        return User(senderId: selfProfile.Required_UID, displayName: selfProfile.Required_NickName)
    }

    func otherSender() -> SenderType {
        return User(senderId: targetProfile.Required_UID, displayName: targetProfile.Required_NickName)
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageArray.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageArray[indexPath.section]
    }

    // メッセージの上に文字を表示
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
            return NSAttributedString(
                string: TIMETOOL.string(from: message.sentDate),
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.darkGray
                ]
            )
    }

    // メッセージの下に文字を表示（時間）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = TIMETOOL.dateToStringFormatt(date: message.sentDate, formatFlg: .HM)
        return NSAttributedString(string: dateString, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

///EXTENSION[メッセージラベル関連処理]
extension ChatViewController:MessagesLayoutDelegate {
    ///日付ラベルの高さ（有無）設定
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        ///messageはmessageTypeで直接フラグを持ってこれないので一旦MockMessage型に変換
        let messages = message as! Message
        ///フラグがTrueであれば日付ラベルは同一のため表示しない
        if messages.DateGroupFlg{
            return 0
        } else {
            return 10
        }

    }
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        16
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        16
    }
}

///EXTENSION[画面タップ時の関連処理]
extension ChatViewController:MessageCellDelegate {
    //MARK: - Cellのバックグラウンドをタップした時の処理
    func didTapBackground(in cell: MessageCollectionViewCell) {
        print("バックグラウンドタップ")
        closeKeyboard()
    }

    //MARK: - メッセージをタップした時の処理
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("メッセージタップ")
        closeKeyboard()
    }

    //MARK: - アバターをタップした時の処理
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("アバタータップ")
        closeKeyboard()
    }

    //MARK: - メッセージ上部をタップした時の処理
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("メッセージ上部タップ")
        closeKeyboard()
    }

    //MARK: - メッセージ下部をタップした時の処理
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("メッセージ下部タップ")
        closeKeyboard()
    }
    
}

extension ChatViewController:InputBarAccessoryViewDelegate {
    
    ///送信ボタン押下時
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        ///送信ボタンを無効化
        messageInputBar.sendButton.isEnabled = false
        let messageID:String = UUID().uuidString
        let sentDate = Date()

        ///Messageインスタンスとして保存
        let messageEntity = MessageEntity(message: text, senderID: selfProfile.Required_UID, displayName: selfProfile.Required_NickName, messageID: messageID, sentDate: sentDate, DateGroupFlg: false, SENDUSER: .SELF)

        ///Firebaseにメッセージデータを送信
        CHATDATAHOSTSETTER.messageUpload(callback: { err in

            if err != nil {
                createSheet(for: .Retry(title: "メッセージの送信に失敗しました"), SelfViewController: self)
                ///送信ボタンを有効化
                self.messageInputBar.sendButton.isEnabled = true
            } else {
                ///チャットデータに登録できたらリストデータに登録
                self.TALKLISTSETTER.talkListToUserInfoSetter(callback: { success in
                    if !success {
                        ///送信ボタンを有効化
                        self.messageInputBar.sendButton.isEnabled = true
                    }
                    ///送信ボタンを有効化
                    self.messageInputBar.sendButton.isEnabled = true
                    self.sendToMessageBar()
                }, UID1: self.selfProfile.Required_UID, UID2: self.targetProfile.Required_UID, message: text, sender: self.selfProfile.Required_UID, nickName1: self.selfProfile.Required_NickName, nickName2: self.targetProfile.Required_NickName, like: false, blocked: false)
            }
        }, Message: messageEntity.createBasicMessage(), text: text, roomID: roomID, Like: false, receiverID: targetProfile.Required_UID,senderNickname: self.selfProfile.Required_NickName)
    }
}


///EXTENSION[表示UI関連処理]
extension ChatViewController:MessagesDisplayDelegate {
    // メッセージの背景色を変更している
    func backgroundColor(
        for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        switch message.kind {
        case .photo(_):
            return .clear
        default:
            let targetColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            return isFromCurrentSender(message: message) ? .white : targetColor
        }
    }
    // メッセージの枠にしっぽを付ける
    func messageStyle(
        for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView
    ) -> MessageStyle {
        if case .photo(_) = message.kind {
            return .none
        }
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft

        let outlineColor:UIColor = isFromCurrentSender(message: message) ? .black: .clear
        
        return .bubbleTailOutline(outlineColor, corner, .curved)
    }

    // プロフィール画像をセット
    func configureAvatarView(
        _ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView
    ) {
        if message.sender.senderId == self.selfProfile.Required_UID{
            ///自身のプロフィール画像設定
            avatarView.set( avatar: Avatar(image: selfProfileImage) )
        } else {
            ///相手のプロフィール画像設定
            avatarView.set( avatar: Avatar(image: targetProfileImage) )
        }

    }

}
///EXTENSION[メッセージの受信関連]
extension ChatViewController {
    ///ローカルからチャットデータを取得
    func localMessageGetting() {
        self.messageListAppendManager()
    }
    
    func hostingMessageGetting() {
        ///自分がブロックしている場合または自分がブロックされている場合は受信しない
        if self.BLOCKING == .IBlocked || self.BLOCKING == .Meblocked {
            return
        } else {
            ///ハンドラーに追加
            handle = CHATDATAHOSTGETTER.messageListenerManager(callback: { hstMsgArray in
                ///メッセージを一つずつ取り出して保存関数へ
                for hstMessage in hstMsgArray {
                    self.LocalMessageDataSave(lclMessage: hstMessage)
                    ///相手のメッセージだった場合は既読をつける
                    if hstMessage.lcl_Sender != self.selfProfile.Required_UID {
                        self.CHATDATAHOSTSETTER.ProcessListendFetch(childKey: hstMessage.lcl_ChildKey, roomID: self.roomID)
                    }
                }
                ///Firebaseから受信したものも含めてローカルデータでチャットデータ追加処理
                self.messageListAppendManager()
                ///ここで配列格納変数を呼び出し
            }, roomID: roomID, TIMETOOL: TIMETOOL)
        }
    }
    
    ///ローカル保存
    func LocalMessageDataSave(lclMessage:MessageLocalObject) {
        var MessgeLocalSetterManager = MessageLocalSetterManager(updateMessage: lclMessage)
        MessgeLocalSetterManager.commiting = true
    }
    
}

///EXTENSION[配列にメッセージを追加]
extension ChatViewController {
    func messageListAppendManager() {
        ///現在ある配列から時間を取得
        let desiredUpdateAtValue = messageArray.last?.sentDate
        
        for lclMessage in MESSAGELOCALGETTER.Getter(loomId: roomID, desiredUpdateAtValue: desiredUpdateAtValue) {
            ///Date型をStringに変換
            let messageSentDataString = TIMETOOL.dateToStringFormatt(date: lclMessage.lcl_Date, formatFlg: .YMDHMS)
            ///日付を年月までで切り取り
            let YEARMONTHDATE = (messageSentDataString as NSString).substring(to: 10)
            let GroupingFlag = DateGrouping(localmessage: lclMessage, YEARMONTHDATE: YEARMONTHDATE)
            messageAppend(localmessage: lclMessage, GroupFlag: GroupingFlag, YEARMONTHDATE: YEARMONTHDATE)
        }
        reloadData = true
    }
    
    private func DateGrouping(localmessage:MessageLocalObject,YEARMONTHDATE:String) -> (Bool) {

        ///日付格納配列がNULLでない
        if let DateFirst = DateGrouping.last {
            ///日付格納配列の中の最新が現在見ているデータと異なっている
            if DateFirst != YEARMONTHDATE {
                return false
            } else {
                return true
            }
        ///日付格納配列がNULL
        } else {
            
            return false
        }
    }
    
    private func messageAppend(localmessage:MessageLocalObject,GroupFlag:Bool,YEARMONTHDATE:String) {
        ///自分と相手どちらのニックネームかを判断
        let assignedNickName:String = {
            if localmessage.lcl_Sender == selfProfile.Required_UID {
                return selfProfile.Required_NickName
            }
            return targetProfile.Required_NickName
        }()
        ///自分と相手どちらが送信者かを判断
        let assignedUser:SENDUSER = {
            if localmessage.lcl_Sender == selfProfile.Required_UID {
                return .SELF
            }
            return .TARGET
        }()
        
        ///データ不備が一つでもあれば追加しない
        guard let message = localmessage.lcl_Message,let sender = localmessage.lcl_Sender, let messageID = localmessage.lcl_MessageID , let sentDate = localmessage.lcl_Date else {
            return
        }
        
        ///配列格納
        //ライクデータ
        if localmessage.lcl_LikeButtonFLAG {
            let photo = MessageMediaEntity.new(image: UIImage(named: "star"))
            let MediaMessage = MessageEntity(Contents: photo, senderID: sender, displayName: assignedNickName, messageID: messageID, sentDate: sentDate, DateGroupFlg: GroupFlag, SENDUSER: assignedUser)
            messageArray.append(MediaMessage.createBasicMessage())
                
        } else {
        ///配列格納
        //メッセージデータ
            let Message = MessageEntity(message: message, senderID: sender, displayName: assignedNickName, messageID: messageID, sentDate: sentDate, DateGroupFlg: GroupFlag, SENDUSER: assignedUser)
            messageArray.append(Message.createBasicMessage())
        }
        ///最後に日付格納
        DateGrouping.append(YEARMONTHDATE)
    }
}

///EXTENSION[各種処理]
extension ChatViewController:FloatingPanelControllerDelegate,reportViewControllerDelegate {
    
    func initSetting() {
        ///背景色
        messagesCollectionView.backgroundColor = .white
        ///デリゲート設定
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        ///送信バーの装飾
        messageInputBar.inputTextView.placeholder = "メッセージを入力"
        messageInputBar.inputTextView.textColor = .black
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.image = UIImage(systemName: "paperplane")
    }
    
    func closeKeyboard(){
        self.messageInputBar.inputTextView.resignFirstResponder()
        self.messagesCollectionView.scrollToLastItem()
    }
    
    func navigationBarSetUp() {
        /// カスタムのタイトルビューを作成
        let titleLabel = UILabel()
        titleLabel.text = targetProfile.Required_NickName
        titleLabel.textColor = UIColor.gray
        /// ナビゲーションバーのタイトルビューを設定
        self.navigationItem.titleView = titleLabel
        navigationController?.navigationBar.barTintColor = UIColor.white
        ///barボタン初期設定
        let barButtonArrowItem = barButtonItem(frame: .zero, BarButtonItemKind: .left)
        barButtonArrowItem.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        let customBarButtonItem = UIBarButtonItem(customView: barButtonArrowItem)
        self.navigationItem.leftBarButtonItem = customBarButtonItem
    }
    
    ///戻るボタンタップ時のアクション
    @objc func backButtonTapped() {
        ///リスト画面へのデリゲート処理。
        listViewControllerDelegateAction()
        ///前の画面に戻る
        self.dismiss(animated: false, completion: nil)
        self.slideOutToLeft()
    }
    //デリゲート処理(最新画像および通知アイコン更新)
    func listViewControllerDelegateAction() {
        if let newTargetProfileImage = newTargetProfileImage {
            delegate?.newImageSettingDelegate(UID: targetProfile.Required_UID, targetImage: newTargetProfileImage)
        }
    }
    ///メニューボタンタップ時のアクション
    @objc func menuBarButtonTapped() {
        createSheet(for: .Options(["プロフィールを表示",blockText,"通報"], { selected in
            switch selected {
                ///プロフィール画面遷移
            case 0:
                ///遷移先の画面
                let profileViewController = ProfileViewController(TARGETINFO: self.targetProfile, SELFINFO: self.selfProfile, TARGETIMAGE: self.targetProfileImage)
                ///チャットビューから来ていることを知らせるフラグ
                profileViewController.fromChatViewController = true
                profileViewController.modalPresentationStyle = .fullScreen
                self.present(profileViewController, animated: false, completion: nil)
                self.slideInFromRight() // 遷移先の画面を横スライドで表示
                return
                ///ブロックボタン押下処理
            case 1:
                ///現在ブロックしていたら解除
                if self.BLOCKING == .IBlocked {
                    self.blockPush(Blocking: false)
                } else {
                ///現在ブロックしていなかったらブロック
                    self.blockPush(Blocking: true)
                }
                return
            case 2:
                self.REPORT_FPC.delegate = self
//                self.modalState = .report
                self.REPORT_FPC.layout = CustomFloatingPanelLayout(initialState: .full)
                self.REPORT_FPC.isRemovalInteractionEnabled  =  true
                self.REPORT_FPC.backdropView.dismissalTapGestureRecognizer.isEnabled = true
                let reportViewController = ReportViewController(roomID: self.roomID, selfInfo: self.selfProfile, targetInfo: self.targetProfile)
                reportViewController.delegate = self
                self.REPORT_FPC.set(contentViewController: reportViewController)
                self.REPORT_FPC.addPanel(toParent: self, at: -1, animated: true, completion: nil)
            default:
                return
            }
        }), SelfViewController:  self)
    }
    
    func removeFPC() {
        REPORT_FPC.removePanelFromParent(animated: true)
    }

    ///送信した後の処理
    func sendToMessageBar() {
        messageInputBar.inputTextView.text = ""
    }
    ///ブロックサーバー確認
    func targetBlockingConf() {
        BLOCLHOSTGETTER.targetBlockConfListener(callback: { BlockKind in
            switch BlockKind {
            case .INone:
                self.BLOCKING = .INone
                ///ブロック情報が問題ない場合サーバーメッセージ取得
                self.hostingMessageGetting()
            case .MeNone:
                self.BLOCKED = .MeNone
                ///ブロック情報が問題ない場合サーバーメッセージ取得
                self.hostingMessageGetting()
            case .IBlocked:
                self.BLOCKING = .IBlocked
                
            case .Meblocked:
                self.BLOCKED = .Meblocked
            }

        }, targetUID: targetProfile.Required_UID, selfUID: selfProfile.Required_UID)
    }
    ///ブロック押下時
    func blockPush(Blocking:Bool) {
        ///ロードビュー表示
        loadingView.loadingViewIndicator(isVisible: true)
        ///ブロック登録処理
        BLOCKHOSTSETTER.blockingOperater(callback: { result in
            ///ロードビュー非表示
            self.loadingView.loadingViewIndicator(isVisible: false)
            if !result {
                createSheet(for: .Retry(title: "ブロック処理に失敗しました。再度試してください"), SelfViewController: self)
            } else {
                if Blocking {
                    ///ブロック成功
                    self .BLOCKING = .IBlocked
                } else {
                    ///ブロック解除成功
                    self .BLOCKING = .INone
                }
            }
        }, MyUID: selfProfile.Required_UID, targetUID: targetProfile.Required_UID, block: Blocking, nickname: targetProfile.Required_NickName)
    }
    ///ブロック時のViewレイアウト
    func blockingLayout(Enable:Bool) {
        if Enable {
            messageInputBar.inputTextView.placeholder = "ブロック中"
            ///送信画像の色彩変更
            if let image = UIImage(systemName: "paperplane") {
                let coloredImage = image.withTintColor(UIColor.gray)
                messageInputBar.sendButton.image = coloredImage
            }
            messageInputBar.inputTextView.isEditable = false // テキスト入力を無効にする
            messageInputBar.sendButton.isEnabled = false // 送信ボタンを無効にする
        } else {
            messageInputBar.inputTextView.placeholder = "メッセージを入力"
            messageInputBar.sendButton.image = UIImage(systemName: "paperplane")
            messageInputBar.inputTextView.isEditable = true // テキスト入力を有効にする
            messageInputBar.sendButton.isEnabled = true // 送信ボタンを有効にする
        }

    }
    
}

