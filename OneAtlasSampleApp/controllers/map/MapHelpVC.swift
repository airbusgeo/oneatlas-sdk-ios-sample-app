//
//  MapHelpVC.swift
//  OneAtlasSampleApp
//
//  Created by Airbus DS on 18/10/2019.
//  Copyright © 2019 Airbus DS. All rights reserved.
//

import UIKit
import GDCheckbox


class MapHelpVC: BaseFilterVC {

    @IBOutlet weak var ivHelp: UIImageView!
    @IBOutlet weak var ivHand: UIImageView!
    @IBOutlet weak var lbHelp: UILabel!
    
    @IBOutlet weak var cbShow: GDCheckbox!
    @IBOutlet weak var lbShow: UILabel!
    
    private var _step = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ivHand.alpha = 0
        
        lbShow.textColor = Color.textDark.value
        lbShow.font = AirbusFont.tiny.value
        lbShow.text = Config.loc("lp_tut_dontshow")

        lbHelp.textColor = Color.textDark.value
        lbHelp.font = AirbusFont.regularBold.value
        lbHelp.text = Config.loc("lp_tut_explain")

        cbShow.checkColor = Config.appColor
        cbShow.containerColor = Config.appColor

        setupWithTitle(Config.loc("lp_tut_title"),
                       color: Config.appColor,
                       iconImage: UIImage(named: "baseline_help_outline_black_36pt"))
    }
    

    override func viewDidAppear(_ animated: Bool) {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
            self.animationStep()
        }.fire()
    }
    
    
    @IBAction func onDeclineChecked(_ sender: Any) {
        CacheUtils.mapDidDeclineHelp = cbShow.isOn
    }
    
    
    private func animationStep() {
        switch(_step) {
        case 0:
            // set base image
            ivHelp.image = UIImage(named: "help1")!
        case 1:
            // show hand
            UIView.animate(withDuration: Config.animDurationFast, animations: {
                self.ivHand.alpha = 1
            })
        case 2:
            // show longpress
            ivHelp.image = UIImage(named: "help2")!
            break
        case 3:
            // show result
            UIView.animate(withDuration: Config.animDurationFast, animations: {
                self.ivHand.alpha = 0
            })
        default:
            break
        }
        
        // next step
        _step += 1
        if _step == 4 {
            _step = 0
        }
    }
}
