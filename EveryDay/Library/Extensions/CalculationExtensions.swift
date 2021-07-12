//
//  CalculationExtensions.swift
//  EveryDay
//
//  Created by "pl" on 2019/12/19.

import Foundation
import UIKit

// MARK: - CGFloat
extension CGFloat {
    func roundFraction(_ digits: Int) -> Self {
        let divisor = pow(10.0, CGFloat(digits))
        return (self * divisor).rounded() / divisor
    }
}
