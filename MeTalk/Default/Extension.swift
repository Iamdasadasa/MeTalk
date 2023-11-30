//
//  Extension.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/10/18.
//

import Foundation
import UIKit
import RealmSwift

extension UIView {
    // childViewを親Viewに目一杯addSubView()する
    func addSubViewFill(_ childView: UIView) {
        self.addSubview(childView)
        childView.translatesAutoresizingMaskIntoConstraints = false
        childView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        childView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        childView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        childView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
    ///背景画像を画面一杯に指定する
    /// レイアウト全般処理
    func backGroundViewImageSetUp(imageName:String) {
        ///背景画像設定
        // スクリーンサイズの取得
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        // スクリーンサイズにあわせてimageViewの配置
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let backgroundImage = UIImage(named: imageName)
        imageViewBackground.image = backgroundImage
        imageViewBackground.contentMode = .scaleAspectFill
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
}

extension UIViewController:UIGestureRecognizerDelegate {
    
    enum gestureDirection {
        case left
        case right
    }
    
    func edghPanGestureSetting (selfVC:UIViewController,selfView:UIView,gestureDirection:gestureDirection) {
        switch gestureDirection {
        case .left:
            // UIScreenEdgePanGestureRecognizerを作成
            let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleLeftEdgePan(_:)))
            edgePanGesture.edges = .left // 画面左端からのスワイプを検出
            edgePanGesture.delegate = selfVC // デリゲートを設定
            // ビューにジェスチャーを追加
            selfView.addGestureRecognizer(edgePanGesture)
        case .right:
            // UIScreenEdgePanGestureRecognizerを作成
            let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleRightEdgePan(_:)))
            edgePanGesture.edges = .right // 画面右端からのスワイプを検出
            edgePanGesture.delegate = selfVC // デリゲートを設定
            // ビューにジェスチャーを追加
            selfView.addGestureRecognizer(edgePanGesture)
        }

    }
    
    @objc func handleLeftEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        ///チャット画面の時だけセルのリロード処理
        if let CHATVC = self as? ChatViewController  {
            CHATVC.listViewControllerDelegateAction()
        }
        if gesture.state == .recognized {
            // スワイプが検出された場合の処理
            self.dismiss(animated: true, completion: nil)
            self.slideOutToLeft()
        }
    }
    
    @objc func handleRightEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            // スワイプが検出された場合の処理
            self.dismiss(animated: true, completion: nil)
            self.slideInFromRight()
        }
    }
    
    func slideInFromBottom() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window?.layer.add(transition, forKey: kCATransition)
    }

    func slideOutToTop() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        self.view.window?.layer.add(transition, forKey: kCATransition)
    }
    
    func slideOutToLeft() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window?.layer.add(transition, forKey: kCATransition)
    }
    
    func slideInFromRight() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window?.layer.add(transition, forKey: kCATransition)
    }
}

//extension UITextField {
//    func textFieldFontSizeAutoResize(MaxCharacterDigit:Int) {
//        // 最大文字サイズの計算
//        let textFieldWidth = self.bounds.width
//        let characterWidth = textFieldWidth / CGFloat(MaxCharacterDigit)
//        let maximumFontSize = UIFont.systemFont(ofSize: 1).pointSize * characterWidth
//        self.font = UIFont.systemFont(ofSize: maximumFontSize)
//    }
//}

extension String {
    enum birthStringType{
        case EightDigit
        case YearsOld
    }
    func convertToFormattedDateString(targetAgeString:String,Type:birthStringType) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        if let birthDate = dateFormatter.date(from: targetAgeString) {
            let formattedString = dateFormatter.string(from: birthDate)
            return formattedString
        } else {
            return nil
        }
    }
    
    enum birthIntType{
        case EightDigit
        case YearsOld
    }
    
    func convertToFormattedDateInt(targetAgeString:String,Type:birthIntType) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"

        if let date = dateFormatter.date(from: targetAgeString) {
            let modifiedDateFormatter = DateFormatter()
            modifiedDateFormatter.dateFormat = "yyyyMMdd"
            let modifiedDateString = modifiedDateFormatter.string(from: date)

            if let modifiedDate = Int(modifiedDateString) {
                return modifiedDate
            }
        }
        return nil
    }
    
}

extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            print("トランザクションが存在しています")
        } else {
            print("トランザクションは存在していません")
        }
    }
}

extension UIImage {

    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    func tabbarImageResized(to targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)

        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    enum imageKind:String{
        case selectedTalk
        case selectedCHAT
        case selectedPROFILE
        case nonSelectedTalk
        case nonSelectedCHAT
        case nonSelectedPROFILE
        case selectedChatNotification
        case nonSelectedChatNortification
        
        var ImageName:String {
            switch self {
            case .selectedTalk:
                return "TAB_TALK"
            case .selectedCHAT:
                return "TAB_CHAT"
            case .selectedPROFILE:
                return "TAB_PROFILE"
            case .nonSelectedTalk:
                return "TAB_TALK_Non"
            case .nonSelectedCHAT:
                return "TAB_CHAT_Non"
            case .nonSelectedPROFILE:
                return "TAB_PROFILE_Non"
            case .selectedChatNotification:
                return "TAB_CHAT_Nor"
            case .nonSelectedChatNortification:
                return "TAB_CHAT_Non_Nor"
            }
        }
    }
    
    func tabBarImageCreate(KIND:imageKind) ->UIImage? {
        ///選択されていない時（デフォルト）の画像
        var targetImage = UIImage(named: KIND.ImageName)
        ///サイズ設定
        targetImage = targetImage?.tabbarImageResized(to: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysOriginal)
        return targetImage
    }
    
}
