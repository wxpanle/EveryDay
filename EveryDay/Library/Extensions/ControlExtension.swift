//
//  ControlExtension.swift
//  ExtremePlusDriver
//
//  Created by SF-潘乐 on 2019/11/15.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIControl {
    /// 扩大点击事件范围
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let widthDelta = max(44.0 - bounds.size.width, 0)
        let heightDelta = max(44.0 - bounds.size.height, 0)
        let resultBounds = bounds.insetBy(dx: -0.5 * widthDelta, dy: -0.5 * heightDelta)
        return resultBounds.contains(point)
    }
}
