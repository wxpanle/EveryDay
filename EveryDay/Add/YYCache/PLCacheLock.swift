//
//  PLCacheLock.swift
//  EveryDay
//
//  Created by pl on 2021/6/10.
//

import Foundation

class MutextLock {
    private var mutextLock = pthread_mutex_t()
    
    init() {
        pthread_mutex_init(&mutextLock, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&mutextLock)
    }
    
    func execute(_ block: (() -> Void)) {
        lock()
        block()
        unLock()
    }
    
    func lock() {
        pthread_mutex_lock(&mutextLock)
    }
    
    func unLock() {
        pthread_mutex_unlock(&mutextLock)
    }
    
    func tryLock() -> Bool {
        return pthread_mutex_trylock(&mutextLock) == 0
    }
}


class SemaphoreLock {
    private var semaphore = DispatchSemaphore(value: 1)
    
    init() { }
    deinit {
        semaphore.signal()
    }
    
    func execute(_ block: (() -> Void)) {
        lock()
        block()
        unLock()
    }
    
    func lock() {
        semaphore.wait()
    }
    
    func unLock() {
        semaphore.signal()
    }
}
