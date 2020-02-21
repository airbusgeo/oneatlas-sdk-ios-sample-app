//
//  UICardFooterView.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 07/06/2019.
//  Copyright © 2019 Airbus. All rights reserved.
//

import UIKit


class UICardFooterView: UIView {
    
    
    class var DEFAULT_HEIGHT:CGFloat {
        // give just enough height for making nice rounded corners,
        // + add some padding (8px)
        return 8 + (Config.defaultCornerRadius * 2)
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        addFooter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
        addFooter()
    }
    
    
    func addFooter() {
        let footer = UIView.init(frame: self.bounds)
        
        let v = UIView.init(frame: CGRect(x: 0, y: 0,
                                                width: self.bounds.width,
                                                height: Config.defaultCornerRadius * 2))
        v.clipsToBounds = true
        v.layer.cornerRadius = Config.defaultCornerRadius
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.backgroundColor = AirbusColor.cardCell.value

        footer.addSubview(v)
        addSubview(footer)
    }
}
