// Copyright © 2020 Lambda, Inc. All rights reserved.
// Created by Shawn James
// JoinCodeViewController.swift

import UIKit

final class JoinCodeViewController: UIViewController {
    @IBOutlet var joinCodeTextField: UITextField!
    @IBOutlet var joinButton: StandardButton!

    let topicController = TopicController()

    @IBAction func editingDidBegin(_ sender: UITextField) {
        joinButton.isEnabled = true
    }

    @IBAction func joinButtonPressed(_ sender: StandardButton) {
        guard
            let userInput = joinCodeTextField.text >< "No user input", !userInput.isEmpty
        else {
            sender.shakeAnimate()
            presentSimpleAlert(with: nil, message: "Please Enter a Code", preferredStyle: .alert, dismissText: "Ok")
            return
        }
        sender.loadAnimate(true)

        topicController.getTopic(withJoinCode: userInput) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    sender.loadAnimate(false)
                    sender.springAnimate()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Allow time for spring animation to complete
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure:
                DispatchQueue.main.async {
                    sender.loadAnimate(false)
                    sender.shakeAnimate()
                    self.presentSimpleAlert(with: nil, message: "No Matches Found", preferredStyle: .alert, dismissText: "Ok")
                }
            }
        }
    }
}
