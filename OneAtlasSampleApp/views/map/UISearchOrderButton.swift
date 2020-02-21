//
//  UIMapSearchOrderButton.swift
//  OneAtlasApp
//
//  Created by Airbus DS on 30/07/2019.
//  Copyright © 2019 Airbus. All rights reserved.
//

import UIKit
import AirbusUI
#if TARGET_INT
import OneAtlasINT
#elseif TARGET_PREPROD
import OneAtlasPREPROD
#else
import OneAtlas
#endif


@objc enum ESearchOrderButtonPurpose: Int {
    case search = 0
    case order
    case none
}

@objc protocol UISearchOrderButtonDelegate {
    func onSearchOrderButtonClicked(_ purpose:ESearchOrderButtonPurpose,
                                    feature:OAProductFeature?) -> Void;
}


@objc class UISearchOrderButton: UIButton {
    
    @objc var delegate:UISearchOrderButtonDelegate?
    @objc var feature:OAProductFeature?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
    }
    
    @objc var purpose: ESearchOrderButtonPurpose = .search {
        didSet {
            switch purpose {
            case .search:
                setImage(UIImage(named: "baseline_crop_free_black_36pt"), for:.normal)
                isEnabled = true
                tintColor = Config.appColor
            case .order:
                setImage(UIImage(named: "outline_shopping_cart_black_36pt"), for:.normal)
                isEnabled = true
                tintColor = Config.appColor
            case .none:
                setImage(UIImage(named: "outline_shopping_cart_black_36pt"), for:.normal)
                isEnabled = false
                tintColor = AirbusColor.textLight.value
            }
        }
    }
    
    
    @objc private func onClick(_ sender:Any) {
        delegate?.onSearchOrderButtonClicked(purpose, feature: feature)
    }
}

