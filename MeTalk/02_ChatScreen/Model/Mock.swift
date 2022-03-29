import MessageKit
import UIKit
import InputBarAccessoryView
import Firebase

struct User: SenderType {
    var senderId: String
    let displayName: String
}

enum userType {
    case me
    case you
    
    var data: SenderType {
        let Meuid = Auth.auth().currentUser?.uid
        var youuid:String?
        if Meuid == "MyQw4B7Zwr54un8YJsJ"{
            youuid = "MyQzN6hTobiVUQL2rkI"
        } else if Meuid == "MyQzN6hTobiVUQL2rkI"{
            youuid = "MyQw4B7Zwr54un8YJsJ"
        }
        guard let Meuid = Meuid else {
            return User(senderId: "エラー", displayName: "エラー")
        }
//        一旦このViewControllerの前に別のViewControllerを用意してそこでユーザーコレクションを取得してこの画面に渡して遷移するようにする
            switch self {
            case .me:
                return User(senderId: "Meuid", displayName: "俺")
            case .you:
                return User(senderId: "002", displayName: "お前")
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

    ///
    init(text: String, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }

    ///メッセージの情報だけを取り扱いたい時はこっちでInitしてインスタンス化
    init(attributedText: NSAttributedString, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }

    // サンプル用に適当なメッセージ
    static func getMessages() -> [MockMessage] {
        return [
            createMessage(text: "おはよう", user: .me),
            createMessage(text: "wwwwww", user: .me),
            createMessage(text: "おはようございます", user: .you),
            createMessage(text: "wwww", user: .me),
            createMessage(text: "草", user: .you),
        ]
    }

    static func createMessage(text: String, user: userType) -> MockMessage {
        let attributedText = NSAttributedString(
            string: text,
            attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black]
        )
        return MockMessage(attributedText: attributedText, sender: user.data, messageId: UUID().uuidString, date: Date())
    }
}
