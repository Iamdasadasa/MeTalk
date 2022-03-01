//
//  initialSettingModel.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/01/31.
//

import Foundation
import UIKit

struct ModalImageData {
    let closedImage:UIImage = {
        var returnImage = UIImage(named: "Down")!
        return returnImage
    }()
    let clearImage:UIImage = {
        var returnImage = UIImage(named: "Close")!
        return returnImage
    }()
}

