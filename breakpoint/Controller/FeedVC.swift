//
//  FirstViewController.swift
//  breakpoint
//
//  Created by Alan Tseng on 5/31/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

class FeedVC: UIViewController {

//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    var messagesArray = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.register(FeedCell.self, forCellReuseIdentifier: "feedCell")
        self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.size.width, height: self.view.frame.size.height - self.tableView.frame.origin.y)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataService.instance.getAllFeedMessages { (returnedMessagesArray) in
            self.messagesArray = returnedMessagesArray.reversed()
            self.tableView.reloadData()
            
            if self.messagesArray.count > 0 {
                print("Scrollin...")
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
            }
        }
    }
   


}

extension FeedVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Delegate
    
    
    // MARK: - Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell") as! FeedCell
        cell.imageView?.image = nil
//        cell.contentLabel.text = ""
//        cell.emailLabel.text = ""
        
        let image = UIImage(named: "defaultProfileImage")
        let message = messagesArray[indexPath.row]
        
        DataService.instance.getUser(forUID: message.senderId, handler: { (user) in
            if let user = user {
                cell.configureCell(profileImageUrl: user.profileImageUrl, defaultImage: image!, email: user.email, content: message.content)
            }
        })
        
        return cell 
    }
}

