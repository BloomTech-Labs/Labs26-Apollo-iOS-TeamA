//
//  UIViewController+SimpleAlert.swift
//  labs-ios-starter
//
//  Created by Spencer Curtis on 7/30/20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import UIKit

extension UIViewController {

    /// Present an alert with a message, dismiss button, and custom dismiss text
    /// - Parameters:
    ///   - title: The alert's title
    ///   - message: The alert's message to the user
    ///   - preferredStyle: .alert (normal), .actionSheet(??)
    ///   - dismissText: The button that closes the alert's title
    ///   - completionUponDismissal: optional completion handler
    func presentSimpleAlert(with title: String?,
                            message: String?,
                            preferredStyle: UIAlertController.Style,
                            dismissText: String,
                            completionUponDismissal: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        // Cancel button
        let dismissAction = UIAlertAction(title: dismissText, style: .cancel, handler: completionUponDismissal)
        alert.addAction(dismissAction)

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    /// Show an alert with a title, message, yes button, and no button
    /// - Parameters:
    ///   - title: The Alert's Title
    ///   - message: The Alert's Message
    ///   - vc: The View Controller Presenting the Alert
    ///   - complete: Returns a bool (false if no was pressed, true if yes)
    func presentAlertWithYesNoPrompt(with title: String,
                                     message: String,
                                     preferredStyle: UIAlertController.Style,
                                     complete: @escaping (Bool) -> Void) {

        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: preferredStyle)
        // Yes button completes true
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            complete(true)
        }))
        /// No Button in red (.cancel) completes false
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            complete(false)
        }))
        // Always on the main queue in case we're presenting from a background thread
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
