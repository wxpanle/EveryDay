//
//  String+Pinyin.swift
//  ExtremePlusDriver
//
//  Created by "pl" on 2020/6/2.
//  Copyright © 2020 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

private let chineseStartUncode: UInt32 = 0x4E00
private let chineseEndUncode: UInt32 = 0x9FEF

// MARK: - 本扩展是模糊搜索时使用 会清除空格、换行、标点符号  慎用

extension String {
    /// 转化成拼音
    func toPinYin() -> Self {
        return internalToPinYin()
    }
    
    /// 获取转换成拼音之后的数组
    func pinYinArray() -> [String] {
        let string = toPinYinClean()
        let (othersArray, chineseString) = string.pickUpChineseAndReturnOtherCharactersArray()
        var result = [String]()
        let transformChineseString = chineseString.internalToPinYin()
        result.append(contentsOf: othersArray)
        result.append(contentsOf: transformChineseString.components(separatedBy: " "))
        return result
    }
    
    /// 全部转换成大写
    func uppercasedPinYinArray() -> [String] {
        return pinYinArray().map { $0.uppercased() }
    }
    
    private func internalToPinYin() -> Self {
        //提取中文
        let bridgingString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, self as CFString)
        CFStringTransform(bridgingString, nil, kCFStringTransformToLatin, false)
        //去除声调
        CFStringTransform(bridgingString, nil, kCFStringTransformStripDiacritics, false)
        return String(bridgingString ?? "")
    }

    private func pickUpChineseAndReturnOtherCharactersArray() -> ([String], String) {
        var chineseString = ""
        var otherStrings = [String]()
        for value in self.unicodeScalars {
            if value.value >= chineseStartUncode && value.value <= chineseEndUncode {
                chineseString += String(value)
            } else {
                otherStrings.append(String(value))
            }
        }
        return (otherStrings, chineseString)
    }
    
    // MARK: - Help
    private func toPinYinClean() -> String {
        return self.cleanWhitespaceAndNewline().cleanPunctuationCharacters()
    }
    
    private func cleanWhitespaceAndNewline() -> String {
        return self.components(separatedBy: .whitespacesAndNewlines).joined(separator: "")
    }
    
    private func cleanPunctuationCharacters() -> String {
        return self.components(separatedBy: .punctuationCharacters).joined(separator: "")
    }
}
