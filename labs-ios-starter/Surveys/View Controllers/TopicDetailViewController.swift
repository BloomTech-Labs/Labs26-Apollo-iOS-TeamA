// Copyright © 2020 Shawn James. All rights reserved.
// TopicDetailViewController.swift

import UIKit

class TopicDetailViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet var CRUDCollectionView: UICollectionView!

    // MARK: - Actions -
    @IBAction func showMembers(_ sender: UIButton) {
        // Popover Segue to ProfileListViewController
    }

    // MARK: - Properties -
    var id: Int64?
    let fetchController = FetchController()
    var topic: Topic? {
        didSet {
            if let topic = topic,
               let id = topic.id {
                questions = fetchController.fetchQuestions(withTopicId: id)
            }
        }
    }

    var questions: [Question]? {
        didSet {
            updateViews()
        }
    }
    let reuseIdentifier = String.getCollectionViewCellID(.questionDetailCell)

    // MARK: - View Lifecycle -
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let id = self.id else {return}
        self.topic = fetchController.fetchTopic(with: id)
    }

    private func updateViews() {
        CRUDCollectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == .getSegueID(.popoverMemberList) {
            guard let memberList = segue.destination as? MemberListViewController else {
                print("Invalid Segue for presenting Member List")
                return
            }
            memberList.topic = self.topic
        }
    }
    
    // MARK: - Handlers

    // MARK: - Reusable
}

extension TopicDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.questions?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = CRUDCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? QuestionCollectionViewCell else {
            // TODO: Remove before prod
            fatalError("invalid identifier: \(reuseIdentifier)") 
      }
        cell.question = self.questions?[indexPath.item]
        cell.setDimensions(width: view.frame.width - 40, height: 80)
        return cell
    }
}

extension TopicDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: .getSegueID(.popoverMemberList), sender: nil)
    }
}



// MARK: - Live Previews

#if DEBUG

    import SwiftUI

    struct TopicDetailViewControllerPreview: PreviewProvider {
        static var previews: some View {
            let storyboard = UIStoryboard(name: "Surveys", bundle: .main)
            let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController

            return tabBarController?.view.livePreview.edgesIgnoringSafeArea(.all)
        }
    }

#endif
