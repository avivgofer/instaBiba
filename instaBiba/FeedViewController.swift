//
//  postViewController.swift
//  instaBiba
//
//  Created by    aviv gofer on 16/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit
import Firebase

class feedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var allPosts = [Post]()
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.myTableView.separatorStyle = .singleLine
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.allPosts.removeAll()
        getAllFollowingPosts()
    }
    
    func getAllFollowingPosts(){
        Model.instance.getAllFollowingPosts(){(posts) in
            for post in posts{
                self.allPosts.append(post)
                self.myTableView.reloadData()
            }
            self.allPosts.sort(by: { $1.date.compare($0.date) == .orderedAscending })
        }
    }
    
    func setPreference(){
        
    }
    
    func circleImageView(image: UIImageView)
    {
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.black.cgColor
        //image.layer.cornerRadius = userProfileImage.frame.height/2
        image.clipsToBounds = true
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return CGFloat(integerLiteral: 350)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (allPosts.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! FeedTableViewCell
        
        if tableView == self.myTableView {
            let tempPost = allPosts[indexPath.row]
            Model.instance.getProfileImageUrlByEmailName(emailName:cutEmailName(email:tempPost.email)){(result) -> () in
                Model.instance.downloadImage(url: URL(string:result)!){(image) in
                    cell.profileImage.image = image
                }
            }
            Model.instance.downloadImage(url: URL(string:tempPost.imageUrl)!){(image) in
                //cell.profileImage.image = image
                cell.postImage.image = image
            }
            cell.timeLabel.text = self.getTimestringFromTimeInterval(interval: self.getTimeIntervalFromStringDate(string: tempPost.date))
            //cell.commentLabel.text = tempComment.comment
            cell.userNameLabel.text = cutEmailName(email:tempPost.email)
            Model.instance.getAllLikesByEmail(email: tempPost.email, postId: tempPost.id){(likes) in
                cell.likesLabel.text = String(likes.count) + " Likes"
            }
        }
        
        return cell
    }
}
