//
//  UICardHeaderView.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 16/09/2019.
//  Copyright © 2019 52inc. All rights reserved.
//

import UIKit



protocol UICardHeaderViewDelegate {
    func onMoreClicked(header: UICardHeaderView, inSection:Int)
}


class UICardHeaderView: UIXibView {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    var delegate:UICardHeaderViewDelegate?
    var section:Int = 0

    
    class var DEFAULT_HEIGHT:CGFloat {
        return 44
    }
    
    
    override func customInit() {
        super.customInit()
        
        aiLoading.hidesWhenStopped = true
        clipsToBounds = true
        layer.cornerRadius = Config.defaultCornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        backgroundColor = AirbusColor.cardHeader.value
    }
    
    
    var isLoading = false {
        didSet {
            if isLoading == true {
                aiLoading.startAnimating()
            }
            else {
                aiLoading.stopAnimating()
            }
            moreButton.isHidden = isLoading
        }
    }
    
    
    @IBAction func onMoreClicked(_ sender: Any) {
        delegate?.onMoreClicked(header: self, inSection: section)
    }
}
