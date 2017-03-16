//
//  UploadNewPostViewController.swift
//  mittens
//
//  Created by Cristian Turetta on 27/10/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import UIKit
import MapKit
import GeoFire
import Firebase
import FirebaseAuth
import MBProgressHUD
import FirebaseStorage
import QBImagePickerController

class UploadNewPostViewController: UIViewController, QBImagePickerControllerDelegate, UITextViewDelegate {
    
    // MARK: - Model
    let coreLocationManager = CLLocationManager()
    
    let geoFire: GeoFire = {
        let geofireReference = FIRDatabase.database().reference().child("GeoFireLocations")
        let geo = GeoFire(firebaseRef: geofireReference)
        return geo!
    }()
    
    var postCategory: String?
    var postTitle: String?
    var postText: String?
    var pickedImages: [UIImage]?
    var pickedImagesUrls = [String]()
    
    // MARK: - Outlets
    let chatPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let setChatPhotoButton: UIButton = {
        let button = UIButton()
        button.setTitle("Set Group Photo", for: .normal)
        button.setTitleColor(UIColor(red: 14/255, green: 122/255, blue: 254/255, alpha: 1), for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    let firstMessageTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .lightGray
        textView.text = "Inserisci un messaggio di benvenuto"
        textView.font = UIFont.init(name: "AppleGhotic", size: 14)
        return textView
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Overrided Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
        setupConstraints()
        setupGestureRecognizers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Public Implementatios
    func pickImg(){
        let pickerCointroller = QBImagePickerController()
        pickerCointroller.delegate = self
        pickerCointroller.allowsMultipleSelection = false
        pickerCointroller.maximumNumberOfSelection = 1
        pickerCointroller.showsNumberOfSelectedAssets = true
        
        present(pickerCointroller, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func uploadImagesAndFeed(){
        navigationItem.rightBarButtonItem?.isEnabled = false
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "Uploading..."
        if pickedImages != nil {
            for image in pickedImages! {
                guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {return}
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpg"
                
                // File path on Firebase Storage
                let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
                
                // Lets upload Images on Firebase
                FIRStorage.storage().reference().child(filePath).put(imageData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil{
                        // An error occurred...
                        print("Error during uploading images: \(error?.localizedDescription)")
                        return
                    }else{
                        // Image uploaded successfully...
                        guard let fileUrl = metadata?.downloadURLs?.first?.absoluteString else {return}
                        
                        DispatchQueue.main.async{
                            self.pickedImagesUrls.append(fileUrl)
                            if self.pickedImagesUrls.count == self.pickedImages?.count{
                                self.upload()
                            }
                        }
                    }
                })
            }
        }else{
            upload()
        }
    }
    
    
    func upload(){
        // Dismiss Keyboard:
        view.endEditing(true)
        
        // User informations
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        // Date settings
        let timeInterval = NSDate().timeIntervalSince1970 * 10000000
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let date = String(Int(timeInterval))
        
        // Setting post atribute
        let text = postText!
        let typology = postCategory!
        let reference = FIRDatabase.database().reference().child("Feeds").child(date)
        let likes = [String:String]()
        
        // Chat settings
        let chatPath = AllFirebasePaths.firebase(pathName: "pathChats")
        guard let chatID = chatPath?.childByAutoId().key else {return}
        let chatTitle = postTitle!
        
        // Get the location info and save into locationInfo array.
        let locationInfo =  [
            "city" : MyLocationInfo.myLocation.city ?? "",
            "state": MyLocationInfo.myLocation.state  ?? "",
            "thoroughfare":MyLocationInfo.myLocation.thoroughfare  ?? "",
            "latitude":MyLocationInfo.myLocation.latitude ?? 0.0 ,
            "longitude":MyLocationInfo.myLocation.longitude ?? 0.0
            ] as NSDictionary
        
        
        geoFire.setLocation(CLLocation(latitude: MyLocationInfo.myLocation.latitude ?? 0.0, longitude: MyLocationInfo.myLocation.longitude ?? 0.0), forKey: date)
        {
            (error) in
            if (error != nil) {
                print("An error occured: \(error)")
            } else {
                print("Saved location successfully!")
            }
        }
        
        // Feed settings
        var feedType = "img"
        if pickedImagesUrls.count == 0{
            feedType = "txt"
        }
        
        let feed: [String : Any] = ["chatReference": chatID, "type": typology, "feedText": text, "PublicationData": timeInterval, "authorID": userID!, "Media": feedType, "MediaItemsUrl": pickedImagesUrls, "Likes": likes, "chatName": chatTitle, "locationInfo": locationInfo]
        
        // Save feed on firebase
        reference.setValue(feed)
        
        // Save feed reference under author section
        let authorPath = FIRDatabase.database().reference().child("UsersPublicationsReference").child(userID!).child("Publications").child(date)
        authorPath.setValue(["status":"online"])
        
        // Saving chat into Core Data
        let myId = UserDefaults.standard.object(forKey: "uid") as! String
        guard let context = AllContext.mainContext else {return}
        let chat = Chat.newChat(hashtag: chatID, nameChat: chatTitle, context: context)
        
        if let myContact = Contact.isContactExisting(withId: myId, inContext: context) {
            chat?.isMyChat = true
            chat?.userID = myId
            chat?.addToContacts(myContact)
            chat?.photoChat = UIImageJPEGRepresentation(chatPhotoImageView.image!, 0.5) as NSData?
            
            context.performAndWait {
                do {
                    try context.save()
                }catch {
                    
                }
            }
        }
        
        Observers.observer.observeThisChat(chat: chat!, context: context)
        
        // Put welcome message into Firebase
        let timeIntervals = NSDate().timeIntervalSince1970 * 100000
        let senderDisplayName = UserDefaults.standard.object(forKey: "displayName") as! String
        let messageRefer = AllFirebasePaths.firebase(pathName: "pathChats")?.child(chatID).child("messages")
        let messageData = [
            "text": firstMessageTextView.text ?? "Welcome to my chat!",
            "senderId": myId,
            "senderDisplayName": senderDisplayName,
            "MediaType": "TEXT",
            "timestamp": timeIntervals,
            "chat": chatID,
            "chatName": chatTitle
            ] as [String : Any]
        let thisDate = String(Int(timeIntervals))
        
        // Save welcome message on Firebase
        messageRefer!.child(thisDate).setValue(messageData)
        chat?.lastMessage = NSDate(timeIntervalSince1970: timeIntervals / 100000)
        
        // Save Chat Group Image into Firebase Storage
        let chatPhotoGroupData = UIImageJPEGRepresentation(chatPhotoImageView.image!, 0.5)
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"
        
        let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/chatGroupPhoto/\(chatID)"
        
        // Lets upload Images on Firebase
        FIRStorage.storage().reference().child(filePath).put(chatPhotoGroupData!, metadata: metadata, completion: { (metadata, error) in
            if error != nil{
                // An error occurred...
                print("Error during uploading images: \(error?.localizedDescription)")
                return
            }else{
                // Image uploaded successfully...
                guard let fileUrl = metadata?.downloadURLs?.first?.absoluteString else {return}
                
                DispatchQueue.main.async{
                    // Save Url of photo group and administator of this chat on this chat path
                
                    FIRDatabase.database().reference().child("Chats").child((chat?.hashtagID!)!).child("Info").updateChildValues(["groupPhoto" : fileUrl, "administrator" : myId])
            
                    // Save my token on firebase to recive notifications
                    let userDefault = UserDef()
                    let myToken = userDefault.returnMyToken()
                    FIRDatabase.database().reference().child("Chats").child((chat?.hashtagID!)!).child("joined").updateChildValues([myId:myToken!])
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    // Return to Mittens Home
                    Helpers.helper.switchToNavigationController()
                }
            }
        })
    }
    
    // MARK: - Private Implementations
    private func setupView(){
        view.backgroundColor = .white
        title = "New Post"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(uploadImagesAndFeed))
        
        let viewComponents = [chatPhotoImageView, setChatPhotoButton, firstMessageTextView, dividerView]
        
        for comoponent in viewComponents {
            comoponent.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(comoponent)
        }
        
        firstMessageTextView.delegate = self
        chatPhotoImageView.image = UIImage(named: "profile-picture")
    }
    
    private func setupConstraints(){
        chatPhotoImageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 80).isActive = true
        chatPhotoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        chatPhotoImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        chatPhotoImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        setChatPhotoButton.topAnchor.constraint(equalTo: chatPhotoImageView.bottomAnchor, constant: 8).isActive = true
        setChatPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        firstMessageTextView.topAnchor.constraint(equalTo: setChatPhotoButton.bottomAnchor, constant: 10).isActive = true
        firstMessageTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        firstMessageTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        firstMessageTextView.bottomAnchor.constraint(equalTo: dividerView.topAnchor, constant: 8).isActive = true
        
        if pickedImages != nil{
            dividerView.backgroundColor = .lightGray
            dividerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
            dividerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
            dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
            calculatingPreview()
        }else{
            dividerView.backgroundColor = .clear
            dividerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
            dividerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
            dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
            dividerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }
    
    private func calculatingPreview(){
        let side = (view.frame.width / CGFloat((pickedImages?.count)!)) - (5 * CGFloat((pickedImages?.count)!))
        
        var position:CGFloat = 1
        
        for image in pickedImages! {
            let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: side, height: side))
            imgView.layer.cornerRadius = 3
            imgView.layer.masksToBounds = true
            imgView.image = image
            
            addImageView(imgageView: imgView, whitRepetitions: position)
            position += 1
        }
    }
    
    private func addImageView(imgageView imgView: UIImageView, whitRepetitions repetions: CGFloat){
        var side:CGFloat = 110
        
        if (pickedImages?.count)! > 3 {
            side = (view.frame.width / CGFloat((pickedImages?.count)!)) - (2 * CGFloat((pickedImages?.count)!))
        }
        
        let step = side + 5
        let story = (step * (repetions - 1))
        
        view.addSubview(imgView)
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        imgView.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 4).isActive = true
        imgView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: (story)).isActive = true
        imgView.widthAnchor.constraint(equalToConstant: side).isActive = true
        imgView.heightAnchor.constraint(equalToConstant: side).isActive = true
        imgView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4).isActive = true
    }
    
    private func setupGestureRecognizers(){
        setChatPhotoButton.addTarget(self, action: #selector(pickImg), for: .touchUpInside)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    private func calculateDynamicHeightForFirstMessageTextField(){ // Unused
        let textFrame = firstMessageTextView.frame
        let defaultSize = CGSize(width: textFrame.width, height: 50000)
        let surroundings = NSString(string: firstMessageTextView.text ?? "").boundingRect(
            with: defaultSize,
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)],
            context: nil)
        
        firstMessageTextView.frame = CGRect(x: firstMessageTextView.frame.origin.x, y: firstMessageTextView.frame.origin.y, width: textFrame.width, height: surroundings.height)
    }
    
    // MARK: - PickerControllerDelegate Methods
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didSelect asset: PHAsset!) {
        print("selected: \(asset)\n\n")
    }
    
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        
        
        if !assets.isEmpty {
            for asset in assets{
                guard let metadata = asset as? PHAsset else{return}
                manager.requestImage(for: metadata, targetSize: CGSize(width: Double(metadata.pixelWidth), height: Double(metadata.pixelHeight)), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                    self.chatPhotoImageView.image = result
                })
            }
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITextViewDelegate Methods
    
    /*
     func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
     calculateDynamicHeightForFirstMessageTextField()
     return true
     }
     */
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if firstMessageTextView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if firstMessageTextView.text.isEmpty {
            textView.text = "Inserisci un messaggio di benvenuto..."
            textView.textColor = UIColor.lightGray
        }
    }
}
