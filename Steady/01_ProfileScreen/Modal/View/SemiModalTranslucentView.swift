//
//  SemiModalTranslucent .swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/12.
//

import Foundation
import UIKit
protocol SemiModalTranslucentViewProtcol:AnyObject {
    func TranslucentViewTappedDelegate()
}

class SemiModalTranslucentView:UIView{
    
    weak var delegate:SemiModalTranslucentViewProtcol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.frame = UIScreen.main.bounds
        // タップジェスチャーを作成し、ビューに追加する
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    // タップハンドラ関数
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.TranslucentViewTappedDelegate()
    }
    //※初期化処理※
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
