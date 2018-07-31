//
//  UserCell.swift
//  breakpoint
//
//  Created by Alan Tseng on 6/3/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    let userCellId = "userCell"

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    var showing = false
    
    func configureCell(profileImage image: UIImage, username email: String, isSelected: Bool) {
        self.profileImage.image = image
        self.emailLabel.text = email
        self.checkImage.isHidden = isSelected ? false : true 
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            if showing == false {
                checkImage.isHidden = false
                showing = true
            } else {
                checkImage.isHidden = true
                showing = false
            }
        }
        
    }

}
