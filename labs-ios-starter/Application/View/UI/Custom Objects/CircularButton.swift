// Copyright © 2020 Lambda, Inc. All rights reserved.
// CircularButton.swift

import UIKit

/// The system icons used throughout the app, enums prevents typos -> UIImage(systemName: "[HERE]")
enum Icon: String {
    case plus = "plus"
}

/// A rounded button with an ICON
class CircularButton: UIButton {
    
    // MARK: - Initializers
    
    /// The initializer called directly by the Developer
    convenience init(withIcon systemName: Icon?, size: CGFloat?) {
        self.init()
        
        if let systemName = systemName?.rawValue {
            setImage(UIImage(systemName: systemName), for: .normal)
        }
        
        if let size = size {
            setDimensions(width: size, height: size)
            layer.cornerRadius = size / 2 // Circular shape            
        }
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Programmatic init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    /// Storyboard init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    /// Sets up the button with configuration
    private func commonInit() {
        setShadow()
        setColors()
    }
    
    // MARK: - Configuration Methods
    
    /// Configure the appearance of the button's shadow
    private func setShadow() {
        layer.shadowColor = UIColor(red: 0.64, green: 0.71, blue: 0.78, alpha: 1.00).cgColor
        layer.shadowOffset = CGSize(width: 7, height: 7)
        layer.shadowRadius = 7
        layer.shadowOpacity = 0.8
    }
    
    /// Configures the button's color scheme
    private func setColors() {
        backgroundColor = .action
        tintColor = .white
    }
    
    // MARK: - Button Animation Methods
    
    /// Button will spring animate to resemble a successful press
    public func springAnimate() {
        UIButton.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (_) in
            UIButton.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
}

// MARK: - Live Previews

#if DEBUG

import SwiftUI

struct CircularButtonPreview: PreviewProvider {
    static var previews: some View {
        let previewView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        previewView.backgroundColor = .background
        let button = CircularButton(withIcon: .plus, size: 60)
        
        previewView.addSubview(button)
        button.center(in: previewView)
                
        return previewView.livePreview.edgesIgnoringSafeArea(.all)
    }
}

#endif
