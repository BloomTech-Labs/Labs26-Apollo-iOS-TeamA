// Copyright © 2020 Shawn James. All rights reserved.
// TopicQuestionsViewController.swift

import UIKit

class TopicQuestionsViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet var pickerView: SingleRowPickerView!

    @IBOutlet var questionsCollectionView: UICollectionView!
    // @IBOutlet var contextSegmentControl: UISegmentedControl!

    // MARK: - Properties -
    let spinner = UIActivityIndicatorView()
    var topicName: String?
    let topicController = TopicController()
    let questionsCellReuseId = String.getCollectionViewCellID(.questionsCollectionViewCell)
    let addNewQuestionCellReuseId = String.getCollectionViewCellID(.addNewQuestionCell)
    let correctSegueId = String.getSegueID(.reviewDetailsSegue)
    var contextID: Int? // from TopicNameViewController
    private var fetchController = FetchController()

    var questions: [ContextQuestion]? {
        didSet {
            DispatchQueue.main.async {
                self.pickerView.reloadAllComponents()
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPickerView()
        getAllContextQuestions()
    }

    private func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tapDelegate = self
    }

    // TODO: refactor to get `default` context and request questions
    // Get questions from server, save to CoreData, and fetch from CoreData
    private func getAllContextQuestions() {
        topicController.getDefaultContextQuestions { result in
            switch result {
            case .success():
                self.questions = self.fetchController.fetchDefaultContextQuestionsRequest()

            case let .failure(error):
                self.presentNetworkError(error: error.rawValue) { tryAgain in
                    if tryAgain != nil {
                        // user wants to try again
                        if tryAgain! {
                            self.getAllContextQuestions()
                        }
                    }
                    // user didn't want to try again
                }
            }
        }
    }

    // MARK: - Update -

    private func postTopic(contextID: Int) {
        // TODO: Dynamic questions when made available
        guard let topicName = topicName else {
            print("TopicName was nil!")
            return
        }

        guard let questions = questions else {
            print("couldn't fetch questions from CoreData")
            return
        }

        topicController.postTopic(with: topicName, contextId: contextID, contextQuestions: questions, requestQuestions: []) { result in
            switch result {
            case let .success(joinCode):
                // alert user of success and add notification
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

    // Supposed to prevent collisions with tap gesture recognizers, may or may not be needed
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension TopicQuestionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // TODO: Convert section to added questions rather than all questions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let questions = questions else {
            print(" topic questions array empty")
            return UICollectionViewCell()
        }

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
        guard indexPath.row == questions?.count else { return }

        // questions+=1
        collectionView.reloadData()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == correctSegueId,
            let destinationVC = segue.destination as? ReviewDetailsViewController
        // TODO: finish unwrapping dependancies
        else {
            fatalError("Early exit from prepare(for segue:) -> Missing dependancies"); return
        }
        if let topicName = topicName {
            destinationVC.topicName = topicName
        }
        if let questions = questions {
            var string = ""
            questions.forEach { question in
                string += "\n\n" // Double-spacing
                string.append(question.question)
            }
            destinationVC.questions = string
            destinationVC.delegate = self
        }
        // TODO:
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
        // setup label
        let padding: CGFloat = 20
        let pickerLabelHeight: CGFloat = 50
        let pickerLabel = UILabel(frame: CGRect(x: 0,
                                                y: 0,
                                                width: pickerView.frame.size.width - padding,
                                                height: pickerLabelHeight)
        )

        let font = UIFont(name: "Apple Symbols", size: 24)
        pickerLabel.numberOfLines = 0
        pickerLabel.font = font
        pickerLabel.text = questions[row].question
        pickerLabel.sizeToFit()
        pickerLabel.lineBreakMode = .byWordWrapping

        let stackViewHeight: CGFloat = 70
        let stackView = UIStackView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: pickerView.frame.size.width - padding,
                                                  height: stackViewHeight)
        )

        stackView.spacing = 0
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.addArrangedSubview(pickerLabel)

        // down arrow
        let width: CGFloat = 40
        let height = width / 2
        let arrowView = UIButton(frame: CGRect(x: 0,
                                               y: 0,
                                               width: width,
                                               height: height)
        )

        let isLastRow = row == questions.count - 1
        let image = isLastRow ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
        arrowView.setImage(image, for: .normal)
        stackView.addArrangedSubview(arrowView)

        return stackView
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        100
    }
}

// Move the spinner to the next row when the row is tapped
extension TopicQuestionsViewController: SingleRowSpinnerDelegate {
    func updateSpinner() {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        let numberOfRows = pickerView.numberOfRows(inComponent: 0) - 1
        let isLastRow = selectedRow == numberOfRows
        let nextRow = isLastRow ? 0 : selectedRow + 1

        DispatchQueue.main.async {
            self.pickerView.selectRow(nextRow, inComponent: 0, animated: true)
        }
    }
}

extension TopicQuestionsViewController: ReviewDetailsViewControllerDelegate {
    func sendTopic() {
        guard let contextID = contextID else {
            print("no context id")
            return
        }
        postTopic(contextID: contextID)
    }
}
