//
//  ParticipantTableViewController.swift
//  mittens
//
//  Created by Cristian Turetta on 20/10/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ParticipantsTableViewController: UITableViewController {

    // MARK: - Model
    var chat: Chat?
    var administrator: String?
    var status: Bool?
    var allParticipants = [Contact]()
    var allMedia = [Media]()
    
    // MARK: - Outlets
    let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let chatName: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 16)
        return label
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: "participant")
        tableView.register(ChatSettingTableViewCell.self, forCellReuseIdentifier: "settings")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "chatImg")
        
        tableView.separatorInset.left = 70
        tableView.tableFooterView = UIView(frame: .zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return nil
        }
        return " "
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightBold)
        headerView.addSubview(label)
        headerView.addConstraintsWithFormat("H:|-10-[v0]|", views: label)
        headerView.addConstraintsWithFormat("V:|[v0]|", views: label)
        
        switch section {
        case 0:
            return nil
        case 1:
            label.text = " "
        case 2:
            label.text = "Subscribers"
        default:
            break
        }
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return allParticipants.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        switch indexPath.section {
        case 0:
            let chatCell = tableView.dequeueReusableCell(withIdentifier: "chatImg", for: indexPath)
            chatCell.addSubview(chatImageView)
            chatCell.addSubview(chatName)
            
            chatCell.addConstraintsWithFormat("H:|-10-[v0(50)]", views: chatImageView)
            chatCell.addConstraintsWithFormat("V:|-10-[v0(50)]-10-|", views: chatImageView)
            
            chatCell.addConstraintsWithFormat("H:[v0]-10-[v1]", views: chatImageView, chatName)
            chatCell.addConstraintsWithFormat("V:|-25-[v0]", views: chatName)
            
            chatImageView.image = UIImage(data: chat?.photoChat as! Data)
            chatName.text = chat?.nameChat
            
            return chatCell
        case 1:
            let settingsCell = tableView.dequeueReusableCell(withIdentifier: "settings", for: indexPath) as! ChatSettingTableViewCell
            switch indexPath.row {
            case 0:
                settingsCell.chat = chat
                settingsCell.status = status!
                settingsCell.title = "Notifications"
                return settingsCell
                
            case 1:
                settingsCell.title = "Media item shared"
                return settingsCell
                
            default:
                break
            }
            return settingsCell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "participant", for: indexPath) as! PersonTableViewCell
            // TODO:
            if allParticipants[indexPath.row].id == administrator {
                cell.isGroupAdmin = true
            }
            cell.contact = allParticipants[indexPath.row]
            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 70
        case 1:
            return 50
        default:
            return 70
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // TODO:
            // put here an option
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            let sharedMediaCVC = SharedMediaCollectionViewController()
            sharedMediaCVC.title = "Shared Media (\(allMedia.count))"
            sharedMediaCVC.sharedMedias = allMedia
            navigationController?.pushViewController(sharedMediaCVC, animated: true)
        }
        
        if indexPath.section == 2 {
            let selectedProfile = ProfileViewController()
            selectedProfile.userID = allParticipants[indexPath.row].id
            selectedProfile.profileImage = UIImage(data: allParticipants[indexPath.row].profilePhoto as! Data)!
            selectedProfile.name = allParticipants[indexPath.row].displayName
            
            navigationController?.pushViewController(selectedProfile, animated: true)
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
