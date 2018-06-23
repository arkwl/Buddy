//
//  FirstAidKitViewController.swift
//  BuddyV2
//
//  Created by Alexa Rockwell on 6/18/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftInstagram

class ImagePostTableViewCell: UITableViewCell {
    
    @IBOutlet var openInInstagram: UIButton!
    @IBOutlet var imagePost: UIImageView!
    
    var isChecked = true
    var url: String!
    
    @IBAction func like(_ sender: UIButton) {
        isChecked = !isChecked
        if isChecked {
            sender.setTitle("💖", for: .normal)
            sender.setTitleColor(.green, for: .normal)
        } else {
            sender.setTitle("🖤", for: .normal)
            sender.setTitleColor(.red, for: .normal)
        }
    }
    
    @IBAction func openPost(_ sender: UIButton) {
        
        print("clicked")
        print(self.url)
        
        let stringURL = URL(string: self.url)
        if UIApplication.shared.canOpenURL(stringURL!) {
            print("can open")
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(stringURL!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(stringURL!)
            }
        }
    }
}

class TextPostTableViewCell: UITableViewCell {
    
    @IBOutlet var postText: UILabel!
    
}

extension UIImageView{
    
    func setImageFromURl(stringImageUrl url: String){
        
        if let url = NSURL(string: url) {
            if let data = NSData(contentsOf: url as URL) {
                self.image = UIImage(data: data as Data)
            }
        }
    }
}


class FirstAidKitViewController: UIViewController, UITableViewDataSource {
    
    let sections = ["Fruit", "Vegetables"]
    let fruit = ["Apple", "Orange", "Mango"]
    let vegetables = ["Carrot", "Broccoli", "Cucumber"]
    
    @IBOutlet var tableView: UITableView!
    
    var json = JSON([[ "type" : "text" , "content": "you are loved"], [ "type" : "image" , "content" : "http://cdn2-www.dogtime.com/assets/uploads/2010/12/puppies.jpg"], [ "type": "text", "content": "keep your head up"]  ])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let api = Instagram.shared
        
        // Returns whether a user is currently authenticated or not
        if api.isAuthenticated {
            let accessToken = api.retrieveAccessToken()
            print(accessToken)
            api.recentMedia(withTag: "nofilter", count: 10, success: { mediaList in
                
                mediaList.forEach{ item in
                    //print(item.caption?.text)
                    let image = item.images.standardResolution.url
                    let url = item.link
                    let update =  JSON([["type" : "instagram", "content" : "https://scontent.cdninstagram.com"+image.path, "link": "\(url)"]])
                    self.json = JSON(self.json.arrayObject! + update.arrayObject!)
                }
                print("updated list of posts")
                print(self.json)
                self.tableView.reloadData()
            }, failure: { error in
                print(error.localizedDescription)
            })
        } else {
            // Login
            api.login(from: navigationController!, success: {
                // Do your stuff here ...
            }, failure: { error in
                print(error.localizedDescription)
            })
            
        }
        print("Success")

        //populate tableview with sample data
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return json.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create an object of the dynamic cell “PlainCell”
        let cell = tableView.dequeueReusableCell(withIdentifier: "post", for: indexPath)
        // Depending on the section, fill the textLabel with the relevant text
        
        let contents = self.json[indexPath.row]["content"].rawString()!
        
        switch self.json[indexPath.row]["type"] {
        case "text":
            // Fruit Sectbion
            print("text detected")
            cell.textLabel?.text = contents
            break
        case "image":
            // Vegetable Section
            print("image detected")
            let imageCell = tableView.dequeueReusableCell(withIdentifier: "image_post", for: indexPath) as! ImagePostTableViewCell
            imageCell.url = contents
            let url = URL(string: contents)
            var imageData : Data!
            do {
                imageData = try Data(contentsOf: url!)
            } catch {
                return cell
            }
            let image_post : UIImage = UIImage(data:imageData)!
            print("The loaded image: \(image_post)")
            imageCell.imagePost?.image = image_post
            
            return imageCell
        case "instagram":
            // Vegetable Section
            print("instagram detected")
            let imageCell = tableView.dequeueReusableCell(withIdentifier: "image_post", for: indexPath) as! ImagePostTableViewCell
            imageCell.url = self.json[indexPath.row]["link"].rawString()!
            let url = URL(string: contents)
            var imageData : Data!
            do {
                imageData = try Data(contentsOf: url!)
            } catch {
                return cell
            }
            let image_post : UIImage = UIImage(data:imageData)!
            print("The loaded image: \(image_post)")
            imageCell.imagePost?.image = image_post
            
            return imageCell
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("table clicked")
        print(indexPath.row)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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



