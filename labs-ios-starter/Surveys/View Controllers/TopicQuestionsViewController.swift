// Copyright © 2020 Shawn James. All rights reserved.
// TopicQuestionsViewController.swift

import UIKit

class TopicQuestionsViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet var pickerView: SingleRowPickerView!

    @IBOutlet var questionsCollectionView: UICollectionView!
    //@IBOutlet var contextSegmentControl: UISegmentedControl!

    @IBAction func postTopicButton(_ sender: UIButton) {
        // TODO: Context Title
        guard let contextID = contextID else {
            print("no conext id")
            return
        }
        postTopic(contextID: contextID)
    }

    // MARK: - Properties -
    let spinner = UIActivityIndicatorView()
    var topicName: String?
    let topicController = TopicController()
    let questionsCellReuseId = String.getCollectionViewCellID(.questionsCollectionViewCell)
    let addNewQuestionCellReuseId = String.getCollectionViewCellID(.addNewQuestionCell)
    var contextID: Int?
    private var fetchController = FetchController()

    var questions: [Question]? {
        didSet {
            DispatchQueue.main.async {
                self.pickerView.reloadAllComponents()
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tapDelegate = self

        getAllContextQuestions()
        //baseurl = https://apollo-a-api.herokuapp.com/
    }

    private func getAllContextQuestions() {
        // get questions from CoreData (fetched from API on prior screen)
        guard let questions = self.fetchController.fetchQuestionRequest() else {
            print("Couldn't fetch questions")
            return
        }
        // reload questions Picker
        self.questions = questions
    }

    // MARK: - Update -

    private func postTopic(contextID: Int) {
        // TODO: Dynamic questions when made available
        guard let topicName = topicName else {
            print("TopicName was nil!")
            return
        }

        //let selected = contextSegmentControl.selectedSegmentIndex + 1
        guard let questions = fetchController.fetchQuestionRequest() else {
            print("couldn't fetch questions from CoreData")
            return
        }

        topicController.postTopic(with: topicName, contextId: contextID, questions: questions) { result in
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
                            self.postTopic(contextID: contextID)
                        }
                    }
                }
            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Handlers

    // MARK: - Reusable
}

extension TopicQuestionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    //TODO: Convert section to added questions rather than all questions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let questions = questions else {
            print(" topic questions array empty")
            return UICollectionViewCell()
        }

        switch indexPath.row {
        case 0 ..< questions.count :
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
        guard indexPath.row == questions?.count else { return }

        // questions+=1
        collectionView.reloadData()
    }
}

extension TopicQuestionsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        questions?.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        guard let questions = questions else {
            print("questions array empty")
            return UIView()
        }

        let pickerLabel = UILabel(frame: CGRect(
                                    x: 0,
                                    y: 0,
                                    width: pickerView.frame.size.width - 20,
                                    height: 50)
        )

        pickerLabel.numberOfLines = 0
        pickerLabel.text = questions[row].question
        pickerLabel.sizeToFit()
        pickerLabel.lineBreakMode = .byWordWrapping
        //down arrow
        let arrowView = UIButton(frame: CGRect(
                                x: 0,
                                y: 0,
                                width: 40,
                                height: 20)
        )

        if row != questions.count - 1 {
            //arrowView.tag = row
            //arrowView.addTarget(self, action: #selector(selectRow(sender:)), for: .touchUpInside)
            let image = UIImage(systemName: "chevron.down")
            arrowView.setImage(image, for: .normal)

            let stackView = UIStackView(frame: CGRect(
                                            x: 0,
                                            y: 0,
                                            width: pickerView.frame.size.width - 20,
                                            height: 70)
            )
            stackView.spacing = 0
            stackView.distribution = .fillProportionally
            stackView.alignment = .center
            stackView.axis = .vertical
            stackView.addArrangedSubview(pickerLabel)
            stackView.addArrangedSubview(arrowView)
            return stackView
        } else {
            return pickerLabel
        }
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        100
    }

}

extension TopicQuestionsViewController: SingleRowSpinnerDelegate {

    func updateSpinner() {
        let row = pickerView.selectedRow(inComponent: 0)
        if row != pickerView.numberOfRows(inComponent: 0) - 1 { // -1 to account for non 0 based count
            print("I'm at row \(pickerView.selectedRow(inComponent: 0))")

            let nextRow = pickerView.selectedRow(inComponent: 0) + 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.pickerView.selectRow(nextRow, inComponent: 0, animated: true)
                print("I'm at row \(self.pickerView.selectedRow(inComponent: 0))")
            }

        }
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
