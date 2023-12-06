//
//  CustomFloatingPanelLayout.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/12.
//

import Foundation
import FloatingPanel

class CustomFloatingPanelLayout: FloatingPanelLayout {
    var state:FloatingPanelState
    init(initialState:FloatingPanelState) {
        self.state = initialState
    }
    
    var position: FloatingPanelPosition {
        return .bottom
    }
    
    var initialState: FloatingPanelState {
        return state
    }
    
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring]{
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 50.0, edge: .top, referenceGuide: .safeArea),
            // 半モーダル時のレイアウト
            .half: FloatingPanelLayoutAnchor(absoluteInset: 500.0, edge: .top, referenceGuide: .safeArea)
        ]
    } 
}
