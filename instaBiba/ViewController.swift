//
//  ViewController.swift
//  instaBiba
//
//  Created by    aviv gofer on 20/11/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase



class ViewController: UIViewController ,UICollectionViewDataSource,UICollectionViewDelegate  {

    
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var numberOfFollowing: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    @IBOutlet weak var numberOfPosts: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var imageFileName :String = ""
    var posts : [Post]?
    var customImageFlowLayout : CustomImageFlowLayout!
    @IBOutlet weak var imageCollection: UICollectionView!
    var images = [UIImage]()
    @IBOutlet weak var LoginButton: UIBarButtonItem!
    var ref : DatabaseReference?
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var addImageButton: UIBarButtonItem!
    var currentUser : User?
   
    override func viewDidLoad() { 
        super.viewDidLoad()
        circleImageView(image: self.profileImageView)
        customImageFlowLayout = CustomImageFlowLayout()
        imageCollectionPrefrence()
        ref = Database.database().reference()
        imagePicker.delegate = self
     
    }
    
    func imageCollectionPrefrence()
    {
        imageCollection.collectionViewLayout = customImageFlowLayout
        imageCollection.backgroundColor = .white
        imageCollection.dataSource = self
        imageCollection.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (Auth.auth().currentUser != nil){
            self.LoginButton.title = "Logout"
            images.removeAll()
            self.loadImages()
            imageCollection.reloadData()
            posts?.removeAll()
            Model.instance.getAllPostsByEmail(email:((Auth.auth().currentUser!.email)!)){ (result) -> () in
                result.sorted(by: { $0.date > $1.date})
                self.posts = result
                print("d")
            }
            Model.instance.getCurrentUser(completion:{ result in
                self.downloadProfileImage(from: URL(string: result.profileImgUrl )!)
                self.profileName.text = result.name
                self.numberOfPosts.text = String(self.images.count)
            })
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    
    func circleImageView(image: UIImageView)
    {
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.cornerRadius = profileImageView.frame.height/2
        image.clipsToBounds = true
    }

 
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
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
    
    
    func loadImages(){
        ref?.child("Posts").child(getEmailName()).observeSingleEvent(of: .value, with: { (snapshot) in
            //in my case the answer is of type array so I can cast it like this, should also work with NSDictionary or NSNumber
            if let snapshotValue = snapshot.value as? NSDictionary{
                //then I iterate over the values
                for (_,eachFetchedRestaurant) in snapshotValue{
                    let x = eachFetchedRestaurant as? NSDictionary
                    let imageUrlData = (x!.value(forKey: "imageUrl"))!
                    print(imageUrlData)
                    self.downloadImage(from: URL(string: imageUrlData as! String)!){ () -> () in
                        //Callback
                        self.imageCollection.reloadData()
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func addImageClick(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker,animated: true,completion: nil)  //open the image picker and call the imagePickerController
    }

    
    @IBAction func LogoutButtonClick(_ sender: Any) {
        if Auth.auth().currentUser != nil{
            self.images.removeAll()
            imageCollection.reloadData()
            do{
               try Auth.auth().signOut()
            }catch let SignOutError as NSError{
                print("Error SignOut: %@",SignOutError)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollection.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell
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
            vc.userNameTemp = profileName.text!
            vc.userProfileImageTemp = self.profileImageView
            vc.postImage = images[indexPath[1]]
            vc.post = self.posts![indexPath[1]]
            //   vc.myImageView.image = x
            present(vc, animated: true, completion: nil)
        }
    }
}

extension ViewController :  UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    func randomStringWithLength(length: Int) -> NSString {
        let characters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString: NSMutableString = NSMutableString(capacity: length)
        
        for _ in 0..<length {
            let len = UInt32(characters.length)
            let rand = arc4random_uniform(len)
            randomString.appendFormat("%C", characters.character(at: Int(rand)))
        }
        return randomString
    }
    
    //getting the name of the current user from is email before the "@" and "."
    func getEmailName() -> String {
       return  Model.instance.getNameFromEmail()
    }
    
    //Upload image from gallery to firebase
        func uploadImage(image: UIImage) {
            let randomName = randomStringWithLength(length: 10)
            let imageData = image.jpegData(compressionQuality: 10)
            //let imageData = image.pngData()
            
            
            let uploadRef = Storage.storage().reference().child("images/\(getEmailName())/\(randomName).jpg")
            _ = uploadRef.putData(imageData!, metadata: nil) { (metadata, error) in
                uploadRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
            let key = self.ref?.childByAutoId().key
            let image = ["url" : downloadURL.absoluteString]
            let childUpdates = ["/\(String(describing: key))": image]
            self.ref?.updateChildValues(childUpdates)
            }
        }
    }
    
    //Open image picker from gallery
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            images.append(image)
            uploadImage(image: image)
        }
        dismiss(animated: true, completion: nil)
        self.imageCollection.reloadData()
    }
}

