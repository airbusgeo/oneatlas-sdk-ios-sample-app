//
//  UIAutoRegisterTableCell.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 30/08/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit


class UIAutoRegisterTableCell: UITableViewCell {

    class var DEFAULT_HEIGHT: CGFloat {
        return 44
    }

    class func identifier() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    class func registerNibIntoTable(_ table:UITableView) {
        let name = self.identifier()
        let nib = UINib(nibName: name, bundle: nil)
        table.register(nib, forCellReuseIdentifier: name)
    }
}
