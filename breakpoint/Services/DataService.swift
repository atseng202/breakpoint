//
//  DataService.swift
//  breakpoint
//
//  Created by Alan Tseng on 5/31/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = Database.database().reference()

class DataService {
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_GROUPS = DB_BASE.child("groups")
    private var _REF_FEED = DB_BASE.child("feed")
    
    // MARK: - Public Properties
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_GROUPS: DatabaseReference {
        return _REF_GROUPS
    }
    
    var REF_FEED: DatabaseReference {
        return _REF_FEED
    }
    
    func createDBUser(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    // MARK: - Saving profileImageUrl to users ref
    func uploadPhoto(withImage image: UIImage, forUID uid: String, uploadComplete: @escaping (_ success: Bool) -> Void) {
        
        guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else {
            uploadComplete(false)
            return
        }
        
        let fileName = UUID().uuidString
        Storage.storage().reference().child("profile_image").child(fileName).putData(uploadData, metadata: nil) { [weak self] (metaData, error) in
            if let error = error {
                print("Failed to upload profile image:", error.localizedDescription)
                uploadComplete(false)
                return
            }
            
            guard let profileImageUrl = metaData?.downloadURL()?.absoluteString else {
                uploadComplete(false)
                return
            }
            print("Successfully uploaded profile image data to storage:", profileImageUrl)
            
            let profileImageValueDict: [String: Any] = ["profileImageUrl": profileImageUrl]
            self?.REF_USERS.child(uid).updateChildValues(profileImageValueDict, withCompletionBlock: { (error, reference) in
                if let error = error {
                    print("Failed to save profileImageUrl into database:", error.localizedDescription)
                    uploadComplete(false)
                    return
                }
                print("Successfully saved profileImageUrl into DB")
                uploadComplete(true)
            })
            
        }
        
        
    }
    // MARK: - Instead of just getting username (email) I will just get the user
    func getUser(forUID uid: String, handler: @escaping (_ user: User?) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value, with: { (userSnapshot) in
            guard let userDict = userSnapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, userDictionary: userDict)
            
            handler(user)
        }) { (error) in
            print("Failed to get user for \(uid):", error.localizedDescription)
            handler(nil)
        }
    }
    
    
    // MARK: - To be Organized...
    func getUsername(forUID uid: String, handler: @escaping (_ username: String) -> Void) {
        REF_USERS.observeSingleEvent(of: .value, with: { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if user.key == uid {
                    guard let username = user.childSnapshot(forPath: "email").value as? String else { continue }
                    handler(username)
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
    
    func uploadPost(withMessage message: String, forUID uid: String, withGroupKey groupKey: String?, sendComplete: @escaping (_ status: Bool) -> Void) {
        if let groupKey = groupKey {
            // send to groups ref
            let groupDict: [String: Any] = ["content": message, "senderId": uid]
            REF_GROUPS.child(groupKey).child("messages").childByAutoId().updateChildValues(groupDict) { (error, ref) in
                if let error = error {
                    print("Failed to update groups ref with messages with error:", error.localizedDescription)
                    sendComplete(false)
                } else {
                    sendComplete(true)
                }
            }
        } else {
            let feedDict: [String: Any] = ["content": message, "senderId": uid]
            REF_FEED.childByAutoId().updateChildValues(feedDict)
            sendComplete(true)
        }
    }
    
    func getAllFeedMessages(handler: @escaping (_ messages: [Message]) -> Void) {
        var messageArray = [Message]()
        REF_FEED.observeSingleEvent(of: .value, with: { (feedMessageSnapshot) in
            guard let feedMessageSnapshot = feedMessageSnapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for message in feedMessageSnapshot {
                guard let content = message.childSnapshot(forPath: "content").value as? String, let senderId = message.childSnapshot(forPath: "senderId").value as? String  else { continue }
                
                let message = Message(content: content, senderId: senderId)
                messageArray.append(message)
            }
            handler(messageArray)
            
        }) { (error) in
            print("Error getting feed messages", error.localizedDescription)
        }
    }
    
    func getAllMessagesFor(desiredGroup: Group, handler: @escaping (_ messagesArray: [Message]) -> Void) {
        var groupMessageArray = [Message]()
        REF_GROUPS.child(desiredGroup.key).child("messages").observeSingleEvent(of: .value) { (groupMessageSnapshot) in
            guard let groupMessageSnapshot = groupMessageSnapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for groupMessage in groupMessageSnapshot {
                guard let content = groupMessage.childSnapshot(forPath: "content").value as? String,
                    let senderId = groupMessage.childSnapshot(forPath: "senderId").value as? String else { continue }
                
                let groupMessage = Message(content: content, senderId: senderId)
                groupMessageArray.append(groupMessage)
            }
            handler(groupMessageArray)
        }
    }
    
    func getEmail(forSearchQuery query: String, handler: @escaping (_ emailArray: [String]) -> Void) {
        var emailArray = [String]()
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for user in userSnapshot {
                guard let email = user.childSnapshot(forPath: "email").value as? String else { continue }
                
                if email.contains(query) && email != Auth.auth().currentUser?.email {
                    emailArray.append(email)
                }
            }
            handler(emailArray)
        }
    }
    
    func getIds(forUsernames usernames: [String], handler: @escaping (_ uidArray: [String]) -> Void) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            var idArray = [String]()
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for user in userSnapshot {
                guard let email = user.childSnapshot(forPath: "email").value as? String else { continue }
                
                if usernames.contains(email) {
                    idArray.append(user.key)
                }
            }
            handler(idArray)
        }
    }
    
    func createGroup(withTitle title: String, andDescription description: String, forUserIds ids: [String], handler: @escaping (_ groupCreated: Bool) -> Void) {
        
        let groupsDict: [String: Any] = ["title": title, "description": description, "members": ids]
        
        REF_GROUPS.childByAutoId().updateChildValues(groupsDict) { (error, reference) in
            if let error = error {
                print("Failed to update Firebase for group with error:", error.localizedDescription)
                handler(false)
            } else {
                handler(true)
            }
        }
    }
    
    func getAllGroups(handler: @escaping (_ groupsArray: [Group]) -> Void) {
        var groupsArray = [Group]()
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        REF_GROUPS.observeSingleEvent(of: .value) { (groupSnapshot) in
            
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for group in groupSnapshot {
                guard let memberArray = group.childSnapshot(forPath: "members").value as? [String],
                    let title = group.childSnapshot(forPath: "title").value as? String,
                    let description = group.childSnapshot(forPath: "description").value as? String else { continue }
                
                if memberArray.contains(currentUserUid) {
                    let newGroup = Group(title: title, description: description, key: group.key, members: memberArray, memberCount: memberArray.count)
                    groupsArray.append(newGroup)
                }
            }
            handler(groupsArray)
        }
    }
    
    func getEmailsFor(group: Group, handler: @escaping (_ emailArray: [String]) -> Void) {
        var emailArray = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for user in userSnapshot {
                if group.members.contains(user.key) {
                    
                    guard let email = user.childSnapshot(forPath: "email").value as? String else { continue }
                    emailArray.append(email)
                }
            }
            handler(emailArray)
        }
    }
    
}











