//
//  ProfileViewController.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 5.09.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var messageButton: UIButton!
    
    var tempUser : Dictionary<String,Any>?
    var currentUser : Dictionary<String,Any>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUsers()
        setupProfile()
        
        /*let left = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: #selector(myRightSideBarButtonItemTapped(_:)))
        self.navigationItem.leftBarButtonItem = left*/
    }
    /*@objc func myRightSideBarButtonItemTapped(_ sender:UIBarButtonItem!)
    {
        print("myRightSideBarButtonItemTapped")
    }*/
    
    override func viewDidAppear(_ animated: Bool) {
        /*let tabbar = self.tabBarController as! HomeTabBarController
        if tabbar.backChatLogController != false{
           
        }else{
            tabbar.backChatLogController = false
        }*/
    }
    
    @IBAction func messageButtonTabbed(_ sender: Any) {
        if tempUser != nil{
            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            let tabbar = self.tabBarController as! HomeTabBarController
            tabbar.tempUsersDatas = tempUser
            chatLogController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chatLogController, animated: true)
            
        }
    }
    
    private func setupProfile(){
        if tempUser != nil {//baskasinin  profiline bakarken burasi calisiyor
            setupMiddleNavItem((tempUser!["userName"] as? String)!)
            setupRightNavItem(#imageLiteral(resourceName: "ThreeDot"))
            setupProfileImage((tempUser!["imageUrl"] as? String)!)
            messageButton.setImage(#imageLiteral(resourceName: "message"), for: .normal)
        }else {//kendi profilini acinca da burasi calisiyor
            setupMiddleNavItem((currentUser!["userName"] as? String)!)
            setupRightNavItem(#imageLiteral(resourceName: "Settings"))
            setupProfileImage((currentUser!["imageUrl"] as? String)!)
            messageButton.setImage(#imageLiteral(resourceName: "plus"), for: .normal)
        }
        
    }
    
    private func setupMiddleNavItem(_ userName : String){
        let frame = CGRect(x: 0 ,y: 0,width: 34,height: 34)
        let titleTextView = UILabel(frame: frame)
        titleTextView.text = userName
        navigationItem.titleView = titleTextView
    }
    
    private func setupRightNavItem(_ rightImage : UIImage){
        let rightImageButton = UIButton(type: .system)
        rightImageButton.setImage(rightImage.withRenderingMode(.alwaysOriginal), for: .normal)
        rightImageButton.frame = CGRect(x: 0 ,y: 0,width: 34,height: 34)
        //titleImageView.contentMode = .scaleAspectFit
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightImageButton)
    }
    
    private func setupProfileImage(_ stringUrl : String){
        let url = NSURL(string:stringUrl)
         ImageService.getImage(withURL: url! as URL ){ image in
         self.profilePhoto.image = image
         }
    }
    
    private func setUsers(){
        let tabbar = self.tabBarController as! HomeTabBarController
        if tabbar.tempUsersDatas != nil {
            tempUser = tabbar.tempUsersDatas
            tabbar.tempUsersDatas = nil
        }else{
            tempUser = nil
        }
        currentUser = tabbar.currentUserDatas
    }
    
}
