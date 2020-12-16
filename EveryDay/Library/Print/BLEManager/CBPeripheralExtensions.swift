//
//  CBPeripheralExtensions.swift
//  ExtremePlusDriver
//
//  Created by "pl" on 2019/12/25.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: - File Constants
fileprivate struct Constants {
    static let kMacAddressAssociatedKey = UnsafeRawPointer(bitPattern: "k_RefreshAssociatedHeaderKey".hashValue)!
    static let kRecommendPrefixKey = "BTP"
}

extension CBPeripheral {
    
    var macAddress: String? {
        get {
            objc_getAssociatedObject(self, Constants.kMacAddressAssociatedKey) as? String
        }
        set {
            objc_setAssociatedObject(self, Constants.kMacAddressAssociatedKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var isFirstConnect: Bool {
        return false == (BLEManager.connectedPeripheralIdentifiers[name ?? ""] ?? false)
    }
    
    var isRecommendConnect: Bool {
        guard isFirstConnect else { return false }
        return name?.hasPrefix(Constants.kRecommendPrefixKey) ?? false
    }
    
    var isRepeatConnect: Bool {
        return true == BLEManager.connectedPeripheralIdentifiers[identifier.uuidString]
    }
    
    var isConnected: Bool {
        guard BLEManager.isConnected else { return false }
        return BLEManager.shared.connectedPeripheral?.identifier.uuidString == identifier.uuidString
    }
    
    var isConnecting: Bool {
        return state == .connecting
    }
}
