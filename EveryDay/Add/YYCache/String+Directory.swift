//
//  CacheHelp.swift
//  EveryDay
//
//  Created by pl on 2021/6/9.
//

import Foundation

fileprivate func CacheDirectory() -> String {
    if let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
        return path
    }
    return NSHomeDirectory() + "/Library/Caches"
}

/// Free disk space in bytes.
func DiskSpaceFree() -> Int64 {
    do {
        let attrs = try FileManager.default.attributesOfItem(atPath: NSHomeDirectory())
        return attrs[FileAttributeKey.systemFreeSize] as? Int64 ?? 0
    } catch  {
        return -1
    }
}

internal extension String {
    
    /// 拼接缓存路径
    var cachePath: Self {
        if self.hasPrefix("/") {
            return CacheDirectory() + self
        } else {
            return CacheDirectory() + "/" + self
        }
    }
    
    /// 获取路径最后一个参数
    var lastPathComponent: Self {
        return self.components(separatedBy: "/").last ?? self
    }
}
