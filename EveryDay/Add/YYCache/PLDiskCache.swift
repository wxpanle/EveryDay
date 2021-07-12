//
//  PLDiskCache.swift
//  EveryDay
//
//  Created by pl on 2021/4/25.
//

import Foundation
import UIKit

/// weak reference for all instances
let globalInstances = NSMapTable<NSString, PLDiskCache>.init(keyOptions: .strongMemory, valueOptions: .weakMemory)
let globalInstancesLock = DispatchSemaphore(value: 1)

func DiskCacheGetGlobal(_ path: String) -> PLDiskCache? {
    guard !path.isEmpty else { return nil }
    globalInstancesLock.wait()
    let cache = globalInstances.object(forKey: path as NSString)
    globalInstancesLock.signal()
    return cache
}

func DiskCacheSetGlobal(_ cache: PLDiskCache) {
    guard !cache.path.isEmpty else { return  }
    globalInstancesLock.wait()
    globalInstances.setObject(cache, forKey: cache.path as NSString)
    globalInstancesLock.wait()
}

public class PLDiskCache {
    // MARK: - Property
    
    /// 唯一识别符
    public private(set) var identifier: String = ""
    /// 磁盘缓存路径
    public private(set) var path: String = ""
    
    /// 如果对象的数据大小大于此值，对象存储为文件，否则会存储在DB中
    public private(set) var inlineThreshold: UInt = 20480
//    YYKVStorage *_kv;
//    dispatch_semaphore_t _lock;
//    dispatch_queue_t _queue;
    
    public private(set) var countLimit = UInt.max
    public private(set) var costLimit = UInt.max
    public private(set) var ageLimit = Double.greatestFiniteMagnitude
    public private(set) var freeDiskSpaceLimit = UInt.max
    public private(set) var autoTrimInterval: TimeInterval = 60
    
    private var kv: PLKVStorage?
    private var semaphore = SemaphoreLock()
    private var queue = DispatchQueue(label: "com.pl.disk.cache", attributes: .concurrent)
    
    // MARK: - Initial
    
    public class func cache(path: String, threshold: UInt = 0) -> PLDiskCache {
        if let diskCache = DiskCacheGetGlobal(path) {
            return diskCache
        }
        return Self.init(path: path)
    }
    
    public required init(path: String, threshold: UInt = 0) {
        self.path = path
        self.identifier = path.lastPathComponent

        self.kv = PLKVStorage.storage(path: path, style: threshold.storageStyle)

        self.path = path
        self.inlineThreshold = threshold

//        [self _trimRecursively];
        DiskCacheSetGlobal(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillBeTerminated), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        queue.suspend()
    }
    
    // MARK: - Public
    
    /// 某一个key对应的缓存是否存在
    /// - Parameter key: key
    /// - Returns: true or false
    public func isExistedCache(for key: String) -> Bool {
        semaphore.execute {
//            BOOL contains = [_kv itemExistsForKey:key];
        }
        return true
    }
    
    private func fileName(for key: String) -> String {
        // 支持自定义 TODO
        return key.md5()
    }

    public func isExistedCache(for key: String, callBack: @escaping PLCacheStyleThreeBlock<String, Bool>) {
        queue.async { [weak self] in
            guard let self = self else { return }
            callBack(key, self.isExistedCache(for: key))
        }
    }
    
    public func select<T>(for key: String, type: T.Type) -> T? {
        return nil
//        Lock();
//        YYKVStorageItem *item = [_kv getItemForKey:key];
//        Unlock();
//        if (!item.value) return nil;
//
//        id object = nil;
//        if (_customUnarchiveBlock) {
//            object = _customUnarchiveBlock(item.value);
//        } else {
//            @try {
//                object = [NSKeyedUnarchiver unarchiveObjectWithData:item.value];
//            }
//            @catch (NSException *exception) {
//                // nothing to do...
//            }
//        }
//        if (object && item.extendedData) {
//            [YYDiskCache setExtendedData:item.extendedData toObject:object];
//        }
//        return object;
    }
    
    
    public func select<T>(for key: String, type: T.Type, callBack: PLCacheStyleFiveBlock<String, T>) {
//        __weak typeof(self) _self = self;
//        dispatch_async(_queue, ^{
//            __strong typeof(_self) self = _self;
//            id<NSCoding> object = [self objectForKey:key];
//            block(key, object);
//        });
    }
    
    public func update(for key: String, cache: Codable?) {
//        if (!key) return;
//        if (!object) {
//            [self removeObjectForKey:key];
//            return;
//        }
//
//        NSData *extendedData = [YYDiskCache getExtendedDataFromObject:object];
//        NSData *value = nil;
//        if (_customArchiveBlock) {
//            value = _customArchiveBlock(object);
//        } else {
//            @try {
//                value = [NSKeyedArchiver archivedDataWithRootObject:object];
//            }
//            @catch (NSException *exception) {
//                // nothing to do...
//            }
//        }
//        if (!value) return;
//        NSString *filename = nil;
//        if (_kv.type != YYKVStorageTypeSQLite) {
//            if (value.length > _inlineThreshold) {
//                filename = [self _filenameForKey:key];
//            }
//        }
//
//        Lock();
//        [_kv saveItemWithKey:key value:value filename:filename extendedData:extendedData];
//        Unlock();
    }
    
    public func update(for key: String, cache: Codable?, callBack: PLCacheVoidBlock) {
//        __weak typeof(self) _self = self;
//        dispatch_async(_queue, ^{
//            __strong typeof(_self) self = _self;
//            [self setObject:object forKey:key];
//            if (block) block();
//        });
//
//        queue.async { [weak self] in
//            guard let self = self else { return }
//            self.update(for: <#T##String#>)
//        }
    }


//    - (void)removeObjectForKey:(NSString *)key {
//        if (!key) return;
//        Lock();
//        [_kv removeItemForKey:key];
//        Unlock();
//    }
//
//    - (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block {
//        __weak typeof(self) _self = self;
//        dispatch_async(_queue, ^{
//            __strong typeof(_self) self = _self;
//            [self removeObjectForKey:key];
//            if (block) block(key);
//        });
//    }
//
//    - (void)removeAllObjects {
//        Lock();
//        [_kv removeAllItems];
//        Unlock();
//    }
//
//    - (void)removeAllObjectsWithBlock:(void(^)(void))block {
//        __weak typeof(self) _self = self;
//        dispatch_async(_queue, ^{
//            __strong typeof(_self) self = _self;
//            [self removeAllObjects];
//            if (block) block();
//        });
//    }
//
//    - (void)removeAllObjectsWithProgressBlock:(void(^)(int removedCount, int totalCount))progress
//                                     endBlock:(void(^)(BOOL error))end {
//        __weak typeof(self) _self = self;
//        dispatch_async(_queue, ^{
//            __strong typeof(_self) self = _self;
//            if (!self) {
//                if (end) end(YES);
//                return;
//            }
//            Lock();
//            [_kv removeAllItemsWithProgressBlock:progress endBlock:end];
//            Unlock();
//        });
//    }
//
//    - (NSInteger)totalCount {
//        Lock();
//        int count = [_kv getItemsCount];
//        Unlock();
//        return count;
//    }
//
//    - (void)totalCountWithBlock:(void(^)(NSInteger totalCount))block {
//        if (!block) return;
//        __weak typeof(self) _self = self;
//        dispatch_async(_queue, ^{
//            __strong typeof(_self) self = _self;
//            NSInteger totalCount = [self totalCount];
//            block(totalCount);
//        });
//    }
//
//    - (NSInteger)totalCost {
//        Lock();
//        int count = [_kv getItemsSize];
//        Unlock();
//        return count;
//    }
//
//    - (void)totalCostWithBlock:(void(^)(NSInteger totalCost))block {
//        if (!block) return;
//        __weak typeof(self) _self = self;
//        dispatch_async(_queue, ^{
//            __strong typeof(_self) self = _self;
//            NSInteger totalCost = [self totalCost];
//            block(totalCost);
//        });
//    }
//
//    - (void)trimToCount:(NSUInteger)count {
//        Lock();
//        [self _trimToCount:count];
//        Unlock();
//    }
//
//    - (void)trimToCount:(NSUInteger)count withBlock:(void(^)(void))block {
//        __weak typeof(self) _self = self;
//        dispatch_async(_queue, ^{
//            __strong typeof(_self) self = _self;
//            [self trimToCount:count];
//            if (block) block();
//        });
//    }
//
//    - (void)trimToCost:(NSUInteger)cost {
//        Lock();
//        [self _trimToCost:cost];
//        Unlock();
//    }
//
//    - (void)trimToCost:(NSUInteger)cost withBlock:(void(^)(void))block {
//        __weak typeof(self) _self = self;
//        dispatch_async(_queue, ^{
//            __strong typeof(_self) self = _self;
//            [self trimToCost:cost];
//            if (block) block();
//        });
//    }
//
//    - (void)trimToAge:(NSTimeInterval)age {
//        Lock();
//        [self _trimToAge:age];
//        Unlock();
//    }
//
//    - (void)trimToAge:(NSTimeInterval)age withBlock:(void(^)(void))block {
//        __weak typeof(self) _self = self;
//        dispatch_async(_queue, ^{
//            __strong typeof(_self) self = _self;
//            [self trimToAge:age];
//            if (block) block();
//        });
//    }
//
//    + (NSData *)getExtendedDataFromObject:(id)object {
//        if (!object) return nil;
//        return (NSData *)objc_getAssociatedObject(object, &extended_data_key);
//    }
//
//    + (void)setExtendedData:(NSData *)extendedData toObject:(id)object {
//        if (!object) return;
//        objc_setAssociatedObject(object, &extended_data_key, extendedData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//
//    - (NSString *)description {
//        if (_name) return [NSString stringWithFormat:@"<%@: %p> (%@:%@)", self.class, self, _name, _path];
//        else return [NSString stringWithFormat:@"<%@: %p> (%@)", self.class, self, _path];
//    }
//
//    - (BOOL)errorLogsEnabled {
//        Lock();
//        BOOL enabled = _kv.errorLogsEnabled;
//        Unlock();
//        return enabled;
//    }
//
//    - (void)setErrorLogsEnabled:(BOOL)errorLogsEnabled {
//        Lock();
//        _kv.errorLogsEnabled = errorLogsEnabled;
//        Unlock();
//    }
}

fileprivate extension PLDiskCache {
    
    @objc private func appWillBeTerminated() {
        semaphore.execute {
            kv = nil
        }
    }
    
//    - (void)_trimRecursively {
//        __weak typeof(self) _self = self;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//            __strong typeof(_self) self = _self;
//            if (!self) return;
//            [self _trimInBackground];
//            [self _trimRecursively];
//        });
//    }
//
//    - (void)_trimInBackground {
//        __weak typeof(self) _self = self;
//        dispatch_async(_queue, ^{
//            __strong typeof(_self) self = _self;
//            if (!self) return;
//            Lock();
//            [self _trimToCost:self.costLimit];
//            [self _trimToCount:self.countLimit];
//            [self _trimToAge:self.ageLimit];
//            [self _trimToFreeDiskSpace:self.freeDiskSpaceLimit];
//            Unlock();
//        });
//    }
//
//    - (void)_trimToCost:(NSUInteger)costLimit {
//        if (costLimit >= INT_MAX) return;
//        [_kv removeItemsToFitSize:(int)costLimit];
//
//    }
//
//    - (void)_trimToCount:(NSUInteger)countLimit {
//        if (countLimit >= INT_MAX) return;
//        [_kv removeItemsToFitCount:(int)countLimit];
//    }
//
//    - (void)_trimToAge:(NSTimeInterval)ageLimit {
//        if (ageLimit <= 0) {
//            [_kv removeAllItems];
//            return;
//        }
//        long timestamp = time(NULL);
//        if (timestamp <= ageLimit) return;
//        long age = timestamp - ageLimit;
//        if (age >= INT_MAX) return;
//        [_kv removeItemsEarlierThanTime:(int)age];
//    }
//
//    - (void)_trimToFreeDiskSpace:(NSUInteger)targetFreeDiskSpace {
//        if (targetFreeDiskSpace == 0) return;
//        int64_t totalBytes = [_kv getItemsSize];
//        if (totalBytes <= 0) return;
//        int64_t diskFreeBytes = _YYDiskSpaceFree();
//        if (diskFreeBytes < 0) return;
//        int64_t needTrimBytes = targetFreeDiskSpace - diskFreeBytes;
//        if (needTrimBytes <= 0) return;
//        int64_t costLimit = totalBytes - needTrimBytes;
//        if (costLimit < 0) costLimit = 0;
//        [self _trimToCost:(int)costLimit];
//    }
}
