//
//  ErrorHandler.swift
//  Style
//
//  Created by Kenny on 9/2/20.
//  Copyright © 2020 Apollo. All rights reserved.
//

import Foundation

class ErrorHandler {

    // MARK: - Singleton -
    ///singleton instance
    static var shared = ErrorHandler()
    private init() {}

    /// Success case can be used to pass any type
    /// Failure case can be used to pass anything conforming to Error
    /// define it in the completion handler as with `completionWithDataAndUserError`
    enum Result<Value, Error: Swift.Error> {
        case success(Value)
        case failure(Error)
    }
    /// Used to provide alerts to the user
    struct UserError {
        let title: String
        let message: String
    }

    enum NetworkError: Int, Error {
        case badRequest = 400
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
        case badMethod = 405
        case resourceNotAcceptable = 406
        case timeout = 408
        case tooManyRequests = 429
        case headerFieldTooLarge = 431
        //TODO: Determine with BE team when this is triggered
        case internalServerError = 500
        case badDecode = 998
        case unknown = 999
    }
    
    /// The required init from decoder used for managed objects can throw this error when the managed object context is missing or has broken
    enum DecoderConfigurationError: Error {
        case missingManagedObjectContext
    }

    static var userNetworkErrors: [Int: UserError] = {
        [
            NetworkError.unauthorized.rawValue: UserError(title: "Unauthorized", message: "Please login again"),
            NetworkError.forbidden.rawValue: UserError(title: "Forbidden", message: "Access to that resource is restricted"),
            NetworkError.timeout.rawValue: UserError(title: "Timed out", message: "Please check your connection or try again later."),
            NetworkError.notFound.rawValue: UserError(title: "Not Found", message: "Sorry, we're having trouble finding that resource")
        ]

    }()

    static var internalNetworkErrors: [Int: String] = {
        [
            NetworkError.badRequest.rawValue: "The request was formatted incorrectly.",
            NetworkError.badMethod.rawValue: "Method not accepted",
            NetworkError.resourceNotAcceptable.rawValue: "Resource not acceptable",
            NetworkError.tooManyRequests.rawValue: "Too many requests sent recently",
            NetworkError.headerFieldTooLarge.rawValue: "header too large",
            NetworkError.internalServerError.rawValue: "An internal server error occurred",
            NetworkError.badDecode.rawValue: "decoding error",
            NetworkError.unknown.rawValue: "An unknown error occured"
        ]
    }()

    /// Conforms to Swift.Error protocol so it can be used with Result type
    /// RawValues are used to store titles for UserError struct
    enum UserAuthError: String, Error {
        case invalidEmail = "Invalid E-Mail"
        case invalidPassword = "Incorrect Password"
        case noConnection = "Couldn't Connect"
    }

    /// ViewControllers can pull UserErrors out by passing in the UserAuthError they receive from an AuthService method
    static let userAuthErrors: [UserAuthError:UserError] = [
        UserAuthError.invalidEmail: UserError(title: UserAuthError.invalidEmail.rawValue, message: "That E-Mail address was incorrectly formatted. Please try again."),
        UserAuthError.invalidPassword: UserError(title: UserAuthError.invalidPassword.rawValue, message: "That username and/or password was incorrect. Please try again."),
        UserAuthError.noConnection: UserError(title: UserAuthError.noConnection.rawValue, message: "Please check your internet connection and try again")
    ]

    func getAuthError(authError: UserAuthError) -> UserError? {

        guard let error = ErrorHandler.userAuthErrors[authError] else {
            print("\(authError.rawValue) not defined in userAuthErrors")
            return nil
        }

        return error
    }

}

import UIKit

extension UIViewController {

    /// An Auth specific error occurred (This may remain unused and be deleted if there's no specific backend auth errors to handle that aren't handled by OktaAuth
    /// - Parameter error: The authentication error received
    func presentAuthError(error: ErrorHandler.UserAuthError) {
        guard let errorToDisplay = ErrorHandler.userAuthErrors[error] else {
            print("couldn't retrieve value from ErrorHandler.userAuthErrors Dictionary")
            return
        }
        presentSimpleAlert(with: errorToDisplay.title,
                           message: errorToDisplay.message,
                           preferredStyle: .alert,
                           dismissText: "Ok")
    }

    /// Presents a semantic error if user can take some action, or an unknown error with try again yes/no
    /// - Parameters:
    ///   - error: The network error that was received
    ///   - complete: Completes with the users choice to try again in the case of an unknown error
    func presentNetworkError(error: Int, complete: @escaping(Bool?) -> Void) {
        guard let errorToDisplay = ErrorHandler.userNetworkErrors[error] else {
            if let error = ErrorHandler.internalNetworkErrors[error] {
                print("\(#function): Internal Error: \(error)")
                
                DispatchQueue.main.async {
                    self.presentTryAgainError { result in
                        complete(result)
                    }
                }
            } else {
                print("\(#function): User Error \(error)")
            }
            return
        }

        presentSimpleAlert(with: errorToDisplay.title,
                           message: errorToDisplay.message,
                           preferredStyle: .alert,
                           dismissText: "Ok")
    }

    /// Unknown Error, Try Again Alert
    /// - Parameter complete: Completes with the user's decision to try again
    func presentTryAgainError(complete: @escaping (Bool) -> Void) {
        presentAlertWithYesNoPrompt(with: "Unknown Error",
                                    message: "An unknown error occured. Would you like to try again?",
                                    preferredStyle: .alert) { result in

                                        complete(result)
        }
    }

}
