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



class ViewController: UIViewController ,UICollectionViewDataSource  {
    

    var imageFileName :String = ""
    var customImageFlowLayout : CustomImageFlowLayout!
    @IBOutlet weak var imageCollection: UICollectionView!
    var images = [UIImage]()
    @IBOutlet weak var LoginInfo: UILabel!
    @IBOutlet weak var LoginButton: UIBarButtonItem!
    @IBOutlet weak var LogoutButton: UIBarButtonItem!
    var ref : DatabaseReference?
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var addImageButton: UIBarButtonItem!
    
   
    
    
    override func viewDidLoad() { 
        super.viewDidLoad()
       
        customImageFlowLayout = CustomImageFlowLayout()
        imageCollection.collectionViewLayout = customImageFlowLayout
        imageCollection.backgroundColor = .white
        ref = Database.database().reference()
        imagePicker.delegate = self
       
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   

 
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    func  appendImage(img :UIImage){
        self.images.append(img as UIImage)
        self.imageCollection.reloadData()
    }
    
    func downloadImage(from url: URL) {
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
        ref?.child("Posts").child(getEmailName()).observeSingleEvent(of: .value, with: { (snapshot) in
            //in my case the answer is of type array so I can cast it like this, should also work with NSDictionary or NSNumber
            if let snapshotValue = snapshot.value as? NSDictionary{
                //then I iterate over the values
                for (_,eachFetchedRestaurant) in snapshotValue{
                    let x = eachFetchedRestaurant as? NSDictionary
                    let imageUrlData = (x!.value(forKey: "imageUrl"))!
                    print(imageUrlData)
                    self.downloadImage(from: URL(string: imageUrlData as! String)! )
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
    
    override func viewWillAppear(_ animated: Bool) {
        if (Auth.auth().currentUser != nil){
            self.LoginButton.isEnabled = false
            self.LogoutButton.isEnabled = true
            self.LoginInfo.text = "Hello " + (Auth.auth().currentUser?.email)!
            self.loadImages()
            
        }else{
            self.LogoutButton.isEnabled = false
            self.LoginButton.isEnabled = true
            self.LoginInfo.text = "Pleass log in"
    }
}
    
    @IBAction func LogoutButtonClick(_ sender: Any) {
        if Auth.auth().currentUser != nil{
            do{
               try Auth.auth().signOut()
                self.LogoutButton.isEnabled = false
                self.LoginButton.isEnabled = true
                self.LoginInfo.text = "Pleass log in"
                //self.imageCollection.delete()
                
                self.imageCollection.removeFromSuperview()
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
        let emailName = Auth.auth().currentUser?.email?.split(separator: "@")[0].split(separator: ".")[0]
        
        return emailName != nil ? (String(emailName!)) : "noNameEmail"
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

