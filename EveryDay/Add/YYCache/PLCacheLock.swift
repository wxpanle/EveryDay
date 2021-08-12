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
    
    // 内存管理
    
    /*
     
     Objective-C的内存管理 - 引用计数
     
     什么是引用计数？ 值类型  引用类型
     
     两个时代 MRC ARC
     
     MRC 手动管理内存 （retain release）
     ARC 自动管理内存 （降低程序崩溃、减少开发工作量、减少内存泄漏）
     
     1.什么是自动引用计数？
     内存管理中对引用采取自动计数的技术。
     
     本质上是在编译期自动插入 retain release 代码
     
     生成对象   持有对象   释放对象   废弃对象
     
     2.内存管理的思考方式
     自己生成的对象，自己所持有
     非自己生成的对象，自己也能持有
     不再需要自己持有的对象时释放
     非自己持有的对象无法释放
     
     生成并持有对象  alloc/new/copy/mutablecopy
     持有对象  retain
     释放对象  release
     废弃对象  dealloc
     
     autorelease
     
     autoreleasepool
     
     ARC下的属性修饰符  strong weak copy nonatomic atomic readwrite readonly
     
     */
}
