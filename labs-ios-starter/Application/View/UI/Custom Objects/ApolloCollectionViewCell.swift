// Copyright © 2020 Lambda, Inc. All rights reserved.
// Created by Shawn James
// ApolloCollectionViewCell.swift

import UIKit

class ApolloCollectionViewCell: UICollectionViewCell {
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        commonInit()
    }
    
    private func commonInit() {
        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            layer.shadowColor = UIColor.shadow.cgColor
            layer.shadowOffset = CGSize(width: 5, height: 5)
            layer.shadowRadius = 5
            layer.shadowOpacity = 0.8

            layer.borderColor = UIColor.darkGray.cgColor
            layer.borderWidth = 0.1
        case .dark:
            layer.borderColor = UIColor.action.cgColor
            layer.borderWidth = 2
        @unknown default: fatalError()
        }
        
        layer.cornerRadius = .cornerRadius
        layer.masksToBounds = false
    }
    
}
