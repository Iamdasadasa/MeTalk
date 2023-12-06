//
//  AdminDammyProfileCreateModalView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/11/07.
//

import Foundation
import UIKit

protocol AdminDammyProfileCreateModalViewDelegateProtcol:AnyObject {
    func dicisionButtonTappedAction(button:UIButton,Item:DammyCreateModalItems)
    func closeModalButttonClickedButtonTappedAction(button:UIButton,view:AdminDammyProfileCreateModalView)
    func pickerFinishedButtonTappedAction()
}

enum DammyCreateModalItems {
    case nickName
    case aboutMe
    case Area
    case birth
    case gender
    
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
            ITEMTEXTFIELD.clearButtonMode = .always
        case .aboutMe:
            TITLELABELTEXT = "ひとこと"
            ITEMTEXTFIELD.placeholder = "15文字以内"
            ITEMTEXTFIELD.clearButtonMode = .always
        case .Area:
            TITLELABELTEXT = "住まい"
        case .birth:
            TITLELABELTEXT = "誕生日"
        case .gender:
            TITLELABELTEXT = "性別"
        }
        
        ///インスタンスオプション
        ///タイトルラベル
        ITEMTITLELABEL.text = TITLELABELTEXT
        ITEMTITLELABEL.textColor = .gray
        ITEMTITLELABEL.backgroundColor = .clear
        ITEMTITLELABEL.font = UIFont.systemFont(ofSize: 15)
        ITEMTITLELABEL.textAlignment = NSTextAlignment.left
        ///テキストフィールド
        ITEMTEXTFIELD.borderStyle = .roundedRect
        ITEMTEXTFIELD.textColor = .gray
        ITEMTEXTFIELD.borderStyle = .none
        ITEMTEXTFIELD.tag = 1
        ///決定ボタン
        DICISIONBUTTON.setTitle("決定", for: .normal)
        DICISIONBUTTON.setTitleColor(UIColor.gray, for: .normal)
        DICISIONBUTTON.tag = 1
        DICISIONBUTTON.backgroundColor = .white
        
        let BASELAYOUT = baseObjects(itemTitleLabel: ITEMTITLELABEL, decisionButton: DICISIONBUTTON, CloseModalButton: CLOSEMODALBUTTON, itemTextField: ITEMTEXTFIELD)
        return BASELAYOUT
    }
    
    struct pickerObject {
        var pickerView = UIPickerView()
        var AreaList:[String]
        var birthList:[String]
        var genderList:[String]
    }
    
    var pickerInfo:pickerObject {
        let AreaList:[String]
        let birthList:[String]
        let startYear = 1973
        let endYear = 2005
        switch self {
        case.Area:
            AreaList = ["選択しない",
                    "北海道", "青森", "岩手", "宮城", "秋田", "山形", "福島", "茨城", "栃木", "群馬",
                    "埼玉", "千葉", "東京", "神奈川", "新潟", "富山", "石川", "福井", "山梨", "長野",
                    "岐阜", "静岡", "愛知", "三重", "滋賀", "京都", "大阪", "兵庫", "奈良", "和歌山",
                    "鳥取", "島根", "岡山", "広島", "山口", "徳島", "香川", "愛媛", "高知", "福岡",
                    "佐賀", "長崎", "熊本", "大分", "宮崎", "鹿児島", "沖縄"]
            return pickerObject(AreaList: AreaList, birthList:[], genderList: [])
        case.birth:
            let birthList = (startYear...endYear).map { year in
                let strYear = year * 10000 + 101
                return String(strYear)
            }

            return pickerObject(AreaList: [], birthList: birthList, genderList: [])
        case .gender:
            let genderList = ["0","1","2"]
            return pickerObject(AreaList: [], birthList: [], genderList: genderList)
        default:
            preconditionFailure("不正なCaseの型が指定されています。コード修正が必要です。")
        }
    }
}

class AdminDammyProfileCreateModalView:UIView{
    ///使用する列挙型
    var MODALITEMS:DammyCreateModalItems
    ///CLASSで使用する各ボタン（列挙型から引用してCLASSで使用するとバグる）
    var itemTitleLabel:UILabel
    var decisionButton:UIButton
    var CloseModalButton:UIButton
    var itemTextField:UITextField
    ///陰影表現のView
    var shadowView:ShadowBaseView = ShadowBaseView()
    ///PICKER
    var pickerView:UIPickerView?
    
    init(ModalItems:DammyCreateModalItems,frame:CGRect) {
        self.MODALITEMS = ModalItems
        self.itemTitleLabel = MODALITEMS.objectInfo.itemTitleLabel
        self.itemTextField = MODALITEMS.objectInfo.itemTextField
        self.decisionButton = MODALITEMS.objectInfo.decisionButton
        self.CloseModalButton = MODALITEMS.objectInfo.CloseModalButton
        switch ModalItems {
        case .Area:
            self.pickerView = ModalItems.pickerInfo.pickerView
        case .birth:
            self.pickerView = ModalItems.pickerInfo.pickerView
        case .gender:
            self.pickerView = ModalItems.pickerInfo.pickerView
        default:
            break
        }
        super.init(frame: frame)
        autoLayoutSetUp()
        autoLayout()
        setUp()
    }
        
    ///変数宣言
    weak var delegate: AdminDammyProfileCreateModalViewDelegateProtcol?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shadowView.shadowSetting(offset: .buttomReft)
    }

    func setUp() {
        self.backgroundColor = .white
        self.decisionButton.addTarget(self, action: #selector(dicisionButttonClicked(_:)), for: UIControl.Event.touchUpInside)
        self.CloseModalButton.addTarget(self, action: #selector(closeModalButttonClicked(_:)),for: UIControl.Event.touchUpInside)
        
        switch MODALITEMS {
        case .Area:
            piceker()
        case .birth:
            piceker()
        case .gender:
            piceker()
        default:
            return
        }
    }
    
    @objc func dicisionButttonClicked(_ sender: UIButton) {
        guard let delegate = delegate else { preconditionFailure("DELEGATE委譲に失敗") }
        
        switch MODALITEMS {
        case .aboutMe:
            delegate.dicisionButtonTappedAction(button: sender, Item: .aboutMe)
        case .nickName:
            delegate.dicisionButtonTappedAction(button: sender, Item: .nickName)
        case .Area:
            delegate.dicisionButtonTappedAction(button: sender,Item: .Area)
        case .birth:
            delegate.dicisionButtonTappedAction(button: sender,Item: .birth)
        case .gender:
            delegate.dicisionButtonTappedAction(button: sender,Item: .gender)
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
        addSubview(itemTitleLabel)
        addSubview(itemTextField)
        addSubview(shadowView)
        addSubview(decisionButton)
        addSubview(CloseModalButton)
        ///UIオートレイアウトと競合させない処理
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        itemTextField.translatesAutoresizingMaskIntoConstraints = false
        decisionButton.translatesAutoresizingMaskIntoConstraints = false
        CloseModalButton.translatesAutoresizingMaskIntoConstraints = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false
    }
//※レイアウト※
    func autoLayout() {
        self.CloseModalButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 5).isActive = true
        self.CloseModalButton.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
        self.CloseModalButton.heightAnchor.constraint(equalTo: self.CloseModalButton.widthAnchor).isActive = true
        self.CloseModalButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        ///項目変更テキストフィールド
        self.itemTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 100).isActive = true
        self.itemTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.itemTextField.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        self.itemTextField.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
        ///項目変更タイトルラベル
        self.itemTitleLabel.trailingAnchor.constraint(equalTo: self.itemTextField.leadingAnchor, constant: 5).isActive = true
        self.itemTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 5).isActive = true
        self.itemTitleLabel.topAnchor.constraint(equalTo: self.itemTextField.topAnchor).isActive = true
        self.itemTitleLabel.heightAnchor.constraint(equalTo:self.itemTextField.heightAnchor).isActive = true
        ///決定ボタン
        self.decisionButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        self.decisionButton.heightAnchor.constraint(equalTo: self.itemTextField.heightAnchor).isActive = true
        self.decisionButton.topAnchor.constraint(equalTo: self.itemTextField.bottomAnchor, constant: 10).isActive = true
        self.decisionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ///陰影View
        self.shadowView.widthAnchor.constraint(equalTo: self.decisionButton.widthAnchor).isActive = true
        self.shadowView.heightAnchor.constraint(equalTo: self.decisionButton.heightAnchor).isActive = true
        self.shadowView.topAnchor.constraint(equalTo: self.decisionButton.topAnchor).isActive = true
        self.shadowView.centerXAnchor.constraint(equalTo: self.decisionButton.centerXAnchor).isActive = true
        ///閉じるボタン
        self.CloseModalButton.heightAnchor.constraint(equalTo: self.itemTitleLabel.heightAnchor).isActive = true
        self.CloseModalButton.widthAnchor.constraint(equalTo: self.CloseModalButton.heightAnchor).isActive = true
        self.CloseModalButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.CloseModalButton.topAnchor.constraint(equalTo: self.itemTitleLabel.topAnchor).isActive = true
    }
}

extension AdminDammyProfileCreateModalView{
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

extension AdminDammyProfileCreateModalView:UIPickerViewDelegate,UIPickerViewDataSource{

    func piceker() {
        guard let pickerView = self.pickerView else {
            print("pickerViewが設定されていません。正しいケース状態か確認してください。")
            return
        }
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // 決定・キャンセル用ツールバーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 35))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "決定", style: .plain, target: self, action: #selector(done))
        let cancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(cancel))
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
        if MODALITEMS == .Area {
            self.itemTextField.text = "\(MODALITEMS.pickerInfo.AreaList[pickerView!.selectedRow(inComponent: 0)])"
        } else if MODALITEMS == .birth {
            self.itemTextField.text = "\(MODALITEMS.pickerInfo.birthList[pickerView!.selectedRow(inComponent: 0)])"
        } else if MODALITEMS == .gender {
            self.itemTextField.text = "\(MODALITEMS.pickerInfo.genderList[pickerView!.selectedRow(inComponent: 0)])"
        }
        delegate?.pickerFinishedButtonTappedAction()
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
        if MODALITEMS == .Area {
            return MODALITEMS.pickerInfo.AreaList.count
        } else if MODALITEMS == .birth {
            return MODALITEMS.pickerInfo.birthList.count
        } else if MODALITEMS == .gender {
            return MODALITEMS.pickerInfo.genderList.count
        } else {
            return 0
        }
    }
    // ピッカービューに表示する内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if MODALITEMS == .Area {
            return MODALITEMS.pickerInfo.AreaList[row]
        } else if MODALITEMS == .birth {
            return MODALITEMS.pickerInfo.birthList[row]
        } else if MODALITEMS == .gender {
            return MODALITEMS.pickerInfo.genderList[row]
        } else {
            return ""
        }

    }
}
