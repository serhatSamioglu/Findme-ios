//
//  MatchTableViewController.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 30.08.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class MatchTableViewController: UITableViewController{

    var firebaseUsersDatas:[Dictionary<String,Any>] = []

    var ref: DatabaseReference!
    let currentUserID = Auth.auth().currentUser?.uid
    
    var limit = 0
 /*["picture":"https://firebasestorage.googleapis.com/v0/b/findme-ae3f4.appspot.com/o/Category%2FUsers%2F7pszFxz9nePOfEwcrWLJjWSFlzk2%2FCategories%2Ftest%2F1564923383248?alt=media&token=3dba4bc0-1178-4a0d-80e6-4df6b86b234b",
     "userName":"tank",
     "matchRatio":"50"],
     ["picture":"https://firebasestorage.googleapis.com/v0/b/findme-ae3f4.appspot.com/o/Category%2FUsers%2F7pszFxz9nePOfEwcrWLJjWSFlzk2%2FCategories%2Ftest%2F1564923373959?alt=media&token=fdb23e35-9cb1-4be8-bd1d-8719a2bb1816",
     "userName":"test",
     "matchRatio":"10"]*/

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        let cellNib = UINib(nibName: "MatchItemTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "matchItem")
        getDatasFromFirebase()
        tableView.tableFooterView = UIView(frame: .zero)//bos satirlardakileri cizgileri kaldiriyor
    }

    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }*/

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return limit
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchItem", for: indexPath) as! MatchItemTableViewCell
        let firebaseUser = firebaseUsersDatas[indexPath.row]
        let url = NSURL(string:firebaseUser["picture"] as! String)
        ImageService.getImage(withURL: url! as URL ){ image in
            cell.userImage.image = image
        }
        cell.userName.text = firebaseUser["userName"] as? String
        cell.matchRatio.text = firebaseUser["matchRatio"] as? String

        //let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "matchItem")
        //cell.textLabel?.text = list[indexPath.row]
        // Configure the cell...
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 83.0
    }

    /*override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if indexPath.row == recordsArray.count - 1 {
            // we are at last cell load more content
            // we need to bring more records as there are some pending records available
            var index = recordsArray.count
            limit = index + 20
            while index < limit {
                recordsArray.append(index)
                index = index + 1
            }
            self.perform(#selector(loadTable), with: nil, afterDelay: 1.0)
        }
    }*/
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == limit - 1 {
            //var index = UsersDatas.count
            if limit+18 <= firebaseUsersDatas.count{
                limit += 18
            }else{
                limit += firebaseUsersDatas.count - limit
            }
            self.perform(#selector(loadTable), with: nil, afterDelay: 1.0)
        }
    }
    
    @objc func loadTable() {
        self.tableView.reloadData()
    }
    
    func getDatasFromFirebase(){
        ref.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            for element in snapshot.children{
                let childSnap = element as! DataSnapshot
                /*if childSnap.childSnapshot(forPath: "imageUrl") != nil{
                 url =  String(childSnap.childSnapshot(forPath: "imageUrl"))
                 }*/
                if childSnap.childSnapshot(forPath: "id").value as? String != self.currentUserID &&
                    childSnap.childSnapshot(forPath: "examPassed").value as? Bool == true{
                    //let questionsOtherUsers = childSnap.childSnapshot(forPath: "examPassed").value as? String
                    //let arrayQuestionsOtherUsers = questionsOtherUsers!.components(separatedBy: "-")
                    
                    let deneme = childSnap.childSnapshot(forPath: "imageUrl").value as? String
                    let deneme2 = childSnap.childSnapshot(forPath: "userName").value as? String
                    
                    /*if deneme == ""{
                     deneme="https://firebasestorage.googleapis.com/v0/b/findme-ae3f4.appspot.com/o/Category%2FUsers%2F7pszFxz9nePOfEwcrWLJjWSFlzk2%2FCategories%2Ftest%2F1564923383248?alt=media&token=3dba4bc0-1178-4a0d-80e6-4df6b86b234b"
                     }*/
                    
                    let newElement = ["picture":deneme,
                                      "userName":deneme2,
                                      "matchRatio":"50"] as? [String: String]
                    self.firebaseUsersDatas.append(newElement!)
                }
            }

            DispatchQueue.main.async {
                if self.firebaseUsersDatas.count >= 18 {
                    self.limit = 18
                }else{
                    self.limit = self.firebaseUsersDatas.count
                }
                self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    /*override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }*/
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
