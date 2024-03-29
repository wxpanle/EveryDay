//
//  PrintBoxCodeModel.swift
//  EveryDay
//
//  Created by "pl" on 2019/12/26.
//   All rights reserved.
//

import Foundation
import UIKit

// MARK: - kPrintWidth
fileprivate struct Constants {
    static let kPrintWidth: CGFloat = 600
}

class BitDataInfoModel {
    var data: Data?
    var width: Int = 0
    var height: Int = 0
}

class PrintBoxCodeModel {
    /// 需要打印的箱码model
    var boxCodeModel: Any?
    /// 位图信息model
    var bitDataInfoModel: BitDataInfoModel?
    /// 需要打印的数据
    var printData: Data?
    /// 打印数据是否可用
    var isPrintDataEnable: Bool { return !(printData?.isEmpty ?? true) }
    /// 获取打印数据的长度
    var printDataLength: Int { return printData?.count ?? 0 }
    
    init(boxCodeModel: Any?) {
        self.boxCodeModel = boxCodeModel
    }
    
    /// 打印前调用此方法  isPrintDataEnable  配合使用
    
    func preparePrint() {
        
        guard !isPrintDataEnable else { return }
        // 300 * 312 106000 13764
        // 300 * 312 434400 54308
//        printView.updateData(boxCodeModel)
//        printView.setNeedsLayout()
//        printView.layoutIfNeeded()
//        guard let preViewImage = printView.renderImage else { return }
//        let scaleImage = preViewImage.scaleImage(with: preViewImage, width: 600, height: 840)
//        bitDataInfoModel = scaleImage.bitmapData()
        p_printData()
    }
    
    func subPrintData(with startIndex: Int, length: Int) -> Data {
        
        let fixLength = (startIndex + length <= printDataLength) ? length : (printDataLength - startIndex)
        
        let range = Range.init(NSRange.init(location: startIndex, length: fixLength))
        guard nil != range else {
            return Data()
        }
        return printData?.subdata(in: range!) ?? Data()
    }
    
    private func p_printData() {
        
        guard let bitInfo = bitDataInfoModel else { return }
        guard let bitData = bitInfo.data else { return }
        
        let bytes = [UInt8](bitData)
        var resultData = Data()
        
        var w8 = bitInfo.width / 8
        if bitInfo.width % 8 != 0 { w8 += 1 }
        
        // 1D 76 30 m xL xH yL yH d1...dk
        // m为模式 58mm = 1 other = 0
        // xL 为宽度/256的余数
        // xH 为宽度/256的整数
        // yL 为高度/256的余数
        // yH 为高度/256的整数
        let xL = UInt8(w8 % 256)  //xh <= 72
        let xH = UInt8(bitInfo.width / (8 * 256))
        let yL = UInt8(bitInfo.height % 256)
        let yH = UInt8(bitInfo.height / 256)
        
        resultData.append(contentsOf: [0x1B, 0x40, 0x1B, 0x61, 0x01])        
        resultData.append(contentsOf: [0x1D, 0x76, 0x30, 0x00, xL, xH, yL, yH])
        
//        (xl + xH * 256) * 8 = 512  1代表打印  0  代表不打印
        
        /// 转化为需要发送的数据
        for h in 0..<bitInfo.height {
            
//            let xL = UInt8(w8 % 256)  //xh <= 72
//            let xH = UInt8(bitInfo.width / (8 * 256))
//            let yL = UInt8(1)
//            let yH = UInt8(0)
//            resultData.append(contentsOf: [0x1D, 0x76, 0x30, 0x00, xL, xH, yL, yH])
            
            for w in 0..<w8 {
                // 每8位进行一次处理
                var n: UInt8 = 0
                for i in 0..<8 {
                    let wOffset = i + w * 8
                    var ch: UInt8 = 0
                    if wOffset < bitInfo.width {
                        let piexOffset = h * bitInfo.width + wOffset
                        if piexOffset < bytes.count {
                            ch = bytes[piexOffset]
                        } else {
                            ch = 0x00;
                            debugPrint("获取位图时发生了错误")
                        }
                    } else {
                        ch = 0x00
                    }
                    n = n << 1
                    n = n | ch
                }
                resultData.append(n)
            }
        }
            
        printData = resultData
    }
}

/// 安卓的一条打印指令
//        let str = "G0AbTQAbYQAdIQAbRQAbRwAbYQAbTQAbYQAdIQAbRQAbRwAbYQAbYQAKG2EBHXYwACMAGAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXAAB/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB8AAD4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHwAAfgAAAAUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/AAA+AAAAD4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB8AAH8AAAAfAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH4AAPgAAAB+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFwAAfAAB8AAAAHwHQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAfAAA+AAD4AAAAfA+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB8AAHwAAfwUAAB8B8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH4AAPgAA+D4AAPwPwAAAAAAAAAAAAAAAAAAAAAAAAAAAAHAfAAA/AAHwHwdBfB/AcAAAAAAAAAAAAAAAAAAAAAAAAAAA+A+AAD4AAPg+B4D4H4D4AAAAAAAAAAAAAAAAAAAAAAAAAAH8H8AAXwAAUBwHwfwfQfQAAAAAAAAAAAAAAAAAAAAAAAAAAPwPgAA/AAAAAA/B+A+B+AAAAAAAAAAAAAAAAAAAAAAAAAAAfAcAAB8BwAAAF8HwFwHwAAAAAAAAAAAAAAAAAAAAAAAAAIB+AAAAPwPgAAAPg/AAA/AIAAAAAAAAAAAAAAAAAAAAAAAFwHwAAAAfBcAAAB/B8AAH0FwAAAAAAAAAAAAAAAAAAAAAAAPgPgAACB8D4AAAD4PgAAfgPgAAAAAAAAAAAAAAAAAAAAAAB/AcAAA8HwFAAAAfB/AAB8B8AAAAAAAAAAAAAAAAAAAAAAAD8AgAAD4OAAAAAB+D4AAPwPwAAAAAAAAAAAAAAAAAAAAAAAH0AAAAfQAAAAAAHwfAAB/B/AAAAAAAAAAAAAAAAAAAAAAAAPgAAAA+AAAAAAAfh+AAH4D4AAAAAAAAAAAAAAAAAAAAAAABfAAAAD8AAAAAAB8HwAAfAfAAAAAAAAAAAAAAAAAAAAAAAAD4AAAAPwAAACAAPw/AAD8A8AAAAAAAAAAAAAAAAAAAAAAAAFABQAAfAAHA8FwfB8AAXwBQAAAAAAAAAAAAAAAAAAAAAAAAAAHgAB4AA+D4PD4PgAB+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAfAAHQAB8fx8Px/AAHwAAAAAAAAAAAAAAAAAAAAAAAAAAAAD8AAAAAPg+H4+D4AAPgAAAAAAAAAAAAAAAAAAAAAAAAAAAUHwAAAAAUH8fH0fQABcBAAAAAAAAAAAAAAAAAAAAAAAAAADwPgAAAAAAPj8fh+AAAAeAAAAAAAAAAAAAAAAAAAAAAAAAAfB/AAAAUAB8Hx/HwcAAF8BwAAAAAAAAAAAAAAAAAAAAAAAA8D8AAAD4AD4/H4/D4AAPgPgAAAAAAAAAAAAAAAAAAAAAAAHwHwAAUXwAPB8fF8fwAB8B8AAAAAAAAAAAAAAAAAAAAAAAACAfgAD4+AAIPw8Pg+AAPwP4AAAAAAAAAAAAAAAAAAAAAAAAAB/AAfB8AAAfHx/HwAB/B/AAAAAAAAAAAAAAAAAAAAAAAAAAD8AA+PwAAD4AH4/gAH4H4AAAAAAAAAAAAAAAAAAAAAAAAAAHwAFwfAAAPwAfF8AAfAfQAAAAAAAAAAAAAAAAAAACqAAAAAOAAAB+AAA+AD8PgAA4B8ALoAAAAAAAAAAAAAAAABf9ABQFwQAAAHwAAH8AHwfFABAFwF/wAAAAAAAAAAAAAAAAP/+APgfAAAAAPAgAPgA/Ag+AAAAA//wAAAAAAAAAAAAAAAB//8B9B8AAdAAQPAB/AD8AF0AAAAH//wAAAAAAAAAAAAAAAP8v4D4H4AB8AAA+AD4APgAPgAAAA/o/AAAAAAAAAAAAAAAB/AXwHAfwEHwUAFwAfgB+AB9AAAAHwB9AAAAAAAAAAAAAAAHwAPgAA/A8fj4APAA+AH4AP4AAAA+AD4AAAAAAAAAAAAAAAfABcAAB8Hx/HwAQAH0AfAAfAAAAHwAHwAAAAAAAAAAAAAAD4AA4AAH4PD8/AAAAfgB8AD8AAAAeAAPgAAAAAAAAAAAAAAfAAHwAAfx8Hx8AAAB8AHwAHQAAABwAAcAAAAAAAAAAAAAAA4DgPAAA/Cg+H4AAAH4A+AAIAAAAPgIB4AAAAAAAAAAAAAAHwfA8AAB9ABcfAAAAfAF8AAAAAAAcBwHwAAAAAAAAAAAAAAOB8D4AAD4AAA+AAAB+AfgAAAAAAD4PgeAAAAAAAAAAAAAAB8HwHAAAXwAAHwAdAHwB/AAAAAAAHAfBwAAAAAAAAAAAAAADgOA8AA4/gAAPAB4A/AH4AADgAAA+B4HgAAAAAAAAAAAAAAfAUHwAHx8AAAEAHwB8AfABQfAAAB0BAfAAAAAAAAAAAAAAA8AAOAAfD4AAAAAeAHgD8APh8AAAPgAD4AAAAAAAAAAABcABwAB8AB/HwAAAABQAUAHwB8HwAAAfAAXAAAAAAAAAAAAD4AHgAPgAH8eAAAAAAAAAA+AD4OCAAA+AB8AAAAAAAAAAAAf0AfAB8AAXwQAAAAAAAAAH8AFAU8FQF0AXQAAAAAAAAAAAA/4A/gPwAAfgAAAAgAAAAAPgAAAD4PAH4D+AAAAAAAAAAAAF/AB/38AAB/AAAAHAAAAAB8AAAAfB8Af9fwAAAAAAAAAAAAD+AD//wAAD+AAAA+AAAAAH4AAAA8DwAf/+AAAAAAAAAAAAAHwAF/8AAVH0AAAB8AUAUAfAAAABAXABf/QBQAAAAAAAAAAAOAAD+gAA8P4AAAPwDwDwD8AAAAAAAAA/4APgAAAAAAAAAAAAAABAAcHwfAAAAfAfAfAHwAAAAAABwAVAB8AAAAAAAAAAAAAAAAAD8PB+AAAB+A+A+A+AAAAAAAPgAAAD4AAAAAAAAAFwAAAAAAfxcH8AAAHwFwFwHwAAAXAAB8AAAAFAAAAAAAAAAfgAAAAAA/gAP4AAAPgCAAAPgAAA+AAD4AAAAAAAAAAAAAAB/QABwAAB/AAfwAUAcAAAAAcAUAHwAAFAAAAAAAAAAAAAAAD/gAPgAAH+AA/AD4AAAAAAAADwAPgAAAAAAAAAAAAAAAAAAX8AAfAAAXwAB/AXQAAAAAAAAfAAUAAAAAAQAAAAAAAAAAAAP4AD4AAAPgAD8A+AAAAAAAAB8AAAAqAAADgAAAAAAAAAAAAXAAFAAABUAAXwBwAAAAAAAAHwAAAFwAAAfAAAAAAAAAAAAAAAAAAAAgAAAfgAAAAAAAAAAAAAAAfg4AB8AOAAAAAAAAAAAAAAAXAHABAB/AAAAAAAAAAAABQAF/HwAHwB8AAAAAAAAAAAAAAB+A+AOAD+AAAAAAAAAAAAPgA/4fAAOAPwAAAAAAAAHQAAFAH8B8B8AHwAAAAAAAAAAAB8AF/B8AAAAfAAXAAAAAA/gAA8Af8HgH8APgAAAAAAAAAAAD4Af4Dg+AAB4AD+AAAAAH/QAHwBfwEAfwAUAAABV3dVAAAAFAF/AFHwAQFAF/wAAAAAP+AAPAA/AAA/gAAAAAP////gAAAAA/4AA/gD4AA//gAAAAAf8ABcAB8AAF/AAAABX/////1AAAAF/AAH9BfAAH/8AAAAAAfgAAAADgAAD/AAAAP//////+AAAAf4AB/wP+AA//AAAAAAAXAAAAAAAAAX8AAAF///////9QAAF/AAf9B/wAF/UAAAAAAAAAAAAAAAAAP4AAD/////////AAAP4AD/gD+AAP8AAAAAAAAAAQAB0AAABfwABf/////////AAB/AAf8AfwAAfAAAAAAAAAAHgAH4AAAB+AAP//////////gAD4AH/gA8AAAAAAAAAAAAAAfAAf0AAAFwAF//////////9QAXABf0UBAQAAAAAAAAAAAAB4AB/wAAAAAA////////////AAAAP/B4AD4AAAAAAAAAAAAHwAF/AAAAAAH////////////AAAB/wHwAHAAAAAAAAAAAAAKAgD8AAAAAB////////////+AAAP+A+AA+AAAAAAAAAAFQAQHwFwAAAAAH////VVVXf///0AAB/wBwAB8AAAAAAAAAAPAAA+AAAAAAAAP///4AAAA///+AAAf+AAA4CgAAAAAAAAAB8AABwAAAAHAAAf//1AAAABX//0AAH/QAAHwAAAAAAAAAAADwAAHgIAAA+AAAf/+AAAAAAP/+AAAP4AAAfAAAAAAAAAAAAXB0AQF0AAF0AUBf9QAAAAAAV/UBAB/AAAB8ABcAAAAAAAAAAHgAAP4AAHgA4B/gAAAAAAAH+AOAD4AAADgAHwAAAAAAAAAAfAAA/wAAUAHwB0AAAAAAAAXQB8AFAAAAEAAfAAAAAAAAAAB4AAD/gAAAA/ACAAAAAAAAAMAPwAAAAAAAOB4AAAAAAAAAAFAAAF9AAAAH9AEAAAAAAAAAAB/AAAAAAAB8FQAAAAAAAAAAAAAAD4AAAAP8AAAAAAAAAAAAP+AAAAAAAHgAAAAAAAAABUAAAAUFAAAAB/wAAAAAAAAAAAB/8AAAAABAfAAFUAAAAAAP4AAAB4AAAAAP/gAAAAAAAAAAAH/wAAAAAOA4AA/wAAAAABf0AAAHAAAUABf/AAAAAAAAAAABf/AAFAAB8BABf/AAAAAAD/wAAA+AAD4AH/+AAAAAAAAAAAH/+AA8AAHwAAv/8AAAAAAH/AAAB8AAHwAf/wAAAAAAAAAAAf/8AHwAAfAAX//wAAAAAAP8AAACAAA+AD//AAAAAAAAAAAA//wAPAAA4AD//4AAAAAAAVQAAQAAABUAP/8AAAAAAAAAAAB//AB0AAAAAX/1AAAAAAAAAAAD4AAAAAA//gAAAAAAAAAAAD/+AAAAAAAA/6AAAAAAVAAAAAf8AAAAAH/8AABVAAAAFVAAf/wAAAAAAAB9AAAEAAD+gAAAB/4AAAAAf/wAA/+AAAL//gA//gAAAAIAAAAAAL8AAX/wAAAH/wAAAAB//AAX//AAV///UB//AAAAFwAAAAAX/wAA//wAAAP+AAAAAP/4AD///gD////wH/8AAAP/gAAAAD//gAD//AUAAFwAAAAB//ABf///Af////Qf/wAAV//AAAAAf/8AAH/+D4AACAAAAAD/+AH///4D////+A//gAD//4AAOAA//gAAF/wXAVUAAAFQAf/wB////wH////wF/8AB///AAF/AD90AAAAOA+D/6AAA+AB//AH////A/////gP/4AD//gAA/4ADwAAAAAABwH/8AAB8AH/8Af///8B/////Af/wAf/QAAH/wAEAAAAAAAAA//4AAPgA//gD/+C/gP//r/4B/+AA/gAAAP+AAAAAAAAAAAB//QAAUAB//AX/QBXAf9QFXAH/8ABUAAAB/QAAAAAAAAAAAA/+AAAAAP/4B/4AAYD/wAAOAP/wAAAAAAAgAAAAAAAAAAAAAVQAAAABf/AH/QABQH/AAAUB//AAAAAAAAAAABVQAAAPgAAAAAAAAAD/8Af+AAAA/8AAAAD/8AAAAAAAAAAAH/AAAB/QAEAAAAAAAf/wB/wAAAB/wAAAAP/wAAAAAAAAAFAf8AAAP/gA4AAAAAAA//AH/gAAAP/AAAAA//gAAAAAAAAA+D/wAAAf8AHwAAAAAAH/8Af/AAAAf8AAAAB/8AAAAFAAAAHwH/AAAB/4AfAAAD6AAf/gA/+AAAD/wAAAAP/4AAAAeAAAAPgOgAAABdAB8AAAf8AB//AF/8AAAH/AAAAAf/wAXAB8AAAAUAQAAAAAAADgAAB/4AH/4AP/4AAA/8AAAAD/+AB8AHwAAAAAAAAAAAAAAAAAAH/wAf/wAf/0AAB/wBUAAH/8AHwAdAAAAAAAAAAAAAAAAAAAP+AB/+AB//4AAP/APgAAf/gAPAAAAAAAAAAAAAAAAAAAAABVwAH/0AB//8AAf8BVQAB//ABUAAAAAAAAAAAACsAAAAAAAAAAAf/gAH//4AD/wO/AAH/4AAAAAAAAgAqAAAB//AcAAFQAAAAB//AAX//wAH/BVUAAf/wAAAAAAAHAf8AAAP/+D4AAPAAAAAH/4AAP//gA/8D/wAB/+AAAAAAAA+D/4AAB//wHwAB8AAAAAf/QAAX//AB/wVVAAH/8AAAAAAAF0H/AAAD//A+AADwAAAAB/+AAAP/+AP/A/sAAf/gAAAAAAAHg/8AAAH90BQAAFAAAAAH/8AAAf/8Af8FVQAB//AAAAAAAAUBfQAAAAAAAAAAAAAKAAf/gAAAP/4D/wP+AAH/4AAgAAAAAAAAAAAAAAAAAAABAX8AB/9AAAAX/wH/AVUAAf/wAXcAAAAAAAAAAAAAAAAAAC8B/4AH/4AAAAf/A/8AIAAD/+AB/4ADAAAAAAAAAAAABAAX/8H/wAf/wAAABf8B/wAAAAH/wAH/wAfUAAAAAAAAAAK+AD//wf+AB//AAAAB/4P/AAAAA//gAP+AD/wCAAAAAAAVd/8AH//BdwAH/8AAAAH/Qf8AAAAB/9ABd0AX/BcBQBEAAP///wA//4AgAAP/wAAAAP+D/wAAAAP/4AACAAf8D4Pgf4AB////AB/1AAAAB//AEAAB/8H/AAAABf/AAAAABfwfB8B/wAP///4AAgAAAAAD/+AYAAD/g/8AAAAD/8AAAAAAIA8D4P/AAf//VAAAAAAAAAP/wB0AAX9B/wAAAAf/wAAAAAAAAQFAf8AD/6gAAAAAAAAAA//gHgAB/4P/AAAAB/+AAAAAAAAAAAA/gABEAAAABQAAAAAB/9AfQAH/Qf8AAAAH/8AAAAAfAAAAAAUAAAAAAAAPAAAAAAH/4B/gA/+D/wAAAA//gAAAAA8DgAAAAAAAAAAAAB8AAAFQAf/wH/VX/wH/AAAAF/8AB1AAHwfAAAAAAAAAAAIAHwAAA+AB//Af////A/8AAAAP/4AD+gAPA8AgAAAAAAAABwAVAAAB8AH/8B////8B/wAAAB//AAf8AAUHwPAAAAAAAgAPgAAAAAPgAP/4H////gP/AAAAH/8AA/4AAAPA+AAgAABXQBcAAAVwAUABf/Qf///8Af8AAAAf/wABfwAAAQFwAXUAAP+ADwAAD/AAAAD/+A////gD/wAAAD//AAA+ADgAAPAB/wAB/8AEAAAf8AAAAH/8Bf//8AH/AAAAX/8AAAQAfAAAQAH/AAD/gAAAID/wAAAAf/4A///gA/8AAAA//gAAAAB8AAAAAf+AAX8AAAFwH9AAAAB//QBX9wAB/wAAAH/9AAAAAHwAAAABfwAAOgAAP/g/AAAAAD/+AAIgAAP/AAAAf/wAAAAAOAAwAAAuAAAAAAV//AQAAAAAH/8AAAAAAAAAAAB//AAAAAAQAHAAAAQAAAAAD//4AAAAGAAf/4AAAAAAAAAAAP/4ADgAAAAA+AAAAAAAAAF///AFAAF/AB//AAAAAAAAAAAB//AAfwAAUABwFQAAAAAAA///gA+AA/4AD/8AAAAAAAAAAAD/8AA/gADwAHg+AAAAAAAH//QAX8AH/wAH/wAAAAAAAAAAAH/wAH/wAfAAAB8AAAAAAA//gAD/gD/+AA/+AAAAAAAAAAAAP+AAP/wB8AAAPgAAAAAAB/UAAX8Af/QAB/wAAAAAAAAAAAAf0AAX/wHwVAAUAAAAAAAHoAAA/wB/4AAD+AAAAAAAAAAAAB/gAAP/4CB+AAAAAAAAAAEABUD9AH/AAAHwBQAAAAAAAABAH8AAAf/wAH/AAAAAAAAAAAAP4DAAfgAAAeAPgAAAAAAAA+APgAAAP/AAf+AAAAAAAAAAAH/AAABUAAABUBfQAAAAAAAX8AcAAAAX8AB/wAAAAAAAAAAAf+AAAAAAAACAP/gAAAAAAD/8AwAAAAPwAD/gAAAAAAAAAAB/wAAAAABwAEB//0AAAAAFf/0BAB8AAVBUBcFQAAAAAAAAAH+AAAAAAfgAAP//4AAAAA///4AAD4AAAHgAAPAAAAAAABAAVQFAAAAH9AAB///1EAABd///wAAf0AAAfAAB8AAAAAAAOAAAA+AAAA/4AAP////6AC/////gAA/wAAB4AADwAAAAAAF8AAAX8AAAH/AAB////////////9AAB/wAAHQEAFAAAAAAA/4AAD/gAAA/4AAD////////////gAAD/gAgAB4AAAAAAAAD/wAAf9AAAX9AAAF///////////8AAAH/AHQAHwAAAAAAAAP+AAA/gAAD/wAAAD//////////+gAAAH+A/wA+AAAAAAAABfQAAH0B0Af9AAAAF//////////0AAAAXwB/QBwAAAAAAAAA4AAAKAHgD/gAIAAD/////////8AADgAPgH+ACAAAAAAAAAAAAAAQAfAX8AFwAAF/////////AAAfABUAH8AAAAAAAAAAAAAKAAAB4A/gA/gAAD////////gAAB+AAAAPgAAAAAAAAAAAAF8AAAFAB8AF/AAABf//////0AAAH8AABwVAAAAAAAAAAAAA/wAAAAACAAf4AAAA//////4AAAAP8AAPgAAAAAKAAAAAAAf/AAAAAAAAF/AAAAAXf///UQAAABfwAAdAAAAAB9AAAAAAD/8AAAAAAAA/4AAAAAA///oAAAAAA/gAD4AAAAAH+AAAAAAf/AAAAAAAAF/AAAAAAAVFQAAAAAAF/AAFAAAAAAf8AAAAAD/4AAAAAAAAf4AIAAAAAAAAAAAACAH+AAAAAAAAB/4AAAAAf1AAAAAABQF/ADwAAAAAAAAAAAA9AX8AAAAAAAABfAAAAAA/AAAAAAAPg/4APgAAAAAAAAAAAD4APwAAAAAAAAA+AAAAABQAUAAEAB/F/AB8AAAAAAAAAAAAfwBfAAAFUAAAABQAAAAAAAB4AA4Af4f4ADwAAAAAAAAAAAA/gA4AACqqAAAAAAAAAAAAAHAAHwB/F/AAEAAAAAAAAAAAAB/AAAABVVVAAAAAAAAAAAAA+AAfAP8/4AAAAwAAAAAAAAAgD+AAAAIqKiAAAAAAAAAAAAB8AB8AfB/AAAAHAAAAAAAAAfAHwAAAFVVVVAAAAAAAAAAAACAADgB4P4AAAA+AAAAAAAAB8AfgAAAqqqqqAAAAAAAAAAAAABAAABB/ABcABwAAAAAAAAHwB/AAAVVVVVUAAAAAAAAAAAAAPgAAAD4AD4AHgCAAAAACAPAD+AACqqqqqoAAAAAAAAAAAAB8AAAAFAAfAAAA8AAAAAcAQAH8AAVVVVVVQAAAAAAAAAAAAP4AAAAAAA+AAAD4AgAgD4AAAP4AAqqqqCqgAAAAAAAAAAAB/wAAAAAABQAAAXAXAXAXQAAAfwAVVVVQFVAAAAAAAAAAAAP+AAAAAAAAAAAA8A+A+A+AAAA/AAoqKgACKAAAAAAAAAAAB/QFVAAAAAAAQABADwHwB8AAAB8AFVVVAAFUAAAAAAAAAAAD4A/+AAAAAADwAAAPAPAPwAAAHgAqqqoAAKgAAAAAAAAAAAFAH/9AAAAAAXAAAAEAEAfAAAAVAFVVVQEAVQAAAAAAAAAAAAA//+AAAAAB+AAAAAAAA8AAAAAAKqqoAqAqAAAAAAAAAAAAAH1X8AAAAAHwAAAAAAAFwAAAAABVVVQVUFUAAAAAAAAAAAAA+APwAAAAA/AAAAAAAAAAAAAAAKqqqAqoKgAAAAAAAAAAAAHwAXAAFQUH8AAAAAAAAAAAAAABVVVUFVAVAAAAAAAAAAAAA+AA+AAeD4PgAAAAAAAAAAAAAAAqKigKKCqAAAAAAAAAAAAFwAB8AB8Px8AAAB0AXAAAAAAAAVVVVBVQFUAAAAAAAAAAAAPAADwAPg+PwAAAHgB4AAAAAAAAqqqoCqAqgAAAAAAAAAAAB8FQPAB/HxfABQAfAHwAUABwEAFVVVQVUFVAAAAAAAAAAAADgPA8AP4/H4APAD8AeADwAPg+AKqqqAoAKoAAAAAAAAAAAAfB8BwA/H8fAB8AHwBQAfAAfHwBVVBUFQBVQAAAAAAAAAAAA4DwPAD4fg8OD4A+AAAA+AD8PgCqgCgKAKqAAAAAAAAAAAAHwXA8AXB8FR8XAD8AAAFwAHw8AVUAVBUBVUAAAAAAAAAAAAOAADwAIPwAHwAAPgAAAAAAfhgAKgAoCgIqAAAAAAAAAAAAB8AAfAAB/AAfAAAcAAAAAAB/AAFUAVQVVVVAAAAAAAAAAAAD4AB4AAH4AA4AAAgAAAAAAD4AAKgCqAqqqoAAAAAAAAAAAAHwAXAAAfAAFAAAABQAAAAXHwABVBVUFVVVQAAAAAAAAAAAAfgD8DgA8CAAAAAAPgAAAB8IAACoCqgKqqqAAAAAAAAAAAAB/AXwfABB8AAAAAB8AAAAHwAAAVQVVBVVVUAAAAAAAAAAAAB//+B+AADwAAAAAD4AAAAfgAAAqAqoCqqqgAAAAAAAAAAAAH//QXwAAfAAABQAFAAUAB8AAAFUFVAVVVUAAAAAAAAAAAAAD/8A/gAA8AAAPAAAAD4AD4AAACgKICoqKwAAAAAAAAAAAAAF3AH8AABAAAB8AAAAHwAfwUAAVAVQVVVVAAAAAAAAAAAAAAAAA/gAAAAAADwAAAA+Ag/B4AAqAAAqqqoAAAAAAAAAAAAAAAAH8AAAAAAAdAAAABUXB8HwAFUAAFVVVAAAAAAAAAAAAAAAAAfgAAAAAAAAAAAAAA+H4fAAKgAAqqqoAAAAAAAAAAAAAAAAB8AABAXAAAAAEBQAH8fx0AAVQAFVVVQAAAAAAAAAAAAAAAAPwAAOB8AAAAA8HgAPg+AAAAqgAqqqqAAAAAAAAAAAAAAAABdAAB8HwUAAADwfABfD8AAABVVVVVVQAAAAAAAAAAAAAAAAD4AAPw/D4AAAPj8AD8PgAAACKioqKiAAAAAAAAAAAAAAAAAFAAB/B8XwUAAcHwUHwUAAAAVVVVVVQAAAAAAAAAAAAAAAAAADgH4Pg+DwAAg/D4fgAAAAAKqqqqqAAAAAAAAAAAAAAAAAAAfAfRdH8fBwAB8XR/AAAAAAVVVVVQAAAAAAAAAAAAAAAAAAD4D+D4fh+PgAPw+D4AAAAAAqqqqqAAAAAAAAAAAAAAAAAAAfwfwHB8HwfAAfBwfwAAAAABVVVVQAAAAAAAAAAAAAAAAAAB+B+AIPw/D4AB+AA+AIAAAAAqqqoAAAAAAAAAAAAAAAAAAAHwHwAAfB8XwAHwAB8D0BQAABVVUAAAAAAAAAAAAAAAAAAAA/A/AAA4Pw+AgfAAPwPgPAAAALqAAAAAAAAAAAAAAAAAAAAH8H8AABB/D8HB8AAfB/B8AAAAAAAAAAAAAAAAAAAAAAAAAAfgPgAAAD4Pg+HwAB+D8DwAAAAAAAAAAAAAAAAAAAAAAAAAB8B/BQAAfwcH8fAAHwHwdAAAAAAAAAAAAAAAAAAAAAAAAAAPwP4PgAA+AwPgIAAPg/gAAAAAAAAAAAAAAAAAAAAAAAAAAB/BfA/AAHwAB8AAAB/B/AAAAAAAAAAAAAAAAAAAAAAAAAAAD4D4D4CAfgAD4AAAD8H4AAAAAAAAAAAAAAAAAAAAAAAAAAAXAfAfAfB8AAfwAAAHwfwAAAAAAAAAAAAAAAAAAAAAAAAAAAAD8D+D4P4AA+AAAAfg/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAXwHwHwfAABwAAdB8B8AAAAAAAAAAAAAAAAAAAAAAAAAAAAA+A/AeD8DgAAIB4H4P4AAAAAAAAAAAAAAAAAAAAAAAAAAAAH8H8BAXwfAABwHwfwfwAAAAAAAAAAAAAAAAAAAAAAAAAAAAPgPgAA+B8AAPg/A+A+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAUB8AAH8HwAA/B8F8H8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH4AAPgfgAD4H4PwPwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAfAAB8B8BAHwfAfAfAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB4AAH4PwPg/B+B8D4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFAAAfAfBcB8H8HwFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB+D8D4PwPgPgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHwHwfwfBfBcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/A/A+B+D8DwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB8F8HwHwHwEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHgPgPgfgeAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAVAfB9B8BQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD4D4DgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAFAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABtNABthAB0hABtFABtHABthABthAAobTQAbYQAdIQAbRQAbRwAbYQAbYQAK"
