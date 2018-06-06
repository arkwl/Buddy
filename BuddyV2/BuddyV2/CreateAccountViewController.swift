//
//  CreateAccountViewController.swift
//  BuddyV2
//
//  Created by Alexa Rockwell on 6/5/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func createAccount(_ sender: UIButton) {
        
        if let email = self.emailField.text, let password = self.passwordField.text {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if error == nil {
                    print("You have successfully signed up")
                    let ref = Constants.refs.databaseUsers.childByAutoId()
                    let user = ["email": email]
                    
                    ref.setValue(user)
                    self.dismiss(animated: false, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                
                }
                
            }
        } else {
            print("email/password can't be empty")
        }
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
