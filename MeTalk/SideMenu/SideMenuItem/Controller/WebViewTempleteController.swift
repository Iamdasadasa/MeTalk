//
//  WebViewTempleteController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/15.
//

import Foundation
import UIKit
import WebKit

class WebViewTempleteController:UIViewController,WKUIDelegate{
    ///Barボタンの設定(NavigationBar)
    var backButtonItem: UIBarButtonItem! // Backボタン
    ///インスタンス時にイニシャライザで表示するページの判断フラグ変数
    var webPageFlg:Int
    ///Webページ表示用View
    var webview:WKWebView!
    
    init(webPageFlg:Int){
        self.webPageFlg = webPageFlg
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
        
        let MyURL:URL?
        if self.webPageFlg == 1{
            ///利用規約
            MyURL = URL(string: "https://termsofservice-f2db.web.app/")
            ///タイトルラベル追加
            navigationItem.title = "利用規約"
        } else if self.webPageFlg == 2{
            ///プライバシーポリシー
            MyURL = URL(string: "https://metalk-f132e.web.app/")
            navigationItem.title = "プライバシーポリシー"
        } else {
            MyURL = nil
        }
        guard let MyURL = MyURL else {
            return
        }

        let request = URLRequest(url: MyURL)
        webview.load(request)
    }
    
    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
     }
}
