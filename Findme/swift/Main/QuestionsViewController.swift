//
//  QuestionsViewController.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 28.08.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import UIKit
import Firebase

class QuestionsViewController: UIViewController {

    var ref: DatabaseReference!
    let currentUserID = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func questionOne(_ sender: UIButton) {
        setAnswers(0,sender.tag,sender)
    }
    
    @IBAction func questionTwo(_ sender: UIButton) {
        setAnswers(1,sender.tag,sender)
    }
    
    @IBAction func questionThree(_ sender: UIButton) {
        setAnswers(2,sender.tag,sender)
    }
    
    @IBAction func completeQuestions(_ sender: Any) {
        self.ref.child("Users/\(currentUserID!)/examPassed").setValue(true)

    }
    
    func setAnswers(_ questionNumber: Int,_ answerNumber: Int,_ sender: UIButton){
        
        /*UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
         }) {(success) in
         sender.isSelected = !sender.isSelected
         UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {sender.transform = .identity
         }, completion: nil)
         }
         }*/
            ref.child("Users").child(currentUserID!).child("answers").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let answers = snapshot.value as? String
                var questions = answers!.components(separatedBy: "-")
                let tempBefore = questions[questionNumber].prefix(answerNumber-1)
                print(tempBefore)
                let tempAfter = questions[questionNumber].suffix(questions[questionNumber].count-answerNumber)
                print(tempAfter)
                var setValue = ""
                
                for index in 0...questions.count-1 {
                    if index != questionNumber {
                        setValue += questions[index]
                    }else{
                        if sender.isSelected {
                            sender.isSelected = false
                            setValue += tempBefore + "0" + tempAfter
                        } else {
                            setValue += tempBefore + "1" + tempAfter
                            sender.isSelected = true }
                    }
                    if questions.count != index+1 {
                        setValue += "-"
                    }
                }
                self.ref.child("Users/\(self.currentUserID!)/answers").setValue(setValue)
            }) { (error) in
                print(error.localizedDescription)
            }

    }

}
