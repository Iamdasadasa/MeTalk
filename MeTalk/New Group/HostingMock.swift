import UIKit

class TestViewController: UIViewController {
    ///Barボタンの設定(NavigationBar)
    var backButtonItem: UIBarButtonItem! // Backボタン
    let button = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///barボタン初期設定
        backButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem
        self.view.backgroundColor = .white
        setupButton()
    }
    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
     }
    
    private func setupButton() {
        button.setTitle("ボタン", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    

    ///
    //--------------------------------------------------
    //--ユーザー初期登録単体テスト--
    //--------------------------------------------------
    ///
//
//    let Inof = profileInfoLocal()
//    let LOADINGVIEW = LOADING(loadingView: LoadingView())
//    var USERUID:String? {
//        didSet{
//            UserInfoRegister(callback: { result in
//                ///情報登録失敗
//                if case .failure(let error) = result {
//                    ///エラー対応
//                    createSheet(callback: {
//                        ///ローディング画面非表示
//                        self.LOADINGVIEW.loadingViewIndicator(isVisible: false)
//                    }, for: .Retry(title: "ユーザー情報登録処理に失敗しました"), SelfViewController: self)
//                }
//            }, USER: Inof, uid: "tes")
//        }
//    }
    
}

///
//--------------------------------------------------
//--トークリストメンバー取得単体テスト--
//--------------------------------------------------
///

extension TestViewController{
    
    
    @objc private func buttonTapped() {
        
    }
}
//
//    enum hostingError:Error {
//        case FormattError
//    }
//
//    func onlineUsersGetter(callback: @escaping ([ProfileInfoLocalObject], Error?) -> Void, latedTime: Date?,oneMinuteWithin: Bool,limitCount: Int) {
//        var profileArray:[Int?] = []
//
//        profileArray.append(nil)
//        profileArray.append(2)
//        profileArray.append(3)
//
//        var profileLocalArray:[ProfileInfoLocalObject] = []
//
//        do {
//            for array in profileArray {
//                if let array = array {
//                    if array == 1 {
//                        ///変換等でデータの取得まではできたけどローカル側でエラーになってしまった場合を想定
//                        throw hostingError.FormattError
//                    } else if array == 2 {
//                        ///正常に処理完了
//                        let profile = ProfileInfoLocalObject()
//                        profile.lcl_AboutMeMassage = "エネゴリくん"
//                        profileLocalArray.append(profile)
//                    } else if array == 3 {
//                        ///正常に処理完了
//                        let profile = ProfileInfoLocalObject()
//                        profile.lcl_AboutMeMassage = "酒でらくん"
//                        profileLocalArray.append(profile)
//                    }
//                    callback(profileLocalArray,nil)
//                }
//
//            }
//        } catch let Err {
//            let nsERR = Err as NSError
//            print(nsERR.domain)
//        }
//    }
    
//    /
//    --------------------------------------------------
//    --ユーザー初期登録単体テスト--
//    --------------------------------------------------
//    /
//    extension TestViewController:ProfileRegisterProtocol{
//        func SignUpAuthRegister(callback: @escaping (HostingResult) -> Void) {
//            callback(.Success("DI結果;成功しました。"))
//        }
//
//        func UserInfoRegister(callback: @escaping (HostingResult) -> Void, USER: profileInfoLocal, uid: String) {
//
//            callback(.failure(ERROR.err))
//        }
    //
    //
    //
    //    @objc private func buttonTapped() {
    //        ///ローディング画面表示
    //        LOADINGVIEW.loadingViewIndicator(isVisible: true)
    //
    //        SignUpAuthRegister { result in
    //            if case.Success(let UID) = result {
    //                self.USERUID = UID
    //            }
    //
    //            if case .failure(_) = result {
    //                    ///エラー対応
    //                createSheet(callback: {
    //                        ///ローディング画面非表示
    //                    self.LOADINGVIEW.loadingViewIndicator(isVisible: false)
    //                    }, for: .Retry(title: "ユーザー権限登録処理に失敗しました"), SelfViewController: self)
    //                return
    //            }
    //
    //        }
    //
    //    }
    //}
//}
