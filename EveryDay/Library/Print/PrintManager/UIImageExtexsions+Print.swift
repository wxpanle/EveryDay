//
//  UIImageExtexsions+Print.swift
//  EveryDay
//
//  Created by "pl" on 2019/12/26.
//   All rights reserved.
//

import Foundation
import UIKit

fileprivate struct ARGBModel {
    var alpha: UInt8 = 0
    var red: UInt8 = 255
    var green: UInt8 = 255
    var blue: UInt8 = 255
    
    init(_ value: UInt32) {
        blue = UInt8(value & 0xFF)
        green = UInt8((value >> 8) & 0xFF)
        red = UInt8((value >> 16) & 0xFF)
        alpha = UInt8((value >> 24) & 0xFF)
    }
    
    var gralValue: Int {
        var result = 0.3 * Float(red) + 0.59 * Float(green)
        result += 0.11 * Float(blue)
        return Int(result)
    }
    
    var pixelValue: UInt8 {
        return gralValue <= 185 ? 0x01 : 0x00
    }
}

fileprivate extension UInt32 {
    
    var argbModel: ARGBModel {
        return ARGBModel(self)
    }
}

extension UIImage {
            
    /// 转化为位图 BitDataInfoModel->data 可能为空
    
    /// 获取打印的点阵图数据 resultModel.data [0 1 0 1 0 1 0 1 0 1 0 1 0 1....]  0白色 1黑色
    func bitmapData() -> BitDataInfoModel {
        let resultModel = BitDataInfoModel()
        guard let cgImageRef = cgImage else { return resultModel }
      
        resultModel.data = bitmapOfImageData()
        resultModel.width = cgImageRef.width
        resultModel.height = cgImageRef.height
        return resultModel
    }
        
    /// 创建成功之后，你必须释放 bitmapData
    func bitmapOfImageData() -> Data? {
        guard let cgImageRef = cgImage else { return nil }
        
        var context: CGContext? = nil
    
        // Int

        let pixelsWidth = cgImageRef.width
        let pixelsHeight = cgImageRef.height
        
        // Int
        let bitsPerPixel = 32  //使用灰度位数处理 减小内存消耗
        let bitsPerComponent = 8
        let bytesPerPixel = bitsPerPixel / bitsPerComponent
        
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and alpha.
        let bytesPerRow = bytesPerPixel * pixelsWidth
        let bytesCount = bytesPerRow * pixelsHeight
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let unsafeBitmapData = UnsafeMutableRawPointer.allocate(byteCount: bytesCount, alignment: bytesPerPixel)
                        
        context = CGContext(data: unsafeBitmapData, width: pixelsWidth, height: pixelsHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        guard let imageContext = context  else { return nil }
        
        imageContext.draw(cgImageRef, in:  CGRect(x: 0, y: 0, width: pixelsWidth, height: pixelsHeight))
        
        guard let bitData = imageContext.data else { return nil }
            
        // 把像素点转化为打印机的黑白数据点  1 - 1
        var resultData = Data()
        for h in 0..<pixelsHeight {
            for w in 0..<pixelsWidth {
                let offset = h * pixelsWidth * bytesPerPixel + w * bytesPerPixel
                // UInt8 -> bitsPerPixel 字节位数  如果不同 是需要替换的  切记
//                let rgbResult = bitData.load(fromByteOffset: offset, as: UInt8.self)
                let argbModel = bitData.load(fromByteOffset: offset, as: UInt32.self).argbModel
                resultData.append(argbModel.pixelValue)
//                resultData.append(rgbResult <= 170 ? 0x01 : 0x00)
            }
        }
        
        bitData.deallocate()
        return resultData
    }
    
    func scale(with newWidth: CGFloat) -> UIImage? {
        
        guard size.width != newWidth else { return self }
        defer {
            UIGraphicsEndImageContext()
        }
        let newHeight = newWidth * size.height / size.width
        let size = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(x: 0.0, y: 0.0, width: newWidth, height: newHeight))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - QR
extension UIImage {
    
    
    /// 根据传入的内容创建一个条形码
    /// - Parameter code: code description
    /// - Parameter resultSize: resultSize description
    static func barCodeImage(_ code: String, resultSize: CGSize) -> UIImage? {
        let filter = CIFilter(name: "CICode128BarcodeGenerator")
        filter?.setDefaults()
        let data = code.data(using: .ascii)
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue(0, forKey: "inputQuietSpace")
        return resizeBarCodeImage(filter?.outputImage, resize: resultSize)
    }
    
    /// 重置条形码大小
    /// - Parameter image: image
    /// - Parameter resize: resize
    static func resizeBarCodeImage(_ image: CIImage?, resize: CGSize) -> UIImage? {
        
        guard let inputImage = image else { return nil }
        
        let extent = inputImage.extent.integral
        let scaleWidth = resize.width / extent.width
        let scaleHeight = resize.height / extent.height
        let width: Int = Int(extent.width * scaleWidth)
        let height: Int = Int(extent.height * scaleHeight)
        
        let colorSpaceRef = CGColorSpaceCreateDeviceGray()
        guard let contentRef = CGContext(data: nil,
                                         width: width,
                                         height: height,
                                         bitsPerComponent: 8,
                                         bytesPerRow: 0,
                                         space: colorSpaceRef,
                                         bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
            return nil
        }
        let context = CIContext()
        
        guard let imageRef = context.createCGImage(inputImage, from: extent) else { return nil }
        contentRef.interpolationQuality = .none
        contentRef.scaleBy(x: scaleWidth, y: scaleHeight)
        contentRef.draw(imageRef, in: extent)
        guard let cgImageRef = contentRef.makeImage() else { return nil }
        return UIImage(cgImage: cgImageRef)
    }
}
