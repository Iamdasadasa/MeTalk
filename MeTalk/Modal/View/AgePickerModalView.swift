//
//  pickerModalView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/22.
//

import UIKit

protocol AgePickerModalViewDelegateProtcol:AnyObject{
    func dicisionButtonTappedAction(button:UIButton,view: AgePickerModalView)
    func closeButtonTappedAction(button:UIButton,view:AgePickerModalView)
}

class AgePickerModalView:UIView{

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        picker()
        autoLayoutSetUp()
        autoLayout()
    }
//※初期化処理※
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//※各定義※
    ///変数宣言
    weak var delegate: AgePickerModalViewDelegateProtcol?
    var pickerView: UIPickerView = UIPickerView()
        let list: [String] = ["18", "19", "20",
                          "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                          "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
                          "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
                          "51", "52", "53", "54", "55", "56", "57", "58", "59", "60",
                          "61", "62", "63", "64", "65", "66", "67", "68", "69", "70",
                          "71", "72", "73", "74", "75", "76", "77", "78", "79", "80",
                          "81", "82", "83", "84", "85", "86", "87", "88", "89", "90",
                          "91", "92", "93", "94", "95", "96", "97", "98", "99", "100"
                         ]
    ///項目変更タイトルラベル
    let itemTitleLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "年齢"
        returnLabel.textColor = .white
        returnLabel.backgroundColor = .clear
        returnLabel.font = UIFont.systemFont(ofSize: 15)
        returnLabel.textAlignment = NSTextAlignment.left
        return returnLabel
    }()
    ///項目テキストフィールド
    let itemTextField:UITextField = {
        let returnTextField = UITextField()
        returnTextField.borderStyle = .none
        returnTextField.textColor = .white
        returnTextField.placeholder = "年齢"
        returnTextField.textAlignment = .center
        return returnTextField
    }()
    ///決定ボタン
    let decisionButton:UIButton = {
        let returnButton = UIButton()
        returnButton.setTitle("決定", for: .normal)
        returnButton.setTitleColor(UIColor.white, for: .normal)
        returnButton.tag = 1
        returnButton.backgroundColor = .orange
        returnButton.addTarget(self, action: #selector(butttonClicked(_:)), for: UIControl.Event.touchUpInside)
        return returnButton
    }()
    /// 決定ボタンが押下された際の挙動
    @objc func butttonClicked(_ sender: UIButton) {
        if let delegate = delegate {
            self.delegate?.dicisionButtonTappedAction(button: sender, view: self)
        }
    }
    ///モーダルを閉じるボタン
    let CloseModalButton:UIButton = {
        let returnButton = UIButton()
        returnButton.addTarget(self, action: #selector(closeButttonClicked(_:)), for: UIControl.Event.touchUpInside)
        return returnButton
    }()
    /// クローズボタンが押下された際の挙動
    @objc func closeButttonClicked(_ sender: UIButton) {
        if let delegate = delegate {
            self.delegate?.closeButtonTappedAction(button: sender, view: self)
        }
    }
    
//※レイアウト設定※
    func autoLayoutSetUp() {
        ///各オブジェクトをViewに追加
        addSubview(itemTitleLabel)
        addSubview(itemTextField)
        addSubview(decisionButton)
        addSubview(CloseModalButton)


        ///UIオートレイアウトと競合させない処理
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        itemTextField.translatesAutoresizingMaskIntoConstraints = false
        decisionButton.translatesAutoresizingMaskIntoConstraints = false
        CloseModalButton.translatesAutoresizingMaskIntoConstraints = false
    }
//※レイアウト※
    func autoLayout() {
        ///項目変更タイトルラベル
        itemTitleLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        itemTitleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.03).isActive = true
        itemTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true
        itemTitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ///項目変更テキストフィールド
        itemTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        itemTextField.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
        itemTextField.topAnchor.constraint(equalTo: self.itemTitleLabel.bottomAnchor).isActive = true
        itemTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        ///決定ボタン
        decisionButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        decisionButton.heightAnchor.constraint(equalTo: itemTextField.heightAnchor).isActive = true
        decisionButton.topAnchor.constraint(equalTo: self.itemTextField.bottomAnchor, constant: 10).isActive = true
        decisionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ///閉じるボタン
        CloseModalButton.heightAnchor.constraint(equalTo: self.itemTitleLabel.heightAnchor).isActive = true
        CloseModalButton.widthAnchor.constraint(equalTo: self.CloseModalButton.heightAnchor).isActive = true
        CloseModalButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        CloseModalButton.topAnchor.constraint(equalTo: self.itemTitleLabel.topAnchor).isActive = true
    }

//picker関連の設定
    func picker() {
        ///pickerのデリゲート設定
        pickerView.delegate = self
        pickerView.dataSource = self
        // 3. 決定・キャンセル用ツールバーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 35))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        toolbar.setItems([cancelItem, spaceItem, doneItem], animated: true)
        
        ///テキストフィールドにピッカーを適用
        itemTextField.inputView = pickerView
        itemTextField.inputAccessoryView = toolbar
        
        // 5. デフォルト設定
        pickerView.selectRow(1, inComponent: 0, animated: false)
        
    }
    
    // 1. 決定ボタンのアクション指定
    @objc func done() {
        itemTextField.endEditing(true)
        itemTextField.text = "\(list[pickerView.selectedRow(inComponent: 0)])"
    }
    // 2. キャンセルボタンのアクション指定
    @objc func cancel(){
        itemTextField.endEditing(true)
    }
    // 3. 画面タップでテキストフィールドを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        itemTextField.endEditing(true)
    }
    
}

// ピッカーの初期設定
extension AgePickerModalView : UIPickerViewDelegate, UIPickerViewDataSource {
    
    // ピッカービューの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // ピッカービューの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    // ピッカービューに表示する内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
}

///テキストフィールド装飾
extension AgePickerModalView{
    ///テキストフィールドの枠線を自作
    override func draw(_ rect: CGRect) {
        // UIBezierPath のインスタンス生成
        let line = UIBezierPath();
        // 起点
        line.move(to: CGPoint(x: self.itemTextField.frame.minX, y: self.itemTextField.frame.maxY));
        // 帰着点
        line.addLine(to: CGPoint(x: self.itemTextField.frame.maxX, y: self.itemTextField.frame.maxY));
        // ラインを結ぶ
        line.close()
        // 色の設定
        UIColor.gray.setStroke()
//        UIColor.init(red: 50, green: 50, blue: 50, alpha: 100).setStroke()
        // ライン幅
        line.lineWidth = 1
        // 描画
        line.stroke();
    }
}
