//
//  PublicRoomChatListModel.swift
//  Steady
//
//  Created by KOJIRO MARUYAMA on 2023/12/20.
//

import Foundation
import UIKit

enum RoomInfoCommonImmutable:String{
    case MF2 = "MF2"
    case UF2 = "UF2"
    case UM2 = "UM2"
    
    var maxParticipants:Int {
        switch self {
        case .MF2:
            return 2
        case .UF2:
            return 2
        case .UM2:
            return 2
        }
    }
    
    var RoomImage:UIImage {
        get {
            switch self {
            case .MF2:
                return UIImage(named: "MF2_First")!
            case .UF2:
                return UIImage(named: "UF2_First")!
            case .UM2:
                return UIImage(named: "UM2_First")!
            }
        }
    }
    
    // Stringからenumケースを取得する
    static func getRoomInfoCommonImmutable(from stringValue: String) -> RoomInfoCommonImmutable? {
        return RoomInfoCommonImmutable(rawValue: stringValue)
    }
    
}

struct RequiredPublicRoomInfoStruct {
    let name: String
    let roomObjectName:String
    let maxParticipants: Int
    let currentParticipants: Int
    var isFull: Bool {
        return currentParticipants == maxParticipants
    }
    var roomTypeInfo:RoomInfoCommonImmutable? {
        get {
            return RoomInfoCommonImmutable.getRoomInfoCommonImmutable(from: self.roomObjectName)
        }
    }
    
    var RoomAvailabilityImage:UIImage {
        get {
            if currentParticipants == maxParticipants {
                return UIImage(named: "Full")!
            } else {
                return UIImage(named: "Vacancy")!
            }
        }
    }
    
    // ChatRoomに直接情報を持たせる場合のイニシャライザ
    init(name: String, maxParticipants: Int, currentParticipants: Int,roomObjectName:String) {
        self.roomObjectName = roomObjectName
        self.name = name
        self.maxParticipants = maxParticipants
        self.currentParticipants = currentParticipants
    }
}



