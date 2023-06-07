//
//  initialSettingModel.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/01/31.
//

import Foundation
import UIKit

struct InitialSettingData {
    let maleOrangeImage:UIImage = {
        var returnImage = UIImage(named: "Male_Orange")!
        return returnImage
    }()
    let maleBlackImage:UIImage = {
        var returnImage = UIImage(named: "Male_Black")!
        return returnImage
    }()
    let femaleOrangeImage:UIImage = {
        var returnImage = UIImage(named: "Female_Orange")!
        return returnImage
    }()
    let femaleBlackImage:UIImage = {
        var returnImage = UIImage(named: "Female_Black")!
        return returnImage
    }()
    let unknownSexBlackImage:UIImage = {
        var returnImage = UIImage(named: "Unknown_Sex_Black")!
        return returnImage
    }()
    let unknownSexOrangeImage:UIImage = {
        var returnImage = UIImage(named: "Unknown_Sex_Orange")!
        return returnImage
    }()
}

struct initialProfileInfo {
    var nickName:String?
    var Age:String?
    var gender:GENDER?
}
