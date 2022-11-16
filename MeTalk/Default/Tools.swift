//
//  NetworkConf.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/10/21.
//

import Foundation
import Reachability
import UIKit

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

struct actionSheets{
    let title01:String
    var title02:String?
    var title03:String?
    var message:String?
    var buttonMessage:String?

    init(title01:String) {
        self.title01 = title01
    }
    
    init(title01:String,title02:String) {
        self.title01 = title01
        self.title02 = title02
    }
    
    init(title01:String,title02:String,title03:String) {
        self.title01 = title01
        self.title02 = title02
        self.title03 = title03
    }
    
    init(title01:String,message:String,buttonMessage:String) {
        self.title01 = title01
        self.message = message
        self.buttonMessage = buttonMessage
    }
    
    func showOneActionSheets(callback:@escaping(Int) -> Void,SelfViewController:UIViewController) {
        var actionFlg:Int = 0
        //アクションシートを作る
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //ボタン1
        alert.addAction(UIAlertAction(title: title01, style: .default, handler: {
            (action: UIAlertAction!) in
            actionFlg = 1
            callback(actionFlg)
        }))
        //キャンセルボタン
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    }
    
    func showTwoActionSheets(callback:@escaping(Int) -> Void,SelfViewController:UIViewController) {
        var actionFlg:Int = 0
        //アクションシートを作る
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //ボタン1
        alert.addAction(UIAlertAction(title: title01, style: .default, handler: {
            (action: UIAlertAction!) in
            actionFlg = 1
            callback(actionFlg)
        }))
        //ボタン２
        alert.addAction(UIAlertAction(title: title02, style: .default, handler: {
            (action: UIAlertAction!) in
            actionFlg = 2
            callback(actionFlg)
        }))
        //キャンセルボタン
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    }
    
    func showThreeActionSheets(callback:@escaping(Int) -> Void,SelfViewController:UIViewController) {
        var actionFlg:Int = 0
        //アクションシートを作る
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //ボタン1
        alert.addAction(UIAlertAction(title: title01, style: .default, handler: {
            (action: UIAlertAction!) in
            actionFlg = 1
            callback(actionFlg)
        }))
        //ボタン２
        alert.addAction(UIAlertAction(title: title02, style: .default, handler: {
            (action: UIAlertAction!) in
            actionFlg = 2
            callback(actionFlg)
        }))
        //ボタン3
        alert.addAction(UIAlertAction(title: title03, style: .default, handler: {
            (action: UIAlertAction!) in
            actionFlg = 2
            callback(actionFlg)
        }))
        //キャンセルボタン
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    }
    
    func showAlertActionChoise(callback:@escaping(Int) -> Void,SelfViewController:UIViewController) {
        let alert = UIAlertController(title: title01, message: message, preferredStyle: UIAlertController.Style.alert)
        //ボタン1
        alert.addAction(UIAlertAction(title: buttonMessage, style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            callback(1)
        }))
        //ボタン2
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    }
    
    func showAlertAction(SelfViewController:UIViewController) {
        let alert = UIAlertController(title: title01, message: message, preferredStyle: UIAlertController.Style.alert)
        //ボタン1
        alert.addAction(UIAlertAction(title: buttonMessage, style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
        }))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    }
    
}
