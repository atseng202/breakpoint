//
//  AuthVC.swift
//  breakpoint
//
//  Created by Alan Tseng on 6/1/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FacebookLogin

class AuthVC: UIViewController {

    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.colorScheme = .dark
        googleSignInButton.style = .wide
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser != nil {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func signInWithEmailBtnWasPressed(_ sender: UIButton) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        present(loginVC!, animated: true, completion: nil)
    }
    
    
    @IBAction func googleSignInButtonWasPressed(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance().signInSilently()
    }
    

    
    @IBAction func facebookSignInBtnWasPressed(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.email], viewController: self) { [weak self] (loginResult) in
            switch loginResult {
            case LoginResult.failed(let error):
                print(error)
            case LoginResult.cancelled:
                print("User cancelled login.")
            case LoginResult.success(grantedPermissions: let grantedPermissions, declinedPermissions: let declinedPermissions, token: let accessToken):
                print("Logged in: ")
                
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                
                Auth.auth().signInAndRetrieveData(with: credential, completion: { (authResult, error) in
                    if let error = error {
                        print("Error logging to Firebase using FB login credentials:", error.localizedDescription)
                        return
                    }
                    
                    // User is now signed in to Firebase
                    guard let returnedUser = authResult?.user else { return }
                    let userData: [String: Any] = ["provider": returnedUser.providerID, "email": returnedUser.email]
                    print(userData)
                    DataService.instance.createDBUser(uid: returnedUser.uid, userData: userData)
                    
                    self?.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
}

extension AuthVC: GIDSignInUIDelegate {
    
}
