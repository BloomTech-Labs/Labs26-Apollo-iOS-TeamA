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
    ///   - axis: the stackView's axis, defaults to horizontal
    ///   - alignment: the stackView's alignment, defaults to .fill
    ///   - distribution: the stackView's distribution, defaults to .fill
    ///   - frame: the stackview's frame
    ///   - viewsToStack: Variadiac, pass in a single instance or array
    convenience init(axis: NSLayoutConstraint.Axis = .vertical,
                     alignment: UIStackView.Alignment = .fill,
                     distribution: UIStackView.Distribution = .fill,
                     viewsToStack: UIView...) {
        self.init(translatesAutoresizingMaskIntoConstraints: false)
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        //add arranged subviews in their index order
        //TODO: Test with a single view to make sure variadiac still treats the single instance as an array with a single element
        for view in viewsToStack {
            self.addArrangedSubview(view)
        }

    }
}



