//
//  PrintManager.swift
//  ExtremePlusDriver
//
//  Created by SF-潘乐 on 2019/12/25.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: - help
extension PrintManager {
    class var isBLEEbable: Bool { return PrintManager.default.isBLEEnable }
    class var isPrintEnable: Bool { return PrintManager.default.isPrintEnable }
    class var isEverConnected: Bool { return BLEManager.isEverConnected }
    
    /// 开始扫描蓝牙
    class func startScan() {
        BLEManager.shared.scanPeripherals()
    }
    
    /// 开始打印某一个箱签
    /// - Parameter model: model description
    class func printBoxCode(_ model: Any) {
        printBoxCodes([model])
    }
    
    /// 开始打印一组箱签
    /// - Parameter models: models
    class func printBoxCodes(_ models: [Any]) {
        PrintManager.default.p_printBoxCodes(models)
    }
}

// MARK: - PrintManager
class PrintManager: NSObject {
    
    static let `default` = PrintManager()
    
    lazy private var needPrintModels: [PrintBoxCodeModel] = {
        return []
    }()
    
    weak var delegate: BLEManagerDelegate?
    
    private var printingModel: PrintBoxCodeModel?
    private var peripheral: CBPeripheral?
    
    private var isPrinting: Bool = false
    private var sendDataCount: Int = 0  //发送数据次数  sendDataCount = receiverResponseCount 算结束
    private var receiverResponseCount: Int = 0 //接收数据次数
    private var needSendTotalCount: Int = 0 // 需要发送总的次数
    private var singleCanSendCount: Int = 0
    
    private var isPrintEnable: Bool {
        return BLEManager.isConnected && BLEManager.isFindCharacteristic
    }
    
    private var isBLEEnable: Bool {
        return BLEManager.isPowerOn
    }
    
    override init() {
        super.init()
        BLEManager.shared.delegate = self
    }
    
    private func p_printBoxCodes(_ models: [Any]) {
        let printModels = models.map { PrintBoxCodeModel.init(boxCodeModel: $0) }
        needPrintModels.append(contentsOf: printModels)
        
        if isPrintEnable {
            startPrint()
        }
    }
}


// MARK: - print
fileprivate extension PrintManager {
        
    func resetPrintState() {
        isPrinting = false
    }
    
    func startPrintSetState() {
        isPrinting = true
    }
    
    func resetPrintCount() {
        sendDataCount = 0
        receiverResponseCount = 0
        needSendTotalCount = 0
    }
    
    func startPrint() {
        
        guard isPrintEnable else { return }
        guard !isPrinting else { return }
        
        printingModel = needPrintModels.first
        
        guard nil != printingModel else { return }
            
        startPrintSetState()
        resetPrintCount()
        
        printingModel?.preparePrint()
    
        switch BLEManager.perpheralWriteType {
        case .all: singleCanSendCount = Int(UInt32.max)
        case .part(let count): singleCanSendCount = count
        }
        
        let needSendDataLength = printingModel?.printDataLength ?? 0
        guard needSendDataLength > 0  else {
            resetPrintState()
            debugPrint("打印失败")
            return
        }
        
        needSendTotalCount = needSendDataLength / singleCanSendCount
        if needSendDataLength % singleCanSendCount != 0 {
            needSendTotalCount += 1
        }
        
        // 分批发送
        for _ in 0..<needSendTotalCount {
            startSendContentData(sendDataCount, length: singleCanSendCount)
        }
    }
    
    // 发送图片
    func startSendContentData(_ startIndes: Int, length: Int) {
        let sendData = printingModel?.subPrintData(with: startIndes * singleCanSendCount, length: length)
        guard let data = sendData else { return }
        sendDataCount += 1
        writeDataToBLE(data)
    }
    
    // 向蓝牙写入数据
    func writeDataToBLE(_ data: Data) {
        BLEManager.shared.sendPrintData(data: data, to: self.peripheral)
    }

    func printSuccess() {
        if nil != printingModel {
            needPrintModels.removeFirst()
            printingModel = nil
        }
        resetPrintCount()
        resetPrintState()
        startPrint()
    }
}


// MARK: - print help
fileprivate extension PrintManager {
    
    enum PrintAlignment: UInt8 {
        case left = 0x00
        case center = 0x01
        case right = 0x02
    }
    
    /// 重置打印机
    func reset() {
        var data = Data(count: 2)
        data.append(contentsOf: [0x1B, 0x40])
        writeDataToBLE(data)
    }
    
    /// 唤醒打印机
    func wakeUp() {
        var data = Data(count: 1)
        data.append(contentsOf: [0x00])
        writeDataToBLE(data)
    }
    
    /// 换行
    func newLine() {
        var data = Data(count: 1)
        data.append(0x0A)
        writeDataToBLE(data)
    }
    
    /// 回车
    func enter() {
        var data = Data(count: 1)
        data.append(0x0D)
        writeDataToBLE(data)
    }
    
    /// 对齐方式
    func alignment(_ alignment: PrintAlignment) {
        var data = Data(count: 3)
        data.append(contentsOf: [0x1B, 0x61, alignment.rawValue])
        writeDataToBLE(data)
    }
    
    /// 走纸  0<= n <= 255,一个垂直点距为0.125mm
    func goPage(_ n: UInt8) {
        var data = Data(count: 3)
        data.append(contentsOf: [0x1B, 0x64, n])
        writeDataToBLE(data)
    }
    
    /// 结束x
    func end() {
        var data = Data(count: 3)
        data.append(contentsOf: [0x1D, 0x4C, 0x00])
        writeDataToBLE(data)
    }
}

// MARK: - BLEManagerDelegate
extension PrintManager: BLEManagerDelegate {
    
    // MARK: - BLEManagerDelegate
    
    //蓝牙状态：unknown，resetting，unsupported，unauthorized，poweredOff，poweredOn
    func EBLEManagerStateUpdated(manager: BLEManager, state: BLEState) {
        if state.isPoweredOn && !manager.isScaning {
            BLEManager.shared.scanPeripherals()
        }
    }
    
    func EBLEManagerStartScan(manager: BLEManager) {
        delegate?.EBLEManagerStartScan(manager: manager)
    }
    
    func EBLEManagerStopScan(manager: BLEManager) {
        delegate?.EBLEManagerStopScan(manager: manager)
    }
    
    func EBLEManager(manager: BLEManager, discover peripherals:[CBPeripheral], isTimeOut: Bool, scanError: Error?) {
        delegate?.EBLEManager(manager: manager, discover: peripherals, isTimeOut: isTimeOut, scanError: scanError)
        if isTimeOut {
            manager.stopScan()
        }
    }
    
    func EBLEManager(manager: BLEManager, didConnect peripheral: CBPeripheral, error: Error?) {
        
        debugPrint("外设已经链接")
        if nil != self.peripheral { //把上一个外设取消掉
            manager.cancelSingleConnect(self.peripheral)
        }
        self.peripheral = peripheral
        delegate?.EBLEManager(manager: manager, didConnect: peripheral, error: error)
    }
    
    func EBLEManager(manager: BLEManager, didFailToConnect peripheral: CBPeripheral) {
        // 外设连接失败
    }
    
    func EBLEManager(manager: BLEManager, didDisconnect peripheral: CBPeripheral, error: Error?) {
        debugPrint("外设链接已经断开")
        if !BLEManager.isConnected {
            
        }
        if self.peripheral == peripheral {
            self.peripheral = nil
            resetPrintState()
        }
        delegate?.EBLEManager(manager: manager, didDisconnect: peripheral, error: error)
    }
    
    // 中心模式：获取到设备扫描数据
    func EBLEManager(manager: BLEManager, peripheral: CBPeripheral, didRead result: Data?, error: Error?) {
        delegate?.EBLEManager(manager: manager, peripheral: peripheral, didRead: result, error: error)
        if isPrintEnable {
            startPrint()
        }
    }
    
    // 中心模式：向设备发送数据
    func EBLEManager(manager: BLEManager, didFinishSendDataTo peripheral: CBPeripheral, error: Error?) {
        
        guard self.peripheral == peripheral else { return }
        
        if nil != error {
            resetPrintState()
            resetPrintCount()
            debugPrint("外设链接打印失败")
            return
        }
        
        receiverResponseCount += 1
    
        //
        if receiverResponseCount >= needSendTotalCount {
            printSuccess()
        }
    }
}
