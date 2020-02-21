//
//  ToastUtils.swift
//
//  Created by Airbus DS on 13/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import Toast_Swift



class ToastUtils {
    
    class func showSuccess(_ message:String) {
        toast(message: message,
              color: AirbusColor.green.value,
              icon: UIImage.init(named: "baseline_done_black_24pt"))
    }
    
    
    class func showError(_ message:String) {
        toast(message: message,
              color: AirbusColor.red.value,
              icon: UIImage.init(named: "baseline_error_outline_black_24pt"))
    }
    
    
    class func showWarning(_ message:String) {
        toast(message: message,
              color: AirbusColor.orange.value,
              icon: UIImage.init(named: "baseline_error_outline_black_24pt"))
    }
    
    
    private class func toast(message:String,
                             color:UIColor,
                             icon:UIImage?) {
        
        if let vc = UIApplication.topMostViewController {
            
            var style = ToastStyle()
            style.messageColor = AirbusColor.textWhite.value
            style.backgroundColor = color
            style.imageSize = CGSize(width: 24, height: 24)
            
            ToastManager.shared.isTapToDismissEnabled = true
            ToastManager.shared.isQueueEnabled = true
            
            vc.view.makeToast(message,
                              position: .top,
                              image: icon?.tintedImageWithColor(color: .white),
                              style: style)
        }
    }
    
    
    class func showLoading(_ message:String) {
        if let vc = UIApplication.topMostViewController {
            var style = ToastStyle()
            style.messageColor = AirbusColor.textWhite.value
            style.backgroundColor = AirbusColor.red.value
            
            ToastManager.shared.isTapToDismissEnabled = true
            ToastManager.shared.isQueueEnabled = true
            
            vc.view.makeToastActivity(.center)
        }
    }
    
    
    class func showError(title: String,
                         message: String,
                         button:String?,
                         block:(() -> Void)?) {
        
        if let button = button,
            let vc = UIApplication.topMostViewController {
            // show alert view ?
            let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction.init(title: button, style: .default) { (action) in
                if let block = block {
                    block()
                }
            }
            alert.addAction(ok)
            vc.present(alert, animated: true, completion: nil)
        }
        else {
            // no button: show toast
            ToastUtils.showError(message)
            if let block = block {
                block()
            }
        }
    }
}
