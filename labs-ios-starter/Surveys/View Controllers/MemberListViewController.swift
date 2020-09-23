//
//  ProfileListViewController.swift
//  LabsScaffolding
//
//  Created by Spencer Curtis on 7/23/20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import UIKit
import OktaAuth

// TODO: Use as template to display members for topics

class MemberListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var profileController = ProfileController.shared
    var topic: Topic?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        updateViews()
    }
    
    // MARK: - Private Methods
    
    private func updateViews() {
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == .getSegueID(.showProfileDetail) {
            
            guard let profileDetailVC = segue.destination as? ProfileDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow else {
                    return
            }
            
            profileDetailVC.isUsersProfile = false
            profileDetailVC.profile = topic?.members?.allObjects[indexPath.row] as? Member
        }
    }
}

extension MemberListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topic?.members?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .getTableViewCellID(.profileCell), for: indexPath)
        
        guard let member = topic?.members?.allObjects[indexPath.row] as? Member else {
            print("couldn't pull member out of NSSet")
            return UITableViewCell()
        }
        //default values "unwrap" optionals (prevents Optional(first name))
        cell.textLabel?.text = "\(member.firstName ?? "") \(member.lastName ?? "")"
        cell.detailTextLabel?.text = member.email ?? ""
        
        return cell
    }
    
}
