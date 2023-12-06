//
//  initialSettingAgeSelectView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/05/24.
//

import Foundation
import UIKit




///メインクラスプロトコル
protocol initialSettingAgeSelectViewDelegate:AnyObject {
    func decisionButtonTappedAction(ageSelectionView:initialSettingAgeSelectView)
}
///メインクラス
class initialSettingAgeSelectView:UIView {
    ///生年月日ピッカー
    let yearPicker = AgeCustomDataPickerView(Type: .year)
    let monthPicker = AgeCustomDataPickerView(Type: .month)
    let dayPicker = AgeCustomDataPickerView(Type: .day)
    ///生年月日の西暦部分装飾
    let yearImageView01 = AgeCustomImageView(Type: .year)
    let yearImageView02 = AgeCustomImageView(Type: .year)
    let yearImageView03 = AgeCustomImageView(Type: .year)
    let yearImageView04 = AgeCustomImageView(Type: .year)
    let birthUnder01 = UIImageView(image: UIImage(named: "Birth_Under"))
    let birthUnder02 = UIImageView(image: UIImage(named: "Birth_Under"))
    let birthUnder03 = UIImageView(image: UIImage(named: "Birth_Under"))
    let birthUnder04 = UIImageView(image: UIImage(named: "Birth_Under"))
    let birthSlash01 = UIImageView(image: UIImage(named: "Birth_Slash"))
    let yearTextField = AgeCustomTextField(Type: .year)
    ///生年月日の月部分装飾
    let monthImageView01 = AgeCustomImageView(Type: .month)
    let monthImageView02 = AgeCustomImageView(Type: .month)
    let birthUnder05 = UIImageView(image: UIImage(named: "Birth_Under"))
    let birthUnder06 = UIImageView(image: UIImage(named: "Birth_Under"))
    let birthSlash02 = UIImageView(image: UIImage(named: "Birth_Slash"))
    let monthTextField = AgeCustomTextField(Type: .month)
    ///生年月日の日部分装飾
    let dayImageView01 = AgeCustomImageView(Type: .day)
    let dayImageView02 = AgeCustomImageView(Type: .day)
    let birthUnder07 = UIImageView(image: UIImage(named: "Birth_Under"))
    let birthUnder08 = UIImageView(image: UIImage(named: "Birth_Under"))
    let dayTextField = AgeCustomTextField(Type: .day)
    ///生年月日の各カスタムテキストフィールド格納配列
    var allCustomTextField: [AgeCustomTextField] = []
    ///デリゲート用変数
    weak var delegate:initialSettingAgeSelectViewDelegate?
    ///決定ボタン
    let decisionButton:UIButton = {
       let returnButton = UIButton()
        returnButton.backgroundColor = .clear
        returnButton.addTarget(self, action: #selector(dicisionButtontapped(_:)), for: .touchUpInside)
        return returnButton
    }()
    
    ///決定ボタン押下時の挙動デリゲート
    @objc func dicisionButtontapped(_ sender: UIButton){
        print("押下されました")
        if delegate != nil {
            self.delegate?.decisionButtonTappedAction(ageSelectionView: self)
        }
    }
    ///決定ImageView
    let decisionImageView:UIImageView = {
        let ImageView = UIImageView()
        ImageView.contentMode = .scaleAspectFit
        ImageView.backgroundColor = .clear
        ImageView.layer.masksToBounds = true
        ImageView.isHidden = true
        ImageView.image = UIImage(named: "decisionImage")
        return ImageView
    }()
    
    ///性別選択案内ラベル
    let selectAgeInfoLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "年齢を教えてください"
        returnLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        returnLabel.backgroundColor = .clear
        returnLabel.font = UIFont.systemFont(ofSize: 50)
        returnLabel.textAlignment = NSTextAlignment.center
        returnLabel.adjustsFontSizeToFitWidth = true
        return returnLabel
    }()
    
    ///ビューの初期化
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetUp()
        viewLayoutSetUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension initialSettingAgeSelectView {
    /// レイアウト全般処理
    func viewSetUp() {
        ///カスタムテキストフィールド群格納
        allCustomTextField =  [self.yearTextField, self.monthTextField, self.dayTextField]
        ///背景画像設定
        backGroundViewImageSetUp(imageName: "gemderSelectBack")
        ///テキストフィールドデリゲート
        yearTextField.delegate = self
        monthTextField.delegate = self
        dayTextField.delegate = self

        self.addSubview(yearImageView01)
        self.addSubview(yearImageView02)
        self.addSubview(yearImageView03)
        self.addSubview(yearImageView04)
        self.addSubview(birthUnder01)
        self.addSubview(birthUnder02)
        self.addSubview(birthUnder03)
        self.addSubview(birthUnder04)
        self.addSubview(birthSlash01)
        self.addSubview(yearTextField)
        
        self.addSubview(monthImageView01)
        self.addSubview(monthImageView02)
        self.addSubview(birthUnder05)
        self.addSubview(birthUnder06)
        self.addSubview(birthSlash02)
        self.addSubview(monthTextField)
        
        self.addSubview(dayImageView01)
        self.addSubview(dayImageView02)
        self.addSubview(birthUnder07)
        self.addSubview(birthUnder08)
        self.addSubview(dayTextField)
        
        self.addSubview(selectAgeInfoLabel)
        self.addSubview(decisionImageView)
        self.addSubview(decisionButton)
        
        ///ピッカーの全般設定
        pickerSetting(targetPickerView: yearPicker)
        pickerSetting(targetPickerView: monthPicker)
        pickerSetting(targetPickerView: dayPicker)
        ///オートレイアウト競合(アニメーションを行う際は一時的にTrueにすること)
        yearImageView01.translatesAutoresizingMaskIntoConstraints = false
        yearImageView02.translatesAutoresizingMaskIntoConstraints = false
        yearImageView03.translatesAutoresizingMaskIntoConstraints = false
        yearImageView04.translatesAutoresizingMaskIntoConstraints = false
        birthUnder01.translatesAutoresizingMaskIntoConstraints = false
        birthUnder02.translatesAutoresizingMaskIntoConstraints = false
        birthUnder03.translatesAutoresizingMaskIntoConstraints = false
        birthUnder04.translatesAutoresizingMaskIntoConstraints = false
        birthSlash01.translatesAutoresizingMaskIntoConstraints = false
        yearTextField.translatesAutoresizingMaskIntoConstraints = false
        
        monthImageView01.translatesAutoresizingMaskIntoConstraints = false
        monthImageView02.translatesAutoresizingMaskIntoConstraints = false
        birthUnder05.translatesAutoresizingMaskIntoConstraints = false
        birthUnder06.translatesAutoresizingMaskIntoConstraints = false
        birthSlash02.translatesAutoresizingMaskIntoConstraints = false
        monthTextField.translatesAutoresizingMaskIntoConstraints = false
        
        dayImageView01.translatesAutoresizingMaskIntoConstraints = false
        dayImageView02.translatesAutoresizingMaskIntoConstraints = false
        birthUnder07.translatesAutoresizingMaskIntoConstraints = false
        birthUnder08.translatesAutoresizingMaskIntoConstraints = false
        dayTextField.translatesAutoresizingMaskIntoConstraints = false
        
        selectAgeInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        decisionImageView.translatesAutoresizingMaskIntoConstraints = false
        decisionButton.translatesAutoresizingMaskIntoConstraints = false
        
    }
    ///レイアウト設定処理
    func viewLayoutSetUp() {
        
        ///年齢選択案内ラベル
        selectAgeInfoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        selectAgeInfoLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1).isActive = true
        selectAgeInfoLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        selectAgeInfoLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor,constant: 25).isActive = true
        ///生年月日オブジェクトの固定幅比率
        let birthWidthRatio:Double = 0.08
        
        ///生年月日オブジェクトの固定高さ比率
        let birthHeightRatio:Double = 0.1
        ///レイアウト（中央から左側へ）
        birthSlash01.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: birthWidthRatio).isActive = true
        birthSlash01.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: birthHeightRatio).isActive = true
        birthSlash01.trailingAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        birthSlash01.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        yearImageView04.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: birthWidthRatio).isActive = true
        yearImageView04.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: birthHeightRatio).isActive = true
        yearImageView04.trailingAnchor.constraint(equalTo: birthSlash01.leadingAnchor).isActive = true
        yearImageView04.centerYAnchor.constraint(equalTo: birthSlash01.centerYAnchor).isActive = true
        yearImageView03.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: birthWidthRatio).isActive = true
        yearImageView03.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: birthHeightRatio).isActive = true
        yearImageView03.trailingAnchor.constraint(equalTo: yearImageView04.leadingAnchor).isActive = true
        yearImageView03.centerYAnchor.constraint(equalTo: yearImageView04.centerYAnchor).isActive = true
        yearImageView02.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: birthWidthRatio).isActive = true
        yearImageView02.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: birthHeightRatio).isActive = true
        yearImageView02.trailingAnchor.constraint(equalTo: yearImageView03.leadingAnchor).isActive = true
        yearImageView02.centerYAnchor.constraint(equalTo: yearImageView03.centerYAnchor).isActive = true
        yearImageView01.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: birthWidthRatio).isActive = true
        yearImageView01.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: birthHeightRatio).isActive = true
        yearImageView01.trailingAnchor.constraint(equalTo: yearImageView02.leadingAnchor).isActive = true
        yearImageView01.centerYAnchor.constraint(equalTo: yearImageView02.centerYAnchor).isActive = true
        birthUnder01.topAnchor.constraint(equalTo: yearImageView01.bottomAnchor,constant: 5).isActive = true
        birthUnder01.centerXAnchor.constraint(equalTo: yearImageView01.centerXAnchor).isActive = true
        birthUnder01.heightAnchor.constraint(equalTo: yearImageView01.heightAnchor, multiplier: 0.05).isActive = true
        birthUnder01.widthAnchor.constraint(equalTo: yearImageView01.widthAnchor,constant: -2).isActive = true
        birthUnder02.topAnchor.constraint(equalTo: birthUnder01.topAnchor).isActive = true
        birthUnder02.centerXAnchor.constraint(equalTo: yearImageView02.centerXAnchor).isActive = true
        birthUnder02.heightAnchor.constraint(equalTo: birthUnder01.heightAnchor).isActive = true
        birthUnder02.widthAnchor.constraint(equalTo: birthUnder01.widthAnchor).isActive = true
        birthUnder03.topAnchor.constraint(equalTo: birthUnder02.topAnchor).isActive = true
        birthUnder03.centerXAnchor.constraint(equalTo: yearImageView03.centerXAnchor).isActive = true
        birthUnder03.heightAnchor.constraint(equalTo: birthUnder02.heightAnchor).isActive = true
        birthUnder03.widthAnchor.constraint(equalTo: birthUnder02.widthAnchor).isActive = true
        birthUnder04.topAnchor.constraint(equalTo: birthUnder03.topAnchor).isActive = true
        birthUnder04.centerXAnchor.constraint(equalTo: yearImageView04.centerXAnchor).isActive = true
        birthUnder04.heightAnchor.constraint(equalTo: birthUnder03.heightAnchor).isActive = true
        birthUnder04.widthAnchor.constraint(equalTo: birthUnder03.widthAnchor).isActive = true
        yearTextField.leadingAnchor.constraint(equalTo: yearImageView01.leadingAnchor).isActive = true
        yearTextField.trailingAnchor.constraint(equalTo: yearImageView04.trailingAnchor).isActive = true
        yearTextField.centerYAnchor.constraint(equalTo: yearImageView01.centerYAnchor).isActive = true
        yearTextField.heightAnchor.constraint(equalTo: yearImageView01.heightAnchor).isActive = true
        ///レイアウト（中央から左側へ）
        monthImageView01.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: birthWidthRatio).isActive = true
        monthImageView01.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: birthHeightRatio).isActive = true
        monthImageView01.leadingAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        monthImageView01.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        monthImageView02.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: birthWidthRatio).isActive = true
        monthImageView02.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: birthHeightRatio).isActive = true
        monthImageView02.leadingAnchor.constraint(equalTo: monthImageView01.trailingAnchor).isActive = true
        monthImageView02.centerYAnchor.constraint(equalTo: monthImageView01.centerYAnchor).isActive = true
        birthSlash02.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: birthWidthRatio).isActive = true
        birthSlash02.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: birthHeightRatio).isActive = true
        birthSlash02.leadingAnchor.constraint(equalTo: monthImageView02.trailingAnchor).isActive = true
        birthSlash02.centerYAnchor.constraint(equalTo: monthImageView02.centerYAnchor).isActive = true
        birthUnder05.topAnchor.constraint(equalTo: birthUnder04.topAnchor).isActive = true
        birthUnder05.centerXAnchor.constraint(equalTo: monthImageView01.centerXAnchor).isActive = true
        birthUnder05.heightAnchor.constraint(equalTo: birthUnder04.heightAnchor).isActive = true
        birthUnder05.widthAnchor.constraint(equalTo: birthUnder04.widthAnchor).isActive = true
        birthUnder06.topAnchor.constraint(equalTo: birthUnder05.topAnchor).isActive = true
        birthUnder06.centerXAnchor.constraint(equalTo: monthImageView02.centerXAnchor).isActive = true
        birthUnder06.heightAnchor.constraint(equalTo: birthUnder05.heightAnchor).isActive = true
        birthUnder06.widthAnchor.constraint(equalTo: birthUnder05.widthAnchor).isActive = true
        monthTextField.leadingAnchor.constraint(equalTo: monthImageView01.leadingAnchor).isActive = true
        monthTextField.trailingAnchor.constraint(equalTo: monthImageView02.trailingAnchor).isActive = true
        monthTextField.centerYAnchor.constraint(equalTo: monthImageView01.centerYAnchor).isActive = true
        monthTextField.heightAnchor.constraint(equalTo: monthImageView01.heightAnchor).isActive = true
        
        dayImageView01.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: birthWidthRatio).isActive = true
        dayImageView01.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: birthHeightRatio).isActive = true
        dayImageView01.leadingAnchor.constraint(equalTo: birthSlash02.trailingAnchor).isActive = true
        dayImageView01.centerYAnchor.constraint(equalTo: birthSlash02.centerYAnchor).isActive = true
        dayImageView02.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: birthWidthRatio).isActive = true
        dayImageView02.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: birthHeightRatio).isActive = true
        dayImageView02.leadingAnchor.constraint(equalTo: dayImageView01.trailingAnchor).isActive = true
        dayImageView02.centerYAnchor.constraint(equalTo: birthSlash02.centerYAnchor).isActive = true
        dayTextField.leadingAnchor.constraint(equalTo: dayImageView01.leadingAnchor).isActive = true
        dayTextField.trailingAnchor.constraint(equalTo: dayImageView02.trailingAnchor).isActive = true
        dayTextField.centerYAnchor.constraint(equalTo: dayImageView01.centerYAnchor).isActive = true
        dayTextField.heightAnchor.constraint(equalTo: dayImageView01.heightAnchor).isActive = true
        birthUnder07.topAnchor.constraint(equalTo: self.birthUnder06.topAnchor).isActive = true
        birthUnder07.centerXAnchor.constraint(equalTo: self.dayImageView01.centerXAnchor).isActive = true
        birthUnder07.heightAnchor.constraint(equalTo: self.birthUnder06.heightAnchor).isActive = true
        birthUnder07.widthAnchor.constraint(equalTo: self.birthUnder06.widthAnchor).isActive = true
        birthUnder08.topAnchor.constraint(equalTo: self.birthUnder07.topAnchor).isActive = true
        birthUnder08.centerXAnchor.constraint(equalTo: self.dayImageView02.centerXAnchor).isActive = true
        birthUnder08.heightAnchor.constraint(equalTo: self.birthUnder07.heightAnchor).isActive = true
        birthUnder08.widthAnchor.constraint(equalTo: self.birthUnder07.widthAnchor).isActive = true
        
        decisionImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        decisionImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4).isActive = true
        decisionImageView.heightAnchor.constraint(equalTo: self.selectAgeInfoLabel.heightAnchor).isActive = true
        decisionImageView.topAnchor.constraint(equalTo: self.birthUnder01.bottomAnchor,constant: 30).isActive = true
        
        decisionButton.centerXAnchor.constraint(equalTo: self.decisionImageView.centerXAnchor).isActive = true
        decisionButton.centerYAnchor.constraint(equalTo: self.decisionImageView.centerYAnchor).isActive = true
        decisionButton.widthAnchor.constraint(equalTo: decisionImageView.widthAnchor).isActive = true
        decisionButton.heightAnchor.constraint(equalTo: decisionImageView.heightAnchor).isActive = true
        
    }

}
///テキスト系処理
extension initialSettingAgeSelectView:UITextFieldDelegate {
    ///テキスト入力無効化
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    // コピーとペーストを禁止にする
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) || action == #selector(paste(_:)) {
            return false
        }
        return true
    }
    
}

extension initialSettingAgeSelectView:UIPickerViewDataSource, UIPickerViewDelegate{
    ///Picker設定
    func pickerSetting(targetPickerView:AgeCustomDataPickerView) {
        targetPickerView.delegate = self
        targetPickerView.dataSource = self
        
        // 決定・キャンセル用ツールバーの生成
        ///共通アイテム
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        ///各フィールド分の終了とキャンセル、ベースのツールバー用意
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 35))
        let doneItem = UIBarButtonItem(title: "決定", style: .plain, target: self, action: #selector(done))
//        UIBarButtonItem(barButtonSystemItem: .,
        let cancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(cancel))
        toolbar.backgroundColor = .clear
        toolbar.setItems([cancelItem, spaceItem, doneItem], animated: true)
        
        ///適用するテキストフィールドにピッカーを適用
        switch targetPickerView.birthType {
        case .year:
            self.yearTextField.inputView = targetPickerView
            self.yearTextField.inputAccessoryView = toolbar
        case .month:
            self.monthTextField.inputView = targetPickerView
            self.monthTextField.inputAccessoryView = toolbar
        case .day:
            self.dayTextField.inputView = targetPickerView
            self.dayTextField.inputAccessoryView = toolbar
        }

        // デフォルト設定
        targetPickerView.selectRow(0, inComponent: 0, animated: false)
    }
    
    // 1. 決定ボタンのアクション指定
    @objc func done() {
        ///適切な種別を返却
        guard let targetBirthType = birthTypeReturn() else {
            return
        }
        ///取得したピッカーの種類でアクション
        switch targetBirthType {
        ///適切な画像データを取得＆生年月日データを保持
        case .year:
            self.yearImageView01.image = getTargetBirthImage(targetDigitNum: 0, type: .year)
            self.yearImageView02.image = getTargetBirthImage(targetDigitNum: 1, type: .year)
            self.yearImageView03.image = getTargetBirthImage(targetDigitNum: 2, type: .year)
            self.yearImageView04.image = getTargetBirthImage(targetDigitNum: 3, type: .year)
            self.yearTextField.selectedAge = self.yearPicker.birthList[self.yearPicker.selectedRow(inComponent: 0)]
            self.yearTextField.endEditing(true)
        case .month:
            self.monthImageView01.image = getTargetBirthImage(targetDigitNum: 0, type: .month)
            self.monthImageView02.image = getTargetBirthImage(targetDigitNum: 1, type: .month)
            self.monthTextField.selectedAge = self.monthPicker.birthList[self.monthPicker.selectedRow(inComponent: 0)]
            self.monthTextField.endEditing(true)
        case .day:
            self.dayImageView01.image = getTargetBirthImage(targetDigitNum: 0, type: .day)
            self.dayImageView02.image = getTargetBirthImage(targetDigitNum: 1, type: .day)
            self.dayTextField.selectedAge = self.dayPicker.birthList[self.dayPicker.selectedRow(inComponent: 0)]
            self.dayTextField.endEditing(true)
        }
        ///完了後にラベル色を変更
        if allAgeSelected() {
            //生年月日不正チェック
            if !isValidDate(month: self.monthPicker.birthList[self.monthPicker.selectedRow(inComponent: 0)], day: self.dayPicker.birthList[self.dayPicker.selectedRow(inComponent: 0)], year: self.yearPicker.birthList[self.yearPicker.selectedRow(inComponent: 0)]) {
                //不正だった場合決定ボタン無効化
                self.decisionButton.isEnabled = false
                self.decisionImageView.isHidden = true
                return
            }
            self.decisionButton.isEnabled = true
            self.decisionImageView.isHidden = false
        } else {
            self.decisionButton.isEnabled = false
            self.decisionImageView.isHidden = true
        }
        
    }
    // 2. キャンセルボタンのアクション指定
    @objc func cancel(){
        guard let targetBirthType = birthTypeReturn() else {
            return
        }
        
        switch targetBirthType {
        case .year:
            self.yearTextField.endEditing(true)
        case .month:
            self.monthTextField.endEditing(true)
        case .day:
            self.dayTextField.endEditing(true)
        }
    }
    // 3. 画面タップでテキストフィールドを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let targetBirthType = birthTypeReturn() else {
            return
        }
        
        switch targetBirthType {
        case .year:
            self.yearTextField.endEditing(true)
        case .month:
            self.yearTextField.endEditing(true)
        case .day:
            self.yearTextField.endEditing(true)
        }
    }
    
    // ピッカービューの行数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // ピッカービューの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let targetPickerCustomView = pickerView as! AgeCustomDataPickerView
        
        switch targetPickerCustomView.birthType {
        case .year:
            return self.yearPicker.birthList.count
        case .month:
            return self.monthPicker.birthList.count
        case .day:
            return self.dayPicker.birthList.count
        }
    }
    // ピッカービューに表示する内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let targetPickerCustomView = pickerView as! AgeCustomDataPickerView
        switch targetPickerCustomView.birthType {
        case .year:
            return "\(self.yearPicker.birthList[row])"
        case .month:
            return "\(self.monthPicker.birthList[row])"
        case .day:
            return "\(self.dayPicker.birthList[row])"
        }
    }
    
    /// 現在アクティブなテキストフィールドを調査して適切な種別を返却
    /// - Returns: birthType 西暦・月・日のどれを設定中か返却
    func birthTypeReturn() -> birthType? {
        let allCustomTextField: [AgeCustomTextField] = [self.yearTextField, self.monthTextField, self.dayTextField]

        for customTextField in allCustomTextField {
            if customTextField.isFirstResponder {
                return customTextField.birthType
            }
        }
        return nil // .isFirstResponderの要素が見つからなかった場合はnilを返す
    }
    
    /// ユーザーが選択した生年月日から適切な画像データを返却
    /// - Parameters:
    ///   - targetDigitNum: 取得したい桁の位置
    ///   - type: 取得したい生年月日のいずれか
    /// - Returns: 生年月日画像データ
    func getTargetBirthImage(targetDigitNum:Int,type:birthType) -> UIImage {
        let birthValue:Int
        
        switch type {
        case .year:
            birthValue = self.yearPicker.birthList[self.yearPicker.selectedRow(inComponent: 0)]
        case .month:
            birthValue = self.monthPicker.birthList[self.monthPicker.selectedRow(inComponent: 0)]
        case .day:
            birthValue = self.dayPicker.birthList[self.dayPicker.selectedRow(inComponent: 0)]
        }
        ///画像データ返却用クロージャ
        let ReturnImage = {(targetStr:Character) -> UIImage in
            switch targetStr {
            case "1":
                return UIImage(named:"Birth_1")!
            case "2":
                return UIImage(named:"Birth_2")!
            case "3":
                return UIImage(named:"Birth_3")!
            case "4":
                return UIImage(named:"Birth_4")!
            case "5":
                return UIImage(named:"Birth_5")!
            case "6":
                return UIImage(named:"Birth_6")!
            case "7":
                return UIImage(named:"Birth_7")!
            case "8":
                return UIImage(named:"Birth_8")!
            case "9":
                return UIImage(named:"Birth_9")!
            case "0":
                return UIImage(named:"Birth_0")!
            default:
                ///想定外の数値
                return UIImage(named:"Birth_0")!
            }
        }
        ///文字列変換
        let birthString = String(birthValue)
        ///桁数が一桁の場合の適切な画像返却
        if birthString.count == 1 {
            if targetDigitNum == 0 {
                ///桁数が1(月または日選択中の1〜9の場合)は2桁(01月や09日)の返却にしたいため一桁目は強制的に0画像のイメージデータを返却
                return UIImage(named:"Birth_0")!
            } else {
                let targetString = birthString[birthString.index(birthString.startIndex, offsetBy: 0)]
                return ReturnImage(targetString)
            }
        }
        ///適切な画像返却
        if birthString.count >= targetDigitNum {
            ///取得したい桁の数値を取得
            let targetString = birthString[birthString.index(birthString.startIndex, offsetBy: targetDigitNum)]
            ///画像返却
            return ReturnImage(targetString)
        } else {
            ///適切に変換されなかった
            return UIImage(named:"Birth_0")!
        }
    }

    /// すべての年齢データが決定されている場合年齢を返却
    /// - Returns: 年齢が変数に入っているか否かのBool
    func allAgeSelected() -> Bool {
        for customTextField in allCustomTextField {
            guard let selectedAge = customTextField.selectedAge else {
                return false
            }
        }
        return true
    }
    
    /// 年齢の論理チェック
    /// - Returns: 論理的に合致しているか。
    func isValidDate(month: Int?, day: Int?, year: Int?) -> Bool {
        guard let month = month , let day = day , let year = year else {
            return true
        }
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month)
        
        guard let date = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            // 日付が無効な場合の処理（例: デフォルトの日を設定したり、エラーメッセージを表示したりする）
            return false
        }
        
        let maxDay = range.upperBound - 1
        return day >= 1 && day <= maxDay
    }
}
