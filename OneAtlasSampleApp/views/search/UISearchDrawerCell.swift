//
//  UISearchDrawerCell.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 19/09/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit


class UISearchDrawerCell: UIAutoRegisterTableCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textLabel?.textColor = Color.textDark.value
        textLabel?.font = AirbusFont.regularBold.value
        
        detailTextLabel?.textColor = Color.textLight.value
        detailTextLabel?.font = AirbusFont.tiny.value
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
