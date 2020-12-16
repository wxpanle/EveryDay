//
//  UIApplication+OpenUrl.swift
//  ExtremePlusDriver
//
//  Created by on 2020/5/31.
//  Copyright © 2020 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

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
