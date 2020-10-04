//
//  SingleRowPickerView.swift
//  labs-ios-starter
//
//  Created by Kenny on 10/1/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import UIKit

typealias CompletionHandler = () -> Void

protocol SingleRowSpinnerDelegate: UIGestureRecognizerDelegate {
    func updateSpinner()
}

class SingleRowPickerView: UIPickerView {

    var rowHeight: CGFloat {
        self.rowSize(forComponent: 0).height
    }

    var tapDelegate: SingleRowSpinnerDelegate? {
        didSet {
            commoninit()
        }
    }

    var tap: UITapGestureRecognizer?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutIfNeeded() {

    }


    func commoninit() {
        tap = UITapGestureRecognizer(target: self, action: #selector(changeRow))
        tap!.delegate = tapDelegate
        self.addGestureRecognizer(tap!)
    }
    
    @objc func changeRow() {
        // get tap location
        // determine row
        // selectRow(row+1)
        if tap!.state == .ended {
            let selectedRowFrame = self.bounds.insetBy(dx: 0, dy: (self.frame.height - rowHeight) / 2)
            let userTappedOnSelectedRow = selectedRowFrame.contains(tap!.location(in: self))
            if userTappedOnSelectedRow {
                tapDelegate?.updateSpinner()
                self.layoutIfNeeded()
            }
        }
    }
}
