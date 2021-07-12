//
//  BLEManager.swift
//  EveryDay
//
//  Created by "pl" on 2019/12/25.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation
import CoreBluetooth

//MARK: - help
extension BLEManager {
    
    static let shared = BLEManager()
    
    class var isScaning: Bool {
        return BLEManager.shared.isScaning
    }
    
    class var isConnected: Bool {
        guard let peripheral = BLEManager.shared.connectedPeripheral else { return false }
        return peripheral.state == .connected
    }
    
    class var isConnecting: Bool {
        guard let peripheral = BLEManager.shared.connectedPeripheral else { return false }
        return peripheral.state == .connecting
    }
    
    class var isFindCharacteristic: Bool {
        return BLEManager.shared.writeCharacteristic != nil
            || BLEManager.shared.backupCharacteristic != nil
    }
    
    class var isPowerOn: Bool {
        return BLEManager.shared.state.isPoweredOn
    }
    
    class var isEverConnected: Bool {
        return BLEManager.shared.p_lastConnectedPeripheralIdentifier()?.isEmpty ?? false
    }
    
    class var connectedPeripheralIdentifiers: [String : Bool] {
        return BLEManager.shared.connectedPeripheralIdentifiers
    }
    
    class var perpheralWriteType: PerpheralWriteType {
        guard isConnected else { return .part(kDefaultSendDataCount) }
        guard let peripheral = BLEManager.shared.connectedPeripheral else {
            return .part(kDefaultSendDataCount)
        }
        let sendData = peripheral.maximumWriteValueLength(for: writeType)
        return (sendData <= 0) ? .all : .part(sendData)
    }
        
    /// 优先返回writeWithResponse
    private class var writeType: CBCharacteristicWriteType {
        if BLEManager.shared.writeCharacteristic != nil {
            return .withResponse
        } else if BLEManager.shared.backupCharacteristic != nil {
            return .withoutResponse
        } else {
            return .withResponse
        }
    }
}


// MARK: - BLEManager
class BLEManager: NSObject {
    
    weak var delegate: BLEManagerDelegate?
    var isScaning: Bool { return centralManager?.isScanning ?? false }
    
    private var state: BLEState = .unknown
    
    private var centralManager: CBCentralManager?
    private var peripherals = [CBPeripheral]()  // 检索到的设备
    private var peripheralIdentifier = [String : Bool]()
    private var needAutoConnectLastDev = false // 是否需要自动连接上次连接成功的设备
    
    private(set) var connectedPeripheral: CBPeripheral? //已经连接的设备
    lazy private var connectedPeripheralIdentifiers: [String : Bool] = {
        return p_connectedPeripheralIdentifiers() ?? [String : Bool]()
    }()
    
    // CBCharacteristic
    private var writeCharacteristic: CBCharacteristic?
    private var backupCharacteristic: CBCharacteristic?
    private var notifyCharacteristic: CBCharacteristic?
    
    private var overtime: TimeInterval = 20
        
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: [CBCentralManagerOptionShowPowerAlertKey: false])
    }
    
    
    //MARK: -- 接口
    
    /// 开启检索
    func scanPeripherals() {
        scanPeripheralsWithAlert(true)
    }
    
    /// 扫描外设
    func scanPeripheralsWithAlert(_ isNeed: Bool) {
        needAutoConnectLastDev = false
        
        guard state.isPoweredOn else {
            BLEManager.OpenBLEAlert()
            return
        }
        
        startScanPeripherals(timeOut: overtime)
    }
    
    /// 检索设备
    /// - Parameter timeOut: 超时时间
    /// - Parameter needName: 是否需要设备具备设备名称
     private func startScanPeripherals(timeOut: TimeInterval) {
        
        if centralManager?.isScanning ?? false {
            centralManager?.stopScan()
        }
        
        cancelConnect() //cancel
        resetPeripheralStatus()
        overtime = max(timeOut, 20)
        centralManager?.scanForPeripherals(withServices: nil, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey : true])
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(scanFailed), object: nil)
        perform(#selector(scanFailed), with: nil, afterDelay: overtime)
        delegate?.EBLEManagerStartScan(manager: self)
    }

    /// 取消单一连接
    func cancelSingleConnect(_ pripheral: CBPeripheral?) {
        guard let p = pripheral else { return }
        centralManager?.cancelPeripheralConnection(p)
    }

    /// 中心设备断开所有已连接外设
    func cancelConnect() {
        guard let p = connectedPeripheral else { return }
        centralManager?.cancelPeripheralConnection(p)
    }
    
    /// 停止设备检索
    func stopScan() {
        centralManager?.stopScan()
        delegate?.EBLEManagerStopScan(manager: self)
    }

    /// 中心设备连接指定外设
    ///
    /// - Parameter filterBlk: 设备名称匹配，传入name，由业务方判断名称匹配成功与否
    func connectPeripheral(peripheral: CBPeripheral) {
        guard state.isPoweredOn else {
            debugPrint("请打开蓝牙")
            return
        }
        if peripheral.state == .connected || peripheral.state == .connecting { return }
        centralManager?.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey : true])
    }

    func autoConnectPeripheral(overtime: TimeInterval) {
        needAutoConnectLastDev = true
        startScanPeripherals(timeOut: overtime)
    }

    func sendPrintData(data: Data, to peripheral: CBPeripheral?) {
        
        guard let usePeripheral = peripheral,
            let connectedPeripheral = connectedPeripheral else {
            debugPrint("外设不一致")
            return
        }
        
        guard usePeripheral.state == .connected else {
            debugPrint("外设没有连接")
            return
        }
        
        if let writeChara = writeCharacteristic {
            connectedPeripheral.writeValue(data, for: writeChara, type: .withResponse)
        } else if let backupChara = backupCharacteristic {
            connectedPeripheral.writeValue(data, for: backupChara, type: .withoutResponse)
        }
        
        debugPrint("外设链接写入了一次数据")
    }

    @objc private func scanFailed() {
        stopScan()
        delegate?.EBLEManager(manager: self, discover: peripherals, isTimeOut: true, scanError: nil)
    }

    private func resetPeripheralStatus() {
        peripherals.removeAll()
        peripheralIdentifier.removeAll()
    }
    
    private func resetConnectionState() {
        connectedPeripheral = nil
        writeCharacteristic = nil
        backupCharacteristic = nil
        notifyCharacteristic = nil
    }
}

//MARK: -- CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 10.0, *) {
            state = central.state.bleState
        } else {
            state = (central.state.rawValue == CBCentralManagerState.poweredOn.rawValue) ? .poweredOn : .unknown
        }
        delegate?.EBLEManagerStateUpdated(manager: self, state: state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let macData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            peripheral.macAddress = macData.macAddress
        }
    
        if (advertisementData[CBAdvertisementDataIsConnectable] as? Bool) == false {
            return
        }
        
        guard let peripheralName = peripheral.name, !peripheralName.isEmpty else { return }
        
        guard nil == peripheralIdentifier[peripheral.identifier.uuidString] else { return }
        
        peripherals.append(peripheral)
        peripheralIdentifier[peripheral.identifier.uuidString] = true
        
        delegate?.EBLEManager(manager: self, discover: peripherals, isTimeOut: false, scanError: nil)
        
        guard needAutoConnectLastDev,
            let lastPeripheral = p_lastConnectedPeripheralIdentifier() else {
                return
        }
        
        guard lastPeripheral == peripheral.identifier.uuidString else { return }
        connectPeripheral(peripheral: peripheral)
    }

    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        stopScan()
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        delegate?.EBLEManager(manager: self, didConnect: peripheral, error: nil)

        if (connectedPeripheralIdentifiers[peripheral.identifier.uuidString] ?? false) == false {
            connectedPeripheralIdentifiers[peripheral.identifier.uuidString] = true
            p_saveConnectedPeripheralIdentifiers()
        }
        
        // last
        p_saveLastConnectedPeripheralIdentifier(peripheralName: peripheral.identifier.uuidString)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        delegate?.EBLEManager(manager: self, didFailToConnect: peripheral)
        
        guard let connectPeripheral = connectedPeripheral,
            connectPeripheral.identifier.uuidString == peripheral.identifier.uuidString else { return }
        resetConnectionState()
    }
        
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        delegate?.EBLEManager(manager: self, didDisconnect: peripheral, error: error)
        
        // 重置当前链接的外设
        guard let connectPeripheral = connectedPeripheral,
        connectPeripheral.identifier.uuidString == peripheral.identifier.uuidString else { return }
        resetConnectionState()
    }
}

// cache
extension BLEManager {
    
    private func p_saveLastConnectedPeripheralIdentifier(peripheralName: String) {
        UserDefaults.standard.set(peripheralName, forKey: DEFAULT_PERIPHERAL_NAME)
        UserDefaults.standard.synchronize()
    }
        
    private func p_lastConnectedPeripheralIdentifier() -> String? {
        return UserDefaults.standard.value(forKey: kLastConnectedPeripheralIdentifiersKey) as? String
    }
    
    private func p_connectedPeripheralIdentifiers() -> [String : Bool]? {
        return UserDefaults.standard.dictionary(forKey: kConnectedPeripheralIdentifiersKey) as? [String : Bool]
    }
    
    private func p_saveConnectedPeripheralIdentifiers() {
        UserDefaults.standard.set(connectedPeripheralIdentifiers, forKey: kConnectedPeripheralIdentifiersKey)
        UserDefaults.standard.synchronize()
    }
}

// MARK: - CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard nil == error else { return }
        peripheral.services?.forEach {
            peripheral.discoverCharacteristics(nil, for: $0)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let _ = characteristic.value
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        service.characteristics?.forEach({ (characteristic) in
            
            let properties = characteristic.properties
    
            // BTP-P33的数据
            // 49535343-8841-43F4-A8D4-ECBE34729BB3 0xc
            // 49535343-1E4D-4BD9-BA61-23C647249616 0x10
            // 49535343-ACA3-481C-91EC-D85E28A60318  0x18
            
            if characteristic.uuid.uuidString == "49535343-8841-43F4-A8D4-ECBE34729BB3" {
                writeCharacteristic = characteristic
            }
            
//            if properties.rawValue & CBCharacteristicProperties.write.rawValue != 0 {
//                //有反馈写入特征  这个有坑
//                writeCharacteristic = characteristic
//            } else if properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue != 0 {
//                //无反馈写入特征
//                backupCharacteristic = characteristic
//            } else
                
            if properties.rawValue & CBCharacteristicProperties.notify.rawValue != 0 {
                // 通知特征
                notifyCharacteristic = characteristic
                if !characteristic.isNotifying {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
//
//                else if characteristic.properties.rawValue & CBCharacteristicProperties.read.rawValue != 0 {
//                //读特征值
//            }
        })
        
        delegate?.EBLEManager(manager: self, peripheral: peripheral, didRead: nil, error: error)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        delegate?.EBLEManager(manager: self, didFinishSendDataTo: peripheral, error: error)
    }
}

extension Data {
    
    var macAddress: String {
        
        var mac_addrs = [String]()

        let bytes = [UInt8](self)

        for value in bytes {
            mac_addrs.append(String(format: "%02lx", value))
        }
        
        if (mac_addrs.count > 6) {
            return mac_addrs[0...5].joined(separator: ":")
        }

        return mac_addrs.joined(separator: ":")
    }
}
