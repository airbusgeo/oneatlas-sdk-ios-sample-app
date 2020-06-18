//
//  UINavigationBarButton.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 16/09/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit



protocol UINavigationBarButtonDelegate {
    func onBarButtonClicked(_ button:UINavigationBarButton)
}

class UINavigationBarButton: UIButton {

    private var _delegate:UINavigationBarButtonDelegate?
    private var _badge:UIView?

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    class func buttonWithIcon(_ icon:UIImage,
                              size:CGFloat,
                              tintColor:UIColor,
                              badgeOrigin:CGPoint?,
                              delegate:UINavigationBarButtonDelegate) -> UINavigationBarButton {
        
        let filter = UINavigationBarButton.init(frame: CGRect.init(x: 0, y: 0, width: size, height: size))
        
        filter.setBackgroundImage(icon, for: .normal)
        filter.tintColor = tintColor
        filter.imageView?.contentMode = .scaleAspectFit
        filter.addTarget(filter, action: #selector(onFilterClicked(_:)), for: .touchUpInside)
        filter.widthAnchor.constraint(equalToConstant: size).isActive = true
        filter.heightAnchor.constraint(equalToConstant: size).isActive = true
        filter._delegate = delegate
        if let origin = badgeOrigin {
            let bsz = size / 2.5
            filter._badge = UIView.init(frame: CGRect.init(x: origin.x, y: origin.y, width: bsz, height: bsz))
            if let badge = filter._badge {
                badge.backgroundColor = Color.red.value
                badge.layer.cornerRadius = badge.bounds.size.width / 2
                badge.isHidden = true
                filter.addSubview(badge)
            }
        }
        return filter
    }
    
    
    var isBadgeHidden:Bool = true {
        didSet {
            _badge?.isHidden = isBadgeHidden
        }
    }
    
    
    @objc func onFilterClicked(_ sender:Any) {
        _delegate?.onBarButtonClicked(self)
    }
}
