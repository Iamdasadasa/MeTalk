import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    ///init変数　自分のUIDと相手のUID
    var MeUID:String!
    var YouUID:String!
    var MeInfo:[String:Any]!
    var YouInfo:[String:Any]!
    ///init変数　自分のプロフィール画像と相手のプロフィール画像
    var meProfileImage:UIImage!
    var youProfileImage:UIImage!
    ///日付判断用格納(セルの高さとセルのテキストのそれぞれ)
    var cellheigtDateSorting:[String] = []
    var cellTextValueDateSorting:[String] = []
    ///RoomID格納変数
    var roomID:String!
    ///追加でロードする際のCount変数
    var loadToLimitCount:UInt = 25
    ///重複してメッセージデータを取得しないためのフラグ
    var loadDataLockFlg:Bool = true
    ///追加メッセージデータ関数の起動を停止するフラグ
    var loadDataStopFlg:Bool = false
    ///時間計測
    var start:Date?
    ///時間まとめ用のKeyValue
    var DateGrouping:[String] = []
    
    ///インスタンス化(Model)
    let chatManageData = ChatDataManagedData()
    let databaseRef: DatabaseReference! = Database.database().reference()
    private var handle: DatabaseHandle!

    var messageList: [MockMessage] = [] {
        didSet {

            if !loadDataLockFlg {
                self.messagesCollectionView.reloadDataAndKeepOffset()
            } else {
                // messagesCollectionViewをリロード
                self.messagesCollectionView.reloadData()
                // 一番下までスクロールする
                self.messagesCollectionView.scrollToLastItem()
            }

        }
    }

    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        ///listendがFalse（既読扱いになっていないもののみ）を取得
        handle = databaseRef.child("Chat").child(roomID).queryOrdered(byChild: "listend").queryEqual(toValue: false).observe(.value) { (snapshot: DataSnapshot) in
            DispatchQueue.main.async {//クロージャの中を同期処理
                self.snapshotToArray(snapshot: snapshot)//スナップショットを配列(readData)に入れる処理。下に定義
            }
        }
        

        ///ここで初回のメッセージを取得してくる。また、リアルタイム更新もここでやる。
        self.LoadMessageGet(roomID: roomID)

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self

        setupInput()
        setupButton()
        // 背景の色を指定
        messagesCollectionView.backgroundColor = .black

        // メッセージ入力時に一番下までスクロール
        scrollsToLastItemOnKeyboardBeginsEditing = true
        ///これをTrueにするとキーボードにメッセージのセルがアクションごとに追従するようになる。
        maintainPositionOnKeyboardFrameChanged = false
        
        ///タイトルラベル追加
        navigationItem.title = "\(YouInfo["nickname"] as! String)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //viewが表示されなくなる直前に呼び出されるメソッド
    override func viewWillDisappear(_ animated: Bool) {
        databaseRef.child("chats").removeObserver(withHandle: handle)
    }

    private func setupInput(){
        // プレースホルダーの指定
        messageInputBar.inputTextView.placeholder = "入力"
        // 入力欄のカーソルの色を指定
        messageInputBar.inputTextView.tintColor = .red
        // 入力欄の色を指定
        messageInputBar.inputTextView.backgroundColor = .white
        //入力欄に入力した文字色を変更
        messageInputBar.inputTextView.textColor = .black
    }

    private func setupButton(){
        // ボタンの変更
        messageInputBar.sendButton.title = "送信"
        // 送信ボタンの色を指定
        messageInputBar.sendButton.tintColor = .orange
    }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return userType.me(UID: self.MeUID, displayName: self.MeInfo["nickname"] as! String).data
    }

    func otherSender() -> SenderType {
        return userType.you(UID: self.YouUID, displayName: self.YouInfo["nickName"] as! String).data
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }

    // メッセージの上に文字を表示
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
            return NSAttributedString(
                string: chatManageData.string(from: message.sentDate),
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.darkGray
                ]
            )
    }

    // メッセージの上に文字を表示（名前）
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    // メッセージの下に文字を表示（時間）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = ChatDataManagedData.dateToStringFormatt(date: message.sentDate, formatFlg: 1)
        return NSAttributedString(string: dateString, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    //NSAttributedStringを使用している場合はこれは呼ばれない
//    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
//    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
//        return isFromCurrentSender(message: message) ? .white : .darkText
//    }
    
    // メッセージの背景色を変更している
    func backgroundColor(
        for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        isFromCurrentSender(message: message) ? .orange : .darkGray
    }

    // メッセージの枠にしっぽを付ける
    func messageStyle(
        for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView
    ) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    // アイコンをセット
    func configureAvatarView(
        _ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView
    ) {
        avatarView.set( avatar: Avatar(image: message.sender.senderId == MeUID ? meProfileImage : youProfileImage) )
    }
}


// 各ラベルの高さを設定（デフォルト0なので必須）
// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    
    
    ///日付ラベルの高さ（有無）設定
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        ///messageはmessageTypeで直接フラグを持ってこれないので一旦MockMessage型に変換
        let messages:MockMessage = message as! MockMessage
        
        ///フラグがTrueであれば日付ラベル表示
        if messages.DateGroupFlg{
            return 10
        } else {
            return 0
        }

    }
    

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        16
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        16
    }
}

// MARK: - MessageCellDelegate
extension ChatViewController: MessageCellDelegate {

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

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    // 送信ボタンをタップした時の挙動
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        let attributedText = NSAttributedString(
            string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
        let message = MockMessage(attributedText: attributedText, sender:currentSender(), messageId: UUID().uuidString, date: Date(), messageDateGroupingFlag: false)

            ///FireBaseにデータ書き込み（書き込みした時点で読み込みリロードhandlerが呼ばれる）
            chatManageData.writeMassageData(mockMassage: message, text: text, roomID: self.roomID)
            ///最初のメッセージが存在していない場合のみそれぞれのAuthにUIDを登録、存在していたらデータ更新
        chatManageData.talkListUserAuthUIDCreate(UID1: MeUID, UID2: YouUID,NewMessage: text, meNickName: self.MeInfo["nickname"] as! String, youNickname: self.YouInfo["nickname"] as! String, LikeButtonFLAG: false)
        
            self.messageInputBar.inputTextView.text = String()
            self.messageInputBar.invalidatePlugins()
//            self.messagesCollectionView.scrollToLastItem()
    }
}

extension ChatViewController {
    func closeKeyboard(){
        self.messageInputBar.inputTextView.resignFirstResponder()
        self.messagesCollectionView.scrollToLastItem()
    }
}


///本当は下記の処理もChatDataManagedDataのModelに書きたかったが、非同期処理内で自身のメッセージリストに投入する方法がなかったためにやむなくextesionで対応
import Firebase
extension ChatViewController {
    func LoadMessageGet(roomID:String){
        ///最初のメッセージまでロードしていたらリターン
        if loadDataStopFlg == true {
            return
        }
    }
    
    //データベースから読み込んだデータを配列(readData)に格納するメソッド
    func snapshotToArray(snapshot: DataSnapshot){
        //スナップショットとは、ある時点における特定のデータベース参照にあるデータの全体像を写し取ったもの
        if snapshot.children.allObjects as? [DataSnapshot] != nil  {
            let snapChildren = snapshot.children.allObjects as? [DataSnapshot]
            //snapChildrenの中身の数だけsnapChildをとりだす
            for snapChild in snapChildren! {
                ///それぞれのValue配列を取得
                if let postDict = snapChild.value as? [String: Any] {
                    ///日付格納配列初期化
                    DateGrouping = []
                    ///送信UIDが自身のUIDでなかった場合
                    let senderID = postDict["sender"] as! String
                    if  senderID != self.MeUID {
                        ///読み込んだメッセージのlistendは全てtrueに更新（送信者が自分以外）
                        databaseRef.child("Chat").child(roomID).child(snapChild.key).updateChildValues(["listend":true])
                    }
                    ///ライクボタン有無（ライクボタン以外がきたらfalse）
                    var likeButtonFLAG:Bool = false
                    likeButtonFLAG = postDict["LikeButtonFLAG"] as? Bool ?? false
                    ///ローカルデータベースに保存
                    localMessageDataRegist(roomID: roomID, listend: true, message: postDict["message"] as! String, sender: postDict["sender"] as! String, Date: ChatDataManagedData.stringToDateFormatte(date: postDict["Date"] as! String), messageID: postDict["messageID"] as! String, likeButtonFLAG: likeButtonFLAG)
                }
            }
        } else {
            print("ここはどうかな？")
        }
    }
    
    func messageListAppend() {
        var messageArray:[MockMessage] = []
        ///ローカルDBからメッセージ取得
        let LOCALMESSAGEDATA = localMessageDataGet(roomID: roomID)
        ///ローカルデータからデータ抽出
        for localmessage in LOCALMESSAGEDATA {
            ///Date型をStringに変換
            let messageSentDataString = ChatDataManagedData.dateToStringFormatt(date: localmessage["Date"] as? Date, formatFlg: 0)
            ///日付を年月までで切り取り
            let YEARMONTHDATE = (messageSentDataString as NSString).substring(to: 10)

            ///日付格納配列がNULLでない
            if let DateFirst = DateGrouping.last {
                ///日付格納配列の中の最新が現在見ているデータと異なっている
                if DateFirst != YEARMONTHDATE {
                    ///日付ラベルフラグをTRUE
                    messageAppend(FLAG: true)
                } else {
                    ///日付ラベルフラグをFALSE
                    messageAppend(FLAG: false)
                }
            ///日付格納配列がNULL
            } else {
                ///日付ラベルフラグをTRUE
                messageAppend(FLAG: true)
            }
            
            ///日付格納配列に格納
            DateGrouping.append(YEARMONTHDATE)
            
            ///メッセージ配列に適用
            func messageAppend(FLAG:Bool) {
                let likeTrue = localmessage["likeButtonFLAG"] as? Bool ?? false
                if likeTrue {
                    let mediaItem = MessageMediaEntity.new(image: UIImage(named: "LIKEBUTTON_IMAGE_Pushed"))
                    messageArray.append(MockMessage.likeInfoLoad(photo: mediaItem, user: userTypeJudge(senderID: localmessage["sender"] as! String), data: localmessage["Date"] as! Date, messageID: localmessage["messageID"] as! String, messageDateGroupingFlag: FLAG))
                }else {
                    messageArray.append(MockMessage.loadMessage(text: localmessage["message"] as! String, user: userTypeJudge(senderID: localmessage["sender"] as! String),data:localmessage["Date"] as! Date, messageID: localmessage["messageID"] as! String, messageDateGroupingFlag:FLAG))
                }
            }
            ///一番最初のメッセージまでロードし終えていたらフラグにTrueを設定
            if messageArray.first?.messageId == messageList.sorted(by: {$0.sentDate < $1.sentDate}).first?.messageId{
                loadDataStopFlg = true
            }
            
            self.messageList = messageArray

            self.becomeFirstResponder()
            loadDataLockFlg = true
        }
    }
    
    ///自身かどうか判断
    func userTypeJudge(senderID:String) -> userType{
        if senderID == Auth.auth().currentUser?.uid{
            return userType.me(UID: MeUID, displayName: self.MeInfo["nickname"] as! String)
        } else {
            return userType.you(UID: YouUID, displayName: self.YouInfo["nickname"] as! String)
        }
    }
    
}
