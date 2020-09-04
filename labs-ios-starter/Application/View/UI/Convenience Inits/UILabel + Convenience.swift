//
//  UILabel + Convenience.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/4/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import UIKit

extension UILabel {

    /// Autolayout Init for UILabel
    /// - Parameters:
    ///   - font: The label's font, defaults to systemFont 14
    ///   - lines: The number of lines the labels displays, defaults to 0 (unlimited)
    ///   - breakBy: how to handle the label running out of room to display all text. Defaults to truncating Tail. i.e. "this line of text is too l..."
    ///   - backgroundColor: the label's background color
    convenience init(font: UIFont = UIFont.systemFont(ofSize: 14),
                     lines: Int = 0,
                     breakBy: NSLineBreakMode = .byTruncatingTail,
                     backgroundColor: UIColor) {

        self.init(translatesAutoresizingMaskIntoConstraints: false, backgroundColor: backgroundColor)
        self.font = font
        self.numberOfLines = lines
        self.lineBreakMode = breakBy

    }
}
