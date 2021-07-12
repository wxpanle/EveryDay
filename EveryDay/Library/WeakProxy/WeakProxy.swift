//
//  WeakProxy.swift
//  EveryDay
//
//  Created by pl on 2021/6/10.
//

import Foundation

public class WeakProxy: NSObject {

    public var deinitCallback: (()->())? {
        set {
            if tracker != nil {
                removeTracker()
            } else {
                let tracker = Tracker(newValue)
                self.tracker = tracker
                setTracker(tracker)
            }
        }
        get { tracker?.deinitCallback }
    }

    public weak var target: AnyObject?
    private weak var tracker: Tracker?

    deinit {
        debugPrint("SFWeakProxy deinit")
    }

    public init(target: AnyObject) {
        self.target = target
    }

    public class func proxy(target: AnyObject) -> WeakProxy {
        return WeakProxy(target: target)
    }

    public func removeTracker() {
        guard let tracker = tracker else { return }
        tracker.deinitCallback = nil
        setTracker(nil)
    }

    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }

    override public func isProxy() -> Bool {
        return true
    }

    private func setTracker(_ value: Any?) {
        guard let target = target else { return }
        guard let tracker = tracker else { return }
        objc_setAssociatedObject(target, Unmanaged.passUnretained(tracker).toOpaque(), value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    class Tracker {
        var deinitCallback: (()->())?

        init(_ deinitCallback: (()->())?) {
            self.deinitCallback = deinitCallback
        }

        deinit {
            deinitCallback?()
        }
    }
}
