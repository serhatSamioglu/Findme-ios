//
//  LoginViewController.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 16.08.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController , UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{

    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        if Auth.auth().currentUser != nil {
            getCurrentUserDatas()
        }
        
        getLanguage()
        createPickerView()
        dissmissPickerView()
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password){user , error in
            if error == nil && user != nil{
                ToastView.shared.message(self.view, txt_msg: "login")
                self.getCurrentUserDatas()
                //self.performSegue(withIdentifier: "toHomeScreen", sender: self)
                //self.dismiss(animated: false, completion: nil)
                //dissmise bak, daha iy bir intent yapısı kullan, atılın kodları incele
            }else{
                print("Error : \(error!.localizedDescription)")
                ToastView.shared.message(self.view, txt_msg: error!.localizedDescription)
            }
        }
    }
    
    
    var priortyTypes = ["Turkish","English"]
    let preferences = UserDefaults.standard

    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return priortyTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return priortyTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = priortyTypes[row]
        preferences.set(priortyTypes[row], forKey: "currentLanguage")
    }
    
    func createPickerView(){
        let pickerView = UIPickerView()
        pickerView.delegate = self
        textField.inputView=pickerView
    }
    
    func dissmissPickerView(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dissmissKeyboard))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolBar
        emailTextField.inputAccessoryView = toolBar
        passwordTextField.inputAccessoryView = toolBar
    }
    
    @objc func dissmissKeyboard(){
        view.endEditing(true)
    }
    
    func getLanguage(){
        if preferences.object(forKey: "currentLanguage") == nil {
            textField.text = "Turkish"
        } else {
            textField.text = preferences.string(forKey: "currentLanguage")!
        }
    }
    
    func getCurrentUserDatas(){
        
        let currentUserID = Auth.auth().currentUser?.uid
        ref.child("Users").child(currentUserID!).child("examPassed").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value,
            /*let value = snapshot.value as? NSDictionary
             var passtehexam = value?["passtheexam"] as? Bool ?? false*/
            let passTheexam = snapshot.value as? Bool
            if(passTheexam!){
                self.performSegue(withIdentifier: "toHomeScreen", sender: self)
            }else{
                self.performSegue(withIdentifier: "openQuestions", sender: self)}
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
}
