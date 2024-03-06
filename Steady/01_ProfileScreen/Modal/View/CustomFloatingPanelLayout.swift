//
//  CustomFloatingPanelLayout.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/02/12.
//

import Foundation
import FloatingPanel

//モーダルの種類
enum modalKind {
    case profileEdit
    case report
}

class CustomFloatingPanelLayout: FloatingPanelLayout {
    var state:FloatingPanelState
    var kind:modalKind
    
    init(initialState:FloatingPanelState,kind:modalKind) {
        self.state = initialState
        self.kind = kind
    }
    
    
    var position: FloatingPanelPosition {
        return .bottom
    }
    
    var initialState: FloatingPanelState {
        return state
    }
    
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring]{
        if kind == .report {
            return [
                .full: FloatingPanelLayoutAnchor(absoluteInset: 50.0, edge: .top, referenceGuide: .safeArea),
                // 半モーダル時のレイアウト
                .half: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .safeArea)
            ]
            
        } else {
            return [
                .full: FloatingPanelLayoutAnchor(absoluteInset: 50.0, edge: .top, referenceGuide: .safeArea),
                // 半モーダル時のレイアウト
                .half: FloatingPanelLayoutAnchor(absoluteInset: 500.0, edge: .top, referenceGuide: .safeArea)
            ]
        }

    } 
}
