//
//  SecondViewController.swift
//  breakpoint
//
//  Created by Alan Tseng on 5/31/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

class GroupsVC: UIViewController {

    let groupCellId = "groupCell"
    var groupsArray = [Group]()
    
    @IBOutlet weak var groupsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupsTableView.delegate = self
        groupsTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DataService.instance.REF_GROUPS.observe(.value) { (_) in
            DataService.instance.getAllGroups { (returnedGroupsArray) in
                self.groupsArray = returnedGroupsArray
                self.groupsTableView.reloadData()
            }
        }
    }


}

extension GroupsVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = groupsTableView.dequeueReusableCell(withIdentifier: groupCellId) as? GroupCell else { return UITableViewCell() }
        
        let group = groupsArray[indexPath.row]
        cell.configureCell(title: group.groupTitle, description: group.groupDescription, memberCount: 3)
        return cell
    }
    
    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let groupFeedVC = storyboard?.instantiateViewController(withIdentifier: "GroupFeedVC") as? GroupFeedVC else { return }
        
        groupFeedVC.initData(forGroup: groupsArray[indexPath.row])
        
        presentDetail(groupFeedVC)
//        present(groupFeedVC, animated: true, completion: nil)
    }
    
}





