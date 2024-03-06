//
//  DefaultValue.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/08/16.
//

import Foundation
///ユーザー情報初期値
enum USERINFODEFAULTVALUE {
    case aboutMeMassage
    case area

    var value:String {
        switch self {
        case .aboutMeMassage:
            return "よろしくお願いします"
        case .area:
            return "未設定"
        }
    }
}
