//
//  Message.swift
//  breakpoint
//
//  Created by Alan Tseng on 6/3/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import Foundation

struct Message {
    private var _content: String
    private var _senderId: String
    
    var content: String {
        return _content
    }
    
    var senderId: String {
        return _senderId
    }
    
    init(content: String, senderId: String) {
        self._content = content
        self._senderId = senderId
    }
}
