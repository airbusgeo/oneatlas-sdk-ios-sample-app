//
//  XibUtils.swift
//
//  Created by Airbus DS on 07/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit

extension UIApplication {
    
    static var topMostViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.visibleViewController
    }
}



extension UIViewController {
    
    class func fromXib() -> UIViewController {
        return self.init(nibName: NSStringFromClass(self).components(separatedBy: ".").last!, bundle: nil)
    }
    
    
    // The visible view controller from a given view controller
    var visibleViewController: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.visibleViewController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleViewController
        } else if let presentedViewController = presentedViewController {
            return presentedViewController.visibleViewController
        } else {
            return self
        }
    }
}


extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}


class UIXibView: UIView {
    @IBOutlet weak var contentView:UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }


    internal func customInit() {
        let str = NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
        Bundle.main.loadNibNamed(str, owner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // force apply xib-defined constraints
        self.contentView.frame = bounds
    }
}
