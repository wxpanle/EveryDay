//
//  UIApplication+OpenUrl.swift
//  EveryDay
//
//  Created by on 2020/5/31.

import Foundation
import UIKit

extension UIApplication {
    static func startUrl(_ url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
