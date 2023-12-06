//
//  AdminUserCheckingChatViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/11/01.
//

import Foundation
import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase


class AdminUserCheckingChatViewController:MessagesViewController {
    let selfProfile:RequiredProfileInfoLocalData    ///自身のプロフィール
    let targetProfile:RequiredProfileInfoLocalData  ///相手のプロフィール
    var TargetProfileImage:UIImage = UIImage()
    var selfProfileImage:UIImage
    
    let CONTENTSHOSTGETTER = ContentsHostGetter()   ///コンテンツ取得インスタンス(FIREBASE)
    let CHATDATAHOSTGETTER = ChatDataHostGetterManager()
    let MESSAGELOCALGETTER = MessageLocalGetterManager()

    let loadingView = LOADING(loadingView: LoadingView(), BackClear: true)  ///画面ロードビュー
    let ROOMIDMANAGER = chatTools() ///ルームID生成インスタンス
    let TIMETOOL = TimeTools()  ///時間関連ツールインスタンス
    let PASTTIME = TIME()   ///時間関連ツールインスタンス
    var messageArray:[MessageType] = [] ///メッセージを格納する配列
    var DateGrouping:[String] = []  ///時間グルーピング用配列
    let databaseRef: DatabaseReference! = Database.database().reference()   //DBインスタンス
    private var handle: DatabaseHandle? ///リスナーハンドラ
    var navigationBarHeight:CGFloat {
        get {
            guard let navigationController = navigationController else {
                return 44
            }
            return navigationController.navigationBar.frame.size.height
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
    
    init (selfProfile:RequiredProfileInfoLocalData,targetProfile:RequiredProfileInfoLocalData,SELFPROFILEIMAGE:UIImage) {
        self.selfProfile = selfProfile
        self.targetProfile = targetProfile
        self.selfProfileImage = SELFPROFILEIMAGE
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
        ///初回メッセージ取得
        self.messageManager()
        ///Firebase通信（最新画像）
        CONTENTSHOSTGETTER.MappingDataGetter(callback: {OBJECT, err in
            ///相手のプロフィール画像設定
            self.TargetProfileImage = OBJECT.profileImage
            
        }, UID: targetProfile.Required_UID, UpdateTime:PASTTIME.pastTimeGet())
        
    }
    
    //viewが表示されなくなる直前に呼び出されるメソッド
    override func viewWillDisappear(_ animated: Bool) {
        if let handle = handle {
            databaseRef.child("chats").removeObserver(withHandle: handle)
        }
    }
}

///EXTENSION[メッセージ関連]
extension AdminUserCheckingChatViewController:MessagesDataSource {
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
extension AdminUserCheckingChatViewController:MessagesLayoutDelegate {
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
extension AdminUserCheckingChatViewController:MessageCellDelegate {
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
///EXTENSION[表示UI関連処理]
extension AdminUserCheckingChatViewController:MessagesDisplayDelegate {
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
            avatarView.set( avatar: Avatar(image: TargetProfileImage) )
        }

    }
}
///EXTENSION[メッセージの受信関連]
extension AdminUserCheckingChatViewController {
    func messageManager() {
            ///ハンドラーに追加
            CHATDATAHOSTGETTER.adminMessageListnerManager(callback: { hstMsgArray in
                ///メッセージを一つずつ取り出して保存関数へ
                for hstMessage in hstMsgArray {
                    ///Date型をStringに変換
                    let messageSentDataString = self.TIMETOOL.dateToStringFormatt(date: hstMessage.lcl_Date, formatFlg: .YMDHMS)
                    ///日付を年月までで切り取り
                    let YEARMONTHDATE = (messageSentDataString as NSString).substring(to: 10)
                    let GroupingFlag = self.DateGrouping(localmessage: hstMessage, YEARMONTHDATE: YEARMONTHDATE)
                    self.messageAppend(localmessage: hstMessage, GroupFlag: GroupingFlag, YEARMONTHDATE: YEARMONTHDATE)
                }
                ///リロードデータ
                self.reloadData = true
            }, roomID: roomID, TIMETOOL: TIMETOOL)
    }
}

///EXTENSION[配列にメッセージを追加]
extension AdminUserCheckingChatViewController {
    
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
extension AdminUserCheckingChatViewController {
    
    func initSetting() {
        ///デリゲート設定
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        ///送信バーの装飾

        messageInputBar.sendButton.title = nil
        messageInputBar.inputTextView.isEditable = false // テキスト入力を無効にする
        messageInputBar.sendButton.isEnabled = false // 送信ボタンを無効にする
    }
    
    func closeKeyboard(){
        self.messageInputBar.inputTextView.resignFirstResponder()
        self.messagesCollectionView.scrollToLastItem()
    }
    
    func navigationBarSetUp() {
        /// カスタムのタイトルビューを作成
        let titleLabel = UILabel()
        titleLabel.text = targetProfile.Required_NickName
        titleLabel.textColor = UIColor.black
        /// ナビゲーションバーのタイトルビューを設定
        self.navigationItem.titleView = titleLabel
        ///バックボタン設定
        let backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(backButtonTapped))
        ///バーボタンセット
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    ///戻るボタンタップ時のアクション
    @objc func backButtonTapped() {
        ///前の画面に戻る
        self.dismiss(animated: false, completion: nil)
        self.slideOutToLeft()
    }
    
}

