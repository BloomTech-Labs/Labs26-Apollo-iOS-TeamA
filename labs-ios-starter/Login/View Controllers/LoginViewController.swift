//
//  LoginViewController.swift
//  LabsScaffolding
//
//  Created by Spencer Curtis on 7/23/20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import OktaAuth
import UIKit

class LoginViewController: DefaultViewController {
    // MARK: - Outlets -
    @IBOutlet var signInButton: UIButton!

    // MARK: - Properties -
    let userTextField = UITextField()
    let profileController = ProfileController.shared

    // MARK: - View Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: Add observers
        NotificationCenter.default.addObserver(forName: .oktaAuthenticationSuccessful,
                                               object: nil,
                                               queue: .main,
                                               using: checkForExistingProfile)

        NotificationCenter.default.addObserver(forName: .oktaAuthenticationExpired,
                                               object: nil,
                                               queue: .main,
                                               using: alertUserOfExpiredCredentials)

        loginWithOkta()
    }

    // MARK: - Actions
    /// Used when login fails
    @IBAction func signIn(_ sender: Any) {
        loginWithOkta()
    }

    // MARK: - Private Methods -
    private func loginWithOkta() {
        UIApplication.shared.open(ProfileController.shared.oktaAuth.identityAuthURL()!) { result in
            if result {
                print("logged in, directing to entryVC")
            } else {
                self.presentSimpleAlert(with: "Login Failed!",
                                        message: "Please try again",
                                        preferredStyle: .alert,
                                        dismissText: "Ok")
            }
        }
    }

    private func alertUserOfExpiredCredentials(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.presentAlertWithYesNoPrompt(with: "Your Okta credentials have expired",
                                             message: "Please sign in again",
                                             preferredStyle: .alert) { result in
                switch result {
                case true:
                    self.loginWithOkta()
                case false:
                    // exit app??
                    print("User declined to login after failed attempt.")
                }
            }
        }
    }

    // MARK: - Notification Handling -
    private func checkForExistingProfile(with notification: Notification) {
        checkForExistingProfile()
    }

    private func checkForExistingProfile() {
        profileController.checkForExistingAuthenticatedUserProfile { [weak self] exists in

            guard let self = self,
                self.presentedViewController == nil else { return }

            if exists {
                self.handleLogin()
            } else {
                DispatchQueue.main.async {
                    self.presentSimpleAlert(with: "Okta Account Not Approved for Apollo",
                                            message: "Please contact your administrator.",
                                            preferredStyle: .alert,
                                            dismissText: "Ok")
                }
            }
        }
    }

    // MARK: - Override Methods -
    /// Used by parent VC to override behavior post-login (stop spinner, load topics, etc...)
    func handleLogin() {}
}

// MARK: - Live Previews -
#if DEBUG

    import SwiftUI

    struct LoginViewControllerPreviews: PreviewProvider {
        static var previews: some View {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateInitialViewController()

            return viewController?.view.livePreview.edgesIgnoringSafeArea(.all)
        }
    }

#endif
