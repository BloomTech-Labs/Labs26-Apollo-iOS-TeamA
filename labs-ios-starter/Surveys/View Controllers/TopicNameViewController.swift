// Copyright © 2020 Shawn James. All rights reserved.
// TopicNameViewController.swift

import UIKit

class TopicNameViewController: UIViewController {
    
    // MARK: - Outlets -
    @IBOutlet var nameTextField: UITextField!

    // MARK: - Properties -
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Handlers
    
    // MARK: - Reusable

    // MARK: - Navigation -

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == .segueID(.showQuestions) {
            //TODO: prevent segue instead of popping back if no name is entered
            guard let topicName = nameTextField.text,
                !topicName.isEmpty else {
                    presentSimpleAlert(with: "Oops!", message: "Please enter a topic name", preferredStyle: .alert, dismissText: "Ok")  { result in
                        //this will pop the currently presented ViewController which will be the next VC
                        self.navigationController?.popViewController(animated: true)
                    }
                return
            }

            guard let questionsVC = segue.destination as? TopicQuestionsViewController else {
                print("Couldn't downcast TopicQuestionsViewController")
                return
            }
            questionsVC.topicName = topicName
        }
    }
    
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
