//
//  postViewController.swift
//  instaBiba
//
//  Created by    aviv gofer on 16/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit
import Firebase

class postViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var newCommentField: UITextField!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    var post :Post?
    var allComments = [Comment]()
    var postImage :UIImage?
    var userProfileImageTemp :UIImageView?
    var userNameTemp :String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        myImageView.image = postImage!
        postTitle.text = post?.title
        userProfileImage.image = userProfileImageTemp!.image
        userNameLabel.text = userNameTemp!
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.separatorStyle = .none
        circleImageView(image: userProfileImage)
        // Do any additional setup after loading the view.
    }
    
    func circleImageView(image: UIImageView)
    {
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.cornerRadius = userProfileImage.frame.height/2
        image.clipsToBounds = true
    }
    
    var dataBaseRef: DatabaseReference! {
        return Database.database().reference()
    }
    var storageRef: Storage {
        return Storage.storage()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let usersRef = dataBaseRef.child("Posts").child(cutEmailName(email: (post?.email)!)).child((post?.id)!).child("Comments")
        usersRef.observe(.value, with: { (snapshot) in
            var tempComments = [Comment]()
            for comment in snapshot.children {
                let tempComment = Comment(snapshot: comment as! DataSnapshot)
                tempComments.append(tempComment)
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let x = tempComment.date
                guard let date = dateFormatter.date(from: x) else {
                    fatalError("ERROR: Date conversion failed due to mismatched format.")
                }
                
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//               // dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
//                let date = dateFormatter.date(from: tempComment.date)!
//                let timeInterval = date.timeIntervalSinceNow
//                print(timeInterval)
//                print(self.getTimestringFromTimeInterval(interval: timeInterval))
            }
            self.allComments = tempComments
          //  print(self.users)
            self.myTableView.reloadData()
        }) { (error) in
            let alertView = UIAlertView(title: "Erreur", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
    
    func getTimeIntervalFromStringDate(string:String) -> TimeInterval{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = dateFormatter.date(from: string) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        return date.timeIntervalSinceNow
    }
    
    func getTimestringFromTimeInterval(interval:TimeInterval) -> String {
        
        let ti = NSInteger(interval)
        let seconds = Int((ti % 60) * (-1))
        let minutes = Int(((ti / 60) % 60) * (-1))
        let hours = Int(((ti / 3600)) * (-1))
        if(hours >= 24){
            return String(hours / 24)+"d"
        }else if(hours >= 1){
            return String(hours)+"h"
        }else if(minutes >= 1){
            return String(minutes)+"m"
        }else{
            return String(seconds)+"sec"
        }
       
    }
    
    func cutEmailName(email:String) -> String{
        let emailName = email.split(separator: "@")[0].split(separator: ".")[0]
        return emailName != "" ? (String(emailName)) : "noNameEmail"
    }
    
//
//    @IBAction func addCommentClicked(_ sender: Any) {
//   // Model.instance.addComment(self.commentFiled.text!)
//    }
//
    @IBAction func addCommentClicked(_ sender: Any) {
        if(self.newCommentField.text! != "")
        {
            Model.instance.addCommentToData(comment:newCommentField.text!,post:self.post!)
            self.newCommentField.text = ""
        }
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
   
//
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allComments.count
    }

    
 
   
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! commentsTableViewCell

        if tableView == self.myTableView {
            let tempComment = allComments[indexPath.row]
//            cell.backgroundColor = UIColor.white
//            cell.layer.borderColor = UIColor.black.cgColor
//            cell.layer.borderWidth = 1
//            cell.layer.cornerRadius = 8
//            cell.clipsToBounds = true
            
            Model.instance.getProfileImageUrlByEmailName(emailName: tempComment.userEmailName){(result) -> () in
                
                self.storageRef.reference(forURL:result).getData(maxSize: 10 * 1024 * 1024) { (imgData, error) in
                    if let error = error {
                        let alertView = UIAlertView(title: "Erreur", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                        alertView.show()
                    } else {
                        DispatchQueue.main.async(execute: {
                            if let data = imgData {
                                cell.userImage.image = UIImage(data: data)
                            }
                        })
                    }
                }
                
                print(result)
                
            }
          //  cell.imageView?.image = Model.i
           // cell.watcherName.text = allComments[indexPath.row].comment
             cell.timeLabel.text = self.getTimestringFromTimeInterval(interval: self.getTimeIntervalFromStringDate(string: tempComment.date))
             cell.commentLabel.text = tempComment.comment
            cell.userNameLabel.text = tempComment.userEmailName+":"
            }

        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
