// Copyright © 2020 Shawn James. All rights reserved.
// TopicNameViewController.swift

import UIKit

class TopicNameViewController: UIViewController {
    
    // MARK: - Outlets & Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nextButton: StandardButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Handlers
    /// Segues to the next controller and runs an animation on the button
    @IBAction func nextButtonPressed(_ sender: StandardButton) {
        guard (nameTextField.text != nil) else {
            nextButton.shakeAnimate()
            presentSimpleAlert(with: "Please add a title to continue", message: nil, preferredStyle: .alert, dismissText: "Ok")
            return
        }
        
        nextButton.springAnimate()
        performSegue(withIdentifier: "TempSegName", sender: self); #warning("Use incoming structs to implement better segueID")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "TempSegName" else { return }
    }
    
    // MARK: - Reusable
    
}

// MARK: - Live Previews

#if DEBUG

import SwiftUI

struct TopicNameViewControllerPreview: PreviewProvider {
    static var previews: some View {
        let storyboard = UIStoryboard(name: "Surveys", bundle: .main)
        let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController
        
        return tabBarController?.view.livePreview.edgesIgnoringSafeArea(.all)
    }
}

#endif
