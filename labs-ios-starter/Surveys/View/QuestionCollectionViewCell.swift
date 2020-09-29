//
//  QuestionCollectionViewCell.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/17/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import UIKit

class QuestionCollectionViewCell: UICollectionViewCell {
    @IBOutlet var nameLabel: UILabel!

    var question: Question? {
        didSet {
            updateViews(adjustingForWidthOf: self, question: question!.question)
        }
    }

    ///set nameLabel.text, initialize label parameters
    func updateViews( adjustingForWidthOf view: UIView, withWidthDeltaOf widthDelta: CGFloat = 40, height: CGFloat = 40, question: String? = nil, font: UIFont = .systemFont(ofSize: 17) ) {
        nameLabel.numberOfLines = 0
        nameLabel.font = font

        if let question = question {
            self.nameLabel.text = question
        }

        //increase height if needed
        var height = height
        if nameLabel.frame.size.height + 50 > height { //50 for padding TODO: More dynamic/less magic
            height = nameLabel.frame.size.height + 50 // padding
        }
        self.setDimensions(width: view.frame.width - widthDelta, height: height)

    }
}
