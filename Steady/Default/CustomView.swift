//
//  CustomView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/07/12.
//

import Foundation
import UIKit
///陰影処理ベースView
class ShadowBaseView:UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    enum offset{
        case topRight
        case buttomReft
    }
    ///陰影付与処理
    ///適用は使用する側のlayoutSubviews内で(super.layoutSubviews()入れるの忘れないで)
    func shadowSetting(offset:offset) {
        ///角丸
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        /// 陰影をつける（ボタンっぽくする）
        switch offset {
        case .topRight:
            self.layer.shadowOffset = CGSize(width: 3, height: -3)
        case .buttomReft:
            self.layer.shadowOffset = CGSize(width: -3, height: 3)
        }
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor

        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 2
        /// シャドウパスとして保持
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    ///選択中を表現するグローアニメーションインスタンス
    let glowLayer:CALayer = {
        let glowLayer = CALayer()
        glowLayer.backgroundColor = UIColor.white.cgColor
        glowLayer.shadowColor = CGColor(red: 1.0, green: 0.55, blue: 0.55, alpha: 1.0)
        glowLayer.shadowOffset = CGSize.zero
        glowLayer.shadowRadius = 10.0
        glowLayer.shadowOpacity = 0.0 // 最初はグローを非表示にする
        glowLayer.cornerRadius = 10
        glowLayer.masksToBounds = false
        return glowLayer
    }()
    
    ///グローアニメーションの開始
    func GrowAnimation(shouldStart: Bool) {
        if shouldStart {
            let animation = CABasicAnimation(keyPath: "shadowOpacity")
            self.backgroundColor = UIColor.white
            glowLayer.backgroundColor = UIColor.white.cgColor
            glowLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            glowLayer.bounds = self.bounds
            self.layer.insertSublayer(glowLayer, at: 0)
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.duration = 1.0
            animation.repeatCount = .infinity
            animation.autoreverses = true
            glowLayer.add(animation, forKey: "glowAnimation")
        } else {
            self.backgroundColor = UIColor(cgColor: CGColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0))
            glowLayer.backgroundColor = UIColor.clear.cgColor
            glowLayer.removeAnimation(forKey: "glowAnimation")
        }
    }
}

///画面ハイライト用オーバーレイビュークラス
class OverlayView: UIView {
    func show() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
}

///性別画像Viewカスタムクラス
class genderImageView:UIImageView {
    var gender:GENDER
    var selected:Bool = false
    var centerValue:CGPoint?
    ///どのビューで使用するか
    enum ViewType {
        case initial
        case search
    }
    init(gender: GENDER,Type:ViewType) {
        self.gender = gender
        super.init(image: nil) // 親クラスの指定イニシャライザを呼び出す
        ///ベース設定
        setting()
        ///タイプによってレイアウト振り分け
        switch Type {
        case .initial:
            self.setting()
        case .search:
            self.searchSetting()
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// レイアウト設定
    func setting() {
        self.contentMode = .scaleAspectFit
        self.clipsToBounds = true
        self.image = gender.genderImage
    }
    /// 登録時Viewでのレイアウト設定
    func initialSetting() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
    }
    /// 検索時Viewでのレイアウト設定
    func searchSetting() {

    }
}

///性別ボタンカスタムクラス
class genderButton:UIButton {
    var gender:GENDER
    var dicitionFlag:Bool = false
    init(gender: GENDER) {
        self.gender = gender
        super.init(frame: .zero)// 親クラスの指定イニシャライザを呼び出す
        self.setting()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///性別に対するタグ割り当て
    func setting() {
        self.backgroundColor = .clear
        switch gender {
        case .male:
            self.tag = 0
        case .female:
            self.tag = 1
        case .none:
            self.tag = 2
        }
    }
}

///性別テキストラベルカスタムクラス
class genderTextLabel:UILabel {
    var gender: GENDER
    
    init(gender: GENDER) {
        self.gender = gender
        super.init(frame: .zero) // 親クラスの指定イニシャライザを呼び出す
        self.setting()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// レイアウト設定
    func setting() {
        self.text = gender.genderText
        self.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        self.backgroundColor = .clear
        self.font = UIFont.systemFont(ofSize: 25)
        self.textAlignment = NSTextAlignment.center
    }
}

///イメージ名称列挙型配列
enum GENDER:Int {
    case male = 1
    case female = 2
    case none = 0
    
    var genderImage:UIImage {
        switch self {
        case .female:
            return UIImage(named: "Female")!
        case .male:
            return UIImage(named: "Male")!
        case .none:
            return UIImage(named: "Unknown")!
        }
    }
    
    var genderText:String {
        switch self {
        case .female:
            return "女性"
        case .male:
            return "男性"
        case .none:
            return "選択しない"
        }
    }
}

///年齢カスタムテキストフィールド
class AgeCustomTextField:UITextField{
    ///西暦年月日種別判断
    var birthType:birthType
    ///選択された年齢
    var selectedAge:Int?
    init(Type:birthType){
        self.birthType = Type
        super.init(frame: .zero)
        setting()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///テキストフィールドの修飾
    private func setting() {
        self.borderStyle = .roundedRect
        self.textColor = .black
        self.borderStyle = .none
        self.clearButtonMode = .always
        self.backgroundColor = .clear
        self.textAlignment = .center
        self.tintColor = UIColor.clear
        self.adjustsFontSizeToFitWidth = true
    }

}
///年齢カスタムイメージビュー
class AgeCustomImageView:UIImageView {
    ///西暦年月日種別判断
    var birthType:birthType
    
    init(Type: birthType) {
        self.birthType = Type
        super.init(image: nil) // 親クラスの指定イニシャライザを呼び出す
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///レイアウト設定
    func setting() {
        self.contentMode = .scaleAspectFit
        self.clipsToBounds = true
    }
}
///カスタム年齢データピッカー
class AgeCustomDataPickerView:UIPickerView{
    ///西暦年月日種別判断
    var birthType:birthType
    private var maxBirth:Int
    private var minBirth:Int
    
    init(Type:birthType){
        self.birthType = Type
        
        switch Type {
        ///月要素設定
        case .day:
            minBirth = 01
            maxBirth = 31
        ///日要素設定
        case .month:
            minBirth = 01
            maxBirth = 12
        ///西暦要素設定
        case .year:
            minBirth = 1950
            maxBirth = Calendar.current.component(.year, from: Date()) - 18
        }
        super.init(frame: .zero)
        setting()
    }

    ///西暦年月日格納配列
    var birthList: [Int] = []

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///配列の要素投入処理
    private func setting() {
        birthList = (minBirth...maxBirth).map { $0 }
    }
}

///Field選択状態
enum birthType{
    case year
    case month
    case day
}

///ニックネーム入力カスタムテキストフィールド
class nickNameCustomTextField:UITextField{
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setting()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///テキストフィールドの修飾
    private func setting() {
        self.textColor = .black
        self.borderStyle = .none
        self.backgroundColor = .clear
        self.textAlignment = .center
        self.attributedPlaceholder = NSAttributedString(string: "最大5文字",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.5)])
    }
}

///表題用のラベル
class CustomThemaLabel:UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        setting()
    }
    
    private func setting() {
        ///装飾
        self.backgroundColor = .clear
        self.textAlignment = .left
        self.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)   
    }
}

///検索画像イメージビュー
class CustomFilterImageView:UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setting()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setting() {
        self.image = UIImage(named: "filter02")
        self.backgroundColor = .clear
    }
    
}
enum BarButtonItemKind {
    case up
    case down
    case left
    case right
    case any(String)  // String型のプロパティを持つケース

    var ImageValue: String {
        switch self {
        case .up: return "upArrow"
        case .down: return "downArrow"
        case .left: return "leftArrow"
        case .right: return "rightArrow"
        case .any(let value): return value
        }
    }
}
class barButtonItem:UIButton {

    // 引数付きのカスタムイニシャライザ
    init(frame: CGRect, BarButtonItemKind: BarButtonItemKind) {
        super.init(frame: frame)
        setUp(ItemKind: BarButtonItemKind)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(ItemKind:BarButtonItemKind) {
        self.setImage(UIImage(named: ItemKind.ImageValue), for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
}

class LogoShowLoadingView: UIView {

    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        startLoading()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        startLoading()
    }

    private func setupViews() {
        // ローディングインジケータの設定
        self.backgroundColor = .white
        addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.gray

        // 画像の設定
        let image = UIImage(named: "appLogo")
        imageView.image = image

        addSubview(imageView)
        

        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2).isActive = true
        activityIndicator.heightAnchor.constraint(equalTo: activityIndicator.widthAnchor).isActive = true
        activityIndicator.topAnchor.constraint(equalTo: self.imageView.bottomAnchor,constant:1).isActive = true
    }

    // ローディング開始
    func startLoading() {
        activityIndicator.startAnimating()
    }

    // ローディング停止
    func stopLoading() {
        activityIndicator.stopAnimating()
    }
    
    func animateViewToCenter(callback: @escaping () -> Void) {
        // アニメーション開始前の初期位置とサイズを設定
        self.transform = CGAffineTransform(scaleX: 7.5, y: 7.5)
        
        // ズームインアニメーション
        UIView.animate(withDuration: 1.5, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.transform = CGAffineTransform(scaleX: 50, y: 50)
        }, completion: { _ in
            callback()
        })
    }
    
}
