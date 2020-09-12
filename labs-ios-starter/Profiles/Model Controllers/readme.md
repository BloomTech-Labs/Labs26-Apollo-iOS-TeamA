# Okta Authentication Using Spencer Curtis' OktaAuth Package

## Info

- Okta Authentication requires the URL for the Okta app, a clientID, and redirectURI
    - The URL for the Okta app and clientID are used to authenticate the app with Okta's servers and vice-versa
    
- When Okta login is triggered, a Safari browser is opened to the login URL
    - The redirectURI is used to redirect the user back to the iOS app after they've signed in using their safari browser

## Implementation 

1. In ProfileController.swift, locate the following code (specific values will be different and the different variables may not be together)

    ``` Swift
    private let baseURL = URL(string: "https://dev-625244.okta.com/")!
    lazy var oktaAuth = OktaAuth(baseURL: baseURL,
                            clientID: "0oavsbe2kAVi9pJPx4x6",
                            redirectURI: "labs://apollo/implicit/callback")
    ```

    - baseURL needs to be the URL that's provided to all of the teams - it may be referenced as the CallBack URL - this is NOT our redirectURI

    - clientID will be provided

    - your redirectURI may not be provided initially. Somebody with access to the Okta app (on the Okta side!) needs to implement a redirect URI and provide you with it. Ryan Hamblin (Experiential Learning Manager: Lambda Labs Engineering) was our point of contact
    
    2. A separate URL may be used for testing. We used  `private let testingURL = URL(string: "https://auth.lambdalabs.dev/")!`
