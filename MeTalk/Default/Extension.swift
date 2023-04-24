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
}
