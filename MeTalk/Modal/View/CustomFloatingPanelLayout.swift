//
//  CustomFloatingPanelLayout.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/12.
//

import Foundation
import FloatingPanel

class CustomFloatingPanelLayout: FloatingPanelLayout {
    var position: FloatingPanelPosition {
        return .bottom
    }
    
    var initialState: FloatingPanelState {
        return .full
    }
    
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring]{
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            // ハンモーダル時のレイアウト
//            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.35, edge: .bottom, referenceGuide: .safeArea),
//            .tip: FloatingPanelLayoutAnchor(fractionalInset: 0.1, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
    
    
}
