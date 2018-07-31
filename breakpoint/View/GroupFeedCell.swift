//
//  GroupFeedCell.swift
//  breakpoint
//
//  Created by Alan Tseng on 6/4/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

class GroupFeedCell: UITableViewCell {


    @IBOutlet weak var profileImage: CustomImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    func configureCell(profileImageUrl: String?, defaultProfileImage: UIImage, email: String, content: String) {
        
        if let url = profileImageUrl {
            profileImage.loadImage(urlString: url)
            profileImage.layer.cornerRadius = profileImage.frame.width / 2
        } else {
            profileImage.image = defaultProfileImage
        }
        self.emailLabel.text = email
        self.contentLabel.text = content
    }
}
