//
//  ScreenExtensions.swift
//  ExtremePlusDriver
//
//  Created by SF-潘乐 on 2019/12/18.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation
import NXDesign
import SFFoundation

fileprivate let UIWidth: CGFloat = 375.0
fileprivate let UIHeight: CGFloat = 667.0

extension UIScreen {
    
    /// 屏幕宽度缩放
    static var widthScale: CGFloat {
        return SF.Const.screenWidth / UIWidth
    }
    /// 屏幕高度缩放
    static var heightScale: CGFloat {
        return SF.Const.screenHeight / UIHeight
    }
}

extension CGFloat {
    
    /// UI宽度调整
    var uiWidthAdjust: CGFloat {
        return self * UIScreen.widthScale
    }
    /// UI高度调整
    var uiHeightAdjust: CGFloat {
        return self * UIScreen.heightScale
    }
}

