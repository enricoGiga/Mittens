//
//  PostCerationViewController.swift
//  mittens
//
//  Created by Cristian Turetta on 26/10/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import UIKit
import CoreData
import QBImagePickerController

class PostCerationViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, QBImagePickerControllerDelegate {
    
    // MARK: - Model
    let context = AllContext.mainContext
    var selectedCategory: String?
    var selectedImage = [UIImage]()
    var bottomConstraint: NSLayoutConstraint?
    
    // MARK: - Outlets
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let insertionisName: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 14)
        return label
    }()
    
    let postDetails: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 9)
        label.textColor = .lightGray
        return label
    }()
    
    let postTitle: UITextField = {
        let label = UITextField()
        label.font = .boldSystemFont(ofSize: 20)
        label.placeholder = "Type a title..."
        return label
    }()
    
    private let characterNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    let postText: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.init(name: "AppleGhotic", size: 18)
        textView.textColor = .lightGray
        textView.isEditable = true
        textView.text = "Type somethigs"
        return textView
    }()
    
    let mediaBarView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    let mediaBarDescription: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 16)
        label.textColor = UIColor(red: 119/255, green: 221/255, blue: 48/255, alpha: 1)
        label.text = "Pick photos for your post"
        return label
    }()
    
    let mediaBarPickPhotoIcon: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "camera")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(red: 119/255, green: 221/255, blue: 48/255, alpha: 1)
        return imageView
    }()
    
    let mediaBarPickedPhotoIndicator: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 119/255, green: 221/255, blue: 48/255, alpha: 1)
        return label
    }()
    
    // MARK: - Overrided Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        postText.delegate = self
        setupView()
        setKeyboardObservers()
        self.updateCharacterLabel(forCharCount: 0)
        
        postTitle.delegate = self
        
        // Navigation Button
        title = "New Post"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextStep))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Implementations
    private func setupView(){
        view.backgroundColor = .white
        
        let viewComponents = [profileImageView, insertionisName, postDetails, postTitle, characterNumberLabel, postText, mediaBarView]
        let subviewComponets = [mediaBarDescription, mediaBarPickPhotoIcon]
        
        for componet in viewComponents {
            componet.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(componet)
        }
        
        for subviewComponent in subviewComponets {
            subviewComponent.translatesAutoresizingMaskIntoConstraints = false
            mediaBarView.addSubview(subviewComponent)
        }
        
        setupConstraints()
        setupGestureRecognizers()
        
        // Setting values
        let myUserIdentifier = UserDefaults.standard.object(forKey: "uid") as? String
        let myContact = Contact.isContactExisting(withId: myUserIdentifier!, inContext: context!)
        let data = myContact?.profilePhoto as! Data
        let displayName = myContact?.displayName
        
        profileImageView.image = UIImage(data: data)
        insertionisName.text = displayName
        postDetails.text = "New post for \(selectedCategory!)"
    }
    
    private func setupConstraints(){
        profileImageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 80).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        insertionisName.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 95).isActive = true
        insertionisName.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        
        postDetails.topAnchor.constraint(equalTo: insertionisName.bottomAnchor, constant: 4).isActive = true
        postDetails.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        
        postTitle.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        postTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 13).isActive = true
        postTitle.rightAnchor.constraint(equalTo: characterNumberLabel.leftAnchor, constant: 0).isActive = true
        
        characterNumberLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        characterNumberLabel.leftAnchor.constraint(equalTo: postTitle.rightAnchor, constant: 0).isActive = true
        characterNumberLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        postText.topAnchor.constraint(equalTo: postTitle.bottomAnchor, constant: 4).isActive = true
        postText.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        postText.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        postText.bottomAnchor.constraint(equalTo: mediaBarView.topAnchor, constant: 10).isActive = true
        
        mediaBarView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -1.1).isActive = true
        mediaBarView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 1.1).isActive = true
        mediaBarView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        bottomConstraint = NSLayoutConstraint(
            item: mediaBarView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        view.addConstraint(bottomConstraint!)
        
        mediaBarPickPhotoIcon.leftAnchor.constraint(equalTo: mediaBarView.leftAnchor, constant: 10).isActive = true
        mediaBarPickPhotoIcon.centerYAnchor.constraint(equalTo: mediaBarView.centerYAnchor).isActive = true
        mediaBarPickPhotoIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        mediaBarPickPhotoIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        mediaBarDescription.leftAnchor.constraint(equalTo: mediaBarPickPhotoIcon.rightAnchor, constant: 10).isActive = true
        mediaBarDescription.centerYAnchor.constraint(equalTo: mediaBarView.centerYAnchor).isActive = true
    }
    
    private func setKeyboardObservers(){
        // Keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func keyboardAnimation(){
        // Animation
        UIView.animate(
            withDuration: 0,
            delay: 0,
            options: .curveEaseOut,
            animations: {self.view.layoutIfNeeded()},
            completion: {(completed) in}
        )
    }
    
    private func setupGestureRecognizers(){
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        mediaBarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickImg)))
    }
    
    private func alertForError(error: String) {
        let alertController = UIAlertController(title: "Oooops", message: error, preferredStyle: .alert)
        let understood = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(understood)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Public Implementations
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func nextStep(){
        guard let _ = postTitle.text, postTitle.text!.characters.count > 3, postText.text.characters.count > 15 else{
            if (postText.text.characters.count <= 15 || postText.text == nil) && postTitle.text!.characters.count <= 3 {
                self.alertForError(error: "Please enter a title with almost 4 characters and a description with almost 15 characters.")
                return
            }
            
            if postTitle.text!.characters.count <= 3{
                self.alertForError(error: "Please enter a title with almost 4 characters.")
                return
            }
            
            if postText.text.characters.count <= 15{
                self.alertForError(error: "Please enter a description with almost 15 characters.")
                return
            }
            
            return
        }
        
        let uploadVC = UploadNewPostViewController()
        if selectedImage.count > 0 {
            uploadVC.pickedImages = selectedImage
        }
        uploadVC.postTitle = postTitle.text
        uploadVC.postCategory = selectedCategory
        uploadVC.postText = postText.text
        navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    func updateCharacterLabel(forCharCount length: Int) {
        characterNumberLabel.text = String(25 - length)
    }
    
    func updateNextButton(forCharCount length: Int){
        if length == 0 {
            //uploadButton.tintColor = UIColor.lightGray
            //uploadButton.isEnabled = false
        } else {
            //uploadButton.tintColor = view.tintColor
            //uploadButton.isEnabled = true
        }
    }
    
    func pickImg(){
        let pickerCointroller = QBImagePickerController()
        pickerCointroller.delegate = self
        pickerCointroller.allowsMultipleSelection = true
        pickerCointroller.maximumNumberOfSelection = 5
        pickerCointroller.showsNumberOfSelectedAssets = true
        
        present(pickerCointroller, animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConstraint?.constant = -keyboardSize.height
            keyboardAnimation()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConstraint?.constant = 0
            keyboardAnimation()
        }
    }
    
    // MARK: - UITextViewDelegate Methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        if postText.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type somethigs"
            textView.textColor = UIColor.lightGray
        }
    }
    
    // MARK: - TextFieldDelegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        if newLength <= 25 {
            updateCharacterLabel(forCharCount: newLength)
            updateNextButton(forCharCount: newLength)
            return true
        }
        return false
    }

    
    // MARK: - PickerControllerDelegate Methods
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didSelect asset: PHAsset!) {
        print("selected: \(asset)\n\n")
    }
    
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        
        if !selectedImage.isEmpty{
            selectedImage.removeAll()
        }
        
        if !assets.isEmpty {
            for asset in assets{
                guard let metadata = asset as? PHAsset else{return}
                manager.requestImage(for: metadata, targetSize: CGSize(width: Double(metadata.pixelWidth), height: Double(metadata.pixelHeight)), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                    // Append for showing preview...
                    self.selectedImage.append(result!)
                })
            }
            mediaBarView.addSubview(mediaBarPickedPhotoIndicator)
            mediaBarPickedPhotoIndicator.translatesAutoresizingMaskIntoConstraints = false
            mediaBarPickedPhotoIndicator.rightAnchor.constraint(equalTo: mediaBarView.rightAnchor, constant: -10).isActive = true
            mediaBarPickedPhotoIndicator.centerYAnchor.constraint(equalTo: mediaBarView.centerYAnchor).isActive = true
            mediaBarPickedPhotoIndicator.widthAnchor.constraint(equalToConstant: 30).isActive = true
            mediaBarPickedPhotoIndicator.heightAnchor.constraint(equalToConstant: 30).isActive = true
            
            mediaBarPickedPhotoIndicator.text = "\(selectedImage.count)"
        }else{
            mediaBarPickedPhotoIndicator.removeFromSuperview()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        dismiss(animated: true, completion: nil)
    }
}
