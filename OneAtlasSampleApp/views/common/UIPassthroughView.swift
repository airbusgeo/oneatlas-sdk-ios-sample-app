//
//  UIPassthroughView.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 11/10/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit

class UIPassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let v = super.hitTest(point, with:event)
        return v == self ? nil : v;
    }
}
