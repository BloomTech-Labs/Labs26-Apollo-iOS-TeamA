
## Okta Login

### viewDidLoad

Post notifications for auth failure and auth success. 
    On Failure (expired token) alert user
    On Success, checkForExistingProfile
    Use profileController to determine if profile exists
        If exists, perform segue to profile detail
        if !exists, segue to addProfile (register) screen


### Okta Setup for signout redirect to app (https://developer.okta.com/docs/guides/sign-users-out/ios/define-signout-callback/)
In Info.plist, setup URL Scheme for com.okta.dev-625244
