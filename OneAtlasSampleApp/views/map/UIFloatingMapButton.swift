//
//  UIFloatingMapButton.swift
//  Tap button to toggle label and/or image, like in camera flash and timer buttons.
//
//  Created by Yonat Sharon on 02.03.2015 (MIT license)
//  Modded by Airbus DS 2019
//  Copyright (c) 2015 Yonat Sharon. All rights reserved.
//


import UIKit

import OneAtlas

enum EFloatingMapButtonState: Int {
    case search = 0
    case searchCollapsed
    
    var color: UIColor {
        switch self {
        case .search, .searchCollapsed:
            return Config.appColor
        }
    }
    
    var icon: UIImage {
        switch self {
        case .search, .searchCollapsed:
            return UIImage(named: "baseline_search_black_24pt")!
        }
    }
    
    var title: String {
        switch self {
        case .search:
            return Config.loc("map_search_this_area").uppercased()
        case .searchCollapsed:
            return ""
        }
    }
}


class UIFloatingMapButton: UIButton {

    
    func resetToDefaultState() {
        buttonState = .searchCollapsed
    }
    
    var feature: OAFeature?
    
    var buttonState: EFloatingMapButtonState {
        get {
            return EFloatingMapButtonState(rawValue: currentStateIndex) ?? .search
        }
        set {
            currentStateIndex = newValue.rawValue
        }
    }    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        states = [EFloatingMapButtonState.search.title,
                  EFloatingMapButtonState.searchCollapsed.title]
        images = [EFloatingMapButtonState.search.icon,
                  EFloatingMapButtonState.searchCollapsed.icon]
        backgroundColors = [EFloatingMapButtonState.search.color,
                            EFloatingMapButtonState.searchCollapsed.color]
    }
    
    
    override var isEnabled: Bool  {
        didSet {
            backgroundColor = isEnabled ? currentBackgroundColor : AirbusColor.textLight.value
        }
    }
    
    
    /// use only this init, it's 'convenience' only to avoid overriding required inits
    public convenience init(
        images: [UIImage?],
        states: [String],
        colors: [UIColor?] = [],
        backgroundColors: [UIColor?] = [],
        action: ((_ sender: UIFloatingMapButton) -> Void)? = nil
        ) {
        self.init(frame: CGRect.zero)
        
        if let image = images.first {
            setImage(image, for: .normal)
        }
        sizeToFit()
        
        self.images = images
        self.states = states
        self.colors = colors
        self.backgroundColors = backgroundColors
        self.action = action
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
        
        setupCurrentState()
    }
    
    public convenience init(
        image: UIImage?,
        states: [String],
        colors: [UIColor?] = [],
        backgroundColors: [UIColor?] = [],
        action: ((_ sender: UIFloatingMapButton) -> Void)? = nil
        ) {
        self.init(images: [image], states: states, colors: colors, backgroundColors: backgroundColors, action: action)
    }
    
    // MARK: - Manual Control
    
    @objc open func toggle() {
        currentStateIndex = (currentStateIndex + 1) % states.count
        action?(self)
    }
    
    @objc open var currentStateIndex: Int = 0 { didSet { setupCurrentState() } }
    open var colors: [UIColor?] = [] { didSet { setupCurrentState() } }
    open var backgroundColors: [UIColor?] = [] { didSet { setupCurrentState() } }
    open var images: [UIImage?] = [] { didSet { setupCurrentState() } }
    open var animationDuration: TimeInterval = Config.animDurationFast
    open var animation: AnimationOptions? = nil
    @objc open var states: [String] = [] {
        didSet {
            currentStateIndex %= states.count
            setupCurrentState()
        }
    }
    
    @objc open var action: ((_ sender: UIFloatingMapButton) -> Void)? {
        didSet {
            addTarget(self, action: #selector(toggle), for: .touchUpInside)
        }
    }
    
    // MARK: - Overrides
    
    open override func tintColorDidChange() {
        if nil == currentColor {
            setTitleColor(tintColor, for: .normal)
        }
    }
    
    // MARK: - Private
    
    private func setupCurrentState() {
        // let current_title = self.titleLabel?.text ?? ""
        
        let new_title = states[currentStateIndex].isEmpty ? nil : " " + states[currentStateIndex]
        let new_color = currentColor ?? tintColor
        let new_background = currentBackgroundColor ?? .clear
        let new_image = currentToggleImage ?? currentImage
        let new_animation = animation
        
        if let animation = new_animation {
            UIView.transition(with: self,
                              duration: animationDuration,
                              options: animation,
                              animations: {
                                
                                self.setTitle(new_title, for: .normal)
                                self.setTitleColor(new_color, for: .normal)
                                self.backgroundColor = new_background
                                self.setImage(new_image, for: .normal)
                                
            }, completion: nil)
            
        }
        else {
            setTitle(new_title, for: .normal)
            setTitleColor(new_color, for: .normal)
            backgroundColor = new_background
            setImage(new_image, for: .normal)
        }
    }
    
    private var currentColor: UIColor? {
        return currentStateIndex < colors.count ? colors[currentStateIndex] : nil
    }
    
    private var currentBackgroundColor: UIColor? {
        return currentStateIndex < backgroundColors.count ? backgroundColors[currentStateIndex] : nil
    }
    
    private var currentToggleImage: UIImage? {
        return currentStateIndex < images.count ? images[currentStateIndex] : nil
    }
}
