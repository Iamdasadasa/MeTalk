//
//  AdminViewModel.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/10/27.
//

import Foundation
//このビューコントローラがメインで使用するデータ構造体（Nil無し）
class RequiredReportMemberInfoLocalData {
    init(ReportDetail:String,reportTime:Date,reportingUID:String,
         reportedUID:String,reportingFlag: Bool,reportingRoomID:String,reportID:String){
        self.Required_ReportDetail = ReportDetail
        self.Required_reportTime = reportTime
        self.Required_reportingUID = reportingUID
        self.Required_reportedUID = reportedUID
        self.Required_reportingFlag = reportingFlag
        self.Required_roomID = reportingRoomID
        self.Required_reportID = reportID
    }
    var Required_ReportDetail: String
    var Required_reportTime: Date
    var Required_reportingUID:String
    var Required_reportedUID:String
    var Required_reportingFlag: Bool
    var Required_roomID:String
    var Required_reportID:String
}
