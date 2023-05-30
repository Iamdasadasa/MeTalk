//
//  Extension.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/10/18.
//

import Foundation
import UIKit

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

extension UIViewController {
    func slideInFromBottom() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: kCATransition)
    }

    func slideOutToTop() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        self.view.window!.layer.add(transition, forKey: kCATransition)
    }
    
    func slideOutToLeft() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
    }
    
    func slideInFromRight() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
    }
}
