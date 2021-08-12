//
//  UIViewExtensions+Print.swift
//  EveryDay
//
//  Created by "pl" on 2019/12/26.
//   All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    var renderImage: UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
