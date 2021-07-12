//
//  Timer+Ectension.swift
//  EveryDay
//
//  Created by SF-潘乐 on 2021/6/10.
//

import Foundation

extension Timer {
//    public convenience init(timeInterval ti: TimeInterval,
//                            weakTarget aWeakTarget: Any,
//                            selector aSelector: Selector,
//                            userInfo: Any?,
//                            repeats yesOrNo: Bool) {
//        let proxy = WeakProxy(target: aWeakTarget as AnyObject)
//        self.init(timeInterval: ti, target: proxy, selector: aSelector, userInfo: userInfo, repeats: yesOrNo)
//        proxy.deinitCallback = { [weak self] in
//            self?.invalidate()
//            debugPrint("timer invalidate")
//        }
//    }
//
//    public convenience init(fireAt date: Date,
//                            interval ti: TimeInterval,
//                            weakTarget aWeakTarget: Any,
//                            selector aSelector: Selector,
//                            userInfo: Any?,
//                            repeats yesOrNo: Bool) {
//        let proxy = WeakProxy(target: aWeakTarget as AnyObject)
//
//        self.init(fireAt: date, interval: ti, target: proxy, selector: aSelector, userInfo: userInfo, repeats: yesOrNo)
//        proxy.deinitCallback = { [weak self] in
//            self?.invalidate()
//            debugPrint("timer invalidate")
//        }
//    }
    
    /// 创建并启动Timer，此方法对 target 弱持有，可放心使用
    /// - Parameters:
    ///   - ti: 触发方法调用的时间间隔
    ///   - aWeakTarget: 弱引用的 target
    ///   - aSelector: 所调用的方法，需要在 target 中存在
    ///   - userInfo: 参数
    ///   - yesOrNo: 是否需要循环
    @discardableResult
    public class func scheduledTimer(timeInterval ti: TimeInterval,
                                     weakTarget aWeakTarget: Any,
                                     selector aSelector: Selector,
                                     userInfo: Any?,
                                     repeats yesOrNo: Bool) -> Timer {
        let proxy = WeakProxy(target: aWeakTarget as AnyObject)
        let timer = scheduledTimer(timeInterval: ti, target: proxy, selector: aSelector, userInfo: userInfo, repeats: yesOrNo)
        proxy.deinitCallback = {
            timer.invalidate()
            debugPrint("timer invalidate")
        }
        return timer
    }
}


