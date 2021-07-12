//
//  ViewController.swift
//  EveryDay
//
//  Created by "pl" on 2020/10/20.
//

import UIKit

class TestClass: NSObject {
//    var timer: Timer?
    
    override init() {
        super.init()
//        timer =
            Timer.scheduledTimer(timeInterval: 5, weakTarget: self, selector: #selector(test), userInfo: nil, repeats: true)
    }
    
    deinit {
        debugPrint("TestClass deinit")
    }
    
    @objc private func test() {
        debugPrint("test")
    }
}

class ViewController: UIViewController {
    
    @objc var test: TestClass?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
            
        let btn = UIButton(type: .custom)
        btn.setTitle("Test", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.frame = CGRect(x: 150.0, y: 150.0, width: 100, height: 70)
        btn.addTarget(self, action: #selector(test1), for: .touchUpInside)
        view.addSubview(btn)
        
        
    }
    
    @objc private func test1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self else { return }
            let vc = ARCLearnViewController()
            self.present(vc, animated: true, completion: nil)
        }
    }
}

