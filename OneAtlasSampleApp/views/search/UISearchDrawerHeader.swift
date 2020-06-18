//
//  UISearchDrawerHeader.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 23/09/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit


protocol UISearchDrawerHeaderDelegate {
    func onFilterClicked()
    func onCancelClicked()
}

class UISearchDrawerHeader: UIXibView {

    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var btFilter: UIButton!
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubtitle1: UILabel!
    @IBOutlet weak var lbSubtitle2: UILabel!
    
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    var delegate:UISearchDrawerHeaderDelegate?
    
    private let _badge = UIView.init(frame: CGRect.init(x: 20, y: 0, width: 10, height: 10))

    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbTitle.textColor = Color.textDark.value
        lbSubtitle2.textColor = Color.textLight.value
        lbSubtitle2.textColor = Color.textLight.value
    
        aiLoading.hidesWhenStopped = true
        btFilter.tintColor = Config.appColor
        btCancel.tintColor = Color.textLight.value
        
        // add simple badge to filter button
        _badge.backgroundColor = Color.red.value
        _badge.layer.cornerRadius = _badge.bounds.size.width / 2
        _badge.isHidden = true
        btFilter.addSubview(_badge)
    }
    
    
    var isBadgeHidden:Bool = true {
        didSet {
            _badge.isHidden = isBadgeHidden
        }
    }
    
    
    var isLoading:Bool = true {
        didSet { 
            btFilter.isEnabled = !isLoading
            btCancel.isEnabled = !isLoading
            // aiLoading.isHidden = isLoading

            if isLoading == true {
                aiLoading.startAnimating()
            }
            else {
                aiLoading.stopAnimating()
            }
        }
    }
    
    
    var title:String = "" {
        didSet {
            lbTitle.text = title
        }
    }
    
    var subtitle1:String = "" {
        didSet {
            lbSubtitle1.text = subtitle1
        }
    }
    
    var subtitle2:String = "" {
        didSet {
            lbSubtitle2.text = subtitle2
        }
    }
    
    
    var showsCancel:Bool = true {
        didSet {
            btCancel.isHidden = !showsCancel
        }
    }
    
    
    var showsFilter:Bool = true {
        didSet {
            btFilter.isHidden = !showsFilter
        }
    }
    
    
    @IBAction func onFilterClicked(_ sender: Any) {
        delegate?.onFilterClicked()
    }
    
    
    @IBAction func onCancelClicked(_ sender: Any) {
        delegate?.onCancelClicked()
    }
}
