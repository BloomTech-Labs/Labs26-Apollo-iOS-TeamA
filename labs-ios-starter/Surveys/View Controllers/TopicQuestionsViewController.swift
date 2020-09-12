// Copyright © 2020 Shawn James. All rights reserved.
// TopicQuestionsViewController.swift

import UIKit

class TopicQuestionsViewController: UIViewController {
    
    // MARK: - Outlets & Properties
    @IBOutlet weak var questionsCollectionView: UICollectionView!
    
    let reuseIdentifier = "QuestionsCollectionViewCell"
    let reuseIdentifier2 = "AddNewQuestionCell"
    
    var questions = 1
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Handlers
    
    // MARK: - Reusable
    
}

extension TopicQuestionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
            case 0..<(questions):
                let cell = questionsCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
                cell.setDimensions(width: view.frame.width - 40, height: 40)
                return cell
            default:
                let cell = questionsCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier2, for: indexPath)
                cell.setDimensions(width: view.frame.width - 40, height: 35)
                return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row == questions else { return }
        
        questions+=1
        collectionView.reloadData()
    }
    
}

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
