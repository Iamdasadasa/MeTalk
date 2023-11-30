//
//  searchSettingView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/07/11.
//

import Foundation
import UIKit
import RangeUISlider

protocol dicitionButtonClicked:AnyObject{
    func clicked()
}

class SearchSettingView:UIView {
    
    var searchLocalData:PerformSearchLocalObject!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        autoLayoutSetUp()
        autoLayout()
        picker()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///Delegate
    weak var delegate:dicitionButtonClicked?
    ///共通性別画像インスタンス
    var femaleImage:genderImageView!
    var maleImage:genderImageView!
    var noneGenderImage:genderImageView!
    
    ///共通性別ボタンインスタンス
    var femaleButton:genderButton!
    var maleButton:genderButton!
    var noneGenderButton:genderButton!
    ///ボタン格納用配列
    var genderButtonArray:[genderButton] = []
    ///性別判断配列
    let genderArray:[GENDER] = [.female,.male,.none]
    
    ///共通性別テキストラベル
    var femaleTxtLabel:genderTextLabel!
    var maleTxtLabel:genderTextLabel!
    var noneTxtLabel:genderTextLabel!
    
    ///年齢スライダー
    var ageSlider:CustomAgeSlider = CustomAgeSlider()
    ///年齢格納用変数
    var minAge:Int = 18
    var maxAge:Int = 100
    
    ///陰影用のView
    let femaleshadowView:ShadowBaseView = ShadowBaseView()
    let maleShadowView:ShadowBaseView = ShadowBaseView()
    let noneShadowView:ShadowBaseView = ShadowBaseView()
    
    ///検索表題
    let genderThemaLabel:CustomThemaLabel = CustomThemaLabel(text: "性別")
    let ageThemaLabel:CustomThemaLabel = CustomThemaLabel(text: "年齢")
    let areaThemaLabel:CustomThemaLabel = CustomThemaLabel(text: "エリア")
    
    ///住まいピッカー
    let areaPicker:SearchCustomPicker = SearchCustomPicker(Type: .area)
    let pickerTextField:UITextField = {
        let txtField = UITextField()
        txtField.textColor = .gray
        return txtField
    }()
    ///ピッカーの陰影用のView
    let pickerShadowView:ShadowBaseView = ShadowBaseView()
    
    ///イメージサイズ
    var imageSize:CGFloat!
    
    ///決定
    //ボタン
    let dicitionButton:UIButton = {
        let Button = UIButton()
        Button.backgroundColor = .clear
        Button.addTarget(self, action: #selector(dicitionButtonClicked(_:)), for: UIControl.Event.touchUpInside)
        return Button
    }()
    //ラベル
    let dicitonLabel:CustomThemaLabel = {
        let label = CustomThemaLabel(text: "")
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 0.3
        )
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()
    
    ///検索画像ビュー
    let filterImage:CustomFilterImageView = CustomFilterImageView(frame: .zero)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ///陰影付与
        femaleshadowView.shadowSetting(offset: .topRight)
        maleShadowView.shadowSetting(offset: .topRight)
        noneShadowView.shadowSetting(offset: .topRight)
        pickerShadowView.shadowSetting(offset: .topRight)
        ///テキストサイズ
        genderThemaLabel.font = UIFont.systemFont(ofSize: 25)
        ageThemaLabel.font = UIFont.systemFont(ofSize: 25)
        areaThemaLabel.font = UIFont.systemFont(ofSize: 25)
        femaleTxtLabel.font = UIFont.systemFont(ofSize: 14.5)
        maleTxtLabel.font = UIFont.systemFont(ofSize: 14.5)
        noneTxtLabel.font = UIFont.systemFont(ofSize: 14.5)
        ///スライダーのノブサイズ
        ageSlider.leftKnobWidth = ageSlider.frame.width / 12
        ageSlider.leftKnobHeight = ageSlider.leftKnobWidth
        ageSlider.leftKnobCorners = ageSlider.leftKnobWidth / 2
        ageSlider.rightKnobWidth = ageSlider.frame.width / 12
        ageSlider.rightKnobHeight = ageSlider.rightKnobWidth
        ageSlider.rightKnobCorners = ageSlider.rightKnobWidth / 2
        /// 保存済みの値適用
        performFilterValueSetting()
        
        ageSlider.delegate = self
    }
    
    /// 性別ボタンが押下された際の挙動
    /// - Parameter sender: クリックされた性別ボタン（カスタムクラス)
    @objc func genderButtonClicked(_ sender: genderButton) {
        ///押下された際のアニメーション
        selectedGenderImageAnimation(gender: sender.gender)
        ///決定フラグ操作
        for array in genderButtonArray {
            if array.gender == sender.gender {
                array.dicitionFlag = true
            } else {
                array.dicitionFlag = false
            }

        }
    }
    ///決定ボタンが押下された際の挙動
    @objc func dicitionButtonClicked(_ sender: UIButton) {
        ///押下された際のアニメーション
        delegate?.clicked()
    }
    ///アニメーション処理関数
    func selectedGenderImageAnimation(gender:GENDER) {
        switch gender {
        case .female:
            femaleshadowView.GrowAnimation(shouldStart: true)
            maleShadowView.GrowAnimation(shouldStart: false)
            noneShadowView.GrowAnimation(shouldStart: false)
        case .male:
            maleShadowView.GrowAnimation(shouldStart: true)
            femaleshadowView.GrowAnimation(shouldStart: false)
            noneShadowView.GrowAnimation(shouldStart: false)
        case .none:
            noneShadowView.GrowAnimation(shouldStart: true)
            maleShadowView.GrowAnimation(shouldStart: false)
            femaleshadowView.GrowAnimation(shouldStart: false)
        }
    }
    
    //※レイアウト設定※
    func autoLayoutSetUp() {
        
        ///列挙型配列からボタンおよび画像のインスタンス生成
        for genderPattern in genderArray {

            ///各インスタンス変数に割り振りおよび初期レイアウト設定
            switch genderPattern {
            case .none:
                noneGenderImage = genderImageView(gender: genderPattern, Type: .search)
                noneTxtLabel = genderTextLabel(gender: genderPattern)
                noneGenderButton = genderButton(gender: genderPattern)
                noneGenderButton.addTarget(self, action: #selector(genderButtonClicked(_:)), for: UIControl.Event.touchUpInside)
                genderButtonArray.append(noneGenderButton)
            case .male:
                maleImage = genderImageView(gender: genderPattern, Type: .search)
                maleTxtLabel = genderTextLabel(gender: genderPattern)
                maleButton = genderButton(gender: genderPattern)
                maleButton.addTarget(self, action: #selector(genderButtonClicked(_:)), for: UIControl.Event.touchUpInside)
                genderButtonArray.append(maleButton)
            case .female:
                femaleImage = genderImageView(gender: genderPattern, Type: .search)
                femaleTxtLabel = genderTextLabel(gender: genderPattern)
                femaleButton = genderButton(gender: genderPattern)
                femaleButton.addTarget(self, action: #selector(genderButtonClicked(_:)), for: UIControl.Event.touchUpInside)
                genderButtonArray.append(femaleButton)
            }
        }

        ///オブジェクト追加
        self.addSubview(genderThemaLabel)
        self.addSubview(ageThemaLabel)
        self.addSubview(areaThemaLabel)
        self.addSubview(noneShadowView)
        self.addSubview(femaleshadowView)
        self.addSubview(maleShadowView)
        self.addSubview(femaleImage)
        self.addSubview(maleImage)
        self.addSubview(noneGenderImage)
        self.addSubview(femaleButton)
        self.addSubview(maleButton)
        self.addSubview(noneGenderButton)
        self.addSubview(ageSlider)
        self.addSubview(femaleTxtLabel)
        self.addSubview(maleTxtLabel)
        self.addSubview(noneTxtLabel)
        self.addSubview(areaThemaLabel)
        self.addSubview(pickerShadowView)
        self.addSubview(pickerTextField)
        self.addSubview(dicitonLabel)
        self.addSubview(dicitionButton)
        self.addSubview(filterImage)

        /// 各オブジェクトのAuto Layout制約を設定
        genderThemaLabel.translatesAutoresizingMaskIntoConstraints = false
        ageThemaLabel.translatesAutoresizingMaskIntoConstraints = false
        areaThemaLabel.translatesAutoresizingMaskIntoConstraints = false
        femaleImage.translatesAutoresizingMaskIntoConstraints = false
        maleImage.translatesAutoresizingMaskIntoConstraints = false
        noneGenderImage.translatesAutoresizingMaskIntoConstraints = false
        femaleButton.translatesAutoresizingMaskIntoConstraints = false
        maleButton.translatesAutoresizingMaskIntoConstraints = false
        noneGenderButton.translatesAutoresizingMaskIntoConstraints = false
        femaleshadowView.translatesAutoresizingMaskIntoConstraints = false
        maleShadowView.translatesAutoresizingMaskIntoConstraints = false
        noneShadowView.translatesAutoresizingMaskIntoConstraints = false
        ageSlider.translatesAutoresizingMaskIntoConstraints = false
        femaleTxtLabel.translatesAutoresizingMaskIntoConstraints = false
        maleTxtLabel.translatesAutoresizingMaskIntoConstraints = false
        noneTxtLabel.translatesAutoresizingMaskIntoConstraints = false
        areaThemaLabel.translatesAutoresizingMaskIntoConstraints = false
        pickerTextField.translatesAutoresizingMaskIntoConstraints = false
        pickerShadowView.translatesAutoresizingMaskIntoConstraints = false
        dicitonLabel.translatesAutoresizingMaskIntoConstraints = false
        dicitionButton.translatesAutoresizingMaskIntoConstraints = false
        filterImage.translatesAutoresizingMaskIntoConstraints = false
        
        // 画像のサイズを画面の1/4に設定
        imageSize = UIScreen.main.bounds.width / 4
        ///画像の円形処理
        noneGenderImage.layer.cornerRadius = imageSize / 2
        maleImage.layer.cornerRadius = imageSize / 2
        femaleImage.layer.cornerRadius = imageSize / 2
    }
    
    //※レイアウト※
    func autoLayout() {
        
        ///一旦テーマの左側以外を決定
        genderThemaLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        genderThemaLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
        genderThemaLabel.heightAnchor.constraint(equalTo: genderThemaLabel.widthAnchor, multiplier: 0.25).isActive = true
        
        noneGenderImage.topAnchor.constraint(equalTo: genderThemaLabel.bottomAnchor, constant: 20).isActive = true
        noneGenderImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        noneGenderImage.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        noneGenderImage.heightAnchor.constraint(equalTo: noneGenderImage.widthAnchor).isActive = true
        
        noneShadowView.centerYAnchor.constraint(equalTo: noneGenderImage.centerYAnchor).isActive = true
        noneShadowView.centerXAnchor.constraint(equalTo: noneGenderImage.centerXAnchor).isActive = true
        noneShadowView.widthAnchor.constraint(equalTo: noneGenderImage.widthAnchor).isActive = true
        noneShadowView.heightAnchor.constraint(equalTo: noneGenderImage.heightAnchor).isActive = true

        maleImage.topAnchor.constraint(equalTo: noneGenderImage.topAnchor).isActive = true
        maleImage.widthAnchor.constraint(equalTo: noneGenderImage.widthAnchor).isActive = true
        maleImage.heightAnchor.constraint(equalTo: noneGenderImage.heightAnchor).isActive = true
        maleImage.trailingAnchor.constraint(equalTo: noneGenderImage.leadingAnchor, constant: -15).isActive = true
        
        maleShadowView.centerYAnchor.constraint(equalTo: maleImage.centerYAnchor).isActive = true
        maleShadowView.centerXAnchor.constraint(equalTo: maleImage.centerXAnchor).isActive = true
        maleShadowView.widthAnchor.constraint(equalTo: maleImage.widthAnchor).isActive = true
        maleShadowView.heightAnchor.constraint(equalTo: maleImage.heightAnchor).isActive = true
        
        femaleImage.topAnchor.constraint(equalTo: noneGenderImage.topAnchor).isActive = true
        femaleImage.widthAnchor.constraint(equalTo: noneGenderImage.widthAnchor).isActive = true
        femaleImage.heightAnchor.constraint(equalTo: noneGenderImage.heightAnchor).isActive = true
        femaleImage.leadingAnchor.constraint(equalTo: noneGenderImage.trailingAnchor, constant: 15).isActive = true
        
        femaleshadowView.centerYAnchor.constraint(equalTo: femaleImage.centerYAnchor).isActive = true
        femaleshadowView.centerXAnchor.constraint(equalTo: femaleImage.centerXAnchor).isActive = true
        femaleshadowView.widthAnchor.constraint(equalTo: femaleImage.widthAnchor).isActive = true
        femaleshadowView.heightAnchor.constraint(equalTo: femaleImage.heightAnchor).isActive = true
        
        maleButton.centerYAnchor.constraint(equalTo: maleImage.centerYAnchor).isActive = true
        maleButton.centerXAnchor.constraint(equalTo: maleImage.centerXAnchor).isActive = true
        maleButton.widthAnchor.constraint(equalTo: maleImage.widthAnchor).isActive = true
        maleButton.heightAnchor.constraint(equalTo: maleImage.heightAnchor).isActive = true
        
        femaleButton.centerYAnchor.constraint(equalTo: femaleImage.centerYAnchor).isActive = true
        femaleButton.centerXAnchor.constraint(equalTo: femaleImage.centerXAnchor).isActive = true
        femaleButton.widthAnchor.constraint(equalTo: femaleImage.widthAnchor).isActive = true
        femaleButton.heightAnchor.constraint(equalTo: femaleImage.heightAnchor).isActive = true
        
        noneGenderButton.centerYAnchor.constraint(equalTo: noneGenderImage.centerYAnchor).isActive = true
        noneGenderButton.centerXAnchor.constraint(equalTo: noneGenderImage.centerXAnchor).isActive = true
        noneGenderButton.widthAnchor.constraint(equalTo: noneGenderImage.widthAnchor).isActive = true
        noneGenderButton.heightAnchor.constraint(equalTo: noneGenderImage.heightAnchor).isActive = true
        
        maleTxtLabel.topAnchor.constraint(equalTo: maleImage.bottomAnchor,constant: 5).isActive = true
        maleTxtLabel.centerXAnchor.constraint(equalTo: maleImage.centerXAnchor).isActive = true
        maleTxtLabel.heightAnchor.constraint(equalTo: genderThemaLabel.heightAnchor,multiplier: 0.5).isActive = true
        maleTxtLabel.widthAnchor.constraint(equalTo: maleImage.widthAnchor).isActive = true
        
        femaleTxtLabel.topAnchor.constraint(equalTo: femaleImage.bottomAnchor,constant: 5).isActive = true
        femaleTxtLabel.centerXAnchor.constraint(equalTo: femaleImage.centerXAnchor).isActive = true
        femaleTxtLabel.heightAnchor.constraint(equalTo: genderThemaLabel.heightAnchor,multiplier: 0.5).isActive = true
        femaleTxtLabel.widthAnchor.constraint(equalTo: femaleImage.widthAnchor).isActive = true
        
        noneTxtLabel.topAnchor.constraint(equalTo: noneGenderImage.bottomAnchor,constant: 5).isActive = true
        noneTxtLabel.centerXAnchor.constraint(equalTo: noneGenderImage.centerXAnchor).isActive = true
        noneTxtLabel.heightAnchor.constraint(equalTo: genderThemaLabel.heightAnchor,multiplier: 0.5).isActive = true
        noneTxtLabel.widthAnchor.constraint(equalTo: noneGenderImage.widthAnchor).isActive = true

        ///性別テーマの残り左側決定
        genderThemaLabel.leftAnchor.constraint(equalTo: maleImage.leftAnchor).isActive = true
        ///年齢テーマ
        ageThemaLabel.leftAnchor.constraint(equalTo: genderThemaLabel.leftAnchor).isActive = true
        ageThemaLabel.topAnchor.constraint(equalTo: maleTxtLabel.bottomAnchor, constant: 15).isActive = true
        ageThemaLabel.widthAnchor.constraint(equalTo: genderThemaLabel.widthAnchor).isActive = true
        ageThemaLabel.heightAnchor.constraint(equalTo: genderThemaLabel.heightAnchor).isActive = true
        ///年齢決定スライダー
        ageSlider.topAnchor.constraint(equalTo: ageThemaLabel.bottomAnchor, constant: 20).isActive = true
        ageSlider.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ageSlider.widthAnchor.constraint(equalTo: self.widthAnchor,multiplier: 0.75).isActive = true
        ageSlider.heightAnchor.constraint(equalTo: femaleImage.heightAnchor,multiplier: 0.5).isActive = true
        ///住まいテーマラベル
        areaThemaLabel.leftAnchor.constraint(equalTo: genderThemaLabel.leftAnchor).isActive = true
        areaThemaLabel.topAnchor.constraint(equalTo: ageSlider.bottomAnchor, constant: 20).isActive = true
        areaThemaLabel.widthAnchor.constraint(equalTo: genderThemaLabel.widthAnchor).isActive = true
        areaThemaLabel.heightAnchor.constraint(equalTo: genderThemaLabel.heightAnchor).isActive = true
        ///住まいピッカー用のテキストフィールド
        pickerTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        pickerTextField.topAnchor.constraint(equalTo: areaThemaLabel.bottomAnchor, constant: 20).isActive = true
        pickerTextField.widthAnchor.constraint(equalTo: self.widthAnchor,multiplier: 0.4).isActive = true
        pickerTextField.heightAnchor.constraint(equalTo: genderThemaLabel.heightAnchor,multiplier:1.25).isActive = true
        ///住まいピッカーの陰影
        pickerShadowView.centerYAnchor.constraint(equalTo: pickerTextField.centerYAnchor).isActive = true
        pickerShadowView.centerXAnchor.constraint(equalTo: pickerTextField.centerXAnchor).isActive = true
        pickerShadowView.widthAnchor.constraint(equalTo: pickerTextField.widthAnchor).isActive = true
        pickerShadowView.heightAnchor.constraint(equalTo: pickerTextField.heightAnchor).isActive = true
        ///決定用ラベル
        dicitonLabel.centerXAnchor.constraint(equalTo: self.pickerTextField.centerXAnchor).isActive = true
        dicitonLabel.topAnchor.constraint(equalTo: self.pickerTextField.bottomAnchor, constant: 35).isActive = true
        dicitonLabel.widthAnchor.constraint(equalTo: self.pickerTextField.widthAnchor,multiplier: 1.5).isActive = true
        dicitonLabel.heightAnchor.constraint(equalTo: self.pickerTextField.heightAnchor).isActive = true
//        ///決定用ボタン
        dicitionButton.centerYAnchor.constraint(equalTo: dicitonLabel.centerYAnchor).isActive = true
        dicitionButton.centerXAnchor.constraint(equalTo: dicitonLabel.centerXAnchor).isActive = true
        dicitionButton.widthAnchor.constraint(equalTo: dicitonLabel.widthAnchor).isActive = true
        dicitionButton.heightAnchor.constraint(equalTo: dicitonLabel.heightAnchor).isActive = true
        ///検索画像
        filterImage.centerYAnchor.constraint(equalTo: dicitonLabel.centerYAnchor).isActive = true
        filterImage.centerXAnchor.constraint(equalTo: dicitonLabel.centerXAnchor).isActive = true
        filterImage.heightAnchor.constraint(equalTo: dicitonLabel.heightAnchor,multiplier: 0.95).isActive = true
        filterImage.widthAnchor.constraint(equalTo: dicitonLabel.heightAnchor).isActive = true
    }
    
    ///保存済みのデータから値を取得して最初に表示する
    func performFilterValueSetting() {
        ///性別の保存済みデータ
        for genderButton in genderButtonArray {
            if genderButton.gender.rawValue == searchLocalData.lcl_Gender {
                ///アニメーション表示
                selectedGenderImageAnimation(gender: genderButton.gender)
                ///フラグを立てる
                genderButton.dicitionFlag = true
            }
        }
        ///年齢の保存済みデータ
        ///ノブ位置調整+年齢変数に格納
        ///初回の検索画面表示で保存オブジェクトが値が初期値だった場合
        if searchLocalData.lcl_MinAge == 0 || searchLocalData.lcl_MaxAge == 0 {
            ageSlider.defaultValueLeftKnob = CGFloat(minAge)
            ageSlider.defaultValueRightKnob = CGFloat(maxAge)
        } else {
        ///検索保存データが存在している場合
            ///年月日から西暦に変換
            let convertMinYear = AgeCalculator.conbertDefaultYear(targetYearOfBirth: searchLocalData.lcl_MinAge, minOrMax: .min)
            let convertMaxYear = AgeCalculator.conbertDefaultYear(targetYearOfBirth: searchLocalData.lcl_MaxAge, minOrMax: .max)
            ///西暦から年齢に変換
            let convertMinAge = AgeCalculator.calculateAge(from: convertMinYear)
            let convertMaxAge = AgeCalculator.calculateAge(from: convertMaxYear)
            ageSlider.defaultValueLeftKnob = CGFloat(convertMinAge)
            ageSlider.defaultValueRightKnob = CGFloat(convertMaxAge)
            minAge = convertMinAge
            maxAge = convertMaxAge
        }
        ///住まいの保存済みデータ
        ///住まい表示
        pickerTextField.text = searchLocalData.lcl_Area
        
        ///ピッカーの中身初期表示設定
        ///リストの中からローカル保存してあるエリアの文言と合致させて位置を特定
        let targetAreaListIndex = areaPicker.list.firstIndex(of: searchLocalData.lcl_Area) ?? 0
        // 表示
        areaPicker.selectRow(targetAreaListIndex, inComponent: 0, animated: false)
    }
}



extension SearchSettingView:UIPickerViewDelegate,UIPickerViewDataSource {
    func picker(){
        self.areaPicker.delegate = self
        self.areaPicker.dataSource = self
        // 決定・キャンセル用ツールバーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 35))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "決定", style: .plain, target: self, action: #selector(done))
        let cancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(cancel))
        toolbar.setItems([cancelItem, spaceItem, doneItem], animated: true)
        
        ///テキストフィールドにピッカーを適用
        self.pickerTextField.inputView = areaPicker
        self.pickerTextField.inputAccessoryView = toolbar
        

        pickerTextField.textAlignment = .center
        pickerTextField.delegate = self
    }
    
    // 1. 決定ボタンのアクション指定
    @objc func done() {
        self.pickerTextField.endEditing(true)
        self.pickerTextField.text = "\(areaPicker.list[areaPicker.selectedRow(inComponent: 0)])"
    }
    // 2. キャンセルボタンのアクション指定
    @objc func cancel(){
        self.pickerTextField.endEditing(true)
    }
    // 3. 画面タップでテキストフィールドを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.pickerTextField.endEditing(true)
    }
    
    // ピッカービューの行数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // ピッカービューの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return areaPicker.list.count
    }
    // ピッカービューに表示する内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return areaPicker.list[row]
    }
}

extension SearchSettingView:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // ピッカービューを表示
        // この場合、trueを返すことで編集を無効化しつつピッカービューの表示を許可します
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // テキストの変更を許可しないようにfalseを返す
        return false
    }
}

extension SearchSettingView:RangeUISliderDelegate{
    func rangeChangeFinished(event: RangeUISliderChangeFinishedEvent) {
        return
    }
    
    /// 年齢スライダーの年齢格納イベント
    /// - Parameter event: 動いているスライダーの現在値
    func rangeIsChanging(event: RangeUISliderChangeEvent) {
        ///動かすたびに年齢を変数に格納
        self.minAge = Int(event.minValueSelected)
        self.maxAge = Int(event.maxValueSelected)
    }
}
