//
//  UIViewExtensions+Print.swift
//  ExtremePlusDriver
//
//  Created by SF-潘乐 on 2019/12/26.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
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
