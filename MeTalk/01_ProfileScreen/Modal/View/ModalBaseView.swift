//
//  ModalBaseView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/01/17.
//

import UIKit

protocol ModalViewDelegateProtcol:AnyObject {
    func dicisionButtonTappedAction(button:UIButton,objects: ModalItems)
    func closeModalButttonClickedButtonTappedAction(button:UIButton,view:ModalBaseView)
}

enum ModalItems {
    case nickName
    case aboutMe
    case Area
    case Age
    
    struct baseObjects {
        var itemTitleLabel:UILabel
        var decisionButton:UIButton
        var CloseModalButton:UIButton
        var itemTextField:UITextField
    }
    
    var objectInfo:baseObjects{
        ///必要なオブジェクト一覧
        let ITEMTITLELABEL = UILabel()
        let DICISIONBUTTON = UIButton()
        let CLOSEMODALBUTTON = UIButton()
        let ITEMTEXTFIELD = UITextField()
        
        ///Caseによって異なる要素
        let TITLELABELTEXT:String
        switch self {
        case .nickName:
            TITLELABELTEXT = "ニックネーム"
            ITEMTEXTFIELD.placeholder = "10文字以内"
        case .aboutMe:
            TITLELABELTEXT = "ひとこと"
            ITEMTEXTFIELD.placeholder = "30文字以内"
        case .Area:
            TITLELABELTEXT = "住まい"
        case .Age:
            TITLELABELTEXT = "年齢"
        }
        
        ///インスタンスオプション
        ///タイトルラベル
        ITEMTITLELABEL.text = TITLELABELTEXT
        ITEMTITLELABEL.textColor = .white
        ITEMTITLELABEL.backgroundColor = .clear
        ITEMTITLELABEL.font = UIFont.systemFont(ofSize: 15)
        ITEMTITLELABEL.textAlignment = NSTextAlignment.left
        ///テキストフィールド
        ITEMTEXTFIELD.borderStyle = .roundedRect
        ITEMTEXTFIELD.textColor = .white
        ITEMTEXTFIELD.borderStyle = .none
        ITEMTEXTFIELD.clearButtonMode = .always
        ITEMTEXTFIELD.tag = 1
        ///決定ボタン
        DICISIONBUTTON.setTitle("決定", for: .normal)
        DICISIONBUTTON.setTitleColor(UIColor.white, for: .normal)
        DICISIONBUTTON.tag = 1
        DICISIONBUTTON.backgroundColor = .orange
        
        let BASELAYOUT = baseObjects(itemTitleLabel: ITEMTITLELABEL, decisionButton: DICISIONBUTTON, CloseModalButton: CLOSEMODALBUTTON, itemTextField: ITEMTEXTFIELD)
        return BASELAYOUT
    }
    
    struct pickerObject {
        var pickerView = UIPickerView()
        var list:[String]
    }
    
    var pickerInfo:pickerObject {
        let LIST:[String]
        switch self {
        case.Age:
            LIST = ["選択しない",
                    "北海道", "青森", "岩手", "宮城", "秋田", "山形", "福島", "茨城", "栃木", "群馬",
                    "埼玉", "千葉", "東京", "神奈川", "新潟", "富山", "石川", "福井", "山梨", "長野",
                    "岐阜", "静岡", "愛知", "三重", "滋賀", "京都", "大阪", "兵庫", "奈良", "和歌山",
                    "鳥取", "島根", "岡山", "広島", "山口", "徳島", "香川", "愛媛", "高知", "福岡",
                    "佐賀", "長崎", "熊本", "大分", "宮崎", "鹿児島", "沖縄"]
            return pickerObject(list: LIST)
        case.Area:
            LIST = ["18", "19", "20",
                    "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                    "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
                    "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
                    "51", "52", "53", "54", "55", "56", "57", "58", "59", "60",
                    "61", "62", "63", "64", "65", "66", "67", "68", "69", "70",
                    "71", "72", "73", "74", "75", "76", "77", "78", "79", "80",
                    "81", "82", "83", "84", "85", "86", "87", "88", "89", "90",
                    "91", "92", "93", "94", "95", "96", "97", "98", "99", "100"]
            return pickerObject(list: LIST)
        default:
            preconditionFailure("不正なCaseの型が指定されています。コード修正が必要です。")
        }
    }
}







class ModalBaseView:UIView{
    ///使用する列挙型
    var MODALITEMS:ModalItems
    ///CLASSで使用する各ボタン（列挙型から引用してCLASSで使用するとバグる）
    var itemTitleLabel:UILabel
    var decisionButton:UIButton
    var CloseModalButton:UIButton
    var itemTextField:UITextField
    
    
    init(ModalItems:ModalItems,frame:CGRect) {
        self.MODALITEMS = ModalItems
        self.itemTitleLabel = MODALITEMS.objectInfo.itemTitleLabel
        self.itemTextField = MODALITEMS.objectInfo.itemTextField
        self.decisionButton = MODALITEMS.objectInfo.decisionButton
        self.CloseModalButton = MODALITEMS.objectInfo.CloseModalButton
        
        super.init(frame: frame)
        autoLayoutSetUp()
        autoLayout()
        setUp()
    }
    
    ///変数宣言
    weak var delegate: ModalViewDelegateProtcol?

    
    func setUp() {
        self.decisionButton.addTarget(self, action: #selector(dicisionButttonClicked(_:)), for: UIControl.Event.touchUpInside)
        self.CloseModalButton.addTarget(self, action: #selector(closeModalButttonClicked(_:)),for: UIControl.Event.touchUpInside)
        
        switch MODALITEMS {
        case .Area:
            piceker()
        case .Age:
            piceker()
        default:
            return
        }
    }
    
    @objc func dicisionButttonClicked(_ sender: UIButton) {
        guard let delegate = delegate else { preconditionFailure("DELEGATE委譲に失敗") }
        
        switch MODALITEMS {
        case .aboutMe:
            delegate.dicisionButtonTappedAction(button: sender, objects: MODALITEMS)
        case .nickName:
            delegate.dicisionButtonTappedAction(button: sender, objects: MODALITEMS)
        case .Age:
            delegate.dicisionButtonTappedAction(button: sender, objects: MODALITEMS)
        case .Area:
            delegate.dicisionButtonTappedAction(button: sender, objects: MODALITEMS)
        }
    }
    
    @objc func closeModalButttonClicked(_ sender: UIButton) {
        guard let delegate = delegate else { preconditionFailure("DELEGATE委譲に失敗") }
        delegate.closeModalButttonClickedButtonTappedAction(button: sender, view: self)
    }
//※初期化処理※
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//※レイアウト設定※
    func autoLayoutSetUp() {

        ///各オブジェクトをViewに追加
        addSubview(self.itemTitleLabel)
        addSubview(self.itemTextField)
        addSubview(self.decisionButton)
        addSubview(self.CloseModalButton)
        
        ///UIオートレイアウトと競合させない処理
        self.itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.itemTextField.translatesAutoresizingMaskIntoConstraints = false
        self.decisionButton.translatesAutoresizingMaskIntoConstraints = false
        self.CloseModalButton.translatesAutoresizingMaskIntoConstraints = false
    }
//※レイアウト※
    func autoLayout() {
        ///項目変更タイトルラベル
        self.itemTitleLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        self.itemTitleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.03).isActive = true
        self.itemTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true
        self.itemTitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ///項目変更テキストフィールド
        self.itemTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.itemTextField.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
        self.itemTextField.topAnchor.constraint(equalTo: self.itemTitleLabel.bottomAnchor).isActive = true
        self.itemTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        ///決定ボタン
        self.decisionButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        self.decisionButton.heightAnchor.constraint(equalTo: self.itemTextField.heightAnchor).isActive = true
        self.decisionButton.topAnchor.constraint(equalTo: self.itemTextField.bottomAnchor, constant: 10).isActive = true
        self.decisionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ///閉じるボタン
        self.CloseModalButton.heightAnchor.constraint(equalTo: self.itemTitleLabel.heightAnchor).isActive = true
        self.CloseModalButton.widthAnchor.constraint(equalTo: self.CloseModalButton.heightAnchor).isActive = true
        self.CloseModalButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.CloseModalButton.topAnchor.constraint(equalTo: self.itemTitleLabel.topAnchor).isActive = true
    }
}

extension ModalBaseView{
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

extension ModalBaseView:UIPickerViewDelegate,UIPickerViewDataSource{

    func piceker() {
        let pickerView = MODALITEMS.pickerInfo.pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // 決定・キャンセル用ツールバーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 35))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        toolbar.setItems([cancelItem, spaceItem, doneItem], animated: true)
        
        ///テキストフィールドにピッカーを適用
        self.itemTextField.inputView = pickerView
        self.itemTextField.inputAccessoryView = toolbar
        
        // 5. デフォルト設定
        pickerView.selectRow(1, inComponent: 0, animated: false)
    }
    
    // 1. 決定ボタンのアクション指定
    @objc func done() {
        self.itemTextField.endEditing(true)
        self.itemTextField.text = "\(MODALITEMS.pickerInfo.list[MODALITEMS.pickerInfo.pickerView.selectedRow(inComponent: 0)])"
    }
    // 2. キャンセルボタンのアクション指定
    @objc func cancel(){
        self.itemTextField.endEditing(true)
    }
    // 3. 画面タップでテキストフィールドを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.itemTextField.endEditing(true)
    }
    
    // ピッカービューの行数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // ピッカービューの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MODALITEMS.pickerInfo.list.count
    }
    // ピッカービューに表示する内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return MODALITEMS.pickerInfo.list[row]
    }
}
