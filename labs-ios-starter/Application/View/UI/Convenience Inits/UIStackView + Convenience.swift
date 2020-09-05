//
//  UIStackView + Convenience.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/4/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import UIKit

extension UIStackView {

    /// Autolayout init for UIStackView
    /// - Parameters:
    ///   - axis: the stackView's axis, defaults to vertical
    ///   - alignment: the stackView's alignment, defaults to .fill
    ///   - distribution: the stackView's distribution, defaults to .fill
    ///   - frame: the stackview's frame
    ///   - viewsToStack: Variadic, pass in a single instance or comma-separated list
    convenience init(axis: NSLayoutConstraint.Axis = .vertical,
                     alignment: UIStackView.Alignment = .fill,
                     distribution: UIStackView.Distribution = .fill ,
                     viewsToStack: UIView...,
                     spacing: CGFloat = 8) {
        self.init()
        self.translatesAutoresizingMaskIntoConstraints = false
        // Setup view
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing

        //add arranged subviews
        for view in viewsToStack {
            self.addArrangedSubview(view)
        }
    }
}



