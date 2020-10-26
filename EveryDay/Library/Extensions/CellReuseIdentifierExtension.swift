//
//  CellReuseIdentifierExtension.swift
//  ExtremePlusDriver
//
//  Created by SF-潘乐 on 2019/10/12.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Foundation
import UIKit
import NXDesign
import SFFoundation

public protocol RegisterReuseIdentifierProtocol: AnyObject {
    static var defaultNibName: String { get }
    static var defaultReuseIdentifier: String { get }
}

public protocol RegisterCellProtocol: RegisterReuseIdentifierProtocol {
    
    static func registerClassCell<T: UITableView>(to tableView: T) -> Void
    static func registerNibCell<T: UITableView>(to tableView: T) -> Void
    static func dequeueReusableCell<T: UITableView>(with tableView: T, for indexPath: IndexPath) -> Self
}

public protocol RegisterHeaderFooterProtocol: RegisterReuseIdentifierProtocol {
    static func registerHeaderFooterView<T: UITableView>(to tableView: T) -> Void
    static func dequeueReusableHeaderFooterView<T: UITableView>(with tableView: T) -> Self
}

extension UICollectionViewCell: RegisterReuseIdentifierProtocol {
    public static var defaultNibName: String {
        return self.defaultReuseIdentifier
    }
    
    public static var defaultReuseIdentifier: String {
        return String.init(describing: self.classForCoder())
    }
}

extension UITableViewCell: RegisterCellProtocol {
    
    public static var defaultNibName: String {
        return self.defaultReuseIdentifier
    }

    public static var defaultReuseIdentifier: String {
        return String.init(describing: self.classForCoder())
    }

    public static func registerClassCell<T>(to tableView: T) where T : UITableView {
        tableView.register(self, forCellReuseIdentifier: self.defaultReuseIdentifier)
    }

    public static func registerNibCell<T>(to tableView: T) where T : UITableView {
        tableView.register(UINib.init(nibName: self.defaultNibName, bundle: nil), forCellReuseIdentifier: self.defaultReuseIdentifier)
    }

    public static func dequeueReusableCell<T>(with tableView: T, for indexPath: IndexPath) -> Self where T : UITableView {
        return tableView.dequeueReusableCell(withIdentifier: self.defaultReuseIdentifier, for: indexPath) as! Self
    }
}

extension UITableViewHeaderFooterView: RegisterHeaderFooterProtocol {
    
    public static var defaultNibName: String {
        return self.defaultReuseIdentifier
    }
    
    public static var defaultReuseIdentifier: String {
        return String.init(describing: self.classForCoder())
    }
    
    public static func registerHeaderFooterView<T>(to tableView: T) where T : UITableView {
        tableView.register(self, forHeaderFooterViewReuseIdentifier: self.defaultReuseIdentifier)
    }
    
    public static func dequeueReusableHeaderFooterView<T>(with tableView: T) -> Self where T : UITableView {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: self.defaultReuseIdentifier) as! Self
    }
}
