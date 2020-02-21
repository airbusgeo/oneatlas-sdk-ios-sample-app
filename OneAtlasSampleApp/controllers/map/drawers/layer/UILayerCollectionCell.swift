//
//  UILayerCollectionCell.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 26/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit



// ============================================================================
// MARK: - UILayerCollectionCell
// ============================================================================
class UILayerCollectionCell : UICollectionViewCell {
    
    static let CELL_ID = "UILayerCollectionCell"
    
    @IBOutlet weak var iconImage: UIImageView! {
        didSet {
            iconImage.layer.borderWidth = 3
            iconImage.layer.cornerRadius = Config.defaultCornerRadius
            iconImage.layer.masksToBounds = true
            iconImage.layer.borderColor = AirbusColor.textLight.value.cgColor
        }
    }
    @IBOutlet weak var iconLabel: UILabel! {
        didSet {
            iconLabel.font = AirbusFont.tinyBold.value
            iconLabel.textColor = AirbusColor.textLight.value
        }
    }
    
    func tint(color:UIColor) {
        iconLabel.textColor = color
        iconImage.layer.borderColor = color.cgColor
    }
}
