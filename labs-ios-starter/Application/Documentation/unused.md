# Unused Methods

###### These methods are unused - but may come in handy!

### Profile Controller
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
        guard var request = networkService.createRequest(url: requestURL, method: .post) else {
            print("invalid request")
            DispatchQueue.main.async {
                completion()
            }
            return
        }
        request.addValue("Bearer \(oktaCredentials.idToken)", forHTTPHeaderField: "Authorization")

        request.encode(from: profile)

        networkService.loadData(using: request) { result in
            switch result {
            case .success(let data):
                self.profiles.append(profile)
                DispatchQueue.main.async {
                    completion()
                }
                print(data)
                return

            case.failure(let error):
                completion()
                print(error)
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
        }
    }
    
    func image(for url: URL, completion: @escaping (UIImage?) -> Void) {
        guard let request = networkService.createRequest(url: url, method: .get) else {
            print("invalid request")
            completion(nil)
            return
        }

        networkService.loadData(using: request) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    completion(UIImage(data: data))
                }
                return
            case .failure(let error):
                print(error)
                completion(nil)
                return
            }
        }

    }

### AddProfileVC and Protocol

    import UIKit

    protocol AddProfileDelegate: class {
        func profileWasAdded()
    }

    class AddProfileViewController: DefaultViewController {

        // MARK: - Outlets -
        @IBOutlet weak var nameTextField: UITextField!
        @IBOutlet weak var emailTextField: UITextField!
        @IBOutlet weak var avatarURLTextField: UITextField!
        @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

        // MARK: - Properties -
        weak var delegate: AddProfileDelegate?
        var profileController: ProfileController = ProfileController.shared
        var keyboardDismissalTapRecognizer: UITapGestureRecognizer!
        
        // MARK: - View Lifecycle -
        override func viewDidLoad() {
            super.viewDidLoad()
            setUpKeyboardDismissalRecognizer()
            
            nameTextField.delegate = self
            emailTextField.delegate = self
            avatarURLTextField.delegate = self
        }
        
        // MARK: - Actions
        
        @IBAction func cancel(_ sender: Any) {
            dismiss(animated: true, completion: nil)
        }
        
        
        
        // MARK: - Private Methods -
        private func setUpKeyboardDismissalRecognizer() {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(recognizer)
            keyboardDismissalTapRecognizer = recognizer
        }
        
        @objc private func dismissKeyboard() {
            view.endEditing(true)
        }
    }

    // MARK: - UITextFieldDelegate -
    extension AddProfileViewController: UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            switch textField {
            case nameTextField:
                emailTextField.becomeFirstResponder()
            case emailTextField:
                avatarURLTextField.becomeFirstResponder()
            case avatarURLTextField:
                avatarURLTextField.resignFirstResponder()
            default:
                break
            }
            return true
        }
    }
    
### AddProfileDelegate Implementation

    // MARK: - Navigation -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == .segueID(.modalAddProfile) {
            guard let addProfileVC = segue.destination as? AddProfileViewController else { return }
            addProfileVC.delegate = self
        }
    }

    // MARK: - Add Profile Delegate -
    extension LoginViewController: AddProfileDelegate {
        func profileWasAdded() {
            checkForExistingProfile()
        }
    }
