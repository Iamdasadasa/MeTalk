//
//  ReportView.swift
//  MeTalk
//
//  Created by KOJIRO MARUYAMA on 2023/10/12.
//

import Foundation
import UIKit

protocol ReportViewDelegateProtcol:AnyObject {
    func dicitionButtontappedAction(reportDetail:ReportReason)
}

class ReportView:UIView{
    lazy var reportDetailSelected:ReportReason = {
        return pickerReportList.first ?? .spam
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        autoLayoutSetUp()
        autoLayout()
        pickerSetting()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        ///本文の文字サイズ調整
        let sentenceFontSize = sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 14, objectWidth: reportMainSentenceLabel.bounds.width)
        reportMainSentenceLabel.font = UIFont.boldSystemFont(ofSize: sentenceFontSize)
        ///説明文の文字サイズ調整
        let explainFontSize = sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 28, objectWidth: reportExplainLabel.bounds.width)
        reportExplainLabel.font = UIFont.boldSystemFont(ofSize: explainFontSize)
        let aboutInfoFontSize = sizeAdjust.objecFontSizeAutoResize(MaxCharacterDigit: 28, objectWidth: reportAboutInfoLabel.bounds.width)
        reportAboutInfoLabel.font = UIFont.boldSystemFont(ofSize: aboutInfoFontSize)

        ///陰影ビューの影付与設定
        shadowView.shadowSetting(offset: .buttomReft)

    }
    weak var delegate: ReportViewDelegateProtcol?    ///デリゲート変数
    var reportTitleLabel:UILabel = {    ///通報タイトルラベル
        var UILabel = UILabel()
        UILabel.text = "通報"
        UILabel.textColor = .gray
        return UILabel
    }()
    
    var reportMainSentenceLabel:UILabel = {
        var UILabel = UILabel()
        UILabel.text = "通報理由の選択"
        UILabel.textColor = .black
        return UILabel
    }()
    
    var reportExplainLabel:UILabel = {  ///通報説明ラベル
        var UILabel = UILabel()
        UILabel.text = "通報を行った場合、運営側での調査が行われ、\n" + "違反行為が発覚した場合に凍結、警告等の措置が当該アカウントに行われます。"
        UILabel.textColor = .gray
        UILabel.numberOfLines = 0
        return UILabel
    }()
    
    var reportAboutInfoLabel:UILabel = {  ///通報情報についてのラベル
        var UILabel = UILabel()
        UILabel.text = "■情報について\n" +
        "|各アカウント情報が運営側に送信されます。\n" +
        "|トーク履歴が運営側に送信されます。"
        UILabel.textColor = .gray
        UILabel.numberOfLines = 0
        return UILabel
    }()
    let pickerReportList:[ReportReason] = {
        var list = ReportReason.allCases.map { $0 }
        return list
    }()

    var shadowView:ShadowBaseView = ShadowBaseView()    ///陰影表現のView
    let dicisionButton:UIButton = { ///決定ボタン
        let Button = UIButton()
        Button.setTitle("通報する", for: .normal)
        Button.setTitleColor(UIColor.gray, for: .normal)
        Button.backgroundColor = .white
        Button.addTarget(self, action: #selector(dicisionButtontapped(_:)), for: .touchUpInside)
        return Button
    }()
    ///決定ボタン押下時の挙動デリゲート
    @objc func dicisionButtontapped(_ sender: UIButton){
        delegate?.dicitionButtontappedAction(reportDetail: reportDetailSelected)
    }
    
    var reportPickerView:UIPickerView = UIPickerView()
    ///
    //※レイアウト設定※
    func autoLayoutSetUp() {
        ///各オブジェクトをViewに追加
        addSubview(reportTitleLabel)
        addSubview(reportExplainLabel)
        addSubview(reportAboutInfoLabel)
        addSubview(reportMainSentenceLabel)
        addSubview(reportPickerView)
        addSubview(shadowView)
        addSubview(dicisionButton)
        ///UIオートレイアウトと競合させない処理
        reportTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        reportExplainLabel.translatesAutoresizingMaskIntoConstraints = false
        reportAboutInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        reportMainSentenceLabel.translatesAutoresizingMaskIntoConstraints = false
        reportPickerView.translatesAutoresizingMaskIntoConstraints = false
        dicisionButton.translatesAutoresizingMaskIntoConstraints = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //※レイアウト※
    func autoLayout() {
        reportTitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        reportTitleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        reportTitleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.05).isActive = true
        reportTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
    
        reportMainSentenceLabel.topAnchor.constraint(equalTo: reportTitleLabel.bottomAnchor, constant: 25).isActive = true
        reportMainSentenceLabel.widthAnchor.constraint(equalTo: reportPickerView.widthAnchor).isActive = true
        reportMainSentenceLabel.heightAnchor.constraint(equalTo: reportPickerView.heightAnchor, multiplier: 0.3).isActive = true
        reportMainSentenceLabel.leadingAnchor.constraint(equalTo: reportPickerView.leadingAnchor).isActive = true
        
        reportPickerView.topAnchor.constraint(equalTo: self.reportMainSentenceLabel.bottomAnchor,constant: 5).isActive = true
        reportPickerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        reportPickerView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        reportPickerView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.3).isActive = true

        reportExplainLabel.topAnchor.constraint(equalTo: reportPickerView.bottomAnchor, constant: 5).isActive = true
        reportExplainLabel.leadingAnchor.constraint(equalTo: reportMainSentenceLabel.leadingAnchor).isActive = true
        reportExplainLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        reportExplainLabel.heightAnchor.constraint(equalTo: reportMainSentenceLabel.heightAnchor).isActive = true
        
        reportAboutInfoLabel.topAnchor.constraint(equalTo: reportExplainLabel.bottomAnchor, constant: 5).isActive = true
        reportAboutInfoLabel.leadingAnchor.constraint(equalTo: reportExplainLabel.leadingAnchor).isActive = true
        reportAboutInfoLabel.trailingAnchor.constraint(equalTo: reportExplainLabel.trailingAnchor).isActive = true
        reportAboutInfoLabel.heightAnchor.constraint(equalTo: reportExplainLabel.heightAnchor).isActive = true
        
        dicisionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dicisionButton.topAnchor.constraint(equalTo: reportAboutInfoLabel.bottomAnchor,constant: 25).isActive = true
        dicisionButton.widthAnchor.constraint(equalTo: reportAboutInfoLabel.widthAnchor,multiplier: 0.4).isActive = true
        dicisionButton.heightAnchor.constraint(equalTo: reportAboutInfoLabel.heightAnchor,multiplier: 0.6).isActive = true
        
        shadowView.centerXAnchor.constraint(equalTo: dicisionButton.centerXAnchor).isActive = true
        shadowView.topAnchor.constraint(equalTo: dicisionButton.topAnchor).isActive = true
        shadowView.widthAnchor.constraint(equalTo: dicisionButton.widthAnchor).isActive = true
        shadowView.heightAnchor.constraint(equalTo: dicisionButton.heightAnchor).isActive = true
    }
}
//ライン引き
extension ReportView {
    ///本文下の枠線を自作
    override func draw(_ rect: CGRect) {
        // UIBezierPath のインスタンス生成
        let line = UIBezierPath();
        // 起点
        line.move(to: CGPoint(x: self.reportMainSentenceLabel.frame.minX, y: self.reportMainSentenceLabel.frame.maxY));
        // 帰着点
        line.addLine(to: CGPoint(x: self.reportMainSentenceLabel.frame.maxX, y: self.reportMainSentenceLabel.frame.maxY));
        // ラインを結ぶ
        line.close()
        // 色の設定
        UIColor.gray.setStroke()
//        UIColor.init(red: 50, green: 50, blue: 50, alpha: 100).setStroke()
        // ライン幅
        line.lineWidth = 1
        // 描画
        line.stroke();
    }
}


//ピッカー設定
extension ReportView:UIPickerViewDelegate,UIPickerViewDataSource {
    func pickerSetting() {
        reportPickerView.delegate = self
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerReportList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerReportList[row].rawValue
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 選択内容を更新
        reportDetailSelected = pickerReportList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = pickerReportList[row].rawValue
        let color = UIColor.black  // ここで色を変更

        return NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
}
