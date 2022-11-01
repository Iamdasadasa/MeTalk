import MessageKit
import UIKit
import InputBarAccessoryView

struct User: SenderType {
    var senderId: String
    let displayName: String
}

enum userType {
    case me(UID:String,displayName:String)
    case you(UID:String,displayName:String)
    
    var data: SenderType {
            switch self {
            case let .me(UID,displayName):
                return User(senderId: UID, displayName: displayName)
            case let .you(UID,displayName):
                return User(senderId: UID, displayName: displayName)
            }
    }
    
    var meFag: Int {
        switch self {
            case .me:
                return 1
            case .you:
                return 0
        }
    }
}

struct MockMessage: MessageType {

    var messageId: String
    var sender: SenderType
    var sentDate: Date
    var kind: MessageKind
    var DateGroupFlg:Bool

    private init(kind: MessageKind, sender: SenderType, messageId: String, date: Date,messageDateGroupingFlag:Bool) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.DateGroupFlg = messageDateGroupingFlag
    }

    ///メッセージの情報だけを取り扱いたい時はこっちでInitしてインスタンス化
    init(attributedText: NSAttributedString, sender: SenderType, messageId: String, date: Date,messageDateGroupingFlag:Bool) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date, messageDateGroupingFlag: messageDateGroupingFlag)
        
//        self.init(kind: .custom(messageDateGroupingFlag), sender: sender, messageId: messageId, date: date)
    }
    ///画像の情報を取り扱いたいときはこっちでinitしてインスタンス化
    init(photo: MediaItem, sender: SenderType, messageId: String, date: Date,messageDateGroupingFlag:Bool) {
        self.init(kind: .photo(photo), sender: sender, messageId: messageId, date: date, messageDateGroupingFlag: messageDateGroupingFlag)
    }

    static func loadMessage(text: String, user: userType,data:Date,messageID:String,messageDateGroupingFlag:Bool) -> MockMessage {
        if user.meFag == 1 {
            let attributedText = NSAttributedString(
                string: text,
                attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor:UIColor.black]
            )
            return MockMessage(attributedText: attributedText, sender: user.data, messageId: messageID, date: data, messageDateGroupingFlag: messageDateGroupingFlag)
        } else {
            let attributedText = NSAttributedString(
                string: text,
                attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor:UIColor.white]
            )
            return MockMessage(attributedText: attributedText, sender: user.data, messageId: messageID, date:data, messageDateGroupingFlag: messageDateGroupingFlag)
        }
    }
    
    static func likeInfoLoad(photo:MediaItem,user: userType,data:Date,messageID:String,messageDateGroupingFlag:Bool) -> MockMessage {
        if user.meFag == 1 {

            return MockMessage(photo: photo, sender: user.data, messageId: messageID, date: data, messageDateGroupingFlag: messageDateGroupingFlag)
        } else {

            return MockMessage(photo: photo, sender: user.data, messageId: messageID, date: data, messageDateGroupingFlag: messageDateGroupingFlag)
        }
        
    }
    
}


struct MessageMediaEntity: MediaItem {
    var url: URL?
    var image: UIImage?

    var placeholderImage: UIImage {
        return UIImage(named: "questionmark.app.fill")!
    }
    var size: CGSize {
        return CGSize(width: UIScreen.main.bounds.width/4,
                      height: UIScreen.main.bounds.width/4)
    }

    // MARK: static new
    static func new(url: URL?) -> MessageMediaEntity {
        MessageMediaEntity(url: url, image: nil)
    }

    static func new(image: UIImage?) -> MessageMediaEntity {
        MessageMediaEntity(url: nil, image: image)
    }
}
