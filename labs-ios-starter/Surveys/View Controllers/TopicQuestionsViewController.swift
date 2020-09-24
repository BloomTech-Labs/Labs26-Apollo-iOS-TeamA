// Copyright © 2020 Shawn James. All rights reserved.
// TopicQuestionsViewController.swift

import UIKit

class TopicQuestionsViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet var questionsCollectionView: UICollectionView!
    @IBOutlet var contextSegmentControl: UISegmentedControl!

    @IBAction func postTopicButton(_ sender: UIButton) {
        // TODO: Context Title
        postTopic()
    }

    // MARK: - Properties -

    var topicName: String?
    let topicController = TopicController()
    let questionsCellReuseId = String.getCollectionViewCellID(.questionsCollectionViewCell)
    let addNewQuestionCellReuseId = String.getCollectionViewCellID(.addNewQuestionCell)

    var questions: [Question] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    print("TopicQuestionViewController was nil when trying to display questions")
                    return
                }
                self.questionsCollectionView.reloadData()
            }
        }
    }

    @objc private func setupSegmentedControl() {
        contextSegmentControl.setDimensions(width: contextSegmentControl.frame.size.width, height: 50)
        setupSegmentLabels()
    }

    private func setupSegmentLabels() {
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).font = .systemFont(ofSize: 11)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        getAllContextQuestions()
        //baseurl = https://apollo-a-api.herokuapp.com/
    }

    private func getAllContextQuestions() {
        topicController.getAllQuestionsAndContexts { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                // get contexts from CoreData
                guard let contexts = self.fetchController.fetchContextRequest() else {
                    print("couldn't fetch contexts")
                    return
                }
                // set segmentControl titles
                for (index, context) in contexts.enumerated() {
                    DispatchQueue.main.async {
                        self.contextSegmentControl.setTitle(context.title, forSegmentAt: index)
                    }
                }
                // get questions from CoreData
                guard let questions = self.fetchController.fetchQuestionRequest() else {
                    print("Couldn't fetch questions")
                    return
                }
                // reload questions tableViewController (can use FRC here)
                self.questions = questions
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

    // MARK: - Update -

    private func postTopic() {
        // TODO: Dynamic questions when made available
        guard let topicName = topicName else {
            print("TopicName was nil!")
            return
        }

        let selected = contextSegmentControl.selectedSegmentIndex + 1
        guard let questions = fetchController.fetchQuestionRequest() else {
            print("couldn't fetch questions from CoreData")
            return
        }

        topicController.postTopic(with: topicName, contextId: selected, questions: questions) { result in
            switch result {
            case let .success(joinCode):
                DispatchQueue.main.async {
                    self.presentSimpleAlert(with: "Topic Posted!",
                                            message: "A join code will be sent to your notifications.",
                                            preferredStyle: .alert,
                                            dismissText: "Ok") { _ in
                                                
                        _ = NewNotificationsMessage("Created \(topicName) with join code: \(joinCode)")
                        self.dismiss(animated: true, completion: nil)
                    }
                }

            case let .failure(error):
                self.presentNetworkError(error: error.rawValue) { result in
                    // unknown/internal error occured:
                    if let result = result {
                        // tryAgain was tapped
                        if result {
                            self.postTopic()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Handlers

    // MARK: - Reusable
}

extension TopicQuestionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0 ..< questions.count:
            let cell = questionsCollectionView.dequeueReusableCell(withReuseIdentifier: questionsCellReuseId, for: indexPath) as! QuestionCollectionViewCell

            cell.updateViews(adjustingForWidthOf: view,
                             question: questions[indexPath.item].question)
            return cell

        default:

            let cell = questionsCollectionView.dequeueReusableCell(withReuseIdentifier: addNewQuestionCellReuseId, for: indexPath) as! QuestionCollectionViewCell
            // TODO: We need a question/text to pass in
            cell.updateViews(adjustingForWidthOf: view)

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row == questions.count else { return }

        // questions+=1
        collectionView.reloadData()
    }
}

// MARK: - Segmented Control Delegate -

// MARK: - Live Previews

#if DEBUG

    import SwiftUI

    struct TopicQuestionsViewControllerPreview: PreviewProvider {
        static var previews: some View {
            let storyboard = UIStoryboard(name: "Surveys", bundle: .main)
            let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController

            return tabBarController?.view.livePreview.edgesIgnoringSafeArea(.all)
        }
    }

#endif
