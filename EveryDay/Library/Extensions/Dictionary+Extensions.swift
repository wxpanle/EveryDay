//
//  Dictionary+Extensions.swift
//  EveryDay
//
//  Created by pl on 2021/6/10.
//

import Foundation

public func CombinedURLString(params: Dictionary<String, CustomStringConvertible>?) -> String {
    guard let params = params else { return "" }
    var paramsArray = Array<String>()
    params.forEach { (key, value) in
        let kv = (key.URLEncode() ?? "") + "=" + (value.description.URLEncode() ?? "")
        paramsArray.append(kv)
    }
    return paramsArray.joined(separator: "&")
}

extension Dictionary {
    public var jsonString: String? {
        if let data = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted), let jsonString = String(data: data, encoding: String.Encoding.utf8) {
            return jsonString
        }
        return nil
    }
}
