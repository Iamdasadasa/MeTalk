//
//  ProfileImageStruct.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/07/07.
//

import Foundation
import UIKit

struct ProfileImageStruct{
    var image:UIImage?
    var updataDate:Date?
    
    init(image:UIImage?,updataDate:Date?){
        self.image = image
        self.updataDate = updataDate
    }
    
}
