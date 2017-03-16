//
//  LikersTableViewController.swift
//  mittens
//
//  Created by Cristian Turetta on 19/10/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import UIKit
import Firebase

class LikersTableViewController: UITableViewController {
    
    weak var delegate: CustomDelegate?
    
    var likers = [String]()
    var profiles = [Person](){
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: "person")
        tableView.separatorInset.left = 70
        tableView.tableFooterView = UIView(frame: .zero)
        // Populationg profiles array
        retrivePersonHowLikeThisPost()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return profiles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "person", for: indexPath) as! PersonTableViewCell

        // Configure the cell...
        if likers.count != 0 {
            cell.person = profiles[indexPath.row]
        }else{
            cell.textLabel?.text = "Ancora nessuno ha messo like..."
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = profiles[indexPath.row]
        delegate?.moveToSelectedProfile!(withID: selected.identifier!, profilePhoto: selected.profileImage, withName: selected.displayName!)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: - Private Implementations
    private func retrivePersonHowLikeThisPost(){
        for user in likers {
            // user is the ID of the profile i-esimo that put like to this post
            FIRDatabase.database().reference().child("users").child(user).observeSingleEvent(of: .value, with: { (snapshot) in
                let retrived = snapshot.value as! [String:String]
                let displayName = retrived["displayName"]
                let userIdentifier = retrived["id"]
                let profilePhotoUrl = retrived["profilePhoto"]
                
                let mediaUrl = URL(string: (profilePhotoUrl)!)
                if let data = try? Data(contentsOf: mediaUrl!){
                    let image: UIImage = UIImage(data: data)!
                    self.profiles.append(Person(personoWhitName: displayName!, userIdentifier: userIdentifier!, andProfileImage: image))
                }
            })
        }
    }
}
