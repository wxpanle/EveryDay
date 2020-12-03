//
//  UIViewControllerExtensions.swift
//  ExtremePlusDriver
//
//  Created by SF-潘乐 on 2020/3/9.
//  Copyright © 2020 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var isVisible: Bool { return isViewLoaded && nil != view.window }
}
