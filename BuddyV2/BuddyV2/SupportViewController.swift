//
//  SupportViewController.swift
//  BuddyV2
//
//  Created by Alexa Rockwell on 6/9/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import UIKit
import Firebase
import NaturalLanguageUnderstandingV1
import AssistantV1

class SupportViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var userInput: UITextView!
    @IBOutlet weak var buddyOutput: UITextView!
    var userId = String("")
    var userKey = String("")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        if let user = user {
            self.userId = user.uid
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //keyboard shows
    func textViewDidBeginEditing(_ textView: UITextView) {
        print ("moveUp")
        moveTextView(textView: textView, moveDistance: -150, up: true)
    }
    
    //keyboard disappears
    func textViewDidEndEditing(_ textView: UITextView) {
        print ("moveDone")
        moveTextView(textView: textView, moveDistance: -150, up: false)
    }
    
    //keyboard disappears
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            
            let ref = Constants.refs.databaseMessages.childByAutoId()
            let message = ["uid": self.userId, "text": userInput.text!]
            ref.setValue(message)
            
            //checking sentiment
            let username = "5a046e48-f187-4177-805c-cfa721b322e0"
            let password = "VfIEIb6hIrTF"
            let version = "2018-06-10" // use today's date for the most recent version
            
            let naturalLanguageUnderstanding = NaturalLanguageUnderstanding(username: username, password: password, version: version)
            
            //let textToAnalyze = "I am feeling great today, nothing can stand in my way. I just got a promotion at work!"
            let textToAnalyze = userInput.text!
            let features = Features(emotion: EmotionOptions(), entities: EntitiesOptions(), keywords: KeywordsOptions(), relations: RelationsOptions(), sentiment: SentimentOptions(document: true), categories: CategoriesOptions())
            let parameters = Parameters(features: features, text: textToAnalyze, returnAnalyzedText: true ) //check text
            let failure = { (error: Error) in print(error) }
            var score = 0.0
            
            naturalLanguageUnderstanding.analyze(parameters: parameters, failure: failure) {
                results in
                
                score = (results.sentiment?.document?.score)!
                let ref = Constants.refs.databaseUsers
                ref.queryEqual(toValue: self.userId)
                
                _ = ref.observeSingleEvent(of: .value, with: { snapshot in
                    
                    var statement: String!
                    
                    if (score > 0.0) {
                        statement = "gratitudes"
                    } else if (score < 0.0){
                        statement = "problems"
                    }
                    
                    if  let data        = snapshot.value as? NSDictionary {
                        let userObject = data[self.userId] as! NSDictionary
                        var gratitudes = NSArray()
                        
                        if (userObject["\(statement!)"] != nil) {
                            gratitudes = userObject["\(statement!)"] as! NSArray
                        }
                        gratitudes = gratitudes.adding(textToAnalyze) as NSArray
                        
                        let childUpdates = ["/\(self.userId)/\(statement!)/": gratitudes]
                        ref.updateChildValues(childUpdates)
                    }
                    
                })
                
                if (score > 0.0) {
                    //use model to react positively
                    DispatchQueue.main.async() {
                        self.buddyOutput.text = "That's so great!"
                    }
                    
                } else if (score < 0.0){
                    //use model to  figure out what to say in response
                    //bring back positive thing from the past
                    DispatchQueue.main.async() {
                        self.buddyOutput.text = "Im so sorry, have hope!"
                    }
                }
                
                
            }
            
            return false
        }
        return true
    }
    
    
    func moveTextView(textView: UITextView, moveDistance: Int, up: Bool){
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        UIView.beginAnimations("animatedTextView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

