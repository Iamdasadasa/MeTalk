//
//  NotificationController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/03/08.
//

import Foundation
import UIKit

class NotificationController:UINavigationController{
    
    ///インスタンス化（View）
    let notificationView = NotificationView()
    override func viewDidLoad() {
        super.viewDidLoad()
        ///Viewの適用
        self.view = notificationView
    }
    
}
