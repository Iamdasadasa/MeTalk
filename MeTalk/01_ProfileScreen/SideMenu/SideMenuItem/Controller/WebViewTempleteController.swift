//
//  WebViewTempleteController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/15.
//

import Foundation
import UIKit
import WebKit

///Webページ用列挙型
enum WebPage{
    ///Case宣言
    case TermsOfService
    case privacyPolicy
    ///URLと画面タイトル格納構造体
    struct Items {
        let MyURL:URL
        let title:String
    }
    ///Caseによって実体化される構造体
    var info:Items {
        switch self {
        case .TermsOfService:
            guard let URL = URL(string: "https://termsofservice-f2db.web.app/") else { preconditionFailure("URLの型変換に失敗しました。")
            }
            let Items = Items(MyURL: URL, title: "利用規約")
            
            return Items
        case .privacyPolicy:
            guard let URL = URL(string: "https://metalk-f132e.web.app/") else { preconditionFailure("URLの型変換に失敗しました。")
            }
            let Items = Items(MyURL: URL, title: "プライバシーポリシー")
            
            return Items
        }
    }
}

class WebViewTempleteController:UIViewController,WKUIDelegate{
    ///Barボタンの設定(NavigationBar)
    var backButtonItem: UIBarButtonItem! // Backボタン
    ///インスタンス時にイニシャライザで受け取るWEBページ用カスタム列挙型
    var webPageItem:WebPage
    ///Webページ表示用View
    var webview:WKWebView!
    ///イニシャライザ
    init(webPageItem:WebPage){
        self.webPageItem = webPageItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let webconf = WKWebViewConfiguration()
        webview = WKWebView(frame: .zero, configuration: webconf)
        webview.uiDelegate = self
        view = webview
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///barボタン初期設定
        backButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem
        ///イニシャライザされたカスタム列挙型によって処理を分岐
        switch self.webPageItem {
            ///プライバシーポリシー
        case .privacyPolicy:
            ///画面上タイトルとしてプライバシーポリシーの文言をセット
            navigationItem.title = self.webPageItem.info.title
            ///Webページを表示
            webview.load(URLRequest(url: self.webPageItem.info.MyURL))
        case .TermsOfService:
            ///画面上タイトルとして利用規約の文言をセット
            navigationItem.title = self.webPageItem.info.title
            ///Webページを表示
            webview.load(URLRequest(url: self.webPageItem.info.MyURL))
        }
    }
    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
     }
}
