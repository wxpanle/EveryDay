//
//  NSBundle+Language.swift
//  ExtremePlusDriver
//
//  Created by SF-潘乐 on 2020/5/20.
//  Copyright © 2020 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation

// MARK: - File Constants
fileprivate struct Constants {
    static let kAssociatedBundleKey = UnsafeRawPointer(bitPattern: "k_associatedBundleKey".hashValue)!
}

extension Bundle {

    class func config(language: String?) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else { return }
        guard let bundle = Bundle(path: path) else { return }
        
        let _: () = {
            object_setClass(Bundle.main, BundleLanguage.self)
        }()
        
        objc_setAssociatedObject(Bundle.main, Constants.kAssociatedBundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

class BundleLanguage: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
    
        guard let bBundle = objc_getAssociatedObject(self, Constants.kAssociatedBundleKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bBundle.localizedString(forKey: key, value: value, table: tableName)
    }
}


