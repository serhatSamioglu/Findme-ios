//
//  BaseTabBarController.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 4.09.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import UIKit
import Firebase

class HomeTabBarController: UITabBarController {
    
    var ref: DatabaseReference!
    var tempUsersDatas:Dictionary<String,Any>? = nil
    var currentUserDatas:Dictionary<String,Any>? = nil
    var backChatLogController : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        getCurrentUserDatas()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func getCurrentUserDatas(){
        let currentUserID = Auth.auth().currentUser?.uid
        ref.child("Users").child(currentUserID!).observeSingleEvent(of: .value, with: { (snapshot) in
            self.currentUserDatas = snapshot.value as? Dictionary<String, Any>
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
       // print("count\(self.sele)")
        //print("item\(item)")

    }
}
