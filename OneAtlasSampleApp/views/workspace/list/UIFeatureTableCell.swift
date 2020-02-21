//
//  UIFeatureTableCell.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 26/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import OneAtlas


class UIFeatureTableCell: UIAutoRegisterTableCell {

    @IBOutlet weak var uvSeparator: UIView!
    @IBOutlet weak var uvFeature:UIFeatureSummaryView!
    
    override class var DEFAULT_HEIGHT: CGFloat {
        return 80
    }
    
    var feature:OAFeature? {
        didSet {
            uvFeature.feature = feature
        }
    }
    
    var separatorColor:UIColor = .clear {
        didSet {
            uvSeparator.backgroundColor = separatorColor
        }
    }
}
