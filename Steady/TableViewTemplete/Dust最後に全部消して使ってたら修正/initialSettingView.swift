////
////  SignUpView.swift
////  ClubSunriseCoast
////
////  Created by KOJIRO MARUYAMA on 2021/04/13.
////
//
//import UIKit
//
/////性別ボタンのプロトコル
//protocol sexImageChangeable{
//    var buttons: [UIButton] {get set}
//    func ChangeImage()
//    func setButtons(buttons: [UIButton])
//}
//
/////性別ボタンクラス
//class SexButton:UIButton,sexImageChangeable {
//    ///決定された際の画像の名前
//    var sexButtonDecidedImageName:String
//    ///未決定の画像の名前
//    var sexButtonUnDecidedImageName:String
//    ///各ボタンを保持する配列
//    var buttons: [UIButton] = []
//    
//    ///決定された際の画像の名称と未決定の画像の名称を初期化値で決定する。
//    init (sexButtonDecidedImageName:String,sexButtonUnDecidedImageName:String) {
//        self.sexButtonDecidedImageName = sexButtonDecidedImageName
//        self.sexButtonUnDecidedImageName = sexButtonUnDecidedImageName
//        super.init(frame: .zero)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    ///各ボタンをセットする処理
//    func setButtons(buttons:[UIButton]) {
//        self.buttons = buttons
//    }
//    ///画像を変更する処理
//    private func selfChangeImage(imageName:String?,button:SexButton) {
//        if let imageName = imageName {
//            let image = UIImage(named: imageName)
//            button.setImage(image, for: .normal)
//        }
//    }
//    ///自身のボタンか他のボタンかを判断し、画像変更処理に渡す
//    func ChangeImage() {
//        for button in buttons {
//            if let button = button as? SexButton{
//                if button == self {
//                    selfChangeImage(imageName: button.sexButtonDecidedImageName, button: button)
//                } else {
//                    selfChangeImage(imageName: button.sexButtonUnDecidedImageName, button: button)
//                }
//            }
//        }
//    }
//}
//protocol InitialSettingViewDelegateProtcol:AnyObject {
//    func SexButtonTappedAction(button:SexButton,view:InitialSettingView)
//    func dicisionButtonTappedAction(button:UIButton,view:InitialSettingView)
//}
/////初期Viewクラス
//class  InitialSettingView:UIView{
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.backgroundColor = .black
//        autoLayoutSetUp()
//        autoLayout()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
////※各定義※
//    ///変数宣言
//    weak var delegate:InitialSettingViewDelegateProtcol?
//
//    ///ボタン・フィールド定義
//    ///
//    ///新規登録タイトルラベル
//    let titleLabel1:UILabel = {
//        let returnLabel = UILabel()
//        returnLabel.text = "新規登録"
//        returnLabel.textColor = .orange
//        returnLabel.backgroundColor = .clear
//        returnLabel.textAlignment = NSTextAlignment.center
//        returnLabel.font = returnLabel.font.withSize(returnLabel.font.pointSize*3)
//        returnLabel.adjustsFontSizeToFitWidth = true
//        return returnLabel
//    }()
//    ///決定ボタン
//    let dicisionButton:UIButton = {
//        let returnUIButton = UIButton()
//        returnUIButton.translatesAutoresizingMaskIntoConstraints = false
//        returnUIButton.backgroundColor = .gray
//        returnUIButton.setTitleColor(UIColor.white, for: .normal)
//        returnUIButton.layer.cornerRadius = 10.0
//        returnUIButton.tag = 99
//        returnUIButton.isEnabled = false
//        returnUIButton.setTitle("決定", for: .normal)
//        returnUIButton.addTarget(self, action: #selector(dicisionButtontapped(_:)), for: .touchUpInside)
//        return returnUIButton
//    }()
//    ///決定ボタン押下時の挙動デリゲート
//    @objc func dicisionButtontapped(_ sender: UIButton){
//        if let delegate = delegate {
//            self.delegate?.dicisionButtonTappedAction(button: sender, view: self)
//        }
//    }
//    ///ニックネームタイトルラベル
//    let nicknameTitleLabel:UILabel = {
//        let returnLabel = UILabel()
//        returnLabel.text = "ニックネームを入力してください"
//        returnLabel.textColor = .white
//        returnLabel.backgroundColor = .clear
//        returnLabel.font = UIFont.systemFont(ofSize: 20)
//        returnLabel.textAlignment = NSTextAlignment.left
//        return returnLabel
//    }()
//    ///ニックネームテキストフィールド
//    let nicknameTextField:UITextField = {
//        let returnTextField = UITextField()
//        returnTextField.borderStyle = .roundedRect
//        returnTextField.placeholder = "10文字まで"
//        return returnTextField
//    }()
//    ///性別タイトルラベル
//    let sexSelectTitleLabel:UILabel = {
//        let returnLabel = UILabel()
//        returnLabel.text = "性別を選択してください"
//        returnLabel.textColor = .white
//        returnLabel.backgroundColor = .clear
//        returnLabel.font = UIFont.systemFont(ofSize: 20)
//        returnLabel.textAlignment = NSTextAlignment.left
//        return returnLabel
//    }()
//    ///性別注意書きラベル
//    let SexCautionLabel:UILabel = {
//        let returnLabel = UILabel()
//        returnLabel.text = "※性別・年齢は後から変更することができません※"
//        returnLabel.textColor = .red
//        returnLabel.backgroundColor = .clear
//        returnLabel.font = UIFont.systemFont(ofSize: 15)
//        returnLabel.textAlignment = NSTextAlignment.left
//        return returnLabel
//    }()
//    ///各ボタンの所持配列　セットされたら各ボタンにセットするようにする
//    var buttons:[UIButton] = [] {
//        didSet {
//            self.malebutton.setButtons(buttons: buttons)
//            self.femalebutton.setButtons(buttons: buttons)
//            self.unknownSexbutton.setButtons(buttons: buttons)
//        }
//    }
//    
//    ///性別ボタン（男性）サブクラス
//    let malebutton:SexButton = {
//        let returnButton = SexButton(sexButtonDecidedImageName: "Male_Orange", sexButtonUnDecidedImageName: "Male_Black")
//        returnButton.setImage(UIImage(named: "Male_Black"), for: .normal)
//        returnButton.backgroundColor = .white
//        returnButton.addTarget(self, action: #selector(butttonClicked(_:)), for: UIControl.Event.touchUpInside)
//        return returnButton
//    }()
//    ///性別ボタン（女性）サブクラス
//    let femalebutton:SexButton = {
//        let returnButton = SexButton(sexButtonDecidedImageName: "Female_Orange", sexButtonUnDecidedImageName: "Female_Black")
//        returnButton.setImage(UIImage(named: "Female_Black"), for: .normal)
//        returnButton.backgroundColor = .white
//        returnButton.addTarget(InitialSettingView.self, action: #selector(butttonClicked(_:)), for: UIControl.Event.touchUpInside)
//        return returnButton
//    }()
//    ///性別ボタン（不明）サブクラス
//    let unknownSexbutton:SexButton = {
//        let returnButton = SexButton(sexButtonDecidedImageName: "Unknown_Sex_Orange", sexButtonUnDecidedImageName: "Unknown_Sex_Black")
//        returnButton.setImage(UIImage(named: "Unknown_Sex_Black"), for: .normal)
//        returnButton.backgroundColor = .white
//        returnButton.addTarget(InitialSettingView.self, action: #selector(butttonClicked(_:)), for: UIControl.Event.touchUpInside)
//        return returnButton
//    }()
//    ///性別ボタンが押下された際の挙動
//    @objc func butttonClicked(_ sender: SexButton) {
//        if let delegate = self.delegate {
//            delegate.SexButtonTappedAction(button: sender, view: self)
//        }
//    }
//    ///性別ラベル
//    let maleLabel:UILabel = {
//        let returnLabel = UILabel()
//        returnLabel.text = "男性"
//        returnLabel.textColor = .white
//        returnLabel.backgroundColor = .clear
//        returnLabel.adjustsFontSizeToFitWidth = true
//        returnLabel.textAlignment = NSTextAlignment.center
//        return returnLabel
//    }()
//    let femaleLabel:UILabel = {
//        let returnLabel = UILabel()
//        returnLabel.text = "女性"
//        returnLabel.textColor = .white
//        returnLabel.backgroundColor = .clear
//        returnLabel.adjustsFontSizeToFitWidth = true
//        returnLabel.textAlignment = NSTextAlignment.center
//        return returnLabel
//    }()
//    let unknownSexLabel:UILabel = {
//        let returnLabel = UILabel()
//        returnLabel.text = "どちらでもない"
//        returnLabel.textColor = .white
//        returnLabel.backgroundColor = .clear
//        returnLabel.adjustsFontSizeToFitWidth = true
//        returnLabel.textAlignment = NSTextAlignment.center
//        return returnLabel
//    }()
////※レイアウト設定※
//    func autoLayoutSetUp() {
//        ///各オブジェクトをViewに追加
//        addSubview(titleLabel1)
//        addSubview(nicknameTitleLabel)
//        addSubview(nicknameTextField)
//        addSubview(sexSelectTitleLabel)
//        addSubview(malebutton)
//        addSubview(femalebutton)
//        addSubview(unknownSexbutton)
//        addSubview(maleLabel)
//        addSubview(femaleLabel)
//        addSubview(unknownSexLabel)
//        addSubview(dicisionButton)
//        addSubview(SexCautionLabel)
//
//        ///UIオートレイアウトと競合させない処理
//        titleLabel1.translatesAutoresizingMaskIntoConstraints = false
//        nicknameTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        dicisionButton.translatesAutoresizingMaskIntoConstraints = false
//        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
//        sexSelectTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        malebutton.translatesAutoresizingMaskIntoConstraints = false
//        femalebutton.translatesAutoresizingMaskIntoConstraints = false
//        unknownSexbutton.translatesAutoresizingMaskIntoConstraints = false
//        maleLabel.translatesAutoresizingMaskIntoConstraints = false
//        femaleLabel.translatesAutoresizingMaskIntoConstraints = false
//        unknownSexLabel.translatesAutoresizingMaskIntoConstraints = false
//        dicisionButton.translatesAutoresizingMaskIntoConstraints = false
//        SexCautionLabel.translatesAutoresizingMaskIntoConstraints = false
//    }
////※レイアウト※
//    func autoLayout() {
//        ///新規登録タイトルラベル
//        titleLabel1.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        titleLabel1.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
//        titleLabel1.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
//        titleLabel1.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        ///ニックネームタイトルラベル
//        nicknameTitleLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        nicknameTitleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
//        nicknameTitleLabel.topAnchor.constraint(equalTo: self.titleLabel1.bottomAnchor, constant: 30).isActive = true
//        ///ニックネームテキストフィールド
//        nicknameTextField.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        nicknameTextField.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
//        nicknameTextField.topAnchor.constraint(equalTo: self.nicknameTitleLabel.bottomAnchor, constant: 30).isActive = true
//        ///性別選択ラベル
//        sexSelectTitleLabel.widthAnchor.constraint(equalTo: nicknameTitleLabel.widthAnchor).isActive = true
//        sexSelectTitleLabel.heightAnchor.constraint(equalTo: nicknameTitleLabel.heightAnchor).isActive = true
//        sexSelectTitleLabel.topAnchor.constraint(equalTo: self.nicknameTextField.bottomAnchor, constant: 100).isActive = true
//        ///性別ボタン男
//        malebutton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
//        malebutton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1).isActive = true
//        malebutton.topAnchor.constraint(equalTo: self.sexSelectTitleLabel.bottomAnchor, constant: 30).isActive = true
//        malebutton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        ///性別ボタン女
//        femalebutton.widthAnchor.constraint(equalTo: self.malebutton.widthAnchor).isActive = true
//        femalebutton.heightAnchor.constraint(equalTo: self.malebutton.heightAnchor).isActive = true
//        femalebutton.topAnchor.constraint(equalTo: self.malebutton.topAnchor).isActive = true
//        femalebutton.leadingAnchor.constraint(equalTo: self.malebutton.trailingAnchor, constant: 10).isActive = true
//        ///性別ボタン不明
//        unknownSexbutton.widthAnchor.constraint(equalTo: self.malebutton.widthAnchor).isActive = true
//        unknownSexbutton.heightAnchor.constraint(equalTo: self.malebutton.heightAnchor).isActive = true
//        unknownSexbutton.topAnchor.constraint(equalTo: self.malebutton.topAnchor).isActive = true
//        unknownSexbutton.trailingAnchor.constraint(equalTo: self.malebutton.leadingAnchor, constant: -10).isActive = true
//        ///性別ラベル男
//        maleLabel.widthAnchor.constraint(equalTo: self.malebutton.widthAnchor).isActive = true
//        maleLabel.heightAnchor.constraint(equalTo: self.malebutton.heightAnchor, multiplier: 0.3).isActive = true
//        maleLabel.topAnchor.constraint(equalTo: self.malebutton.bottomAnchor, constant: 10).isActive = true
//        maleLabel.leadingAnchor.constraint(equalTo: self.malebutton.leadingAnchor).isActive = true
//        ///性別ラベル女
//        femaleLabel.widthAnchor.constraint(equalTo: self.femalebutton.widthAnchor).isActive = true
//        femaleLabel.heightAnchor.constraint(equalTo: self.femalebutton.heightAnchor, multiplier: 0.3).isActive = true
//        femaleLabel.topAnchor.constraint(equalTo: self.femalebutton.bottomAnchor, constant: 10).isActive = true
//        femaleLabel.leadingAnchor.constraint(equalTo: self.femalebutton.leadingAnchor).isActive = true
//        ///性別ラベル不明
//        unknownSexLabel.widthAnchor.constraint(equalTo: self.unknownSexbutton.widthAnchor).isActive = true
//        unknownSexLabel.heightAnchor.constraint(equalTo: self.unknownSexbutton.heightAnchor, multiplier: 0.3).isActive = true
//        unknownSexLabel.topAnchor.constraint(equalTo: self.unknownSexbutton.bottomAnchor, constant: 10).isActive = true
//        unknownSexLabel.leadingAnchor.constraint(equalTo: self.unknownSexbutton.leadingAnchor).isActive = true
//        ///性別注意書きラベル
//        SexCautionLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        SexCautionLabel.heightAnchor.constraint(equalTo: sexSelectTitleLabel.heightAnchor).isActive = true
//        SexCautionLabel.leadingAnchor.constraint(equalTo: unknownSexLabel.leadingAnchor).isActive = true
//        SexCautionLabel.topAnchor.constraint(equalTo: unknownSexLabel.bottomAnchor, constant: 5).isActive = true
//        ///決定ボタン
//        dicisionButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
//        dicisionButton.heightAnchor.constraint(equalTo: self.malebutton.heightAnchor, multiplier: 0.5).isActive = true
//        dicisionButton.topAnchor.constraint(equalTo: self.maleLabel.bottomAnchor, constant: 50).isActive = true
//        dicisionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//    }
//}
//
//
