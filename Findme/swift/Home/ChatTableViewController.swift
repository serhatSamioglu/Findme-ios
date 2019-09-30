//
//  ChatTableViewController.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 17.09.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import UIKit
import Firebase

class ChatTableViewController: UITableViewController {
    var ref: DatabaseReference! = Database.database().reference()
    let currentUserID = Auth.auth().currentUser?.uid
    
    let cellId = "cellId"
    
    var limit = 0

    var lastMessages = [String]()
    var lastMessagesTimes = [Int64]()
    var contactsIDs = [String]()
    var usernames = [String]()
    var imageUrls = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ChatItemCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView(frame: .zero)
        observeMessages()//viewApper kısmına alınması lazım yenilenmesi için
    }
    
    override func viewDidAppear(_ animated: Bool) {
        clearArrays()
        observeMessages()//GECİKMENİN DÜZENLENMESİ LAZIM
    }
    
    func observeMessages(){
        ref.child("Chat").child(currentUserID!).child("contacts").observe(.childAdded, with: { (snapshotID) in//IDs
            
            self.ref.child("Users").child(snapshotID.key).observeSingleEvent(of: .value, with: { (DataSnapshot) in
                let tempUser = DataSnapshot.value as? Dictionary<String, Any>//(Ep 10) 12:22 cell içerisinde de indirelbilirsin
                
                let recentPostsQuery = (self.ref?.child("Chat").child(self.currentUserID!).child("contacts").child(snapshotID.key).child("messages").queryLimited(toLast: 1))!
                recentPostsQuery.observeSingleEvent(of: .value, with: { (snapshot) in//last message
                    //Son mesaj alındı şimdi listede doğru sıraya konulacak
                    for element in snapshot.children{
                        let tempMessage = element as! DataSnapshot
                        
                        if !self.lastMessagesTimes.isEmpty {
                            for index in 0...self.lastMessagesTimes.count {
                                if Int64(tempMessage.key)! > self.lastMessagesTimes[index] {
                                    self.lastMessages.insert((tempMessage.childSnapshot(forPath: "message").value as? String)!, at: index)
                                    self.lastMessagesTimes.insert(Int64(tempMessage.key)!, at: index)
                                    self.contactsIDs.insert(snapshotID.key, at: index)
                                    self.usernames.insert(tempUser!["userName"] as! String, at: index)
                                    self.imageUrls.insert(tempUser!["imageUrl"] as! String, at: index)
                                    break
                                }else if Int64(tempMessage.key)! <= self.lastMessagesTimes[self.lastMessagesTimes.count-1] {
                                    self.lastMessages.append((tempMessage.childSnapshot(forPath: "message").value as? String)!)
                                    self.lastMessagesTimes.append(Int64(tempMessage.key)!)
                                    self.contactsIDs.append(snapshotID.key)
                                    self.usernames.append(tempUser!["userName"] as! String)
                                    self.imageUrls.append(tempUser!["imageUrl"] as! String)
                                    break
                                }
                            }
                        }else{
                            self.lastMessages.append((tempMessage.childSnapshot(forPath: "message").value as? String)!)
                            self.lastMessagesTimes.append(Int64(tempMessage.key)!)
                            self.contactsIDs.append(snapshotID.key)
                            self.usernames.append(tempUser!["userName"] as! String)
                            self.imageUrls.append(tempUser!["imageUrl"] as! String)
                        }
                        
                    }
                    //Fotoğrafların urlsi ve kullanıcı adlarının da aldıktan sonra yapılası lazım buranın
                    //match fragmetteki gibi döngüyü chil ile yapıp, döngü bitince bir kere de alıştırıalabilir
                    //şuan her turda reload data çalışıyor zaten çalışmasıda lazım bu koda göre aradaki performans farkına bakıp birinin
                    //uygulanması gerekiyor
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)}
                
            }, withCancel: { (Error) in
                print(Error.localizedDescription)

            })
        }, withCancel: nil)//buraya da error mesajı eklenmesi lazım eksik  gibi duruyor
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lastMessagesTimes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatItemCell//as! ChatItemCell ile profile image erişim izni almış olduk
        
        let url = NSURL(string:imageUrls[indexPath.row])
        ImageService.getImage(withURL: url! as URL ){ image in
            cell.profileImageView.image = image
        }
        cell.textLabel?.text = usernames[indexPath.row]
        cell.detailTextLabel?.text = lastMessages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func clearArrays(){
        lastMessages.removeAll()
        lastMessagesTimes.removeAll()
        contactsIDs.removeAll()
        usernames.removeAll()
        imageUrls.removeAll()
    }
}

/*Query
 let recentPostsQuery = (self.ref?.child("Chat").child(self.currentUserID!).child("contacts").child(snapshot.key).child("messages").queryLimited(toFirst: 3))!
 recentPostsQuery.observeSingleEvent(of: .value, with: { (snapshot) in
 print(snapshot.value)
 
 }) { (error) in
 print(error.localizedDescription)}
 */

/* USE CELL WİTH CLASS
 
 import UIKit
 import Firebase
 
 class ChatTableViewController: UITableViewController {
 var ref: DatabaseReference! = Database.database().reference()
 let currentUserID = Auth.auth().currentUser?.uid
 let cellId = "cellId"
 override func viewDidLoad() {
 super.viewDidLoad()
 tableView.register(ChatItemCell.self, forCellReuseIdentifier: cellId)
 //observeMessages()
 }
 
 func observeMessages(){
 ref.child("Chat").child(currentUserID!).child("contacts").observe(.childAdded, with: { (snapshot) in
 if let dictionary = snapshot.value as? [String: AnyObject]{
 let message = Message()
 message.setValuesForKeys(dictionary)
 //self
 
 }
 }, withCancel: nil)
 }
 
 override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 // #warning Incomplete implementation, return the number of rows
 return 5
 }
 
 override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
 let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
 cell.textLabel?.text = "Somethink"
 cell.detailTextLabel?.text = "detail"
 return cell
 }
 
 override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
 return 72
 }
 
 
 
 }
 */
