//
//  CreateGroupsVC.swift
//  breakpoint
//
//  Created by Alan Tseng on 6/3/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit
import Firebase

class CreateGroupsVC: UIViewController {
    
    let userCellId = "userCell"
    var emailsArray = [String]()
    var chosenUserArray = [String]()
    
    @IBOutlet weak var titleTextField: InsetTextField!
    @IBOutlet weak var descriptionTextField: InsetTextField!
    @IBOutlet weak var emailSearchTextField: InsetTextField!
    
    @IBOutlet weak var groupMemberLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        emailSearchTextField.delegate = self
        emailSearchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        doneButton.isHidden = true
    }

    // MARK: - Action Methods
    @IBAction func doneButtonWasPressed(_ sender: UIButton) {
        if titleTextField.text != "" && descriptionTextField.text != "" {
            DataService.instance.getIds(forUsernames: chosenUserArray) { [weak self] (returnedIdsArray) in
                
                guard let currentUserUId = Auth.auth().currentUser?.uid else { return }
                guard let title = self?.titleTextField.text, let description = self?.descriptionTextField.text else { return }
                
                var userIds = returnedIdsArray
                userIds.append(currentUserUId)
                
                DataService.instance.createGroup(withTitle: title, andDescription: description, forUserIds: userIds, handler: { (success) in
                    if success {
                        self?.dismiss(animated: true, completion: nil)
                    } else {
                        print("Group could not be created. Please try again.")
                    }
                })
            }
        }
    }
    
    @IBAction func closedButtonWasPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Text Field Methods
    @objc func textFieldDidChange() {
        if emailSearchTextField.text == "" {
            emailsArray = []
            tableView.reloadData()
        } else {
            guard let searchText = emailSearchTextField.text else { return }
            DataService.instance.getEmail(forSearchQuery: searchText) { (returnedEmailArray) in
                self.emailsArray = returnedEmailArray
                self.tableView.reloadData()
            }
        }
    }
}

extension CreateGroupsVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: userCellId) as? UserCell else { return UITableViewCell() }
        let profileImage = UIImage(named: "defaultProfileImage")
        let email = emailsArray[indexPath.row]
        
        if chosenUserArray.contains(email) {
            cell.configureCell(profileImage: profileImage!, username: email, isSelected: true)
        } else {
            cell.configureCell(profileImage: profileImage!, username: email, isSelected: false)
        }
        
        return cell
    }
    
    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? UserCell else { return }
        guard let email = cell.emailLabel.text else { return }
        
        if !chosenUserArray.contains(email) {
            chosenUserArray.append(email)
            groupMemberLabel.text = chosenUserArray.joined(separator: ", ")
            doneButton.isHidden = false
        } else {
            chosenUserArray = chosenUserArray.filter { $0 != email }
            if chosenUserArray.count >= 1 {
                groupMemberLabel.text = chosenUserArray.joined(separator: ", ")
            } else {
                groupMemberLabel.text = "add people to your group"
                doneButton.isHidden = true
            }
        }
        
    }
}


extension CreateGroupsVC: UITextFieldDelegate {
    
}






