//
//  PopoverViewController.swift
//  Mittens
//
//  Created by Cristian Turetta on 26/09/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import UIKit
import Firebase

class PopoverViewController: UITableViewController{

    var feedId: String?
  //  let feedCategory: String?
    var chatId: String?
    weak var removeFeedDelegation: PresentationDelegate?
    
    let staticSettings = ["Edit Post", "Delete"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset.right = 20
        tableView.separatorInset.left = 20
        // Do any additional setup after loading the view.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = staticSettings[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1{
            removeFeedDelegation?.removeFeed!(withID: feedId!, idChat: chatId!)

        }
        if indexPath.row == 2{
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
