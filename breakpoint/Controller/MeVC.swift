//
//  MeVC.swift
//  breakpoint
//
//  Created by Alan Tseng on 6/2/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit
import Firebase
import Photos
import GoogleSignIn

class MeVC: UIViewController {

    @IBOutlet weak var profileImage: CustomImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var currentUser: User? {
        didSet {
            guard let profileImageUrl = currentUser?.profileImageUrl else { return }
            profileImage.loadImage(urlString: profileImageUrl)
            profileImage.layer.cornerRadius = profileImage.frame.width / 2
        }
    }
    
    let feedCellId = "meFeedCell"
    let groupFeedCellId = "meGroupFeedCell"
    
    var myGroupsArray = [Group]()
    var groupMessages = [Message]()
    var feedMessages = [Message]()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleImageTapped(tapGestureRecognizer:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailLabel.text = Auth.auth().currentUser?.email
        
        fetchCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        print("Current user's id", currentUserId)
        DataService.instance.REF_GROUPS.observe(.value) { (_) in
            DataService.instance.getAllGroups(handler: { (returnedGroupsArray) in
                self.myGroupsArray = returnedGroupsArray
                self.groupMessages = [] 
                for group in returnedGroupsArray {
                    
                    DataService.instance.getAllMessagesFor(desiredGroup: group, handler: { (returnedGroupMessages) in
                        print("returned group messages count", returnedGroupMessages.count)
                        self.groupMessages += returnedGroupMessages.filter { $0.senderId == currentUserId }
                        
                        self.tableView.reloadData()
                    })
                }
            })
        }
        
        self.getCurrentUserFeedMessages(forUID: currentUserId)
        
        print("# of group messages:", groupMessages.count)
        print("Feed message:", feedMessages.count)
    }
    
    fileprivate func getCurrentUserFeedMessages(forUID uid: String) {
        DataService.instance.REF_FEED.observe(.value) { (_) in
            DataService.instance.getAllFeedMessages { (returnedFeedMessages) in
                print("returned Feed messages count", returnedFeedMessages.count)
                self.feedMessages = returnedFeedMessages.filter { $0.senderId == uid }
                self.tableView.reloadData()
                
                //            if self.groupMessages.count > 0 {
                //                self.tableView.scrollToRow(at: IndexPath(row: self.groupMessages.count - 1, section: 1), at: .none, animated: false)
                //            }
            }
        }

    }
    
    // MARK: - Action Methods

    @IBAction func signOutBtnWasPressed(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let logoutPopup = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.actionSheet)
        let logoutAction = UIAlertAction(title: "Logout?", style: .destructive) { [weak self] (buttonTapped) in
            
            do {
                try Auth.auth().signOut()
                let authVC = self?.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
                self?.present(authVC!, animated: true, completion: nil)
            } catch {
                print(error)
                // should present an alert to the user that logout failed
            }
        }
        logoutPopup.addAction(logoutAction)
        logoutPopup.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(logoutPopup, animated: true, completion: nil)
    }
    
    // MARK: - Helper Functions
    @objc func handleImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Allowing user to change profile image...")

        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        
        present(imagePickerController, animated: true, completion: nil)
        PHPhotoLibrary.requestAuthorization({ (status) in
            switch status {
            case .authorized:
                print("Authorized")
            case .denied:
                self.dismiss(animated: true, completion: nil)
            default:
                break
            }
        })
    }
    
    // MARK: - Fetch User Methods
    func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        DataService.instance.getUser(forUID: uid) { [weak self] (returnedUser) in
            if let returnedUser = returnedUser {
                self?.currentUser = returnedUser
            }
        }
    }
    
    
}


extension MeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let userUid = Auth.auth().currentUser?.uid else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            profileImage.image = editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            profileImage.image = originalImage.withRenderingMode(.alwaysOriginal)
        } else {
            // no valid image returned
            dismiss(animated: true, completion: nil)
            return
        }
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        // Important to show corner radius
        profileImage.layer.masksToBounds = true
        profileImage.layer.borderColor = UIColor.black.cgColor
        
        // Save profile image to Firebase
        DataService.instance.uploadPhoto(withImage: profileImage.image!, forUID: userUid) { [weak self] (success) in
            if success {
                self?.dismiss(animated: true, completion: nil)
            } else {
                // should present an error to the user that we couldn't upload their profile image to the DB
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension MeVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return feedMessages.count
        } else {
            return groupMessages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: feedCellId, for: indexPath) as? FeedCell else { return UITableViewCell() }
            let feedMessage = feedMessages[indexPath.row]
            let defaultImage = UIImage(named: "defaultProfileImage")!
            
            if let currUser = currentUser {
                cell.configureCell(profileImageUrl: currUser.profileImageUrl, defaultImage: defaultImage, email: currUser.email, content: feedMessage.content)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: groupFeedCellId, for: indexPath) as? GroupFeedCell else { return UITableViewCell() }
            let groupFeedMessage = groupMessages[indexPath.row]
            let defaultImage = UIImage(named: "defaultProfileImage")!
            
            if let currUser = currentUser {
                cell.configureCell(profileImageUrl: currUser.profileImageUrl, defaultProfileImage: defaultImage, email: currUser.email, content: groupFeedMessage.content)
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Feed Posts"
        } else {
            return "Group Posts"
        }
    }
    
    // MARK: - Tableview Delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))

        headerView.backgroundView = UIView(frame: headerView.frame)
        headerView.backgroundView?.backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.2705882353, blue: 0.3137254902, alpha: 1)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = #colorLiteral(red: 0.5607843137, green: 0.8117647059, blue: 0.3058823529, alpha: 1)
        }
    }
}









