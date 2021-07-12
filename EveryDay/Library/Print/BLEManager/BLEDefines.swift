//
//  BLEDefines.swift
//  EveryDay
//
//  Created by "pl" on 2019/12/25.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BLEState: Int {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
    
    var isPoweredOn: Bool { return self == .poweredOn }
}

enum PerpheralWriteType  {
    case all
    case part(Int) //允许写入的字节数
}

@available(iOS 10.0, *)
extension CBManagerState {
    var bleState: BLEState {
        switch self {
        case .unknown: return .unknown
        case .resetting: return .resetting
        case .unsupported: return .unsupported
        case .unauthorized: return .unauthorized
        case .poweredOff: return .poweredOff
        case .poweredOn: return .poweredOn
        default: return .unknown
        }
    }
}

extension CBCentralManagerState {
    var bleState: BLEState {
        switch self {
        case .unknown: return .unknown
        case .resetting: return .resetting
        case .unsupported: return .unsupported
        case .unauthorized: return .unauthorized
        case .poweredOff: return .poweredOff
        case .poweredOn: return .poweredOn
        default: return .unknown
        }
    }
}

let CentralQueueID = "CentralQueue"
let LAST_PERIPHERAL_NAME = "lastPeripheralName"
let DEFAULT_PERIPHERAL_NAME = "HPRT"
let BLE_RECOMMEND_PREFIX = "BTP"
let kConnectedPeripheralIdentifiersKey = "kConnectedPeripheralIdentifiersKey"
let kLastConnectedPeripheralIdentifiersKey = "kLastConnectedPeripheralIdentifiersKey"
let kDefaultSendDataCount = 20
