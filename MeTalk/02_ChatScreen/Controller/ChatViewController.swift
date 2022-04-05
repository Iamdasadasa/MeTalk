import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    ///init変数自分のUIDと相手のUID
    var MeUID:String!
    var YouUID:String!
    var MeInfo:[String:Any]!
    var YouInfo:[String:Any]!
    ///日付判断用格納(セルの高さとセルのテキストのそれぞれ)
    var cellheigtDateSorting:[String] = []
    var cellTextValueDateSorting:[String] = []
    ///RoomID格納変数
    var roomID:String!
    ///Barボタンの設定(NavigationBar)
    var backButtonItem: UIBarButtonItem! // Backボタン
    
    ///インスタンス化(Model)
    let chatManageData = ChatDataManagedData()


    var messageList: [MockMessage] = [] {
        didSet {
            // messagesCollectionViewをリロード
            self.messagesCollectionView.reloadData()
            // 一番下までスクロールする
            self.messagesCollectionView.scrollToLastItem()
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
        self.tabBarController?.tabBar.isHidden = true

        ///ここで初回のメッセージを取得してくる。また、リアルタイム更新もここでやる。
        self.startingLoadMessageGet(roomID: roomID)

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
        
        ///barボタン初期設定
        backButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem
        ///タイトルラベル追加
        navigationItem.title = "トークリスト"
    }
    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func setupInput(){
        // プレースホルダーの指定
        messageInputBar.inputTextView.placeholder = "入力"
        // 入力欄のカーソルの色を指定
        messageInputBar.inputTextView.tintColor = .red
        // 入力欄の色を指定
        messageInputBar.inputTextView.backgroundColor = .white
    }

    private func setupButton(){
        // ボタンの変更
        messageInputBar.sendButton.title = "送信"
        // 送信ボタンの色を指定
        messageInputBar.sendButton.tintColor = .lightGray
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
        let stringData = ChatDataManagedData.dateToStringFormatt(date: message.sentDate)
        var labelValue:Bool
        labelValue = ChatDataManagedData.sectionDateGroup(dateArray: cellTextValueDateSorting, appendDate: stringData).flg
        cellTextValueDateSorting = ChatDataManagedData.sectionDateGroup(dateArray: cellTextValueDateSorting, appendDate: stringData).resultArray
        
        print("cellTopLabelAttributedText:\(indexPath.section):sentDate\(message.sentDate)")
        if labelValue {
            print("cellTopLabelAttributedText【labelValue】:\(indexPath.section):sentDate\(message.sentDate)")
                return NSAttributedString(
                    string: chatManageData.string(from: message.sentDate),
    //                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                    attributes: [
                        .font: UIFont.boldSystemFont(ofSize: 10),
                        .foregroundColor: UIColor.darkGray
                    ]
                )
        }

//        if indexPath.section == 1 {
//            return NSAttributedString(
//                string: chatManageData.string(from: message.sentDate),
////                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
//                attributes: [
//                    .font: UIFont.boldSystemFont(ofSize: 10),
//                    .foregroundColor: UIColor.white
//                ]
//            )
//        }
        return nil
    }

    // メッセージの上に文字を表示（名前）
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    // メッセージの下に文字を表示（日付）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
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
        avatarView.set( avatar: Avatar(initials: message.sender.senderId == "001" ? "😊" : "🥳") )
    }
}


// 各ラベルの高さを設定（デフォルト0なので必須）
// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 15
        
//        let stringData = ChatDataManagedData.dateToStringFormatt(date: message.sentDate)
//        var labelValue:Bool
//        labelValue = ChatDataManagedData.sectionDateGroup(dateArray: cellheigtDateSorting, appendDate: stringData).flg
//        cellheigtDateSorting = ChatDataManagedData.sectionDateGroup(dateArray: cellheigtDateSorting, appendDate: stringData).resultArray
//        print("cellTopLabelHeight:\(indexPath.section):sentDate\(message.sentDate)")
//        if labelValue {
//            print("cellTopLabelHeight:【labelValue】\(indexPath.section):sentDate\(message.sentDate)")
//            return 15
//        } else {
//            return 0
//        }
        
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
            let message = MockMessage(attributedText: attributedText, sender:currentSender(), messageId: UUID().uuidString, date: Date())
        
            ///FireBaseにデータ書き込み
            self.chatManageData.writeMassageData(mockMassage: message, text: text, roomID: self.roomID)
            self.messageList.append(message)
            self.messageInputBar.inputTextView.text = String()
            self.messageInputBar.invalidatePlugins()
            self.messagesCollectionView.scrollToLastItem()
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
    func startingLoadMessageGet(roomID:String){
        let databaseRef: DatabaseReference! = Database.database().reference()
        // 最新25件のデータをデータベースから取得する
        // 最新のデータ追加されるたびに最新データを取得する
        databaseRef.child("Chat").child(roomID).queryLimited(toLast: 50).queryOrdered(byChild: "Date:").observe(.value) { (snapshot: DataSnapshot) in
            DispatchQueue.main.async {//クロージャの中を同期処理
                self.snapshotToArray(snapshot: snapshot)//スナップショットを配列(readData)に入れる処理。下に定義
                
            }
        }
    }
    
    //データベースから読み込んだデータを配列(readData)に格納するメソッド
    func snapshotToArray(snapshot: DataSnapshot){
        var messageArray:[MockMessage] = []
        //スナップショットとは、ある時点における特定のデータベース参照にあるデータの全体像を写し取ったもの
        if snapshot.children.allObjects as? [DataSnapshot] != nil  {
            let snapChildren = snapshot.children.allObjects as? [DataSnapshot]
            //snapChildrenの中身の数だけsnapChildをとりだす
            for snapChild in snapChildren! {
                if let postDict = snapChild.value as? [String: Any] {
                    
                    messageArray.append(MockMessage.loadMessage(text: postDict["message"] as! String, user: userTypeJudge(senderID: postDict["sender"] as! String),data: ChatDataManagedData.stringToDateFormatte(date: postDict["Date"] as! String)))
                }
            }

            self.messageList = messageArray
            self.becomeFirstResponder()
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
