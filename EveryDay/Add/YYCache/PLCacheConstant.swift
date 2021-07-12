//
//  PLCacheUtil.swift
//  EveryDay
//
//  Created by pl on 2021/6/9.
//

import Foundation

/// (() -> Void)
public typealias PLCacheVoidBlock = (() -> Void)

/// ((P) -> Void)
public typealias PLCacheStyleOneBlock<P> = ((P) -> Void)
/// ((P?) -> Void)
public typealias PLCacheStyleTwoBlock<P> = ((P?) -> Void)
/// ((P1, P2) -> Void)
public typealias PLCacheStyleThreeBlock<P1, P2> = ((P1, P2) -> Void)
/// ((P1?, P2) -> Void)
public typealias PLCacheStyleFourBlock<P1, P2> = ((P1?, P2) -> Void)
/// ((P1, P2?) -> Void)
public typealias PLCacheStyleFiveBlock<P1, P2> = ((P1, P2?) -> Void)
/// ((P1?, P2?) -> Void)
public typealias PLCacheStyleSixBlock<P1, P2> = ((P1?, P2?) -> Void)

internal func SyncSafeMain(callBack: PLCacheVoidBlock) {
    if Thread.isMainThread {
        callBack()
    } else {
        DispatchQueue.main.sync { callBack() }
    }
}

internal func AsyncRelease(_ isOnMainThread: Bool, callBack: @escaping PLCacheVoidBlock) {
    if isOnMainThread {
        DispatchQueue.main.async { callBack() }
    } else {
        DispatchQueue.global(qos: .utility).async {
            callBack()
        }
    }
}

internal extension Array {
    mutating func add(_ element: Element?) {
        guard let e = element else { return }
        append(e)
    }
}


