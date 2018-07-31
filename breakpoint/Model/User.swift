//
//  User.swift
//  breakpoint
//
//  Created by Alan Tseng on 6/4/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import Foundation

struct User {
    private var _profileImageUrl: String?
    private var _email: String
    private var _uid: String
    private var _provider: String
    
    var provider: String? {
        return _provider
    }
    
    var profileImageUrl: String? {
        return _profileImageUrl
    }
    
    var email: String {
        return _email 
    }
    
    var uid: String {
        return _uid
    }
    
    init(profileImageUrl: String?, email: String, uid: String, provider: String) {
        self._profileImageUrl = profileImageUrl
        self._email = email
        self._uid = uid
        self._provider = provider
    }
    
    init(uid: String, userDictionary: [String: Any]) {
        self._uid = uid
        self._profileImageUrl = userDictionary["profileImageUrl"] as? String ?? nil
        self._email = userDictionary["email"] as? String ?? ""
        self._provider = userDictionary["provider"] as? String ?? ""
    }
    
}
