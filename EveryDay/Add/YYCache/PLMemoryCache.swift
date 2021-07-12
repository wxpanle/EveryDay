//
//  PLMemoryCache.swift
//  EveryDay
//
//  Created by pl on 2021/4/25.
//

import Foundation
import UIKit

public class PLMemoryCache {
    // MARK: - Property
    
    /// 唯一识别符
    public private(set) var identifier: String = ""
    
    /// 缓存数量限制
    public var countLimit: UInt = UInt.max
    /// 缓存大小限制
    public var costLimit: UInt = UInt.max
    /// 缓存对象的过期时间  默认不会过期
    public var ageLimit: TimeInterval = Double.greatestFiniteMagnitude
    /// 默认检测缓存时间间隔
    public var autoTrimInterval: TimeInterval = 10.0
    /// 收到内存警告时是否移除所有缓存
    public var shouldRemoveAllObjectsOnMemoryWarning: Bool = true
    /// 进入后台的时候是否移除所有缓存
    public var shouldRemoveAllObjectsWhenEnteringBackground: Bool = true
    
    /// 锁
    private var lock = MutextLock()
    private var lruMap = PLLinkedMap()
    private var syncQueue = DispatchQueue(label: "com.plcache.memory")
    
    // MARK: - Initial
    
    public class func cache(identifier: String) -> Self {
        return Self.init(identifier: identifier)
    }
    
    public required init(identifier: String) {
        self.identifier = identifier
        addNotification()
        trimRecursively()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        lruMap.removeAll()
        syncQueue.suspend()
    }

    // MARK: - Public Quere
    
    /// 缓存的数量
    public var totalCount: UInt {
        var result: UInt = 0
        lock.execute { result = lruMap.totalCount }
        return result
    }
    
    /// 缓存的大小
    public var totalCost: UInt {
        var result: UInt = 0
        lock.execute { result = lruMap.totalCost }
        return result
    }
    
    /// 默认在后台线程释放缓存对象
    public var releaseOnMainThread: Bool {
        set {
            lock.execute { lruMap.releaseOnMainThread = newValue }
        }
        get {
            var result: Bool = false
            lock.execute { result = lruMap.releaseOnMainThread }
            return result
        }
    }
    
    /// 异步释放缓存对象
    public var releaseAsynchronously: Bool {
        set {
            lock.execute { lruMap.releaseAsynchronously = newValue }
        }
        get {
            var result: Bool = false
            lock.execute { result = lruMap.releaseAsynchronously }
            return result
        }
    }
    
    /// 判断某个缓存是否存在
    /// - Parameter key: key description
    /// - Returns: description
    public func isExistedCache(for key: String) -> Bool {
        var result = false
        lock.execute { result = lruMap.linkedMap[key] != nil }
        return result
    }
    
    /// 查询某个缓存
    /// - Parameters:
    ///   - key: key description
    ///   - type: 转化为指定对象
    /// - Returns: description
    public func select<T>(for key: String, type: T.Type) -> T? where T: Codable {
        var node: PLLinkedMapNode?
        lock.execute {
            node = lruMap.linkedMap[key]
            if let exist = node {
                exist.time = Date().timeIntervalSince1970
                lruMap.bringToHead(node: exist)
            }
        }
        return node as? T
    }
    
    /// 更新某个缓存 如果 cache == nil 会移除掉缓存
    /// - Parameters:
    ///   - key: key description
    ///   - cache: cache description
    ///   - cost: cost description
    public func update(for key: String, cache: Codable?, cost: UInt = 0) {
        guard !key.isEmpty else { return }
        guard let obj = cache else { return remove(for: key) }
        lock.execute {
            let now = Date().timeIntervalSince1970
            if let exist = lruMap.linkedMap[key] {
                lruMap.totalCost -= exist.cost
                lruMap.totalCost += cost
                exist.cost = cost
                exist.value = obj
                exist.time = now
                lruMap.bringToHead(node: exist)
            } else {
                let node = PLLinkedMapNode(key: key, value: obj)
                node.cost = cost
                node.time = now
                lruMap.insertAtHead(node: node)
            }
            trimCost()
            if lruMap.totalCount > countLimit {
                // 只需要 release 最后一个
                releaseNode(node: lruMap.removeTailNode())
            }
        }
    }
    
    /// 移除某一个缓存
    /// - Parameter key: key
    public func remove(for key: String) {
        guard !key.isEmpty else { return }
        lock.execute {
            if let node = lruMap.linkedMap[key] {
                lruMap.remove(node: node)
                releaseNode(node: node)
            }
        }
    }
    
    /// 移除所有缓存
    public func removeAll() {
        lock.execute { lruMap.removeAll() }
    }
}

// MARK: - Notification
fileprivate extension PLMemoryCache {
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidReceiveMemoryWarningNotification), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc private func appDidReceiveMemoryWarningNotification() {
        guard shouldRemoveAllObjectsOnMemoryWarning else { return  }
        removeAll()
    }
    
    @objc private func appDidEnterBackgroundNotification() {
        guard shouldRemoveAllObjectsWhenEnteringBackground else { return  }
        removeAll()
    }
}

// MARK: - Clean
fileprivate extension PLMemoryCache {
    
    private func releaseNode(node: PLLinkedMapNode?) {
        guard let result = node else { return }
        if lruMap.releaseAsynchronously {
            AsyncRelease(lruMap.releaseOnMainThread) {
                let _ = result
            }
        } else if lruMap.releaseOnMainThread && (pthread_main_np() != 0) {
            DispatchQueue.main.async {
                let _ = result
            }
        }
    }
    
    private func trimCost() {
        guard lruMap.totalCost > costLimit else { return }
        syncQueue.async { [weak self] in
            guard let self = self else { return }
            self.trimToCost(self.costLimit)
        }
    }
    
    private func trimRecursively() {
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + autoTrimInterval) { [weak self] in
            guard let self = self else { return }
            self.trimInBackground()
            self.trimRecursively()
        }
    }
    
    private func trimInBackground() {
        syncQueue.async { [weak self] in
            guard let self = self else { return }
            self.trimToCount(self.countLimit)
            self.trimToCost(self.costLimit)
            self.trimToAge(self.ageLimit)
        }
    }
    
    private func trimToCost(_ cost: UInt) {
        var isFinish = false
        lock.execute {
            if (cost == 0) {
                lruMap.removeAll()
                isFinish = true
            } else if (lruMap.totalCost <= cost) {
                isFinish = true
            }
        }
        guard !isFinish else { return }
        
        handleRemove { () -> Bool in
            return (lruMap.totalCost > cost)
        }
    }
    
    private func trimToCount(_ count: UInt) {
        var isFinish = false
        lock.execute {
            if count == 0 {
                lruMap.removeAll()
                isFinish = true
            } else if lruMap.totalCount <= count {
                isFinish = true
            }
        }
        guard !isFinish else { return }
        
        handleRemove { () -> Bool in
            return (lruMap.totalCount > count)
        }
    }
    
    private func trimToAge(_ age: TimeInterval) {
        var isFinish = false
        let now = Date().timeIntervalSince1970
        lock.execute {
            if (age <= 0) {
                lruMap.removeAll()
                isFinish = true
            } else if ((nil == lruMap.tail) || (now - (lruMap.tail?.time ?? now)) <= age) {
                isFinish = true
            }
        }
        guard !isFinish else { return }
        
        handleRemove { () -> Bool in
            if let tail = lruMap.tail, (now - tail.time) > age {
                return true
            } else {
                return false
            }
        }
    }
    
    private func handleRemove(_ isRemove: (() -> Bool)) {
        var isFinish = false
        var holder = [PLLinkedMapNode]()
        while !isFinish {
            if (lock.tryLock()) {
                if isRemove() {
                    holder.add(lruMap.removeTailNode())
                } else {
                    isFinish = true
                }
                lock.unLock()
            } else {
                usleep(10 * 1000); //10 ms
            }
        }
        guard !holder.isEmpty else { return }
        AsyncRelease(lruMap.releaseOnMainThread) {
            let _ = holder.count
        }
    }
}

/// 链表节点
fileprivate class PLLinkedMapNode {
    var prev: PLLinkedMapNode? // 前一个节点
    var next: PLLinkedMapNode? // 下一个节点
    var cost: UInt = 0
    var time: TimeInterval = 0
    var key: AnyHashable
    var value: Codable
    
    init(key: AnyHashable, value: Codable) {
        self.key = key
        self.value = value
    }
}

fileprivate class PLLinkedMap {
    
    lazy var linkedMap: [AnyHashable: PLLinkedMapNode] = { [:] }()
    var totalCount: UInt = 0
    var totalCost: UInt = 0
    var head: PLLinkedMapNode?
    var tail: PLLinkedMapNode?
    var releaseOnMainThread: Bool = false
    var releaseAsynchronously: Bool = true
        
    deinit {
        clean()
        linkedMap.removeAll()
    }

    func insertAtHead(node: PLLinkedMapNode) {
        linkedMap[node.key] = node
        totalCount += 1
        totalCost += node.cost
        
        if let h = head {
            node.next = h
            h.prev = node
            head = node
        } else {
            head = node
            tail = node
        }
    }

    func bringToHead(node: PLLinkedMapNode) {
        guard head !== node else { return }
        
        if tail === node {
            tail = node.prev
            tail?.next = nil
        } else {
            node.next?.prev = node.prev
            node.prev?.next = node.next
        }
        node.next = head
        node.prev = nil
        head?.prev = node
        head = node
    }

    func remove(node: PLLinkedMapNode) {
        linkedMap.removeValue(forKey: node.key)
        totalCount -= 1
        totalCost -= node.cost
        
        if let n = node.next { n.prev = node.prev }
        if let p = node.prev { p.next = node.next }
        if head === node { head = node.next }
        if tail === node { tail = node.prev }
    }
    
    func removeTailNode() -> PLLinkedMapNode? {
        guard let ttail = tail else { return nil }
        linkedMap.removeValue(forKey: ttail.key)
        if head === tail {
            clean()
        } else {
            tail = ttail.prev
            tail?.next = nil
            totalCount -= 1
            totalCount -= ttail.cost
        }
        return ttail
    }

    func removeAll() {
        clean()
        guard !linkedMap.isEmpty else { return }
        var needReleaseMap = linkedMap
        linkedMap = [:]
        if releaseAsynchronously {
            AsyncRelease(releaseOnMainThread) {
                needReleaseMap.removeAll()
            }
        } else if releaseOnMainThread && (pthread_main_np() != 0) {
            DispatchQueue.main.async {
                needReleaseMap.removeAll()
            }
        }
    }
    
    private func clean() {
        totalCost = 0
        totalCount = 0
        head = nil
        tail = nil
    }
}
