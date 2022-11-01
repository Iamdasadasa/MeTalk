//
//  NetworkConf.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/10/21.
//

import Foundation
import Reachability

struct Reachabiliting{
    func NetworkStatus() -> Int {
        let REACHABILITING = try! Reachability()
        switch REACHABILITING.connection {
        case .wifi:
            return 1
        case .cellular:
            return 2
        case .unavailable:
            return 0
        case .none:
            return 0
        }
    }

}

//struct Dialog {
//    func dialogAction(title:String,message:String,ButtonMessage:String,SELF:UIViewController) -> UIAlertController {
//        let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        dialog.addAction(UIAlertAction(title: ButtonMessage, style: .default, handler: nil))
//        return dialog
//    }
//}
