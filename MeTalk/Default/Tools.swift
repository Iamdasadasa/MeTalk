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
import FirebaseAuth
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
    case Completion(title:String,(() -> Void)) //処理完了
    case Alert(title:String,message:String,buttonMessage:String,((Bool) -> Void))      //警告
    case Options([String],((Int) -> Void))     //選択
}

func createSheet(for type: actionSheetsType,SelfViewController:UIViewController){
    switch type {
    case .Retry(let title):
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        //リトライボタン
        alert.addAction(UIAlertAction(title: "リトライ", style: .default, handler: {
            (action: UIAlertAction!) in

        }))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    case .Completion(let title,let result):
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        //OKボタン
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) in
            result()
        }))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    case .Alert(let title,let message,let buttonMessage,let result):
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        ///ボタン
        alert.addAction(UIAlertAction(title: buttonMessage, style: .default, handler: {
            (action: UIAlertAction!) in
            result(true)
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in
            result(false)  // キャンセルをfalseで返す
        }))
        //アクションシートを表示する
        SelfViewController.present(alert, animated: true, completion: nil)
    case .Options(let choices,let indexBack):
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // 選択アクションの処理
        for (index, choice) in choices.enumerated() {
            alert.addAction(UIAlertAction(title: choice, style: .default, handler: { _ in
                indexBack(index)  // 選択された項目のインデックスをコールバックで返す
            }))
        }
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in
            indexBack(-1)  // キャンセルをコールバックで返す（例として-1とする）
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

///所在パス生成
struct PathCreate {
    ///画像データ
    func imagePathCreate(UID:String) -> URL {
        let fileName = "\(UID)_profileimage.png"
        var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(fileName)

        return documentDirectoryFileURL
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
    
    ///日付変換の基本定義
    private let formatter = DateFormatter()
    public func string(from date: Date) -> String {
        configureDateFormatter(for: date)
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    private func configureDateFormatter(for date: Date) {
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
    
    ///
//    public func attributedString(from date: Date, with attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
//        let dateString = string(from: date)
//        return NSAttributedString(string: dateString, attributes: attributes)
//    }
    
    /// 日付の種類
    enum DateFormatt:String {
        case HM = "HH:mm"
        case YMDHMS = "yyyy/MM/dd/HH:mm:ss"
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
            dateFormatter.dateFormat = formatFlg.rawValue
        case .YMDHMS:
            dateFormatter.dateFormat = formatFlg.rawValue
        }
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
    /// 指定された時間より60分経ってるか
    /// - Parameter pushTime: 指定時間
    /// - Returns: 経っている場合か否かのBool値
    func pushTimeDiffDate(pushTime: Date) -> Bool {
        let minute = round(Date().timeIntervalSince(pushTime) / 60)
        return minute <= 60
    }
}

struct sizeAdjust {
    static func objecFontSizeAutoResize(MaxCharacterDigit:Int,objectWidth:CGFloat) -> CGFloat {
        // 最大文字サイズの計算(半角の場合は２倍の文字で計算してもいいと思う)
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
    
    static func calculateTimeDisplay(from date: Date) -> String {
        let now = Date()
        let calendar = Calendar(identifier: .japanese)
        let NowDate = calendar.startOfDay(for: now)
        let vauleDate = calendar.startOfDay(for: date)
        let nowYear = calendar.component(.year, from: now)
        let valueYear = calendar.component(.year, from: date)
        let components = calendar.dateComponents([.year, .month, .day,.hour], from: vauleDate, to:NowDate )
        if nowYear - valueYear > 0 {
            return formatDate(date, format: "yyyy/MM/dd")
        } else if let day = components.day,let year = components.year, year == 0  && day >= 7{
            return formatDate(date, format: "MM/dd")
        } else if let day = components.day, day >= 2 && day <= 6 {
            return formatWeekday(date)
        } else if let day = components.day, day == 1 {
            return "昨日"
        } else {
            return formatTime(date)
        }
    }

    private static func formatDate(_ date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    private static func formatWeekday(_ date: Date) -> String {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let weekdays = ["", "日", "月", "火", "水", "木", "金", "土"]
        return weekdays[weekday] + "曜日"
    }

    private static func formatTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
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

///エラー種別
enum ErrType{
    case InvalidSelfData
    case targetDataFailedData
    case likeButtonInvalid
}

/// ネットワークエラー処理
/// - Parameter Type: エラー種別
func err(Type:ErrType,TargetVC:UIViewController) {
    switch Type {
    ///不正データ
    case .InvalidSelfData:
        createSheet(for: .Completion(title: "あなたのデータは不正です。再度登録を行なってください。アプリを終了します。", {
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print("SignOut Error: %@", signOutError)
            }
            preconditionFailure("強制退会")
        }), SelfViewController: TargetVC)
    ///ユーザー取得リトライ
    case .targetDataFailedData:
        createSheet(for: .Retry(title: "ユーザーの取得に失敗しました。もう一度お試しください"), SelfViewController: TargetVC)
    ///ボタン押下リトライ
    case .likeButtonInvalid:
        createSheet(for: .Retry(title: "相手にライクを送れせんでした。もう一度お試しください"), SelfViewController: TargetVC)
    }
}

