//
//  SignUpViewController.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 16.08.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }

    
    @IBAction func signUpTabbed(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else{return}
        guard let username = userNameTextField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil && user != nil {
                print("User created")
                let newUser = User(user!.user.uid, email, password, username)
                self.ref.child("Users/\(user!.user.uid)").setValue(newUser.toDictionary())
                
                let chanceRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                chanceRequest?.displayName = username
                chanceRequest?.commitChanges{error in
                    if error == nil {
                        print("User display name chanced")
                        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
                         let pageController = storyboard.instantiateViewController(withIdentifier: "PageViewController")as! PageViewController
                         self.navigationController?.pushViewController(pageController, animated: true)*/
                        self.performSegue(withIdentifier: "openQuestions", sender: nil)
                    }
                    //self.dismiss(animated: false, completion: nil)
                }
            }else{
                print("Error :  \(error!.localizedDescription)")
            }
        }
    }
}
