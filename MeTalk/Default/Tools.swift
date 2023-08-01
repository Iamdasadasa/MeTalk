//
//  NetworkConf.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2022/10/21.
//

import Foundation
import Reachability
import UIKit
import FirebaseFirestore
import RangeUISlider
///ネットワーク状況判断
struct Reachabiliting{
    func NetworkStatus() -> Int {
        let REACHABILITING = try! Reachability()
        switch REACHABILITING.connection {
        case .wifi:
            return 1
        case .cellular:
            return 2
        case .unavailable:
            return 0
        case .none:
            return 0
        }
    }
}

enum actionSheetsType {
    case Retry(title:String)      //リトライ
    case Completion(title:String) //処理完了
    case Alert(title:String,message:String,buttonMessage:String)      //警告
    case Options([String],((Int) -> Void))     //選択
}


func createSheet(callback:@escaping()-> Void,for type: actionSheetsType,SelfViewController:UIViewController){
    switch type {
    case .Retry(let title):
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        //リトライボタン
        alert.addAction(UIAlertAction(title: "リトライ", style: .default, handler: {
            (action: UIAlertAction!) in
            callback()
        }))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    case .Completion(let title):
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        //OKボタン
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) in
            callback()
        }))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    case .Alert(let title,let message,let buttonMessage):
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        ///ボタン
        alert.addAction(UIAlertAction(title: buttonMessage, style: .default, handler: {
            (action: UIAlertAction!) in
            callback()
        }))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    case .Options(let choices,let callback):
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // 選択アクションの処理
        for (index, choice) in choices.enumerated() {
            alert.addAction(UIAlertAction(title: choice, style: .default, handler: { _ in
                callback(index)  // 選択された項目のインデックスをコールバックで返す
            }))
        }
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in
            callback(-1)  // キャンセルをコールバックで返す（例として-1とする）
        }))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    }
}

struct LOADING {
    let loadingView:LoadingView
    init(loadingView:LoadingView,BackClear:Bool) {
        if BackClear {
            loadingView.backgroundColor = .clear
            loadingView.activityIndicator.color = UIColor.gray
        } else {
            loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            loadingView.activityIndicator.color = UIColor.white
        }

        self.loadingView = loadingView
    }

    func loadingViewIndicator(isVisible:Bool){
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        isVisible ? window?.addSubview(loadingView) : loadingView.removeFromSuperview()
    }
}

struct TIME {
    ///過去時間を持ってくる関数
    func pastTimeGet() -> Date{
        
        let calendar = Calendar(identifier: .gregorian)
        let date = Date()
        let modifiedDate = calendar.date(byAdding: .day, value: -10000, to: date)!
        
        return modifiedDate
        
    }
}

struct chatTools {
    ///ChatのルームIDを生成する
    func roomIDCreate(UID1:String,UID2:String) -> String{
        let array = [UID1,UID2]
        let sortArray = array.sorted()
        let roomID:String = sortArray[0] + "_" + sortArray[1]
        return roomID
    }
}

struct TimeTools {
    private let formatter = DateFormatter()
    public func string(from date: Date) -> String {
        configureDateFormatter(for: date)
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    public func attributedString(from date: Date, with attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let dateString = string(from: date)
        return NSAttributedString(string: dateString, attributes: attributes)
    }

    public func configureDateFormatter(for date: Date) {
        switch true {
        case Calendar.current.isDateInToday(date) || Calendar.current.isDateInYesterday(date):
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .short
            formatter.timeStyle = .none
        default:
//            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy/MM/dd"
        }
    }
    
    enum DateFormatt {
        case HM
        case YMDHMS
    }
    ///Date⇨String
    func dateToStringFormatt(date:Date?,formatFlg:DateFormatt) -> String{
        guard let date = date else {
            print("日付変換に失敗しました。")
            return "0000/00/00"
        }
        let dateFormatter = DateFormatter()

        // フォーマット設定
        switch formatFlg{
        case .HM:
            dateFormatter.dateFormat = "HH:mm"
        case .YMDHMS:
            dateFormatter.dateFormat = "yyyy/MM/dd/HH:mm:ss"
        }
        //dateFormatter.dateFormat = "yyyyMMddHHmmssSSS" // ミリ秒込み

        // ロケール設定（端末の暦設定に引きづられないようにする）
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        // タイムゾーン設定（端末設定によらず固定にしたい場合）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        // 変換
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    ///String⇨Date
    func stringToDateFormatte(date:String) -> Date{
        // Date ⇔ Stringの相互変換をしてくれるすごい人
        let dateFormatter = DateFormatter()
        // フォーマット設定
        dateFormatter.dateFormat = "yyyy/MM/dd/HH:mm:ss"
        //dateFormatter.dateFormat = "yyyyMMddHHmmssSSS" // ミリ秒込み

        // ロケール設定（端末の暦設定に引きづられないようにする）
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        // タイムゾーン設定（端末設定によらず、どこの地域の時間帯なのかを指定する）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        //dateFormatter.timeZone = TimeZone(identifier: "Etc/GMT") // 世界標準時

        // 変換
        let date = dateFormatter.date(from: date)

        return date!
    }
    ///Date→TimeStamp
    func convertToTimestamp(date: Date) -> Timestamp {
        return Timestamp(date: date)
    }
}

struct sizeAdjust {
    static func objecFontSizeAutoResize(MaxCharacterDigit:Int,objectWidth:CGFloat) -> CGFloat {
        // 最大文字サイズの計算
        let textFieldWidth = objectWidth
        let characterWidth = textFieldWidth / CGFloat(MaxCharacterDigit)
        let maximumFontSize = UIFont.systemFont(ofSize: 1).pointSize * characterWidth
        return maximumFontSize
    }
}

struct AgeCalculator {
    private static let YearToDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMdd"
        return formatter
    }()
    
    /// 西暦を年齢　西暦を年齢に変換(string To string)
    static func calculateAge(from dateString: String) -> String {
        if let dateOfBirth = YearToDateFormatter.date(from: dateString) {
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
            if let age = ageComponents.year {
                return "\(age)歳"
            }
        }
        return "未設定"
    }
    
    /// 西暦を年齢　西暦を年齢に変換(Int To Int)
    static func calculateAge(from yearOfBirth: Int) -> Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let age = currentYear - yearOfBirth
        return age
    }
    enum minOrNow {
        case min
        case max
    }
    
    
    /// 西暦から検索用の年月日に変換
    /// - Parameters:
    ///   - targetYearToDate: 月日を追加したい西暦
    ///   - minOrMax: 最小年齢か最大年齢か
    /// - Returns: 西暦に正しい月を追加した年月日
    static func convertDefaultYearOfBirth(targetYear:Int,minOrMax:minOrNow) -> Int {
        var convertedYearToDate:String
        if minOrMax == .min {
            let NowDate = dateFormatter.string(from: Date())
            convertedYearToDate = String(targetYear) + NowDate
        } else {
            let tomorrowDate = dateFormatter.calendar.date(byAdding: .day, value: 1, to: Date())
            let tomorrowString = dateFormatter.string(from: tomorrowDate!)
            
            convertedYearToDate = String(targetYear - 1) + tomorrowString
        }
        ///桁数チェック
        if convertedYearToDate.count > 9 {
            return targetYear
        }
        return Int(convertedYearToDate)!
    }
    
    /// 検索用の年月日から西暦に変換
    /// - Parameters:
    ///   - targetYearToDate: 月日を追加したい西暦
    ///   - minOrMax: 最小年齢か最大年齢か
    /// - Returns: 西暦に正しい月を追加した年月日
    static func conbertDefaultYear(targetYearOfBirth:Int,minOrMax:minOrNow) -> Int {
        var convertedYear:Int
        if minOrMax == .min {
            ///後方4桁を削除
            convertedYear = targetYearOfBirth / 10000
        } else {
            convertedYear = targetYearOfBirth / 10000
            convertedYear = convertedYear + 1
        }
        return convertedYear
    }
    
}
///時間を適切な文言に変換
struct TimeCalculator {
    private static var calendar = Calendar.current

    static func calculateRemainingTime(from date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)

        if let year = components.year, year > 0 {
            return "\(year)年"
        } else if let month = components.month, month > 0 {
            return "\(month)ヶ月"
        } else if let day = components.day, day > 0 {
            return "\(day)日"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)時間"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)分"
        } else if let second = components.second, second >= 5 {
            return "\(second)秒"
        }
        return "今"
    }
}
///60秒前の時間を取得
struct AgoDateGetter {
    
    static func oneMinuteAgo() -> Date {
        let day = Date()
        let modifiedDate = Calendar.current.date(byAdding: .minute, value: -1, to: day)
        
        if let modifiedDate = modifiedDate {
            return modifiedDate
        }
        return Date()
    }
}
///カスタム年齢スライダー
class CustomAgeSlider:RangeUISlider {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setting()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setting() {
        let grayColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        self.scaleMinValue = 18
        self.scaleMaxValue = 100
        self.defaultValueLeftKnob = 18
        self.defaultValueRightKnob = 100
        self.leftKnobColor = .clear
        self.leftShadowColor = .black
        self.leftShadowOffset = CGSize(width: -3, height: 3)
        self.leftKnobBorderColor = .gray
        self.leftKnobBorderWidth = 1
        self.rightKnobColor = .clear
        self.rightShadowColor = .black
        self.rightShadowOffset = CGSize(width: -3, height: 3)
        self.rightKnobBorderColor = .gray
        self.rightKnobBorderWidth = 1
        self.showKnobsLabels = true
        self.knobsLabelNumberOfDecimal = 0
        self.stepIncrement = 1
        self.rangeSelectedColor = .gray
        self.rangeNotSelectedColor = grayColor
        self.barHeight = 1.5
        self.knobsLabelFontColor = .gray
    }
}

///検索用ピッカー
class SearchCustomPicker:UIPickerView {
    enum pickerType {
        case area
    }
    
    var list:[String] = []
    
    init(Type: pickerType) {
        super.init(frame: .zero)
        setting(Type: Type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setting(Type:pickerType) {
        switch Type {
        case .area:
            list = ["未設定",
                    "北海道", "青森", "岩手", "宮城", "秋田", "山形", "福島", "茨城", "栃木", "群馬",
                    "埼玉", "千葉", "東京", "神奈川", "新潟", "富山", "石川", "福井", "山梨", "長野",
                    "岐阜", "静岡", "愛知", "三重", "滋賀", "京都", "大阪", "兵庫", "奈良", "和歌山",
                    "鳥取", "島根", "岡山", "広島", "山口", "徳島", "香川", "愛媛", "高知", "福岡",
                    "佐賀", "長崎", "熊本", "大分", "宮崎", "鹿児島", "沖縄"]
        }
    }
}
