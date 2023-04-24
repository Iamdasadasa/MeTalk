//
//  initialSettingGenderSelectViewController.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/04/18.
//

import Foundation
import UIKit

class initialSettingGenderSelectionViewController:UIViewController {
    
    let GenderSelectionView = initialSettingGenderSelectionView()
    
    override func viewDidLoad() {
        self.view = GenderSelectionView
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
}
