//
//  StyleSheet.swift
//  Style
//
//  Created by Kenny on 9/1/20.
//  Copyright © 2020 Apollo. All rights reserved.
//

import UIKit

// MARK: - Properties -

// MARK: - CGFloat + constants -
extension CGFloat {
    static let cornerRadius: CGFloat = 8
}

// MARK: - UIColor + getColor -
extension UIColor {
    /// these colors are in XCAssets
    enum ThemeColorName: String {
        case action, accent, background, cell, shadow, cellText
    }

    static func getColor(_ named: ThemeColorName) -> UIColor {
        UIColor(named: named.rawValue)!
    }

    static var background = getColor(.background)
    static var action = getColor(.action)
    static var shadow = getColor(.shadow)
}

class DefaultViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .background
    }
}
