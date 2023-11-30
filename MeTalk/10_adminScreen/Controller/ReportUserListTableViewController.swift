//
//  ReportUserListTableView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/10/27.
//

import UIKit

class ReportMemberTableViewController: UITableViewController {
    ///Barボタンの設定(NavigationBar)
    let loadingView = LOADING(loadingView: LoadingView(), BackClear: true)  ///画面ロードビュー
    var backButtonItem: UIBarButtonItem! // Backボタン
    let REPORTMEMBERLISTTABLEVIEW = UITableView()   ///Viewのインスタンス化
    var REPORTHOSTGETTER = reportHostGetterManager()
    var REPORTHOSTSETTER = reportHostSetterManager()
    var reportMemberArray:[RequiredReportMemberInfoLocalData] = []
    var PROFILEHOSTGETTER = ProfileHostGetter()

    override func viewDidLoad() {
        super.viewDidLoad()
        reportMemberArray = []
        ///barボタン初期設定
        backButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem
        
        REPORTMEMBERLISTTABLEVIEW.backgroundColor = .white
        self.view = REPORTMEMBERLISTTABLEVIEW
        REPORTMEMBERLISTTABLEVIEW.register(ReportUserListTableViewCell.self, forCellReuseIdentifier: "ReportUserListTableViewCell")
        ///テーブルビューのデリゲート処理
        REPORTMEMBERLISTTABLEVIEW.dataSource = self
        REPORTMEMBERLISTTABLEVIEW.delegate = self
        memberHostGetting()
    }
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
     }

    // テーブルビューのセクション数
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // テーブルビューの行数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データソースから行数を取得するロジックを追加
        return reportMemberArray.count
    }

    // セルの設定
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportUserListTableViewCell", for: indexPath) as! ReportUserListTableViewCell
        cell.targetUID = reportMemberArray[indexPath.row].Required_reportedUID
        // セルのデータを設定するロジックを追加
        cell.delegate = self
        cell.reportID = reportMemberArray[indexPath.row].Required_reportID
        cell.topTextLabel.text = reportMemberArray[indexPath.row].Required_reportedUID
        cell.bottomTextLabel.text = reportMemberArray[indexPath.row].Required_ReportDetail
        return cell
    }

    // セルの高さ
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 // セルの高さを設定
    }

    // セルが選択された時の処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///ロード画面表示
        loadingView.loadingViewIndicator(isVisible: true)
        ///選んだセルのルームIDを取得
        let reportInfo = self.reportMemberArray[indexPath.row]
        
        let errMessage = {
            createSheet(for: .Retry(title: "ユーザー情報の取得に失敗しました。"), SelfViewController: self)
        }
        //まず通報された側を取得
        REPORTHOSTGETTER.reportOnlyUserInfoDataGetter(callback: { reportedUser,reportCount, err in
            ///ロード画面非表示
            self.loadingView.loadingViewIndicator(isVisible: false)
            if err != nil {
                errMessage()
            } else {
                //次点で通報した側を取得
                self.PROFILEHOSTGETTER.mappingDataGetter(callback: { reportingUser, err in
                    if err != nil {
                        errMessage()
                    } else {
                       let reportingInfoData = realmMapping.profileDataMapping(PROFILE: reportingUser, VC: self)
                        let reportedInfoData = realmMapping.profileDataMapping(PROFILE: reportedUser, VC: self)
                        
                        if let requiredReportingInfoData = reportingInfoData, let requiredReportedInfoData = reportedInfoData {
                            ///遷移先の画面
                            let chatNextVC = AdminUserCheckingChatViewController(selfProfile: requiredReportingInfoData, targetProfile: requiredReportedInfoData, SELFPROFILEIMAGE: UIImage(named: "defProfile")!)
                            chatNextVC.messageInputBar.inputTextView.placeholder = "通報回数は\(reportCount ?? 0)回。管理者画面では操作できません。"
                            let UINavigationController = UINavigationController(rootViewController: chatNextVC)
                            UINavigationController.modalPresentationStyle = .fullScreen
                            self.present(UINavigationController, animated: false, completion: nil)
                            self.slideInFromRight() // 遷移先の画面を横スライドで表示
                            
                        }
                    }
                }, UID: reportInfo.Required_reportingUID)
            }
        }, UID: reportInfo.Required_reportedUID)
    }
}


extension ReportMemberTableViewController {
    ///通報ユーザー取得
    func memberHostGetting() {
        REPORTHOSTGETTER.reportMemberGetter { member in
            member.flatMap{(self.reportMemberArray.append($0))}
            self.REPORTMEMBERLISTTABLEVIEW.reloadData()
        }
    }
}

extension ReportMemberTableViewController:ReportUserListTableViewCellDelegate {
    func deleteButtonTapped(targetCell: ReportUserListTableViewCell) {
        guard let reportID = targetCell.reportID else {
            createSheet(for: .Retry(title: "通報実施に必要な一意のドキュメントIDが見つかりません。"), SelfViewController: self)
            return
        }
        createSheet(for: .Alert(title: "通報・凍結を行わずに削除を行いますか？", message: "\(targetCell.targetUID)", buttonMessage: "OK", { result in
            if result {
                self.REPORTHOSTSETTER.reportMemberCompFlagSetter(callback: { result in
                    if !result {
                        createSheet(for: .Retry(title: "削除処理に失敗しました。"), SelfViewController: self)
                    } else {
                        createSheet(for: .Completion(title: "削除に成功しました。", {
                            return
                        }), SelfViewController: self)
                        //成功 配列から対象を削除
                        if let index = self.reportMemberArray.firstIndex(where: { $0.Required_reportID == targetCell.reportID }) {
                            self.reportMemberArray.remove(at: index)
                            let indexPath = IndexPath(row: index, section: 0) // セクション0の指定行のIndexPathを作成
                            self.REPORTMEMBERLISTTABLEVIEW.deleteRows(at: [indexPath], with: .automatic)
                            return
                        }
                    }
                }, reportID: reportID)
            }
        }), SelfViewController: self)
    }
    
    func warningButtonTappedDelegate(targetCell: ReportUserListTableViewCell) {
        guard let reportID = targetCell.reportID else {
            createSheet(for: .Retry(title: "通報実施に必要な一意のドキュメントIDが見つかりません。"), SelfViewController: self)
            return
        }
        createSheet(for: .Alert(title: "警告を行いますか？", message: "\(targetCell.targetUID)", buttonMessage: "OK", { result in
            if result {
                if let UID = targetCell.targetUID {
                    self.REPORTHOSTSETTER.reportExecuteSetter(callback: { result in
                        if !result {
                            createSheet(for: .Retry(title: "通報通知に失敗しました。"), SelfViewController: self)
                        } else {
                            createSheet(for: .Completion(title: "警告に成功しました。", {
                                return
                            }), SelfViewController: self)
                            //成功 配列から対象を削除
                            if let index = self.reportMemberArray.firstIndex(where: { $0.Required_reportID == targetCell.reportID }) {
                                self.reportMemberArray.remove(at: index)
                                let indexPath = IndexPath(row: index, section: 0) // セクション0の指定行のIndexPathを作成
                                self.REPORTMEMBERLISTTABLEVIEW.deleteRows(at: [indexPath], with: .automatic)
                                return
                            }

                        }
                    }, targetUID: UID, flag: 1, reportID: reportID)
                } else {
                    createSheet(for: .Retry(title: "UIDを取得できませんでした。"), SelfViewController: self)
                }
            }
        }), SelfViewController: self)
    }
    
    func acountFreezeButtonTapped(targetCell: ReportUserListTableViewCell) {
        guard let reportID = targetCell.reportID else {
            createSheet(for: .Retry(title: "通報実施に必要な一意のドキュメントIDが見つかりません。"), SelfViewController: self)
            return
        }
        createSheet(for: .Alert(title: "凍結を行いますか？", message: "\(targetCell.targetUID)", buttonMessage: "OK", { result in
            if result {
                if let UID = targetCell.targetUID {
                    self.REPORTHOSTSETTER.reportExecuteSetter(callback: { result in
                        if !result {
                            createSheet(for: .Retry(title: "通報通知に失敗しました。"), SelfViewController: self)
                        } else {
                            createSheet(for: .Completion(title: "凍結に成功しました。", {
                                return
                            }), SelfViewController: self)
                            //成功 配列から対象を削除
                            if let index = self.reportMemberArray.firstIndex(where: { $0.Required_reportID == targetCell.reportID }) {
                                self.reportMemberArray.remove(at: index)
                                let indexPath = IndexPath(row: index, section: 0) // セクション0の指定行のIndexPathを作成
                                self.REPORTMEMBERLISTTABLEVIEW.deleteRows(at: [indexPath], with: .automatic)
                                return
                            }

                        }
                    }, targetUID: UID, flag: 2, reportID: reportID)
                } else {
                    createSheet(for: .Retry(title: "UIDを取得できませんでした。"), SelfViewController: self)
                }
            }
        }), SelfViewController: self)
    }
}
