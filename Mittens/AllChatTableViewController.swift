//
//  AllChatTableViewController.swift
//  Mittens
//
//  Created by enrico  gigante on 07/09/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import UIKit
import CoreData

class AllChatTableViewController: CoreDataTableViewController {
    
    // Notification helpers
    var chatID: String?
    
    var context = AllContext.mainContext {didSet {updateUI() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "filter", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AllChatTableViewController.presentActioSheet))
        
        tableView.separatorInset.left = 80
        
        //nasconde le righe in eccesso
        self.tableView.tableFooterView = UIView(frame: .zero)
        updateUI()        
    }
    
    @objc private func presentActioSheet(){
        let actionSheet = UIAlertController()
        
        let allChatsFilter = UIAlertAction(title: "Tutte le Chats", style: .default) { (action) in
            self.updateUI()
        }
        
        let myChatsFilter = UIAlertAction(title: "Le mie Chats", style: .default) { (action) in
            self.updateUIWithFilterForMyChat()
        }
        
        let otherChatsFilter = UIAlertAction(title: "Chats visitate", style: .default) { (action) in
            self.updateUIWithFilterForOtherChat()
        }
        

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(allChatsFilter)
        actionSheet.addAction(myChatsFilter)
        actionSheet.addAction(otherChatsFilter)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }

    func updateUI() {
        title = "Chats"
        guard let context = context else {return}
        let myId = UserDefaults.standard.object(forKey: "uid") as! String
        let request: NSFetchRequest<Chat> = Chat.fetchRequest()
        request.predicate = NSPredicate(format: "userID = %@", myId)

        request.sortDescriptors = [NSSortDescriptor(key: "hashtagID", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
    }
    
    func updateUIWithFilterForMyChat(){
        title = "Le mie Chats"
        guard let context = context else {return}
        let request: NSFetchRequest<Chat> = Chat.fetchRequest()
        let myId = UserDefaults.standard.object(forKey: "uid") as! String
        request.predicate = NSPredicate(format: "userID = %@ AND isMyChat = true",myId )
        request.sortDescriptors = [NSSortDescriptor(key: "hashtagID", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
    }
    
    func updateUIWithFilterForOtherChat(){
        title = "Chats Visitate"
        guard let context = context else {return}
        let myId = UserDefaults.standard.object(forKey: "uid") as! String
        let request: NSFetchRequest<Chat> = Chat.fetchRequest()
        request.predicate = NSPredicate(format: " userID = %@ AND isMyChat = nil", myId)
        request.sortDescriptors = [NSSortDescriptor(key: "hashtagID", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(ChatCell.self, forCellReuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatCell
        
        if let chat = fetchedResultsController?.object(at: indexPath) {
            cell.accessoryType = .disclosureIndicator
            
            if let data = chat.photoChat {
                if let image = UIImage(data: data as Data) {
                    cell.photoView.image = image
                }
            }
            let nameOfLastSender = chat.lastMessageTime?.sender?.displayName ?? ""
            cell.lastSenderNameLabel.text = nameOfLastSender
            cell.lastMessageLabel.text = chat.lastMessageTime?.text ?? "no message"
            cell.chatNameLabel.text = chat.nameChat//?.uppercased()
            if let numberOfPartecipants = chat.contacts?.count {
                cell.partecipantsLabel.text =  String(numberOfPartecipants) + " utenti"
            }
            
        }
        
        return cell
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        if let notifiactionChatID = chatID {
            print("showing notification")
            chatID = nil

            let chatVC = ChatViewController()
            let chat = Chat.chatExisting(hashtag: notifiactionChatID, context: context!)
            // setting up chat view controller
            chatVC.chat = Chat.chatExisting(hashtag: notifiactionChatID, context: context!)
            chatVC.title = chat?.nameChat
            chatVC.context = AllContext.mainContext
            chatVC.senderId = UserDefaults.standard.object(forKey: "uid") as! String
            chatVC.senderDisplayName = UserDefaults.standard.object(forKey: "displayName") as! String
            chatVC.messageRef = AllFirebasePaths.firebase(pathName: "pathChats")?.child(notifiactionChatID).child("messages")
            chatVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    //MARK: TableViewDataSource
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chat = fetchedResultsController?.object(at: indexPath) else {return}
        guard let hashtag = chat.hashtagID else {return}
        
        let chatVC = ChatViewController()
        
        chatVC.title = chat.nameChat ?? ""
        chatVC.context = AllContext.mainContext
        chatVC.chat = chat
        chatVC.senderId = UserDefaults.standard.object(forKey: "uid") as! String
        chatVC.senderDisplayName = UserDefaults.standard.object(forKey: "displayName") as! String
        chatVC.messageRef = AllFirebasePaths.firebase(pathName: "pathChats")?.child(hashtag).child("messages")
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let chat = fetchedResultsController?.object(at: indexPath){
            context?.delete(chat)
            do{
                try context?.save()
                updateUI()
            }catch {
                print("errpr")
            }
        }
    }
}
