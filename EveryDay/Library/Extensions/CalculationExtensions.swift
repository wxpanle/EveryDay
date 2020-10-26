//
//  CalculationExtensions.swift
//  ExtremePlusDriver
//
//  Created by SF-潘乐 on 2019/12/19.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation
import UIKit

// MARK: - CGFloat
extension CGFloat {
    func roundFraction(_ digits: Int) -> Self {
        let divisor = pow(10.0, CGFloat(digits))
        return (self * divisor).rounded() / divisor
    }
}
