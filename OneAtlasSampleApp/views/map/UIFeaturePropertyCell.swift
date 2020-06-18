//
//  UIProductFeatureTableCell.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 29/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit



class UIFeaturePropertyCell: UIAutoRegisterTableCell {

    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lbValue: UILabel!
    @IBOutlet weak var lbName: UILabel!
    
    override class var DEFAULT_HEIGHT:CGFloat {
        return 44
    }

    
    var property:FeatureProperty = ("", "", "") {
        didSet {
            lbValue.text = property.value
            lbValue.font = AirbusFont.tiny.value
            lbValue.textColor = Color.textLight.value
            
            lbName.text = property.title
            lbName.font = AirbusFont.small.value
            lbName.textColor = Color.textDark.value

            ivIcon.tintColor = Config.appColor
            ivIcon.image = UIImage(named:property.icon) ?? UIImage(named: "icon_angle")!
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
