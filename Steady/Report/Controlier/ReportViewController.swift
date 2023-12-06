//
//  ReportViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/10/12.
//

import Foundation
import UIKit
protocol reportViewControllerDelegate:AnyObject {
    func removeFPC()
}

class ReportViewController:UIViewController {
    var ROOMID:String
    var SELFINFO:RequiredProfileInfoLocalData
    var TARGETINFO:RequiredProfileInfoLocalData
    var REPORTHOSTINGSETTER = reportHostSetterManager()
    var reportView = ReportView()   ///画面
    weak var delegate:reportViewControllerDelegate?
    
    init(roomID:String,selfInfo:RequiredProfileInfoLocalData,targetInfo:RequiredProfileInfoLocalData) {
        self.SELFINFO = selfInfo
        self.TARGETINFO = targetInfo
        self.ROOMID = roomID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = reportView
        ///デリゲート設定
        reportView.delegate = self
    }
}

extension ReportViewController:ReportViewDelegateProtcol{
    ///違反確認ボタン押下時アクション
    func dicitionButtontappedAction(reportDetail: ReportReason) {
        createSheet(for: .Alert(title: "\(reportDetail.rawValue)", message: "虚偽の通報・連続での通報は行わないでください。", buttonMessage: "通報する", { result in
            if result {
                self.reportServerSend(reportDetail: reportDetail)
            }
        }), SelfViewController: self)
    }
    
    func reportServerSend(reportDetail: ReportReason) {
        REPORTHOSTINGSETTER.reportMemberSetter(callback: { result in
            if result {
                createSheet(for: .Completion(title: "通報完了", {
                    self.delegate?.removeFPC()
                }), SelfViewController: self)
            } else {
                createSheet(for: .Retry(title: "通報に失敗しました"), SelfViewController: self)
            }
        }, selfUID: SELFINFO.Required_UID, targetUID: TARGETINFO.Required_UID, roomID: ROOMID, kind: reportDetail)
    }
}
