//
//  ChatLogController.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 7.09.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate{
    
    var ref: DatabaseReference! = Database.database().reference()
    var chatUser : Dictionary<String,Any>?

    let currentUserID = Auth.auth().currentUser?.uid


    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        setupChatUser()
        setupChatUserDatas()
        setupInputComponents()
        //observeMessages()
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
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
    }
    
    deinit {
        //Stop listening for keyboard hide/show events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func setupInputComponents(){
        let containerView = UIView()
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
    }
    
    @objc func handleSend(){
        if inputTextField.text != "" {
            sendMessage(inputTextField.text!)
        }else{
            ToastView.shared.message(self.view, txt_msg: "You can't send empty message")
        }
        inputTextField.text = ""
        /*ref.child("Users").child(currentUserID!).child("examPassed").observeSingleEvent(of: .value, with: { (snapshot) in
         
         
         }) { (error) in
         print(error.localizedDescription)}*/
    }
    
    func sendMessage(_ message : String){
         ref.child("Users").child(chatUser!["id"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
            self.chatUser = snapshot.value as? Dictionary<String, Any>
            self.ref.child("ServerTime/time").setValue(ServerValue.timestamp())
            
            self.ref.child("ServerTime/time").observeSingleEvent(of: .value, with: { (snapshot) in

                //let ınttime = snapshot.value! as! Int64
                let stringTime = "\(snapshot.value! as! Int64)"
                
                let t = snapshot.value as? TimeInterval
                let converted = NSDate(timeIntervalSince1970: t!/1000)
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = NSTimeZone.local
                dateFormatter.dateFormat = "yy MMM dd HH:mm:ss:SSS Z"//SSS ve Z gerekli mi kontrol edilmesi lazım
                let time = dateFormatter.string(from: converted as Date)
                
                //--------------------------
                //Zaman bilgisi alında  şimdi mesaj database de olması gereken yere yollanacak
                //--------------------------
                
                let tempMessage = Message()
                tempMessage.tempCons(message, self.currentUserID!, time, "text")
                
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
    
    func observeMessages(){
        ref.child("Chat").child(currentUserID!).child("contacts").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childSnapshot(forPath: self.chatUser!["id"] as! String).exists(){
                self.ref.child("Chat").child(self.currentUserID!).child("contacts").child(self.chatUser!["id"] as! String).child("unreadMessages/exist").setValue(false)
                //---
                self.ref.child("Chat").child(self.currentUserID!).child("contacts").child(self.chatUser!["id"] as! String).child("messages").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    //Codes
                }) { (error) in
                    print(error.localizedDescription)}
            }
        
        }) { (error) in
            print(error.localizedDescription)}
    }
    
    /*func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }*/

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return(true)
    }
}
