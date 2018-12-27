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

    @IBOutlet weak var LikesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var newCommentField: UITextField!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    var post :Post?
    var allComments = [Comment]()
    var allLikes = [Like]()
    var postImage :UIImage?
    var userProfileImageTemp :UIImageView?
    var userNameTemp :String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        self.setPreference()
        self.timeLabel.text = self.getTimestringFromTimeInterval(interval: self.getTimeIntervalFromStringDate(string: post!.date))
        // Do any additional setup after loading the view.
    }
    
    func setPreference(){
        self.myImageView.image = postImage!
        self.postTitle.text = post?.title
        self.userProfileImage.image = userProfileImageTemp!.image
        self.userNameLabel.text = userNameTemp!
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.myTableView.separatorStyle = .none
        self.myImageView.clipsToBounds = true
        self.myImageView.contentMode = UIView.ContentMode.scaleAspectFill
        self.circleImageView(image: userProfileImage)
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        if likeButton.currentImage == UIImage(named: "redHeartIcon")
        {
            likeButton.setImage(UIImage(named: "heartIcon"), for: .normal)
            Model.instance.deleteLikeFromData(post:self.post!)
        }
        else{
            likeButton.setImage(UIImage(named: "redHeartIcon"), for: .normal)
            Model.instance.addLikeToData(post:self.post!)
        }
    }
    
    @IBAction func click(_ sender: Any) {
//        let testFrame : CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)
//        var testView : UIView = UIView(frame: testFrame)
//        testView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
//        testView.alpha=0.5
//        self.view.addSubview(testView)
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
      loadComments()
      loadLikes()
    }
    
    func loadLikes(){
        Model.instance.getAllLikesByEmail(email:(post?.email)!,postId:(post?.id)!){(likes) in
            self.allLikes = likes
            for like in self.allLikes{
                if(like.userEmailName == self.cutEmailName(email: (Auth.auth().currentUser?.email)!)){
                    self.likeButton.setImage(UIImage(named: "redHeartIcon"), for: .normal)
                }
            }
            
            self.LikesLabel.text = "\(self.allLikes.count) Likes"
        }
//        let usersRef = dataBaseRef.child("Posts").child(cutEmailName(email: (post?.email)!)).child((post?.id)!).child("Likes")
//        usersRef.observe(.value, with: { (snapshot) in
//            var tempLikes = [Like]()
//            for like in snapshot.children {
//                let tempLike = Like(snapshot: like as! DataSnapshot)
//                tempLikes.append(tempLike)
//                if(tempLike.userEmailName == self.cutEmailName(email: (Auth.auth().currentUser?.email)!)){
//                    self.likeButton.setImage(UIImage(named: "redHeartIcon"), for: .normal)
//                }
//            }
//            self.allLikes = tempLikes
//            //  print(self.users)
//            self.LikesLabel.text = "\(self.allLikes.count) Likes"
//        }) { (error) in
//            print(error)
//        }
    }
    
    func loadComments(){
        let usersRef = dataBaseRef.child("Posts").child(cutEmailName(email: (post?.email)!)).child((post?.id)!).child("Comments")
        usersRef.observe(.value, with: { (snapshot) in
            var tempComments = [Comment]()
            for comment in snapshot.children {
                let tempComment = Comment(snapshot: comment as! DataSnapshot)
                tempComments.append(tempComment)
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let x = tempComment.date
                guard dateFormatter.date(from: x) != nil else {
                    fatalError("ERROR: Date conversion failed due to mismatched format.")
                }
            }
            self.allComments = tempComments
            //  print(self.users)
            self.myTableView.reloadData()
        }) { (error) in
            print(error)
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
            return String(seconds)+" sec"
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
            Model.instance.getProfileImageUrlByEmailName(emailName: tempComment.userEmailName){(result) -> () in
                Model.instance.downloadImage(url: URL(string:result)!){(image) in
                    cell.userImage.image = image
                    
                    }
            }
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
