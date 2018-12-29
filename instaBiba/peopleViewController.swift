//
//  peopleViewController.swift
//  instaBiba
//
//  Created by    aviv gofer on 14/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class peopleViewController: UIViewController ,UICollectionViewDataSource ,UICollectionViewDelegate{

    @IBOutlet weak var numberOfFollowing: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberOfPosts: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var imageCollection: UICollectionView!
    var customImageFlowLayout : CustomImageFlowLayout!
    var images = [UIImage]()
    var user : User?
    var posts : [Post]?
    var ref : DatabaseReference?
    override func viewDidLoad() {
        super.viewDidLoad()
        circleImageView(image: self.profileImageView)
        customImageFlowLayout = CustomImageFlowLayout()
        imageCollection.collectionViewLayout = customImageFlowLayout
        imageCollection.backgroundColor = .white
        imageCollection.dataSource = self
        imageCollection.delegate = self
        followButton.backgroundColor = UIColor.blue
        followButton.layer.cornerRadius = 5
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.black.cgColor
        followButton.setTitle("Follow", for:.normal)
        followButton.setTitleColor(UIColor.white, for: .normal)
        followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
       
        ref = Database.database().reference()
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        GlobalSettings.flag = true
         nameLabel.text = self.user?.name ?? "sdfsdf"
        self.downloadProfileImage(from: URL(string: self.user!.profileImgUrl )!)
     //   self.profileName.text = self.user.name
        self.numberOfPosts.text = String(self.images.count)
        images.removeAll()
        loadImages()
        loadFollows()
    }
    

    @IBAction func chatButtonClicked(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatViewController") as? chatViewController
        {
            vc.hisUser = user
            present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    func loadFollows(){
        Model.instance.getAllFollowers(userName: (user?.email)!){(followers) in
            self.numberOfFollowers.text = String(followers.count)
            for user in followers{
                if user.email == Auth.auth().currentUser?.email{
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.backgroundColor = UIColor.gray
                }
            }
        }
        Model.instance.getAllFollowing(userName: (user?.email)!){(following) in
            self.numberOfFollowing.text = String(following.count)
        }
    }
    
    func downloadProfileImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                let imageT = UIImage(data: data)!
                self.profileImageView.image = imageT
                
            }
        }
    }
    @IBAction func followButtonClicked(_ sender: Any) {
        if followButton.titleLabel?.text == "Following"
        {
            Model.instance.deleteFollowFromData(user:user!)
            self.followButton.setTitle("Follow", for: .normal)
            self.followButton.backgroundColor = UIColor.blue
        }
        else if followButton.titleLabel?.text == "Follow"{
            Model.instance.addFollowToData(user:user!)
            followButton.setTitle("Following", for: .normal)
            followButton.backgroundColor = UIColor.gray
        }
    }
    
    func  appendImage(img :UIImage){
        self.images.append(img)
        self.imageCollection.reloadData()
        self.numberOfPosts.text = String(self.images.count)
    }
    
    
    
    
    func newLoad(len:Int = (-1)){
        // let length = self.posts?.count
        var length: Int?
        length = len
        if length == (-1){length = (self.posts?.count)!}
        if(length != nil && length! > 0)
        {
            //        for (post) in self.posts!{
            let imageUrlData = (self.posts![length!-1].imageUrl)
            //            print(imageUrlData)
            if(GlobalSettings.flag)
            {
                Model.instance.downloadImage(url: URL(string: imageUrlData )!) {(image) -> () in
                //Callback
                    self.appendImage(img: image)
                    self.imageCollection.reloadData()
                    self.newLoad(len: (length! - 1))
            }
            }
        }
    }
    
    func loadImages(){
        Model.instance.getAllPostsByEmail(email:(self.user?.email)!){ (result) -> () in
            var temp = result
            temp.sort(by: { $0.date.compare($1.date) == .orderedAscending })
            self.posts = temp
            self.newLoad()
        }
    }
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    @IBAction func returnButtonClicked(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func circleImageView(image: UIImageView)
    {
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.cornerRadius = profileImageView.frame.height/2
        image.clipsToBounds = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollection.dequeueReusableCell(withReuseIdentifier: "Cell2", for: indexPath) as! ImageCollectionViewCell
        let image = images[indexPath.row]
        cell.imageView.image = image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "postViewController") as? postViewController
        {
            print(indexPath[1])
            vc.postImage = images[indexPath[1]]
            var temp = self.posts!
            temp.sort(by: { $1.date.compare($0.date) == .orderedAscending })
            vc.post = temp[indexPath[1]]
            vc.userNameTemp = self.user?.name
            vc.userProfileImageTemp = self.profileImageView
            GlobalSettings.flag = false
            present(vc, animated: true, completion: nil)
        }
    } 
}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


