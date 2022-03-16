//
//  SemiModalTranslucent .swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/12.
//

import Foundation
import UIKit

class SemiModalTranslucentView:UIView{
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            self.frame = UIScreen.main.bounds
        }
    //※初期化処理※
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
