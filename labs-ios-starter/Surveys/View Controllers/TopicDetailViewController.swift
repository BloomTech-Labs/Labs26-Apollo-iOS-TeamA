// Copyright © 2020 Shawn James. All rights reserved.
// TopicDetailViewController.swift

import UIKit

class TopicDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var CRUDCollectionView: UICollectionView!

    // MARK: - Actions -
    @IBAction func showMembers(_ sender: UIButton) {
        // Popover Segue to ProfileListViewController
    }

    // MARK: - Properties -
    var topic: Topic?
    let reuseIdentifier = String.getCollectionViewCellID(.crudCollectionViewCell)
    
    // MARK: - View Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CRUDCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
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
