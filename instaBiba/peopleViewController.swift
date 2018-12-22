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
        ref = Database.database().reference()
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
         nameLabel.text = self.user?.name ?? "sdfsdf"
        self.downloadProfileImage(from: URL(string: self.user!.profileImgUrl )!)
     //   self.profileName.text = self.user.name
        self.numberOfPosts.text = String(self.images.count)
        images.removeAll()
        loadImages()
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
    
    func  appendImage(img :UIImage){
        self.images.append(img)
        self.imageCollection.reloadData()
        self.numberOfPosts.text = String(self.images.count)
    }
    
    func downloadImage(from url: URL ,completion: ()->()) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                let imageT = UIImage(data: data)!
                self.appendImage(img: imageT)
                //  self.imageView.image = UIImage(data: data)
                self.imageCollection.reloadData()
                
            }
        }
    }
    
    
    
    
    func loadImages(){
        Model.instance.getAllPostsByEmail(email:(self.user?.email)!){ (result) -> () in
            self.posts = result
            for (post) in self.posts!{
                self.downloadImage(from: URL(string:post.imageUrl)!){ () -> () in
                    self.imageCollection.reloadData()
                }
            }
        }
    }
//        ref?.child("Posts").child((self.user?.name)!).observeSingleEvent(of: .value, with: { (snapshot) in
//            //in my case the answer is of type array so I can cast it like this, should also work with NSDictionary or NSNumber
//            if let snapshotValue = snapshot.value as? NSDictionary{
//                //then I iterate over the values
//                for (_,eachFetchedRestaurant) in snapshotValue{
//                    let x = eachFetchedRestaurant as? NSDictionary
//                    let imageUrlData = (x!.value(forKey: "imageUrl"))!
//                    let y = eachFetchedRestaurant
//                    let tempPost = Post(json: y as! [String : Any] )
//                    print(imageUrlData)
//                    self.downloadImage(from: URL(string: imageUrlData as! String)!){ () -> () in
//                        //Callback
//                        self.imageCollection.reloadData()
//                    }
//                }
//            }
//        }) { (error) in
//            print(error.localizedDescription)
//        }
    
    
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
          //  vc.user = self.users[indexPath[1]]
//
           
            vc.postImage = images[indexPath[1]]
            vc.post = self.posts![indexPath[1]]
            vc.userNameTemp = self.user?.name
            vc.userProfileImageTemp = self.profileImageView
          //  vc.userProfileImage = self.profileImageView
         //   vc.myImageView.image = x
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


