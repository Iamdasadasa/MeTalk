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

    private init(kind: MessageKind, sender: SenderType, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }

    init(text: String, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }

    ///メッセージの情報だけを取り扱いたい時はこっちでInitしてインスタンス化
    init(attributedText: NSAttributedString, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }

    static func loadMessage(text: String, user: userType,data:Date) -> MockMessage {
        if user.meFag == 1 {
            let attributedText = NSAttributedString(
                string: text,
                attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor:UIColor.black]
            )
            return MockMessage(attributedText: attributedText, sender: user.data, messageId: UUID().uuidString, date: data)
        } else {
            let attributedText = NSAttributedString(
                string: text,
                attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor:UIColor.white]
            )
            return MockMessage(attributedText: attributedText, sender: user.data, messageId: UUID().uuidString, date:data)
        }

    }
    
}
