//
//  PLCache.swift
//  EveryDay
//
//  Created by pl on 2021/4/25.
//

import Foundation

public class PLCache: NSObject {
    // MARK: - Property
    
    /// 缓存识别符
    public var identifier: String { memoryCache.identifier }
    /// 内存缓存
    public private(set) var memoryCache: PLMemoryCache
    /// 磁盘缓存
    public private(set) var diskCache: PLDiskCache
    
    // MARK: - Initial
    
    /// 使用特定的标记创建一个缓存
    /// - Parameter identifier: 唯一识别符
    /// - Returns: Self
    public class func cache(identifier: String = "plcache") -> Self {
        return cache(path: identifier.cachePath)
    }
    
    /// 使用特定的路径创建一个缓存  多个路径会覆盖
    /// - Parameter path: 路径
    /// - Returns: Self
    public class func cache(path: String) -> Self {
        if path.isEmpty { return cache() }
        return self.init(path: path)
    }
    
    public required init(path: String) {
        diskCache = PLDiskCache.cache(path: path)
        memoryCache = PLMemoryCache.cache(identifier: path.lastPathComponent)
        super.init()
    }
    
    // MARK: - Public Query
    
    /// 查询某个缓存是否存在
    /// - Parameter key: key
    /// - Returns: true or false
    public func isExistedCache(for key: String) -> Bool {
        return memoryCache.isExistedCache(for: key) || diskCache.isExistedCache(for: key)
    }
    
    /// 查询某个缓存是否存在
    /// - Parameters:
    ///   - key: key 缓存唯一标识
    ///   - callBack: 回调
    public func isExistedCache(for key: String, callBack: @escaping PLCacheStyleThreeBlock<String, Bool>) {
        callBack(key, true)
    }

    // MARK: - Public Select
    
    public func select<T>(for key: String, type: T.Type) -> T? where T: Codable {
//        id<NSCoding> object = [_memoryCache objectForKey:key];
//        if (!object) {
//            object = [_diskCache objectForKey:key];
//            if (object) {
//                [_memoryCache setObject:object forKey:key];
//            }
//        }
//        return object;
        return nil
    }
    
    /// 查询一个缓存
    /// - Parameters:
    ///   - key: 缓存key
    ///   - callBack: 回调
    public func select<T>(for key: String, type: T.Type, callBack: @escaping PLCacheStyleFiveBlock<String, T>) where T: Codable {
//        id<NSCoding> object = [_memoryCache objectForKey:key];
//        if (object) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                block(key, object);
//            });
//        } else {
//            [_diskCache objectForKey:key withBlock:^(NSString *key, id<NSCoding> object) {
//                if (object && ![_memoryCache objectForKey:key]) {
//                    [_memoryCache setObject:object forKey:key];
//                }
//                block(key, object);
//            }];
//        }
    }
    
    // MARK: - Public Update
    
    public func update(for key: String, cache: Codable) {
//        [_memoryCache setObject:object forKey:key];
//        [_diskCache setObject:object forKey:key];
    }
    
    public func update(for key: String, cache: Codable, callBack: PLCacheStyleOneBlock<String>) {
//        [_memoryCache setObject:object forKey:key];
//        [_diskCache setObject:object forKey:key withBlock:block];
    }
    
    // MARK: - Public Remove
    
    public func remove(for key: String) {
//        [_memoryCache removeObjectForKey:key];
//        [_diskCache removeObjectForKey:key];
    }
    
    public func remove(for key: String, callBack: PLCacheStyleOneBlock<String>) {
//        [_memoryCache removeObjectForKey:key];
//        [_diskCache removeObjectForKey:key withBlock:block];
    }
    
    public func removeAll() {
//        [_memoryCache removeAllObjects];
//        [_diskCache removeAllObjects];
    }

    public func removeAll(callBack: PLCacheVoidBlock) {
//        [_memoryCache removeAllObjects];
//        [_diskCache removeAllObjectsWithBlock:block];
    }
    
    public override var description: String {
        return "PLCache \(identifier) \(self)"
    }
}
