//
//  BaseFilterVC.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 18/09/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit


protocol BaseFilterDelegate {
    func onApplyClicked()
    func onResetClicked()
    func onRefreshRequested()
}


class BaseFilterVC: UIViewController {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var headerView: UICardHeaderView!
    @IBOutlet weak var btApply: UIButton!
    @IBOutlet weak var alphaView: UIView!

    internal let FILTER_CELL_ID = "idFilterCell"
    internal let FILTER_CELL_HEIGHT = CGFloat(32)

    private var _delegate:BaseFilterDelegate?
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        backView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: Config.animDurationFast,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: {
                        self.backView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    func setupWithTitle(_ title:String,
                        color:UIColor,
                        iconImage: UIImage? = nil,
                        delegate:BaseFilterDelegate? = nil) {

        _delegate = delegate
        
        headerView.titleLabel.text = title
        headerView.titleLabel.textColor = color
        headerView.subtitleLabel.text = ""
        
        headerView.moreButton.isHidden = true
        if delegate != nil {
            headerView.moreButton.isHidden = false
            headerView.moreButton.setTitle(Config.loc("filter_reset"), for: .normal)
            headerView.moreButton.tintColor = Config.appColor
        }
        
        headerView.iconImage.image = iconImage ?? UIImage.init(named: "baseline_tune_black_24pt")?.withAlignmentRectInsets(UIEdgeInsets(top: -4, left: -4, bottom: -4, right: -4))
        headerView.iconImage.tintColor = color
        headerView.delegate = self

        backView.clipsToBounds = true
        backView.layer.cornerRadius = Config.defaultCornerRadius
        
        alphaView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onCancelClicked(_:))))

        
        btApply.backgroundColor = Config.appColor
        btApply.tintColor = Color.textWhite.value
        btApply.layer.cornerRadius = Config.defaultCornerRadius
    }
    
    
    @objc func onCancelClicked(_ sender: Any) {
        dismiss(animated: true) {
        }
    }
    
    
    @IBAction func onApplyClicked(_ sender: Any) {
        _delegate?.onApplyClicked()
        dismiss(animated: true) {
        }
    }
}


extension BaseFilterVC: UICardHeaderViewDelegate {
    func onMoreClicked(header: UICardHeaderView, inSection: Int) {
        _delegate?.onResetClicked()
    }
}
