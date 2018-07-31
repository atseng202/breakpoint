//
//  GroupFeedVC.swift
//  breakpoint
//
//  Created by Alan Tseng on 6/4/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit
import Firebase

class GroupFeedVC: UIViewController {
    
    // MARK; - Properties
    let groupCellId = "groupFeedCell"
    
    @IBOutlet weak var groupTitleLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var membersLabel: UILabel!
    
    @IBOutlet weak var sendButtonView: UIView!
    @IBOutlet weak var messageTextField: InsetTextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var sendViewBottomConstraint: NSLayoutConstraint!
    
    
    var group: Group!
    
    var groupMessages = [Message]()
    
    func initData(forGroup group: Group) {
        self.group = group
    }
    
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
         super.viewDidLoad()
        // removed UIView extension and added notifications in viewController because I need to manipulate autolayout constraints

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        
        messageTextField.delegate = self
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.sendViewBottomConstraint.constant = keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
           self.sendViewBottomConstraint.constant = 0

        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        groupTitleLabel.text = group.groupTitle
        DataService.instance.getEmailsFor(group: group) { (returnedEmails) in
            self.membersLabel.text = returnedEmails.joined(separator: ", ")
            
        }
        
        DataService.instance.REF_GROUPS.observe(.value) { (_) in
            DataService.instance.getAllMessagesFor(desiredGroup: self.group, handler: { (returnedGroupMessages) in
                self.groupMessages = returnedGroupMessages
                self.tableView.reloadData()
                
                if self.groupMessages.count > 0 {
                    print("Scrolling to last index")
                    self.tableView.scrollToRow(at: IndexPath(row: self.groupMessages.count - 1, section: 0), at: .none, animated: false)
                }
            })
        }
    }
    
    

    // MARK: - Action Methods
    
    @IBAction func backButtonWasPressed(_ sender: UIButton) {
        dismissDetail()
    }
    
    @IBAction func sendButtonWasPressed(_ sender: UIButton) {
        guard let message = messageTextField.text, message != "",
        let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        DataService.instance.uploadPost(withMessage: message, forUID: currentUserId, withGroupKey: group.key) { (success) in
            if success {
                self.messageTextField.text = ""
                self.messageTextField.isEnabled = true
                self.sendButton.isEnabled = true
            }
        }
        
    }
}

extension GroupFeedVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: groupCellId, for: indexPath) as? GroupFeedCell else { return UITableViewCell() }
        
        let message = groupMessages[indexPath.row]
        let defaultProfileImage = UIImage(named: "defaultProfileImage")!
        
        DataService.instance.getUser(forUID: message.senderId, handler: { (user) in
            if let user = user {
                cell.configureCell(profileImageUrl: user.profileImageUrl, defaultProfileImage: defaultProfileImage, email: user.email, content: message.content)
            }
        })
        return cell
        
    }
    
    // MARK: - TV Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension GroupFeedVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}










