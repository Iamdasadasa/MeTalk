//
//  NetworkConf.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/10/21.
//

import Foundation
import Reachability
import UIKit
///ネットワーク状況判断
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
    ///必要なアクションシート要素変数
    let title01:String
    var title02:String?
    var message:String?
    var buttonMessage:String?
    ///返却アクションが1アクション用のカスタム列挙　結果用
    enum oneActionResult {
        case one
    }
    ///1アクション使用時のイニシャライザ
    init(oneAtcionTitle1:String) {
        self.title01 = oneAtcionTitle1
    }
    ///返却アクションが2アクション用のカスタム列挙　結果用
    enum twoActionResult {
        case one
        case two
    }
    ///2アクション使用時のイニシャライザ
    init(twoAtcionTitle1:String,twoAtcionTitle2:String) {
        self.title01 = twoAtcionTitle1
        self.title02 = twoAtcionTitle2
    }
    ///OKボタンと決定ボタンアクションどちらかを使用するときのイニシャライザ
    init(dicidedOrOkOnlyTitle:String,message:String,buttonMessage:String) {
        self.title01 = dicidedOrOkOnlyTitle
        self.message = message
        self.buttonMessage = buttonMessage
    }
    ///タイトル・1ボタン・キャンセル　アクション
    func showOneActionSheets(callback:@escaping(oneActionResult) -> Void,SelfViewController:UIViewController) {
        //アクションシートを作る
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //ボタン1
        alert.addAction(UIAlertAction(title: title01, style: .default, handler: {
            (action: UIAlertAction!) in
            callback(.one)
        }))
        //キャンセルボタン
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    }
    ///タイトル・2ボタン・キャンセル　アクション
    func showTwoActionSheets(callback:@escaping(twoActionResult) -> Void,SelfViewController:UIViewController) {
        //アクションシートを作る
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //ボタン1
        alert.addAction(UIAlertAction(title: title01, style: .default, handler: {
            (action: UIAlertAction!) in
            callback(.one)
        }))
        //ボタン２
        alert.addAction(UIAlertAction(title: title02, style: .default, handler: {
            (action: UIAlertAction!) in
            callback(.two)
        }))
        //キャンセルボタン
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    }
    ///タイトル・メッセージ・1ボタン・キャンセル　アクション
    func dicidedAction(callback:@escaping(oneActionResult) -> Void,SelfViewController:UIViewController) {
        let alert = UIAlertController(title: title01, message: message, preferredStyle: UIAlertController.Style.alert)
        //ボタン1
        alert.addAction(UIAlertAction(title: buttonMessage, style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            callback(.one)
        }))
        //ボタン2
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    }
    ///タイトル・メッセージ・OK　アクション
    func okOnlyAction(callback:@escaping(oneActionResult) -> Void,SelfViewController:UIViewController) {
        let alert = UIAlertController(title: title01, message: message, preferredStyle: UIAlertController.Style.alert)
        //ボタン1
        alert.addAction(UIAlertAction(title: buttonMessage, style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            callback(.one)
        }))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    }
    
}

struct LOADING {
    let loadingView:LoadingView
    init(loadingView:LoadingView) {
        self.loadingView = loadingView
    }

    func loadingViewIndicator(isVisible:Bool){
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        isVisible ? window?.addSubview(loadingView) : loadingView.removeFromSuperview()
    }
}

struct TIME {
    ///過去時間を持ってくる関数
    func pastTimeGet() -> Date{
        
        let calendar = Calendar(identifier: .gregorian)
        let date = Date()
        let modifiedDate = calendar.date(byAdding: .day, value: -10000, to: date)!
        
        return modifiedDate
        
    }
}

struct chatTools {
    ///ChatのルームIDを生成する
    func roomIDCreate(UID1:String,UID2:String) -> String{
        let array = [UID1,UID2]
        let sortArray = array.sorted()
        let roomID:String = sortArray[0] + "_" + sortArray[1]
        return roomID
    }
}
