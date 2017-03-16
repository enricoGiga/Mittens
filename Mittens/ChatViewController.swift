//
//  ChatViewController.swift
//
//
//  Created by enrico  gigante on 24/08/16.
//
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseMessaging
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import CoreData
import UserNotifications
import Alamofire
class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate  {
    
    // MARK: - Model
    var chat: Chat?
    var administrator: String?
    var messageRef: FIRDatabaseReference?
    let userDefault = UserDef()
    var isSubscribed: Bool?
    var status: Bool?
    var context: NSManagedObjectContext?
    private var allMessages = [Message]() {didSet { collectionView.reloadData() } }
    
    // MARK: - Outlet
    let subscribeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Subscribe", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 119/255, green: 221/255, blue: 48/255, alpha: 0.8)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
    
    let icon: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        return button
    }()
    
    func subscribeToChat(){
        isSubscribed = true
        subscribeButton.removeFromSuperview()
        inputToolbar.isHidden = false
        status = true
        let me = UserDefaults.standard.object(forKey: "uid") as? String
        let myToken = userDefault.returnMyToken()
        FIRDatabase.database().reference().child("Chats").child((chat?.hashtagID!)!).child("joined").updateChildValues([me!:myToken!])
    }
    
    func setChatIconInNavigationController(){
        let chatIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        chatIcon.contentMode = .scaleAspectFill
        
        if let data = chat?.photoChat {
            if let image = UIImage(data: data as Data) {
                chatIcon.image = image
            }
        }
        
        icon.setBackgroundImage(chatIcon.image, for: .normal)
        icon.addTarget(self, action: #selector(showParticipant), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: icon)
        
        navigationItem.rightBarButtonItem = barButton
    }
    
    func showParticipant(){
        let allParticipants = chat?.contacts?.allObjects as? [Contact]
        let allMessages = chat?.messages?.allObjects as? [Message]
        var allMedia = [Media]()
        
        for message in allMessages!{
            if let media = message.media {
                allMedia.append(media)
            }
        }
        
        let allParticipantTVC = ParticipantsTableViewController()
        allParticipantTVC.title = "Chat Info"
        
        allParticipantTVC.chat = chat
        allParticipantTVC.administrator = administrator
        allParticipantTVC.status = status
        allParticipantTVC.allParticipants = allParticipants ?? []
        allParticipantTVC.allMedia = allMedia
        
        navigationController?.pushViewController(allParticipantTVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (navigationController?.isBeingPresented)! {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
            if !(isSubscribed!) {
                inputToolbar.isHidden = true
                view.addSubview(subscribeButton)
                view.addConstraintsWithFormat("H:|-40-[v0]-40-|", views: subscribeButton)
                view.addConstraintsWithFormat("V:[v0(50)]-8-|", views: subscribeButton)
                subscribeButton.addTarget(self, action: #selector(subscribeToChat), for: .touchUpInside)
            }else{
                isSubscribed = true
            }
            
        }
        // Check if notifications are active for this chat
        FIRDatabase.database().reference().child("Chats").child((chat?.hashtagID)!).child("joined").observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as! [String:String]
            let me = UserDefaults.standard.object(forKey: "uid") as? String ?? "default"
            if (users[me] != nil) {
                self.status = true
            }else{
                self.status = false
            }
            
        })
        
        // Retrive the administartor
        FIRDatabase.database().reference().child("Chats").child((chat?.hashtagID)!).child("Info").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: String] {
                self.administrator = dict["administrator"]
            }
        })

        setChatIconInNavigationController()
        
        if let mainContext =  context {
            NotificationCenter.default.addObserver(self, selector: #selector(contextUpdated(notification:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: mainContext)
        }
        
        do {
            guard let context = context else {return}
            guard let chat = chat else {return}
            let request: NSFetchRequest<Message> = Message.fetchRequest()
            
            request.predicate = NSPredicate(format: "chat=%@", chat)
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
            
            let messages = try context.fetch(request)
            for message in messages {
                allMessages.append(message)
            }
        }
        catch {
            print("We couldn't fetch!")
        }
        
    }
    
    func cancel() {
        if !(isSubscribed!){
            context?.delete(chat!)
            do{
                try context?.save()
            }catch let error{
                print(error.localizedDescription)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func contextUpdated(notification: Notification) {
        guard let set = (notification.userInfo![NSInsertedObjectsKey] as? NSSet) else {return}
        let objects = set.allObjects
        for obj in objects {
            guard let message = obj as? Message else {continue}
            allMessages.append(message)
            
            scheduleNotification()
            collectionView.reloadData()
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default()
        let requestIdentifier = "message"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            //handle error
        })
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let timeInterval = NSDate().timeIntervalSince1970 * 100000
        let messageData = [
            "text": text,
            "senderId": senderId,
            "senderDisplayName": senderDisplayName,
            "MediaType": "TEXT",
            "timestamp": timeInterval,
            "chat": chat!.hashtagID!
            
            ] as [String : Any]
        let date = String(Int(timeInterval))
        
        messageRef!.child(date).setValue(messageData)
        chat?.lastMessage = NSDate(timeIntervalSince1970: timeInterval / 100000)
    
        let senderToken = userDefault.returnMyToken()
        
        let chatRef = AllFirebasePaths.firebase(pathName: "pathChats")
    
        chatRef?.child((chat?.hashtagID)!).child("joined").observeSingleEvent(of: .value, with: { (snapshot) in
            let retrived = snapshot.value as? NSDictionary
            let keys = retrived?.allKeys
            let allKeys = keys as! Array<String>

            for key in allKeys {
                let token = retrived?[key] as! String
                if token == senderToken && senderId != key {
                    chatRef?.child((self.chat?.hashtagID)!).child("joined").child(key).removeValue()
                }
                
                if senderToken != token {
                    let parameters: Parameters = [
                        "mess": text!,
                        "author":senderDisplayName!,
                        "destinationToken":token,
                        "chatID":(self.chat?.hashtagID)!
                    ]
                    _ = Alamofire.request("http://www.webuilding.it/esempio_form_html/push.php", method: HTTPMethod.post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                }
            }
        
            self.finishSendingMessage()
        })
    }
    /**
     *  This method is called when the user taps the accessory button on the `inputToolbar`.
     *
     *  @param sender The accessory button that was pressed by the user.
     */
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let sheet = UIAlertController(title: "Media messages", message: "Please select a media", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancel = UIAlertAction(title: "cancel", style: .cancel) { (alert: UIAlertAction) in
            
        }
        
        let photoLibrary = UIAlertAction(title: "Photo library", style: .default) { (alert: UIAlertAction) in
            self.getMediaFrom(type: kUTTypeImage)
            
        }
        let videoLibrary = UIAlertAction(title: "Video library", style: .default) { (alert: UIAlertAction) in
            self.getMediaFrom(type: kUTTypeMovie)
        }
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.present((sheet), animated: true, completion: nil)
        
    }
    
    private func getMediaFrom(type: CFString) {
        print(type)
        let mediaPicker = UIImagePickerController()
        mediaPicker.allowsEditing = true
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    //MARK: Collection View Data Sorce Metods
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMessages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let message = allMessages[indexPath.item]
        if message.media == nil {
            let jsqM = JSQMessage(senderId: message.sender!.id, senderDisplayName: message.sender!.displayName, date: message.timestamp as Date!, text: message.text)
            return jsqM
            
        } else if let picture = UIImage(data: message.media!.data! as Data){
            
            
            let photo = JSQPhotoMediaItem(image: picture)
            
            if self.senderId == message.sender?.id {
                photo?.appliesMediaViewMaskAsOutgoing = true
            } else {
                photo?.appliesMediaViewMaskAsOutgoing = false
            }
            
            let jsqM = JSQMessage(senderId: message.sender!.id, senderDisplayName: message.sender!.displayName, date: message.timestamp as Date! , media: photo)
            
            
            return jsqM
        } else {
            let fileUrl = URL(string: (message.media?.fileUrl)!)
            let video = JSQVideoMediaItem(fileURL: fileUrl, isReadyToPlay: true)
            if self.senderId == message.sender?.id {
                video?.appliesMediaViewMaskAsOutgoing = true
            } else {
                video?.appliesMediaViewMaskAsOutgoing = false
            }
            let jsqM = JSQMessage(senderId: message.sender!.id, senderDisplayName: message.sender!.displayName, date: message.timestamp as Date! , media: video)
            
            return jsqM
        }
    }
    
    // come è la bubble
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let message = allMessages[indexPath.item]
        
        if message.sender!.id == self.senderId {
            return bubbleFactory!.outgoingMessagesBubbleImage(with: UIColor(colorLiteralRed: 25/255, green: 200/255, blue: 250/255, alpha: 1))
        } else {
            return bubbleFactory!.incomingMessagesBubbleImage(with: UIColor.lightGray)
        }
        
    }
    // ritorna l'avatar utente
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = allMessages[indexPath.item]
        guard let data = message.sender?.profilePhoto else{ return nil}
        if let image = UIImage(data: data as Data){
            let userImg = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
            return userImg
        }
        else {
            return nil
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        print("didTapMessageBubbleAtIndexPath indexPath: \(indexPath.item)")
        // estraiamo il messaggio che abbiamo ricevuto
        let message = allMessages[indexPath.item]
        
        // è un media message?
        if message.media != nil {
            // ritoniamo il media e verifichiamo che sia proprio un Media Photo Item
            
            if UIImage(data: message.media!.data! as Data) != nil{
                
                let imageVC = ImageViewController()
                imageVC.imageData =  message.media!.data! as Data
                navigationController?.pushViewController(imageVC, animated: true)
                
            }else{
                
                guard let stringUrl = message.media?.fileUrl else {return}
                print("file url\(stringUrl)")
                let url = URL(string: stringUrl)
                let player = AVPlayer(url: url!)
                
                // è una classe che permette di display un AVPlayer/
                let playerViewController = AVPlayerViewController()
                // dobbiamo dirgli che AVPlayer deve essere capace di mostrare
                playerViewController.player = player
                self.present(playerViewController, animated: true, completion: nil)
            }
            
        }
    }
    
    func sendMediaToFirebase(picture: UIImage?, video:URL?) {
        // creiamo il nostro percorso, con lo uid e data univoca per differenziare risp.
        // utenti e, per ogni utente, i data inseriti
        if let picture = picture {
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
            
            // put data on firebase!
            let data = UIImageJPEGRepresentation(picture, 0.1)// la compressione
            let metadata = FIRStorageMetadata()
            // se vuoi che firebase riconosce che è un JPEGdata, in questa maniera puoi vedere la preview su firebase
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print (error?.localizedDescription ?? "errore")
                    return
                } else {
                    
                    let fileUrl = metadata?.downloadURLs![0].absoluteString
                    
                    let timeInterval = NSDate().timeIntervalSince1970 * 100000
                    let messageData = [
                        "fileUrl": fileUrl!,
                        "senderId": self.senderId,
                        "senderDisplayName": self.senderDisplayName,
                        "MediaType": "PHOTO",
                        "timestamp": timeInterval,
                        "chat": self.chat!.hashtagID!
                        ] as [String : Any]
                    let date = String(Int(timeInterval))
                    self.chat?.lastMessage = NSDate(timeIntervalSince1970: timeInterval / 100000)
                    self.messageRef!.child(date).setValue(messageData)
                }
            }
        } else if let video = video{
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
            
            // put data on firebase!
            let data = try? Data(contentsOf: video)
            let metadata = FIRStorageMetadata()
            // se vuoi che firebase riconosce che è un JPEGdata, in questa maniera puoi vedere la preview su firebase
            metadata.contentType = "video/mp4"
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print (error?.localizedDescription ?? "errore")
                    return
                } else {
                    let fileUrl = metadata?.downloadURLs![0].absoluteString
                    let timeInterval = NSDate().timeIntervalSince1970 * 100000
                    let messageData = [
                        "fileUrl": fileUrl!,
                        "senderId": self.senderId,
                        "senderDisplayName": self.senderDisplayName,
                        "MediaType": "VIDEO",
                        "timestamp": timeInterval,
                        "chat": self.chat!.hashtagID!
                        ] as [String : Any]
                    self.chat?.lastMessage = NSDate(timeIntervalSince1970: timeInterval / 100000)
                    let date = String(Int(timeInterval))
                    self.messageRef!.child(date).setValue(messageData)
                }
            }
            
        }
        
    }
    //MARK: Private implementations
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print ("did finish piking good")
        
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            //             mandiamola su firebase
            sendMediaToFirebase(picture: picture, video: nil)
            
        } else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
            
            
            // mandiamola su firebase
            sendMediaToFirebase(picture: nil, video: video as URL)
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}


