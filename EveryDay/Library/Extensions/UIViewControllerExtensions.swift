//
//  UIViewControllerExtensions.swift
//  EveryDay
//
//  Created by  on 2020/3/9.

import Foundation
import UIKit

extension UIViewController {
    var isVisible: Bool { return isViewLoaded && nil != view.window }
}
