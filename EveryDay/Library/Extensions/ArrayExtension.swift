//
//  ArrayExtension.swift
//  ExtremePlusDriver
//
//  Created by SF-潘乐 on 2019/11/8.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

extension Array {
    /// 安全移除数组下标
    mutating func removeAt(_ index: Int) {
        guard index >= 0 && index < self.count else { return }
        remove(at: index)
    }
    
    mutating func remove(_ isIncluded:(Element) -> Bool) {
        for (index, item) in self.enumerated() {
            if isIncluded(item) {
                remove(at: index)
                break
            }
        }
    }
}
