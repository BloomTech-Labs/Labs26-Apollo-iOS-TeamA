//
//  UIButton + Convenience.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/4/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import UIKit

extension UIButton {
    convenience init(backgroundColor: UIColor,
                     addTo controller: UIViewController,
                     action: Selector,
                     controlEvent: UIControl.Event = .touchUpInside,
                     title: String) {
        self.init(translatesAutoresizingMaskIntoConstraints: false, backgroundColor: backgroundColor)
        self.addTarget(controller, action: action, for: controlEvent)
        //spaces around text to allow for cornerRadius reducing overall width without clipping/crowding text
        self.setTitle("  \(title)  ", for: .normal)
    }
}
