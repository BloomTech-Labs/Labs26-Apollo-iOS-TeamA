// Copyright © 2020 Shawn James. All rights reserved.
// TopicDetailViewController.swift

import UIKit

class TopicDetailViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet var contextLabel: UILabel!
    @IBOutlet var joinCodeLabel: UILabel!
    @IBOutlet var requestSegmentControl: UISegmentedControl!
    @IBOutlet var responseCollectionView: UICollectionView!
    @IBOutlet var responseLabel: UILabel!
    @IBOutlet var memberLabel: UILabel!

    // MARK: - Actions -
    @IBAction func selectContextSegment(_ sender: UISegmentedControl) {}

    @IBAction func showThread(_ sender: UIButton) {
        // TODO: perform segue to thread
    }

    // MARK: - Properties -
    var id: Int64?
    let fetchController = FetchController()
    var topicController: TopicController?
    let headerReuseId = "QuestionNameHeader"

    var topic: Topic? {
        didSet {
            if let topic = topic {
                title = topic.topicName
                questions = topic.contextQuestions?.allObjects as? [ContextQuestion]
            }
        }
    }

    var questions: [ContextQuestion]? {
        didSet {
//             updateViews()
        }
    }

    let reuseIdentifier = String.getCollectionViewCellID(.questionDetailCell)

    // MARK: - View Lifecycle -
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        guard let id = self.id else { return }
//        topic = fetchController.fetchTopic(with: id) // this is injecting the topic but also fetching it here
        guard let topic = topic, let joinCode = topic.joinCode else { return }
        print(joinCode)
        joinCodeLabel.text = "JoinCode: \(joinCode)"
        getAllContexts() // sets context label
        updateViews()
    }

    private func updateViews() {
        responseCollectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == .getSegueID(.popoverMemberList) {
            guard let memberList = segue.destination as? MemberListViewController else {
                print("Invalid Segue for presenting Member List")
                return
            }
            memberList.topic = topic
        }
    }

    private func getAllContexts() {
        topicController?.getDefaultContexts { [weak self] _ in
            guard let self = self else {
                print("Topic Controller is nil")
                return
            }
            try? CoreDataManager.shared.saveContext()
            let allContexts = self.fetchController.fetchDefaultContextsRequest()
            let id = Int(self.topic?.contextId ?? 0)
            let contextName = allContexts?[id - 1].title
            DispatchQueue.main.async {
                self.contextLabel.text = contextName
            }
        }
    }
}

// FIXME: - responses not questions, questions are headers
extension TopicDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        questions?.count ?? 1
    }

    // section titleLabels
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                  withReuseIdentifier: headerReuseId,
                                                                                  for: indexPath) as? QuestionSectionHeader
        else {
            fatalError("Failed to configure collectionView header. Broken method or out of range.")
        }
        let section = indexPath.section
        sectionHeader.questionNameLabel.text = questions?[section].question

        return sectionHeader
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions?.count ?? 0 // cell should be populated by responses instead
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = responseCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? QuestionCollectionViewCell else {
            // TODO: Remove before prod
            fatalError("invalid identifier: \(reuseIdentifier)")
        }
        cell.question = questions?[indexPath.item]
        cell.setDimensions(width: view.frame.width - 40, height: 80)
        return cell
    }
}

extension TopicDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        perform segue to thread
    }
}
