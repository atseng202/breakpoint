//
//  CreatePostVC.swift
//  breakpoint
//
//  Created by Alan Tseng on 6/2/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit
import Firebase

class CreatePostVC: UIViewController {

    @IBOutlet weak var profileImage: CustomImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var sendButtonBottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
//        sendBtn.translatesAutoresizingMaskIntoConstraints = false
//        sendBtn.bindToKeyboard()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DataService.instance.getUser(forUID: uid) { (user) in
            if let user = user {
                DispatchQueue.main.async {
                    guard let imageUrl = user.profileImageUrl else { return }
                    self.profileImage.loadImage(urlString: imageUrl)
                    self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2 
                }
            }
        }
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        print("Send button frame before:", sendBtn.frame)
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("Keyboard will show!")
            self.sendButtonBottomConstraint.constant = keyboardSize.height
            print("Send button frame after:", sendBtn.frame)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.sendButtonBottomConstraint.constant = 0
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        emailLabel.text = Auth.auth().currentUser?.email
    }
    
    
    @IBAction func sendBtnWasPressed(_ sender: UIButton) {
        if textView.text != nil && textView.text != "Say something here..." {
            sendBtn.isEnabled = false
            
            guard let userUid = Auth.auth().currentUser?.uid else {
                sendBtn.isEnabled = true
                return
            }
            
            DataService.instance.uploadPost(withMessage: textView.text, forUID: userUid, withGroupKey: nil) { (isComplete) in
                if isComplete {
                    self.sendBtn.isEnabled = true
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.sendBtn.isEnabled = true
                    print("There was an error!")
                }
            }
        }

    }
    
    @IBAction func closeBtnWasPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension CreatePostVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
}
