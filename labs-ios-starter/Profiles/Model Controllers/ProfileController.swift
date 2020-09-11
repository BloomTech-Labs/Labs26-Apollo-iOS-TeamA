//
//  ProfileController.swift
//  LabsScaffolding
//
//  Created by Spencer Curtis on 7/23/20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import UIKit
import OktaAuth

class ProfileController {
    
    static let shared = ProfileController()

    /// Apollo API base URL
    let baseURL = URL(string: "https://apollo-a-api.herokuapp.com")!

    ///Unit Testing URL
    private let testURL = URL(string: "https://kd-apollo.herokuapp.com/")!

    ///Okta auth URL
    private let oktaAuthURL = URL(string: "https://dev-625244.okta.com/")!

    lazy var oktaAuth = OktaAuth(baseURL: oktaAuthURL,
                            clientID: "0oavsbe2kAVi9pJPx4x6",
                            redirectURI: "labs://apollo/implicit/callback")


    private(set) var authenticatedUserProfile: Member?
    private(set) var profiles: [Member] = []

    
    private init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshProfiles),
                                               name: .oktaAuthenticationSuccessful,
                                               object: nil)
    }
    
    @objc func refreshProfiles() {
        getAllProfiles()
    }
    
    func getAllProfiles(completion: @escaping (ErrorHandler.UserAuthError?) -> Void = { error in }) {
        
        var oktaCredentials: OktaCredentials
        
        do {
            oktaCredentials = try oktaAuth.credentialsIfAvailable()
        } catch {
            postAuthenticationExpiredNotification()
            NSLog("Credentials do not exist. Unable to get profiles from API")
            DispatchQueue.main.async {
                completion(ErrorHandler.UserAuthError.noConnection)
            }
            return
        }
        
        let requestURL = baseURL.appendingPathComponent("profiles")
        var request = URLRequest(url: requestURL)
        
        request.addValue("Bearer \(oktaCredentials.idToken)", forHTTPHeaderField: "Authorization")
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            defer {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
            
            if let error = error {
                NSLog("Error getting all profiles: \(error)")
                completion(ErrorHandler.UserAuthError.noConnection)
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                NSLog("Returned status code is not the expected 200. Instead it is \(response.statusCode)")
                completion(ErrorHandler.UserAuthError.noConnection)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from getting all profiles")
                completion(ErrorHandler.UserAuthError.noConnection)
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let profiles = try decoder.decode([Member].self, from: data)
                
                DispatchQueue.main.async {
                    self.profiles = profiles
                }
            } catch {

                NSLog("Unable to decode [Profile] from data: \(error)")
                completion(ErrorHandler.UserAuthError.noConnection)

            }
        }
        
        dataTask.resume()
    }
    
    func getAuthenticatedUserProfile(completion: @escaping () -> Void = { }) {
        var oktaCredentials: OktaCredentials
        
        do {
            oktaCredentials = try oktaAuth.credentialsIfAvailable()
        } catch {
            postAuthenticationExpiredNotification()
            NSLog("Credentials do not exist. Unable to get authenticated user profile from API")
            DispatchQueue.main.async {
                completion()
            }
            return
        }
        
        guard let userID = oktaCredentials.userID else {
            NSLog("User ID is missing.")
            DispatchQueue.main.async {
                completion()
            }
            return
        }
        
        getSingleProfile(userID) { (profile) in
            self.authenticatedUserProfile = profile
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func checkForExistingAuthenticatedUserProfile(completion: @escaping (Bool) -> Void) {
        getAuthenticatedUserProfile {
            completion(self.authenticatedUserProfile != nil)
        }
    }
    
    func getSingleProfile(testing: Bool = false, _ userID: String, completion: @escaping (Member?) -> Void) {
        
        var oktaCredentials: OktaCredentials
        
        do {
            oktaCredentials = try oktaAuth.credentialsIfAvailable()
        } catch {
            postAuthenticationExpiredNotification()
            NSLog("Credentials do not exist. Unable to get profile from API")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        // if testing, use testURL otherwise use webURL
        let requestURL = !testing ? baseURL : testURL
            .appendingPathComponent("profiles")
            .appendingPathComponent(userID)
        var request = URLRequest(url: requestURL)
        
        request.addValue("Bearer \(oktaCredentials.idToken)", forHTTPHeaderField: "Authorization")
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            var fetchedProfile: Member?
            
            defer {
                DispatchQueue.main.async {
                    completion(fetchedProfile)
                }
            }
            
            if let error = error {
                NSLog("Error getting all profiles: \(error)")
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                NSLog("Returned status code is not the expected 200. Instead it is \(response.statusCode)")
            }
            
            guard let data = data else {
                NSLog("No data returned from getting all profiles")
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let profile = try decoder.decode(Member.self, from: data)
                fetchedProfile = profile
            } catch {
                NSLog("Unable to decode Profile from data: \(error)")
            }
        }
        
        dataTask.resume()
    }
    
    func updateAuthenticatedUserProfile(_ profile: Member, with name: String, email: String, avatarURL: URL, completion: @escaping (Member) -> Void) {
        
        var oktaCredentials: OktaCredentials
        
        do {
            oktaCredentials = try oktaAuth.credentialsIfAvailable()
        } catch {
            postAuthenticationExpiredNotification()
            NSLog("Credentials do not exist. Unable to get authenticated user profile from API")
            DispatchQueue.main.async {
                completion(profile)
            }
            return
        }
        
        let requestURL = baseURL
            .appendingPathComponent("profiles")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(oktaCredentials.idToken)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(profile)
        } catch {
            NSLog("Error encoding profile JSON: \(error)")
            DispatchQueue.main.async {
                completion(profile)
            }
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            var profile = profile
            
            defer {
                DispatchQueue.main.async {
                    completion(profile)
                }
            }
            
            if let error = error {
                NSLog("Error adding profile: \(error)")
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                NSLog("Returned status code is not the expected 200. Instead it is \(response.statusCode)")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from updating profile")
                return
            }
            
            do {
                profile = try JSONDecoder().decode(ProfileWithMessage.self, from: data).profile
                self.authenticatedUserProfile = profile
            } catch {
                NSLog("Error decoding `ProfileWithMessage`: \(error)")
            }
        }
        
        dataTask.resume()
    }
    
    // NOTE: This method is unused, but left as an example for creating a profile.
    
    func createProfile(with email: String, firstName: String, lastName: String, avatarURL: URL) -> Member? {
        var oktaCredentials: OktaCredentials
        
        do {
            oktaCredentials = try oktaAuth.credentialsIfAvailable()
        } catch {
            postAuthenticationExpiredNotification()
            NSLog("Credentials do not exist. Unable to create a profile for the authenticated user")
            return nil
        }
        
        guard let userID = oktaCredentials.userID else {
            NSLog("Credentials do not exist. Unable to create profile")
            return nil
        }
        return Member(id: userID, email: email, firstName: firstName, lastName: lastName, avatarURL: avatarURL)
    }
    
    // NOTE: This method is unused, but left as an example for creating a profile on the scaffolding backend.
    
    func addProfile(_ profile: Member, completion: @escaping () -> Void) {
        
        var oktaCredentials: OktaCredentials
        
        do {
            oktaCredentials = try oktaAuth.credentialsIfAvailable()
        } catch {
            postAuthenticationExpiredNotification()
            NSLog("Credentials do not exist. Unable to add profile to API")
            defer {
                DispatchQueue.main.async {
                    completion()
                }
            }
            return
        }
        
        let requestURL = baseURL.appendingPathComponent("profiles")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(oktaCredentials.idToken)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(profile)
        } catch {
            NSLog("Error encoding profile: \(profile)")
            defer {
                DispatchQueue.main.async {
                    completion()
                }
            }
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            defer {
                DispatchQueue.main.async {
                    completion()
                }
            }
            
            if let error = error {
                NSLog("Error adding profile: \(error)")
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                NSLog("Returned status code is not the expected 200. Instead it is \(response.statusCode)")
                return
            }
            
            self.profiles.append(profile)
        }
        dataTask.resume()
    }
    
    func image(for url: URL, completion: @escaping (UIImage?) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            var fetchedImage: UIImage? = nil
            
            defer {
                DispatchQueue.main.async {
                    completion(fetchedImage)
                }
            }
            if let error = error {
                NSLog("Error fetching image for url: \(url.absoluteString), error: \(error)")
                return
            }
            
            guard let data = data,
                let image = UIImage(data: data) else {
                    return
            }
            fetchedImage = image
        }
        dataTask.resume()
    }
    
    func postAuthenticationExpiredNotification() {
        NotificationCenter.default.post(name: .oktaAuthenticationExpired, object: nil)
    }
}
