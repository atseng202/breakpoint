//
//  Group.swift
//  breakpoint
//
//  Created by Alan Tseng on 6/4/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import Foundation

struct Group {
    private var _groupTitle: String
    private var _groupDescription: String
    private var _key: String
    private var _memberCount: Int
    private var _members: [String]
    
    var groupTitle: String {
        return _groupTitle
    }
    
    var groupDescription: String {
        return _groupDescription
    }
    
    var key: String {
        return _key
    }
    
    var memberCount: Int {
        return _memberCount
    }
    
    var members: [String] {
        return _members
    }
    
    init(title: String, description: String, key: String, members: [String], memberCount: Int) {
        self._groupTitle = title
        self._groupDescription = description
        self._key = key
        self._members = members
        self._memberCount = memberCount 
    }
    
    
}








