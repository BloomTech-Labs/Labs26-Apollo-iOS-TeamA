// Copyright © 2020 Shawn James. All rights reserved.
// TopicNameViewController.swift

import UIKit

class TopicNameViewController: UIViewController {
    // MARK: - Outlets -
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var contextPicker: UIPickerView!

    // MARK: - Properties -
    let topicController = TopicController()
    let fetchController = FetchController()
    let spinner = UIActivityIndicatorView()

    var contexts: [ContextObject]? {
        didSet {
            setupContextPicker()
        }
    }

    // MARK: - View Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpinner()
        getAllContextQuestions()
        self.contextPicker.delegate = self
        self.contextPicker.dataSource = self
    }

    private func setupSpinner() {
        spinner.startAnimating()
        contextPicker.addSubview(spinner)
        spinner.center = view.center
    }

    private func setupContextPicker() {
        DispatchQueue.main.async {
            if self.spinner.isAnimating {
                self.spinner.stopAnimating()
                self.contextPicker.reloadAllComponents()
            }
        }
    }
    

    // MARK: - Handlers

    private func getAllContextQuestions() {
        topicController.getAllContexts { [weak self] result in
            guard let self = self else {
                print("Topic Controller is nil")
                return
            }

            switch result {
            case .success:
                // get contexts from CoreData
                guard let contexts = self.fetchController.fetchContextRequest() else {
                    print("couldn't fetch contexts")
                    return
                }
                self.contexts = contexts

            case .failure(let error):
                print("failure getting questions")

                self.presentNetworkError(error: error.rawValue) { result in
                    if let result = result {
                        if result {
                            // user wants to try again
                            self.getAllContextQuestions()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Reusable

    // MARK: - Navigation -

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == .getSegueID(.showQuestions) {
            // TODO: prevent segue instead of popping back if no name is entered
            guard let topicName = nameTextField.text,
                !topicName.isEmpty else {
                presentSimpleAlert(with: "Oops!", message: "Please enter a topic name", preferredStyle: .alert, dismissText: "Ok") { _ in
                    // this will pop the currently presented ViewController which will be the next VC
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }

            guard let questionsVC = segue.destination as? TopicQuestionsViewController else {
                print("Couldn't downcast TopicQuestionsViewController")
                return
            }
            questionsVC.topicName = topicName
            let index = contextPicker.selectedRow(inComponent: 0)
            let contextId = Int(contexts?[index].id ?? 0)

            questionsVC.contextID = contextId
        }
    }
}

extension TopicNameViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.contexts?.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let questions = contexts,
              row < questions.count - 1 else
        { return nil }
        return questions[row].title
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
