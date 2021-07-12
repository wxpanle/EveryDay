//
//  ArrayExtension.swift
//  EveryDay
//
//  Created by on 2019/11/8.

import Foundation

extension Array {
    /// 安全移除数组下标
    mutating func removeAt(_ index: Int) {
        guard index >= 0 && index < self.count else { return }
        remove(at: index)
    }
    
    public func at(_ index: Int) -> Element? {
        guard index >= 0, index < self.count else { return nil }
        return self[index];
    }
}

extension Array where Element : Equatable {
    /// 移除所有在 array 内的数据
    public mutating func removeElements(in array: Array<Element>) {
        removeAll(where: { array.contains($0) })
    }
    
    /// 去重
    public func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        var filterResult = [E]()
        let filterList = self.map { filter($0) }
        
        for (index, element) in filterList.enumerated() {
            if !filterResult.contains(element) {
                result.append(self[index])
                filterResult.append(element)
            }
        }
        return result
    }
}
