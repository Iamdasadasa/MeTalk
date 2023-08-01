//
//  SearchSettingViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/07/11.
//

import Foundation
import UIKit

class SearchSettingViewController:UIViewController,UINavigationControllerDelegate, dicitionButtonClicked {

    ///Viewのインスタンス化
    let searchSettingView = SearchSettingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///検索条件をViewに受け渡し
        searchSettingView.searchLocalData = gettingPerformSearch()
        
        ///Viewの設定
        self.view = searchSettingView
        
        ///デリゲート適用
        searchSettingView.delegate = self
        
        ///ナビゲーションバーの設定
        navigationBarSetUp()

    }
    ///画面で検索ボタンが押下された際のデリゲート関数
    func clicked() {
        ///決定ボタン押下時検索条件保存
        performFilterValueSave()
        
        backViewAction()
    }
}

extension SearchSettingViewController {
    /// ローカルDBから検索条件の前回保存もしくは初期値を取得してくる
    /// - Returns: 検索条件
    func gettingPerformSearch() -> PerformSearchLocalObject {
        let performSearchLocalDataGetterManager = PerformSearchLocalDataGetterManager()
        ///前回保存データがある場合
        if let searchLocalData = performSearchLocalDataGetterManager.getter() {
            return searchLocalData
        } else {
        ///初回で保存データがない場合
            let newInitPerformSearchData = PerformSearchLocalObject()
            var performSearchLocalDataSetterManager = PerformSearchLocalDataSetterManager(newAddPerformSearch: newInitPerformSearchData)
            performSearchLocalDataSetterManager.commiting = true
            return newInitPerformSearchData
        }
    }
    
    ///新規の検索条件をDBに保存する
    func performFilterValueSave() {
        let retryAlert = {
            createSheet(callback: {
                return
            }, for: .Retry(title: "住まいが正しく設定されていません。確認してください"), SelfViewController: self)
        }
        guard let txt = searchSettingView.pickerTextField.text else {
            retryAlert()
            return
        }
        if txt == "" {
            retryAlert()
            return
        }
        ///決定フラグ確認
        var dicitionGender:GENDER!
        for array in searchSettingView.genderButtonArray {
                if array.dicitionFlag {
                    dicitionGender = array.gender
                }
        }
        ///保存のためのアンマネージドオブジェクト
        let updateObject = PerformSearchLocalObject()
        
        updateObject.lcl_Gender = dicitionGender.rawValue
        updateObject.lcl_Area = txt
        ///画面上の年齢を取得
        let minAge = searchSettingView.minAge
        let maxAge = searchSettingView.maxAge
        ///年齢を西暦に変換
        let minYear = AgeCalculator.calculateAge(from: minAge)
        let maxYear = AgeCalculator.calculateAge(from: maxAge)
        ///西暦に検索クエリ用の日付を追加する
        let convertMinAge = AgeCalculator.convertDefaultYearOfBirth(targetYear: minYear, minOrMax: .min)
        let convertMaxAge = AgeCalculator.convertDefaultYearOfBirth(targetYear: maxYear, minOrMax: .max)
        ///検索用年月日格納
        updateObject.lcl_MinAge = convertMinAge
        updateObject.lcl_MaxAge = convertMaxAge
        
        var setter = PerformSearchLocalDataSetterManager(updatePerformSearch: updateObject)
        setter.commiting = true
    }
}

extension SearchSettingViewController {
    func navigationBarSetUp() {
        /// カスタムのタイトルビューを作成
        let titleLabel = UILabel()
        titleLabel.text = "検索条件"
        titleLabel.textColor = UIColor.black
        /// ナビゲーションバーのタイトルビューを設定
        self.navigationItem.titleView = titleLabel
        ///リロードボタン設定
        let backButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(backButtonTapped))
        ///リロードボタンセット
        navigationItem.rightBarButtonItem = backButton
    }
    
    ///戻るボタンタップ時のアクション
    @objc func backButtonTapped() {
        backViewAction()
    }
}


extension SearchSettingViewController {
    func backViewAction() {
        ///前の画面に戻る
        self.dismiss(animated: false, completion: nil)
        self.slideInFromRight()
    }
}
