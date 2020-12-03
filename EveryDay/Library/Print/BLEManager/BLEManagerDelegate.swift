//
//  BLEManagerDelegate.swift
//  BLECentralManager
//
//  Created by yanghong on 2019/5/23.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

protocol BLEManagerDelegate: NSObjectProtocol {

    //蓝牙状态：unknown，resetting，unsupported，unauthorized，poweredOff，poweredOn
    func EBLEManagerStateUpdated(manager: BLEManager, state: BLEState)
    
    //MARK:--中心模式代理回调
    // 中心模式：检索到设备
    
    /// 检索到设备
    ///
    /// - Parameters:
    ///   - manager: 中心模式管理类
    ///   - peripherals: 检索到的外设
    ///   - isTimeOut: 是否超时
    ///   - scanError: 错误信息
    func EBLEManager(manager: BLEManager, discover peripherals: [CBPeripheral], isTimeOut: Bool, scanError: Error?)
    
    func EBLEManagerStartScan(manager: BLEManager)
    func EBLEManagerStopScan(manager: BLEManager)

    // 中心模式：设备连接完成
    
    /// 设备连接完成
    ///
    /// - Parameters:
    ///   - manager: 中心模式管理类
    ///   - didFinishConnectPeripheral: 连接的设备
    ///   - error:错误信息
    func EBLEManager(manager: BLEManager, didConnect peripheral: CBPeripheral, error: Error?)
    
    /// 外设链接失败
    /// - Parameter manager: manager description
    /// - Parameter peripheral: peripheral description
    func EBLEManager(manager: BLEManager, didFailToConnect peripheral: CBPeripheral)
    
    // 中心模式：断开连接
    
    /// 断开连接
    ///
    /// - Parameters:
    ///   - manager: 中心模式管理类
    ///   - didDisconnectPeripheral: 断开的设备

    ///   - error: 错误信息
    func EBLEManager(manager: BLEManager, didDisconnect peripheral: CBPeripheral, error: Error?)
    
    // 中心模式：获取到设备扫描数据
    
    /// 获取到设备扫描数据
    ///
    /// - Parameters:
    ///   - manager: 中心模式管理类
    ///   - peripheral: 传输数据的设备
    ///   - didReadResult: 设备传输过来的数据
    ///   - error: 错误信息
    func EBLEManager(manager: BLEManager, peripheral: CBPeripheral, didRead result: Data?, error: Error?)
    
    // 中心模式：向设备发送数据
    
    /// 向设备发送数据
    ///
    /// - Parameters:
    ///   - manager:中心模式管理类
    ///   - didFinishSendDataToPeripheral: 连接的设备
    ///   - error: 错误信息
    func EBLEManager(manager: BLEManager, didFinishSendDataTo peripheral: CBPeripheral, error: Error?)
}

extension BLEManagerDelegate {
    func EBLEManagerStateUpdated(state: BLEState) {}
    func EBLEManager(manager: BLEManager, peripherals:[CBPeripheral], isTimeOut: Bool, scanError: Error?) {}
    func EBLEManager(manager: BLEManager, scanError: Error) {}
    func EBLEManager(manager: BLEManager, didFinishConnect peripheral: CBPeripheral, error: Error?) {}
    func EBLEManager(manager: BLEManager, didDisconnect peripheral: CBPeripheral, error: Error?) {}
    func EBLEManager(manager: BLEManager, peripheral: CBPeripheral, didRead result: Data?, error: Error?) {}
    func EBLEManager(manager: BLEManager, didFinishSendDataTo peripheral: CBPeripheral, error: Error) {}
    func EBLEManagerStartScan(manager: BLEManager) { }
    func EBLEManagerStopScan(manager: BLEManager) { }
}
