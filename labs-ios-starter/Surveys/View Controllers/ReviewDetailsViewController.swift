// Copyright © 2020 Lambda, Inc. All rights reserved.
// Created by Shawn James
// ReviewDetailsViewController.swift

import UIKit

protocol ReviewDetailsViewControllerDelegate {
    func sendTopic()
}

class ReviewDetailsViewController: UIViewController {
    @IBOutlet var DetailsTextView: UITextView!
    @IBOutlet var sendButton: StandardButton!

    var delegate: ReviewDetailsViewControllerDelegate?

    var topicName: String?
    var questions: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        DetailsTextView.text =
            """
            Name: \(topicName ?? "Missing")

            Questions: \(questions ?? "Missing")
            """
    }

    @IBAction func sendButtonPressed(_ sender: StandardButton) {
        delegate?.sendTopic()
    }
}
