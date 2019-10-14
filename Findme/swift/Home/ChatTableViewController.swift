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
    
    var lastMessages = [String]()
    var lastMessagesTimes = [Int64]()
    var contactsIDs = [String]()
    var usernames = [String]()
    var imageUrls = [String]()
    var unreadMessages = [Bool]()//bütün bu arraylerin değişken olarak olduğu bir obje yaratıp tek bir obje arrayi kullanmak iyi olabilir
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ChatItemCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView(frame: .zero)
        observeMessages()//viewApper kısmına alınması lazım yenilenmesi için
        onContactdatChance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        clearArrays()
        observeMessages()//GECİKMENİN DÜZENLENMESİ LAZIM
    }
    
    func onContactdatChance(){
        ref.child("Chat").child(currentUserID!).child("contacts").observe(.childChanged) { (DataSnapshot) in//child added ile yapılırsa daha performanslı olur(ios ve android)
            self.clearArrays()
            self.observeMessages()
        }
    }
    
    func observeMessages(){
        ref.child("Chat").child(currentUserID!).child("contacts").observeSingleEvent(of: .value, with: { (snapshotIDs) in//IDs
            for element in snapshotIDs.children{
                let snapshotID = element as! DataSnapshot
                self.ref.child("Users").child(snapshotID.key).observeSingleEvent(of: .value, with: { (snapshotUserDatas) in
                    let tempUser = snapshotUserDatas.value as? Dictionary<String, Any>//(Ep 10) 12:22 cell içerisinde de indirelbilirsin
                    self.ref.child("Chat").child(self.currentUserID!).child("contacts").child(snapshotID.key).child("unreadMessages/exist").observeSingleEvent(of: .value, with: { (snapshotUnreadedMessages) in
                        var tempUnreadMessage = false
                        if snapshotUnreadedMessages.value as? Bool == true {
                            tempUnreadMessage = true
                        }
                        let recentPostsQuery = (self.ref?.child("Chat").child(self.currentUserID!).child("contacts").child(snapshotID.key).child("messages").queryLimited(toLast: 1))!
                        recentPostsQuery.observeSingleEvent(of: .value, with: { (snapshotLastMessage) in//last message
                            //Son mesaj alındı şimdi listede doğru sıraya konulacak
                            for element in snapshotLastMessage.children{
                                let tempMessage = element as! DataSnapshot
                                //sortInPlace gibi kodlarla otomatik sıralayıp sıralndığı indexi kullanabilirsin
                                if !self.lastMessagesTimes.isEmpty {
                                    for index in 0...self.lastMessagesTimes.count {
                                        if Int64(tempMessage.key)! > self.lastMessagesTimes[index] {
                                            self.lastMessages.insert((tempMessage.childSnapshot(forPath: "message").value as? String)!, at: index)
                                            self.lastMessagesTimes.insert(Int64(tempMessage.key)!, at: index)
                                            self.contactsIDs.insert(snapshotID.key, at: index)
                                            self.usernames.insert(tempUser!["userName"] as! String, at: index)
                                            self.imageUrls.insert(tempUser!["imageUrl"] as! String, at: index)
                                            self.unreadMessages.insert(tempUnreadMessage, at: index)
                                            break
                                        }else if Int64(tempMessage.key)! <= self.lastMessagesTimes[self.lastMessagesTimes.count-1] {
                                            self.lastMessages.append((tempMessage.childSnapshot(forPath: "message").value as? String)!)
                                            self.lastMessagesTimes.append(Int64(tempMessage.key)!)
                                            self.contactsIDs.append(snapshotID.key)
                                            self.usernames.append(tempUser!["userName"] as! String)
                                            self.imageUrls.append(tempUser!["imageUrl"] as! String)
                                            self.unreadMessages.append(tempUnreadMessage)
                                            break
                                        }
                                    }
                                }else{
                                    self.lastMessages.append((tempMessage.childSnapshot(forPath: "message").value as? String)!)
                                    self.lastMessagesTimes.append(Int64(tempMessage.key)!)
                                    self.contactsIDs.append(snapshotID.key)
                                    self.usernames.append(tempUser!["userName"] as! String)
                                    self.imageUrls.append(tempUser!["imageUrl"] as! String)
                                    self.unreadMessages.append(tempUnreadMessage)
                                }
                            }
                            //ep 14 23:50 timer ile gecikmeli yüklemeyi anlatıyor
                            if snapshotIDs.childrenCount == self.lastMessagesTimes.count{
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                            //Fotoğrafların urlsi ve kullanıcı adlarının da aldıktan sonra yapılası lazım buranın
                            //match fragmetteki gibi döngüyü chil ile yapıp, döngü bitince bir kere de alıştırıalabilir
                            //şuan her turda reload data çalışıyor zaten çalışmasıda lazım bu koda göre aradaki performans farkına bakıp birinin
                            //uygulanması gerekiyor
                            
                        }) { (error) in
                            print(error.localizedDescription)}
                    }, withCancel: { (Error) in
                        print(Error.localizedDescription)
                    })
                    
                }, withCancel: { (Error) in
                    print(Error.localizedDescription)
                })
            }
        }, withCancel: { (Error) in
            print(Error.localizedDescription)
        })
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
       
        if unreadMessages[indexPath.row] == true {
            cell.unreadMessages.image = #imageLiteral(resourceName: "Red-filled-circle")
        }else{
            cell.unreadMessages.image = nil//buraya farklı bir atama yapılabilinir
        }

        let timestampDate = NSDate(timeIntervalSince1970: TimeInterval(lastMessagesTimes[indexPath.row]))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        cell.timeLabel.text = dateFormatter.string(from: timestampDate as Date)
        
        cell.textLabel?.text = usernames[indexPath.row]
        cell.detailTextLabel?.text = lastMessages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        ref.child("Users").child(contactsIDs[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
            let tabbar = self.tabBarController as! HomeTabBarController
            tabbar.tempUsersDatas = snapshot.value as? Dictionary<String, Any>
            chatLogController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chatLogController, animated: true)
            //self.present(chatLogController, animated: true, completion: nil)
        }) { (error) in
            print(error.localizedDescription)
        }*/
    }
    
    func clearArrays(){
        lastMessages.removeAll()
        lastMessagesTimes.removeAll()
        contactsIDs.removeAll()
        usernames.removeAll()
        imageUrls.removeAll()
        unreadMessages.removeAll()
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
