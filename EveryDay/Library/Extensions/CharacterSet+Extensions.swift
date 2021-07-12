//
//  CharacterSet+Extensions.swift
//  EveryDay
//
//  Created by pl on 2021/6/10.
//

import Foundation

extension CharacterSet {
    public static var sf_urlQueryNotAllowed: CharacterSet = CharacterSet.init(charactersIn: "!*'();:@&=+$,/?%#[]~")
}
