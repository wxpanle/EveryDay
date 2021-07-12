//
//  BLEAlert.swift
//  EveryDay
//
//  Created by "pl" on 2019/12/25.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation
import UIKit

extension BLEManager {
    
    static func OpenBLEAlert() {
        guard let url = URL.init(string: UIApplication.openSettingsURLString) else { return }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

}

