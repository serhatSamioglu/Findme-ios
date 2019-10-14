//
//  ChatLogController.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 7.09.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var ref: DatabaseReference! = Database.database().reference()
    var chatUser : Dictionary<String,Any>?

    let currentUserID = Auth.auth().currentUser?.uid//bütün bu tarz değişkenlere guard ekle
    /*guard let uid = Auth.auth().currentUser?.uid else {
    return
    }*/

    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var messages = [Message]()
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInset = UIEdgeInsets.init(top: 8, left: 0, bottom: 8, right: 0)
        //collectionView.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive//klavyeyi sürükleyerek aşşağıya indirmeyi sağlıyor
        
        setupChatUser()
        setupChatUserDatas()
        observeMessages()
        setupKeyboardObservers()
        self.inputTextField.delegate = self
        
        
        //listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification : Notification){
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification {
            //view.frame.origin.y = -keyboardRect.height
        } else {
            NotificationCenter.default.removeObserver(self)//eski observeleri kaldırarak uygulamaı hızlandırıyor
            //view.frame.origin.y = 0
            //EP 15
        }
    }
    
    deinit {
        //Stop listening for keyboard hide/show events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    lazy var inputContainerView: UIView = {//lazy var araştır
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = #imageLiteral(resourceName: "plus")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitleColor(.purple, for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        //x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true//bunlar neden self değil araştır
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        //UIColor(red: 220, green: 220, blue: 220, alpha: 100)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        return containerView
    }()
    
    @objc func handleUploadTap(){
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("ChatPhotos").child(currentUserID!).child("\(imageName).jpg")
        
        if let uploadData = image.jpegData(compressionQuality: 0.1){
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil{
                    print("Failed to upload image:", error as Any)
                    return
                }
                ref.downloadURL(completion: { (url, err) in
                    if err != nil{
                        print(err as Any)
                        return
                    }
                    else{
                        self.sendMessage(url!.absoluteString, "photo")
                        print(url!.absoluteString)
                    }
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override var inputAccessoryView: UIView? {
        get{
           return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        if messages[indexPath.item].type == "text" {
            cell.textView.text = messages[indexPath.item].message
        }else {
            cell.textView.text = ""
        }
        //cell.textView.text = messages[indexPath.item].message
        
        setupCell(cell: cell, message: messages[indexPath.item])
        
        if messages[indexPath.item].type == "text" {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: messages[indexPath.item].message!).width + 32
        } else if messages[indexPath.item].type == "photo" {
            cell.bubbleWidthAnchor?.constant = 200
        }
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message){
        
        if message.type == "text" {//27:47
            cell.messageImageView.image = nil
        } else if message.type == "photo" {//sonra bir debug yapılabilir arada yazıların arkasına fotoğraf geliyor
            let url = NSURL(string:message.message!)
            ImageService.getImage(withURL: url! as URL ){ image in
                cell.messageImageView.image = image}
        }
        
        if message.sender == currentUserID {
            cell.bubbleView.backgroundColor = ChatMessageCell.purpleColor
            cell.textView.textColor = UIColor.white
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }else {
            cell.bubbleView.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
            cell.textView.textColor = UIColor.black
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        //get estimated height somehow??
        if "text" == messages[indexPath.item].type{
            height = estimateFrameForText(text: messages[indexPath.item].message!).height + 20
        } else if messages[indexPath.item].type == "photo" {
            height = 200//ep 18 14:57
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    /*func test(){
        self.ref.child("Chat").child(self.currentUserID!).child("contacts").child(self.chatUser!["id"] as! String).child("messages").observe(.childAdded, with: { (snapshotMessages)in
                self.messages.removeAll()
                self.observeMessages()
        }) { (error) in
            print(error.localizedDescription)}
    }*/
    
    func observeMessages(){
        ref.child("Chat").child(currentUserID!).child("contacts").observeSingleEvent(of: .value, with: { (snapshotContacts) in
            if snapshotContacts.childSnapshot(forPath: self.chatUser!["id"] as! String).exists(){
            self.ref.child("Chat").child(self.currentUserID!).child("contacts").child(self.chatUser!["id"] as! String).child("unreadMessages/exist").setValue(false)
                //---
            self.ref.child("Chat").child(self.currentUserID!).child("contacts").child(self.chatUser!["id"] as! String).child("messages").observe(.childAdded, with: { (snapshotMessage) in
                    
                    //let snapshotMessage = snapshotMessages.value
                guard let dictionary = snapshotMessage.value as? [String:AnyObject] else {
                        return
                    }
                    
                let message = Message()//ep18 6:42 gibi message class içerisine dictionry i yollayabilirsin
                    //potential of crasshing if keys dont't match
                    //message.setValuesForKeys(dictionary)
                    message.message = dictionary["message"] as? String
                    message.sender = dictionary["sender"] as? String
                    message.date = dictionary["date"] as? String
                    message.type = dictionary["type"] as? String
                    
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        //scroll to the last index
                        let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                    }
                    
                }, withCancel: nil)
                
            }
        }) { (error) in
            print(error.localizedDescription)}
    }
    
    /*func setupInputComponents(){
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        //x,y,w,h
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitleColor(.purple, for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        //x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        //UIColor(red: 220, green: 220, blue: 220, alpha: 100)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }*/
    
    @objc func handleSend(){
        if inputTextField.text != "" {
            sendMessage(inputTextField.text!,"text")
        }else{
            ToastView.shared.message(self.view, txt_msg: "You can't send empty message")
        }
        inputTextField.text = ""
        /*ref.child("Users").child(currentUserID!).child("examPassed").observeSingleEvent(of: .value, with: { (snapshot) in
         
         
         }) { (error) in
         print(error.localizedDescription)}*/
    }
    
    func sendMessage(_ message : String, _ type : String){
         ref.child("Users").child(chatUser!["id"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
            self.chatUser = snapshot.value as? Dictionary<String, Any>
            self.ref.child("ServerTime/time").setValue(ServerValue.timestamp())
            
            self.ref.child("ServerTime/time").observeSingleEvent(of: .value, with: { (snapshot) in

                //let ınttime = snapshot.value! as! Int64
                let stringTime = "\(snapshot.value! as! Int64)"
                
                let t = snapshot.value as? TimeInterval
                let converted = NSDate(timeIntervalSince1970: t!/1000)
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = NSTimeZone.local//bunun ne işe yaradığına bak, lazım değilse kaldır
                dateFormatter.dateFormat = "yy MMM dd HH:mm:ss:SSS Z"//SSS ve Z gerekli mi kontrol edilmesi lazım
                let time = dateFormatter.string(from: converted as Date)
                
                //--------------------------
                //Zaman bilgisi alında  şimdi mesaj database de olması gereken yere yollanacak
                //--------------------------
                
                let tempMessage = Message()
                tempMessage.tempCons(message, self.currentUserID!, time, type)
                
                self.ref.child("Chat").child(self.currentUserID!).child("contacts").child(self.chatUser!["id"] as! String).child("messages").child(stringTime).setValue(tempMessage.toDictionary())//gönderen kisi icin database e yazma kısmı
                //MARK Gönderen kisinin unreadMessage değişkeni yatılmıyor bu chat fragmentte sorun yaratmıyor mu bakılması gerek

                
                if !(self.chatUser!["messagesPrivacy"] as? Bool)! {
                    self.ref.child("Chat").child(self.chatUser!["id"] as! String).child("contacts").child(self.currentUserID!).child("messages").child(stringTime).setValue(tempMessage.toDictionary())
                    self.ref.child("Chat").child(self.chatUser!["id"] as! String).child("contacts").child(self.currentUserID!).child("unreadMessages/exist").setValue(true)
                    /*BU JAVA KODU NOTİFİCATİON OLUNCA SWFİTE CEVİRİLECEK
                    if(!String.valueOf(chatuser.getIdOfChatUser()).equalsIgnoreCase(HomeActivity.mAuth.getCurrentUser().getUid())){
                     sendMessageNotification(tempMessage,chatuser);
                     }*/

                }else{
                    //CHECK CONTACT
                    self.ref.child("Chat").child(self.chatUser!["id"] as! String).child("contacts").observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.childSnapshot(forPath: self.currentUserID!).exists(){
                            self.ref.child("Chat").child(self.chatUser!["id"] as! String).child("contacts").child(self.currentUserID!).child("messages").child(stringTime).setValue(tempMessage.toDictionary())
                            self.ref.child("Chat").child(self.chatUser!["id"] as! String).child("contacts").child(self.currentUserID!).child("unreadMessages/exist").setValue(true)
                            /*if snapshot.childSnapshot(forPath: self.currentUserID!).exists(){
                             BİLDİRİM KODU GELECEK
                             }*/
                        }
                     }) { (error) in
                     print(error.localizedDescription)}
                    
                    //CHECK REQUEST
                    self.ref.child("Chat").child(self.chatUser!["id"] as! String).child("requests").observeSingleEvent(of: .value, with: { (snapshot) in
                        self.ref.child("Chat").child(self.chatUser!["id"] as! String).child("requests").child(self.currentUserID!).child("messages").child(stringTime).setValue(tempMessage.toDictionary())
                        self.ref.child("Chat").child(self.chatUser!["id"] as! String).child("requests").child(self.currentUserID!).child("unreadMessages/exist").setValue(true)
                        
                        /*if snapshot.childSnapshot(forPath: self.currentUserID!).exists(){
                           BİLDİRİM KODU GELECEK
                        }*/
                    }) { (error) in
                        print(error.localizedDescription)}
                }
                
                
            }) { (error) in//ServerTime
                print(error.localizedDescription)}

         }) { (error) in//uptade chatUser
         print(error.localizedDescription)
        }
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShowNotification), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func keyboardDidShowNotification(){
        if messages.count > 0 {
            let indexPath = NSIndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    func setupChatUser(){
        let tabbar = self.tabBarController as! HomeTabBarController
        chatUser = tabbar.tempUsersDatas
        tabbar.tempUsersDatas = nil
    }
    
    func setupChatUserDatas(){
        let frame = CGRect(x: 0 ,y: 0,width: 34,height: 34)
        let titleTextView = UILabel(frame: frame)
        titleTextView.text = chatUser!["userName"] as? String
        navigationItem.titleView = titleTextView
    }
    
    /*func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }*/

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return(true)
    }
    
    /* readMessage
     self.ref.child("Chat").child(self.currentUserID!).child("contacts").child(self.chatUser!["id"] as! String).child("messages").observeSingleEvent(of: .value, with: { (snapshotMessages) in
     
     for element in snapshotMessages.children{
     let snapshotMessage = element as! DataSnapshot
     guard let dictionary = snapshotMessage.value as? [String:AnyObject] else {
     return
     }
     
     let message = Message()
     //potential of crasshing if keys dont't match
     //message.setValuesForKeys(dictionary)
     message.message = dictionary["message"] as? String
     message.sender = dictionary["sender"] as? String
     message.date = dictionary["date"] as? String
     message.type = dictionary["type"] as? String
     
     self.messages.append(message)
     }
     if snapshotMessages.childrenCount == self.messages.count{
     /*DispatchQueue.main.async {
     self.collectionView?.reloadData()
     }*/
     self.collectionView?.reloadData()
     }
     }) { (error) in
     print(error.localizedDescription)}*/
}
