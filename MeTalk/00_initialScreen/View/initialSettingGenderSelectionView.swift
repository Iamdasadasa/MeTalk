//
//  initialSettingGenderSelectView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/04/18.
//

import Foundation
import UIKit



///決定ボタンカスタムクラス
class decisionCustomButton:UIButton {
    var selectedGender:GENDER?
    init() {
        super.init(frame: .zero)// 親クラスの指定イニシャライザを呼び出す
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

///メインクラスプロトコル
protocol initialSettingGenderSelectionViewDelegate:AnyObject {
    func decisionButtonTappedAction(gender:GENDER)
}
///メインクラス
class initialSettingGenderSelectionView:UIView{
    ///共通画像インスタンス
    var femaleImage:genderImageView!
    var maleImage:genderImageView!
    var noneGenderImage:genderImageView!
    
    ///共通ボタンインスタンス
    var femaleButton:genderButton!
    var maleButton:genderButton!
    var noneGenderButton:genderButton!
    
    ///共通テキストラベル
    var femaleTxtLabel:genderTextLabel!
    var maleTxtLabel:genderTextLabel!
    var noneTxtLabel:genderTextLabel!
    
    ///決定ボタン_決定画像
    var decisionButton:decisionCustomButton = decisionCustomButton()
    let decisionImageView:UIImageView = {
        let ImageView = UIImageView()
        ImageView.contentMode = .scaleAspectFit
        ImageView.backgroundColor = .clear
        ImageView.layer.masksToBounds = true
        ImageView.image = UIImage(named: "decisionImage")
        return ImageView
    }()
    ///キャンセルボタン_キャンセル画像
    var cancelButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        return button
    }()
    let cancelImageView:UIImageView = {
        let ImageView = UIImageView()
        ImageView.contentMode = .scaleAspectFit
        ImageView.backgroundColor = .clear
        ImageView.layer.masksToBounds = true
        ImageView.image = UIImage(named: "BackImage")
        return ImageView
    }()
    
    ///ハイライト用View
    var overlayView:OverlayView = OverlayView()
    
    ///イメージサイズ
    var imageSize:CGFloat!
    
    ///delegate
    weak var delegate:initialSettingGenderSelectionViewDelegate?
    
    ///画像選択ロックフラグ
    var selectGenderLocking:Bool = false
    
    ///性別選択案内ラベル
    let selectGenderInfoLabel:UILabel = {
        let returnLabel = UILabel()
        returnLabel.text = "性別を教えてください"
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
    ///各レイアウト描写ごとに対応するメソッド
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    /// 性別ボタンが押下された際の挙動
    /// - Parameter sender: クリックされた性別ボタン（カスタムクラス)
    @objc func genderButtonClicked(_ sender: genderButton) {
        ///性別複数押下無効対応
        if selectGenderLocking {
            return
        }
        ///性別性別ロック
        self.selectGenderLocking = true
        ///性別画像拡大アニメーション
        let FlipAnimation = {(targetImageView:genderImageView) in
            UIView.transition(with: targetImageView, duration: 0.8, options: .transitionFlipFromLeft, animations: {
                targetImageView.transform = CGAffineTransform(scaleX: 2, y: 2)
                targetImageView.center = self.center
            },completion: {_ in
                self.bringSubviewToFront(targetImageView)
                self.decision_CancelIsEnable(isEnable: true)
            })
        }
        ///画面内のすべてのオブジェクト処理
        self.subviews.forEach{ subView in
            ///性別ボタンに対しての処理
            if let Button = subView as? genderButton {
                Button.isEnabled = false
            }
            ///性別画像に対しての処理
            if let ImageView = subView as? genderImageView {
                if ImageView.gender == sender.gender {
                    self.decisionButton.selectedGender = sender.gender
                    ImageView.selected = true
                    ImageView.layer.borderColor = UIColor.white.cgColor
                    ImageView.translatesAutoresizingMaskIntoConstraints = true
                    ///対象Imageの中心座標を取得しておく
                    ImageView.centerValue = ImageView.center
                    FlipAnimation(ImageView)
                }
            }
            ///性別テキストラベルに対しての処理
            if let textLabel = subView as? genderTextLabel {
                if textLabel.gender == sender.gender {
                    textLabel.translatesAutoresizingMaskIntoConstraints = true
                }
            }
        }
        
        self.selectGenderInfoLabel.translatesAutoresizingMaskIntoConstraints = true
        
        ///ハイライト用ビューの差し込み
        overlayViewShowOrHide(isAdding: true)
    }
    /// 決定ボタンが押下された際の挙動
    /// - Parameter sender: クリックされた決定ボタン
    @objc func decitionButtonClicked(_ sender: decisionCustomButton) {
        guard let gender = sender.selectedGender else {
            return
        }
        ///キャンセルボタンを押下させて画面を初期状態に戻す
        self.cancelButtonClicked(self.cancelButton)
        
        if let delegate = self.delegate {
            ///ボタンタグをデリゲート関数の引数で渡す
            delegate.decisionButtonTappedAction(gender:gender)
        }
    }
    /// キャンセルボタンが押下された際の挙動
    /// - Parameter sender: クリックされたキャンセルボタン
    @objc func cancelButtonClicked(_ sender: UIButton) {
        ///性別性別ロック解除
        self.selectGenderLocking = false
        ///性別画像縮小アニメーション
        let FlipAnimation = {(targetImageView:genderImageView) in
            self.decision_CancelIsEnable(isEnable: false)
            UIView.transition(with: targetImageView, duration: 0.8, options: .transitionFlipFromLeft, animations: {
                self.overlayViewShowOrHide(isAdding: false)
                targetImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                targetImageView.center = targetImageView.centerValue!
            },completion: {_ in

            })
        }
        ///画面内のすべてのオブジェクト処理
        self.subviews.forEach{ subView in
            ///オートレイアウト無効処理
            if subView.translatesAutoresizingMaskIntoConstraints {
                subView.translatesAutoresizingMaskIntoConstraints = false
            }
            ///性別画像に対しての処理
            if let ImageView = subView as? genderImageView {
                if ImageView.selected {
                    ImageView.selected = false
                    ImageView.layer.borderColor = UIColor.gray.cgColor
                    FlipAnimation(ImageView)
                    self.insertSubview(ImageView, belowSubview: self.overlayView)
                }
            }
            ///性別テキストラベルに対しての処理
            if let Button = subView as? genderButton {
                Button.isEnabled = true
            }
        }
    }
}

extension initialSettingGenderSelectionView:UIScrollViewDelegate {
    /// レイアウト全般処理
    func viewSetUp() {
        ///背景画像設定
        backGroundViewImageSetUp(imageName: "gemderSelectBack")
        
        ///列挙型配列からボタンおよび画像のインスタンス生成
        let genderArray:[GENDER] = [.female,.male,.none]
        for genderPattern in genderArray {
            ///各インスタンス変数に割り振りおよび初期レイアウト設定
            switch genderPattern {
            case .none:
                noneGenderImage = genderImageView(gender: genderPattern, Type: .initial)
                noneTxtLabel = genderTextLabel(gender: genderPattern)
                noneGenderButton = genderButton(gender: genderPattern)
                noneGenderButton.addTarget(self, action: #selector(genderButtonClicked(_:)), for: UIControl.Event.touchUpInside)
            case .male:
                maleImage = genderImageView(gender: genderPattern, Type: .initial)
                maleTxtLabel = genderTextLabel(gender: genderPattern)
                maleButton = genderButton(gender: genderPattern)
                maleButton.addTarget(self, action: #selector(genderButtonClicked(_:)), for: UIControl.Event.touchUpInside)
            case .female:
                femaleImage = genderImageView(gender: genderPattern, Type: .initial)
                femaleTxtLabel = genderTextLabel(gender: genderPattern)
                femaleButton = genderButton(gender: genderPattern)
                femaleButton.addTarget(self, action: #selector(genderButtonClicked(_:)), for: UIControl.Event.touchUpInside)
            }
        }

        // 画像のサイズを画面の1/3に設定
        imageSize = UIScreen.main.bounds.width / 3

        /// 各UIImageViewのAuto Layout制約を設定
        selectGenderInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        femaleButton.translatesAutoresizingMaskIntoConstraints = false
        maleButton.translatesAutoresizingMaskIntoConstraints = false
        noneGenderButton.translatesAutoresizingMaskIntoConstraints = false
        femaleImage.translatesAutoresizingMaskIntoConstraints = false
        maleImage.translatesAutoresizingMaskIntoConstraints = false
        noneGenderImage.translatesAutoresizingMaskIntoConstraints = false
        femaleTxtLabel.translatesAutoresizingMaskIntoConstraints = false
        maleTxtLabel.translatesAutoresizingMaskIntoConstraints = false
        noneTxtLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false

        ///画像の円形処理
        femaleButton.layer.cornerRadius = imageSize / 2
        maleButton.layer.cornerRadius = imageSize / 2
        noneGenderButton.layer.cornerRadius = imageSize / 2
        noneGenderImage.layer.cornerRadius = imageSize / 2
        maleImage.layer.cornerRadius = imageSize / 2
        femaleImage.layer.cornerRadius = imageSize / 2
        ///オブジェクト 追加
        self.addSubview(selectGenderInfoLabel)
        self.addSubview(noneGenderImage)
        self.addSubview(femaleImage)
        self.addSubview(maleImage)
        self.addSubview(overlayView)///必ず各Imageの後ろでaddSubview
        self.addSubview(femaleButton)
        self.addSubview(maleButton)
        self.addSubview(noneGenderButton)
        self.addSubview(noneTxtLabel)
        self.addSubview(femaleTxtLabel)
        self.addSubview(maleTxtLabel)
    }
    /// オートレイアウト制約処理
    func viewLayoutSetUp() {
        ///無性別イメージビュー
        noneGenderImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -imageSize).isActive = true
        noneGenderImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        noneGenderImage.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        noneGenderImage.heightAnchor.constraint(equalTo: noneGenderImage.widthAnchor).isActive = true
        ///女性イメージビュー
        femaleImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: imageSize).isActive = true
        femaleImage.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        femaleImage.heightAnchor.constraint(equalTo: femaleImage.widthAnchor).isActive = true
        femaleImage.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        ///男性イメージビュー
        maleImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: imageSize).isActive = true
        maleImage.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        maleImage.heightAnchor.constraint(equalTo: maleImage.widthAnchor).isActive = true
        maleImage.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        ///無性別ボタン
        noneGenderButton.centerYAnchor.constraint(equalTo: noneGenderImage.centerYAnchor).isActive = true
        noneGenderButton.centerXAnchor.constraint(equalTo: noneGenderImage.centerXAnchor).isActive = true
        noneGenderButton.widthAnchor.constraint(equalTo: noneGenderImage.widthAnchor).isActive = true
        noneGenderButton.heightAnchor.constraint(equalTo: noneGenderImage.widthAnchor).isActive = true
        ///女性ボタン
        femaleButton.centerYAnchor.constraint(equalTo: femaleImage.centerYAnchor).isActive = true
        femaleButton.widthAnchor.constraint(equalTo: femaleImage.widthAnchor).isActive = true
        femaleButton.heightAnchor.constraint(equalTo: femaleImage.heightAnchor).isActive = true
        femaleButton.leadingAnchor.constraint(equalTo: femaleImage.leadingAnchor).isActive = true
        ///男性ボタン
        maleButton.centerYAnchor.constraint(equalTo: maleImage.centerYAnchor).isActive = true
        maleButton.widthAnchor.constraint(equalTo: maleImage.widthAnchor).isActive = true
        maleButton.heightAnchor.constraint(equalTo: maleImage.heightAnchor).isActive = true
        maleButton.trailingAnchor.constraint(equalTo: maleImage.trailingAnchor).isActive = true
        ///無性別テキストラベル
        noneTxtLabel.centerXAnchor.constraint(equalTo: noneGenderImage.centerXAnchor).isActive = true
        noneTxtLabel.topAnchor.constraint(equalTo: noneGenderImage.bottomAnchor).isActive = true
        noneTxtLabel.trailingAnchor.constraint(equalTo: noneGenderImage.trailingAnchor).isActive = true
        noneTxtLabel.leadingAnchor.constraint(equalTo: noneGenderImage.leadingAnchor).isActive = true
        noneTxtLabel.heightAnchor.constraint(equalTo: selectGenderInfoLabel.heightAnchor, multiplier: 0.5).isActive = true
        ///男性テキストラベル
        maleTxtLabel.centerXAnchor.constraint(equalTo: maleImage.centerXAnchor).isActive = true
        maleTxtLabel.topAnchor.constraint(equalTo: maleImage.bottomAnchor).isActive = true
        maleTxtLabel.trailingAnchor.constraint(equalTo: maleImage.trailingAnchor).isActive = true
        maleTxtLabel.leadingAnchor.constraint(equalTo: maleImage.leadingAnchor).isActive = true
        maleTxtLabel.heightAnchor.constraint(equalTo: selectGenderInfoLabel.heightAnchor, multiplier: 0.5).isActive = true
        ///女性テキストラベル
        femaleTxtLabel.centerXAnchor.constraint(equalTo: femaleImage.centerXAnchor).isActive = true
        femaleTxtLabel.topAnchor.constraint(equalTo: femaleImage.bottomAnchor).isActive = true
        femaleTxtLabel.trailingAnchor.constraint(equalTo: femaleImage.trailingAnchor).isActive = true
        femaleTxtLabel.leadingAnchor.constraint(equalTo: femaleImage.leadingAnchor).isActive = true
        femaleTxtLabel.heightAnchor.constraint(equalTo: selectGenderInfoLabel.heightAnchor, multiplier: 0.5).isActive = true
        ///ハイライト用View
        overlayView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        overlayView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        ///性別選択案内ラベル（Top位置はLayout Sub Viewで設定）
        selectGenderInfoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        selectGenderInfoLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1).isActive = true
        selectGenderInfoLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        selectGenderInfoLabel.bottomAnchor.constraint(equalTo: self.noneGenderImage.topAnchor,constant: -10).isActive = true
    }
    
    
    /// オーバーレイ表示Or非表示
    /// - Parameter isAdding: 表示するか非表示にするか選択するBool値
    func overlayViewShowOrHide(isAdding:Bool) {
        if isAdding {
            self.noneGenderImage.image = UIImage(named: "UnknownSelected")
            overlayView.show()
        } else {
            ///最前面がオーバーレイではなかった場合Return
            guard let overlayView = self.subviews.first(where: { $0 is OverlayView }) as? OverlayView else {
                return
            }
            self.noneGenderImage.image = UIImage(named: "Unknown")
            overlayView.hide()
        }
    }
    
    ///性別決定及びキャンセル設定
    func decision_CancelSetUp() {
        
        ///キャンセルボタンと決定ボタンのタップアクション設定
        cancelButton.addTarget(self, action: #selector(self.cancelButtonClicked(_:)), for: UIControl.Event.touchUpInside)
        decisionButton.addTarget(self, action: #selector(self.decitionButtonClicked(_:)), for: UIControl.Event.touchUpInside)
        
        self.addSubview(decisionImageView)
        self.addSubview(decisionButton)
        self.addSubview(cancelImageView)
        self.addSubview(cancelButton)
        
        decisionButton.translatesAutoresizingMaskIntoConstraints = false
        decisionImageView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    ///性別決定及びキャンセルレイアウト設定
    func decision_CancelLayoutSetUp() {
        ///決定ボタン
        decisionButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
        decisionButton.heightAnchor.constraint(equalTo: self.selectGenderInfoLabel.heightAnchor).isActive = true
        decisionButton.topAnchor.constraint(equalTo: self.centerYAnchor, constant: self.bounds.width/3).isActive = true
        decisionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: self.bounds.width/3).isActive = true
        ///決定画像
        decisionImageView.widthAnchor.constraint(equalTo: decisionButton.widthAnchor).isActive = true
        decisionImageView.heightAnchor.constraint(equalTo: decisionButton.heightAnchor).isActive = true
        decisionImageView.topAnchor.constraint(equalTo: decisionButton.topAnchor).isActive = true
        decisionImageView.centerXAnchor.constraint(equalTo: decisionButton.centerXAnchor).isActive = true
        ///キャンセルボタン
        cancelButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
        cancelButton.heightAnchor.constraint(equalTo: self.selectGenderInfoLabel.heightAnchor).isActive = true
        cancelButton.topAnchor.constraint(equalTo: self.centerYAnchor, constant: self.bounds.width/3).isActive = true
        cancelButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -self.bounds.width/3).isActive = true
        ///キャンセル画像
        cancelImageView.widthAnchor.constraint(equalTo: cancelButton.widthAnchor).isActive = true
        cancelImageView.heightAnchor.constraint(equalTo: cancelButton.heightAnchor).isActive = true
        cancelImageView.topAnchor.constraint(equalTo: cancelButton.topAnchor).isActive = true
        cancelImageView.centerXAnchor.constraint(equalTo: cancelButton.centerXAnchor).isActive = true

    }
    /// 決定・キャンセルボタン有効・無効化
    /// - Parameter isEnable: 有効か無効にするか選択するBool値
    func decision_CancelIsEnable(isEnable:Bool) {
            self.cancelButton.isEnabled = isEnable
            self.decisionButton.isEnabled = isEnable
        if isEnable {
            decision_CancelSetUp()
            decision_CancelLayoutSetUp()
        } else {
            self.cancelButton.removeFromSuperview()
            self.cancelImageView.removeFromSuperview()
            self.decisionButton.removeFromSuperview()
            self.decisionImageView.removeFromSuperview()
        }
    }
}
