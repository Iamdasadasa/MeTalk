//
//  MessageType.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/09/12.
//

import Foundation
import UIKit
import MessageKit

struct User: SenderType {
    var senderId: String
    let displayName: String
}

struct sender:SenderType {
    var senderId: String
    var displayName: String
}

enum SENDUSER {
    case SELF
    case TARGET
}
struct MessageEntity {

    var messageId: String
    var sentDate: Date
    var DateGroupFlg:Bool
    var Kind:MessageKind
    var sender: SenderType {
        get {
            return Steady.sender(senderId: senderId, displayName: displayName)
        }
    }
    
    private let senderId:String
    private let displayName:String
    
    //テキストでインスタンス化する際はこちら
    init(message:String,senderID:String,displayName:String,messageID:String,sentDate:Date,DateGroupFlg:Bool,SENDUSER:SENDUSER) {
        
        self.senderId = senderID
        self.displayName = displayName
        self.messageId = messageID
        self.sentDate = sentDate
        self.DateGroupFlg = DateGroupFlg
        
        switch SENDUSER {
        case .SELF:
            let attributedText = NSAttributedString(
                string: message,
                attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor:UIColor.black]
            )
            self.Kind = .attributedText(attributedText)
        case .TARGET:
            let attributedText = NSAttributedString(
                string: message,
                attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor:UIColor.black]
            )
            self.Kind = .attributedText(attributedText)
        }
    }
    ///イメージエンティティでインスタンス化する際はこちら
    init(Contents:MediaItem,senderID:String,displayName:String,messageID:String,sentDate:Date,DateGroupFlg:Bool,SENDUSER:SENDUSER) {
        self.senderId = senderID
        self.displayName = displayName
        self.messageId = messageID
        self.sentDate = sentDate
        self.Kind = .photo(Contents)
        self.DateGroupFlg = DateGroupFlg
    }
    
    func createBasicMessage() -> MessageType {
       return Message(Entity: self)
    }
    
}

struct Message : MessageType {
    var sender: MessageKit.SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKit.MessageKind
    
    var DateGroupFlg:Bool = false
    
    init(Entity: MessageEntity) {
        self.sender = Entity.sender
        self.messageId = Entity.messageId
        self.sentDate = Entity.sentDate
        self.kind = Entity.Kind
        self.DateGroupFlg = Entity.DateGroupFlg
    }
}

struct MessageMediaEntity: MediaItem {
    var url: URL?
    var image: UIImage?

    var placeholderImage: UIImage {
        return UIImage()
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
