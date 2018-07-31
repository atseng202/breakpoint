//
//  ShadowView.swift
//  breakpoint
//
//  Created by Alan Tseng on 6/1/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    override func awakeFromNib() {
        self.layer.shadowOpacity = 0.75
        self.layer.shadowRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
        super.awakeFromNib()
    }
    
}
