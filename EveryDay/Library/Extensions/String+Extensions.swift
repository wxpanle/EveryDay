//
//  String+Extensions.swift
//  EveryDay
//
//  Created by pl on 2021/6/10.
//

import Foundation
import UIKit

/// substring
extension String {
    
    /// substring with range. If range is illeagal, return nil
    ///
    /// - Parameter range: indicate start and end. like 0..<2
    /// - Returns: sub or nil
    public func substring(range: Range<Int>) -> String? {
        return substring(from: range.lowerBound, to: range.upperBound)
    }
    
    /// substring from index
    public func substring(from: Int) -> String? {
        return substring(from: from, to: self.count)
    }
    
    /// substring with end index of (to - 1), from 0
    public func substring(to: Int) -> String? {
        return substring(from: 0, to: to)
    }
    
    private func substring(from: Int, to: Int) -> String? {
        guard from >= 0, to <= self.count, from < to else { return nil }
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[fromIndex..<toIndex])
    }
}

/// size
extension String {
    public func width(font: UIFont, maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGFloat {
        return self.size(font: font, maxWidth: maxWidth).width
    }
    
    public func height(font: UIFont, maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGFloat {
        return self.size(font: font, maxWidth: maxWidth).height
    }
    
    public func size(font: UIFont, maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        guard self.count > 0 else {
            return .zero
        }
        
        var strSize = NSString.init(string: self).boundingRect(with: .init(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [.font: font], context: nil).size
        
        strSize.width = min(strSize.width, maxWidth)
        
        return CGSize.init(width: ceil(strSize.width), height: ceil(strSize.height))
    }
    
    public func size(font: UIFont, maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude, maxRowNumber: Int) -> CGSize {
        var strSize = self.size(font: font, maxWidth: maxWidth)
        let maxLineHeight = ceil(Double(maxRowNumber) * Double(font.lineHeight))
        if Double(strSize.height) > maxLineHeight {
            strSize.height = CGFloat(maxLineHeight)
        }
        return strSize
    }
}

/// URL
extension String {
    public func URLEncode() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.sf_urlQueryNotAllowed.inverted)
    }
    
    public  func URLString(urlParams: Dictionary<String, CustomStringConvertible>?) -> String {
        guard let params = urlParams, !params.isEmpty else { return self }
        let joinFlag = self.contains("?") ? "&" : "?"
        return self + joinFlag + CombinedURLString(params: params)
    }
    
    public func urlParams() -> Dictionary<String, Any>? {
        guard let url = URL.init(string: self) else { return nil }
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems
        let queryParameters = queryItems?.reduce(into: [:], { (theParameters, item) in
            theParameters[item.name] = item.value
        })
        return queryParameters
    }
}

/// isdigit
extension String {
    /// 校验字符串 是否为十进制数字字符
    public func isdigit() -> Bool {
        let scan: Scanner = Scanner(string: self)
        var val: Int = 0
        if scan.scanInt(&val) && scan.isAtEnd {
            return true
        } else {
            return false
        }
    }
}

/// Email
extension String {
    /// 校验字符串 是否邮箱格式
    public func validateEmail() -> Bool {
        guard let expression = try? NSRegularExpression(pattern: "^([a-zA-Z0-9]+([._\\-])*[a-zA-Z0-9]*)+@([a-zA-Z0-9])+(.([a-zA-Z])+)+$", options: .caseInsensitive) else {
            return false
        }
        let matches = expression.matches(in: self, range: NSRange(location: 0, length: self.count))
        if matches.count > 0 {
            return true
        } else {
            return false
        }
    }
}

/// Id Card
public extension String {
    /// 是否为身份证号格式(18位)
    func validateIdCardNo() -> Bool {
        /// 位数判断
        if self.count != 18 {
            return false
        }
        
        /// 格式校验
        let predictStr = """
                         ^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$
                         """
        let predict = NSPredicate(format: "SELF MATCHES %@", predictStr)
        if !predict.evaluate(with: self) {
            return false
        }
        
        /// 加权因子
        let weightedItems = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        
        /// 位数校验码
        let checkNums = ["1", "0", "10", "9", "8", "7", "6", "5", "4", "3", "2"]
        
        /// 前十七位乘以加权因子的总和
        var weightedNum = 0
        for i in 0..<17 {
            let item = self.substring(range: Range(NSRange(location: i, length: 1))!)
            weightedNum += (Int(item!)! * weightedItems[i])
        }
        
        /// 根据加权因子推算的最后一位在位数校验码数组中的位置
        let checkedLastIndex = weightedNum % 11
        /// 待校验身份证最后一位
        let uncheckLast = self.substring(from: 17)
        
        /// 如果 index 为 2，身份证最后一位应该是 "x"
        if checkedLastIndex == 2 {
            if uncheckLast != "x" && uncheckLast != "X" {
                return false
            }
        } else {
            if uncheckLast != checkNums.at(checkedLastIndex) {
                return false
            }
        }
        
        return true
    }
    
    /// 根据身份证号判断是否为男性
    ///
    /// - Returns: 非身份证号格式返回 nil
    func isMale() -> Bool? {
        if !self.validateIdCardNo() {
            return nil
        }
        guard let genderStr = self.substring(range: Range(NSRange(location: 16, length: 1))!),
            let genderInt = Int(genderStr) else { return nil }
        return (genderInt % 2 == 0) ? false : true
    }
}

// device token
public extension String {
    init(deviceToken: Data) {
        self = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
    }
}

// md5
public extension String {
    func md5() -> String {
        guard let messageData = data(using: .utf8) else { return "" }
        return messageData.hashed(.md5, output: .hex) ?? ""
    }
}


public extension String {
    /// 复制到剪贴板
    func copyToPasteboard() {
        UIPasteboard.general.string = self
    }
}

