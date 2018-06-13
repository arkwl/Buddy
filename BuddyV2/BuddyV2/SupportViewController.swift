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
    var userId = String("")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            let email = user.email
        }
        print(user?.email)
        print(user?.uid)
        
        let query = Constants.refs.databaseUsers
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            
            if  let data        = snapshot.value as? [String: String],
                let uid          = data["uid"],
                let email        = data["email"]
            {
                self?.userId = uid
                /*
                if let message = JSQMessage(senderId: id, displayName: name, text: text)
                {
                    self?.messages.append(message)
                    
                    self?.finishReceivingMessage()
                } */
            }
        })
        
        
        //checking sentiment
        let username = "5a046e48-f187-4177-805c-cfa721b322e0"
        let password = "VfIEIb6hIrTF"
        let version = "2018-06-10" // use today's date for the most recent version
        let result: Any!
        
        let naturalLanguageUnderstanding = NaturalLanguageUnderstanding(username: username, password: password, version: version)
        
        let urlToAnalyze = "I am feeling great today, nothing can stand in my way. I just got a promotion at work!" //"www.wsj.com/news/markets"
        //let features = Features(sentiment: SentimentOptions(document: true))
        let features = Features(emotion: EmotionOptions(), entities: EntitiesOptions(), keywords: KeywordsOptions(), relations: RelationsOptions(), sentiment: SentimentOptions(document: true), categories: CategoriesOptions())
        let parameters = Parameters(features: features, text: urlToAnalyze, returnAnalyzedText: true ) //check text
        let failure = { (error: Error) in print(error) }
        naturalLanguageUnderstanding.analyze(parameters: parameters, failure: failure) {
            results in
            
            print(results)
            
            
            
            
            
            /*
            let score = results.sentiment?.document?.score
            var sentimentValue = "positive"
            if (score! < 0.0) {
                sentimentValue = "negative"
            } else if (score! == 0.0) {
                sentimentValue = "neutral"
            }
            NSLog("!!!!!!!!!!!!!! result: " + results.sentiment.debugDescription)
            print(sentimentValue)
            */
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

