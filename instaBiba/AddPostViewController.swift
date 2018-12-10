//
//  AddPostViewController.swift
//  instaBiba
//
//  Created by    aviv gofer on 07/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase


class AddPostViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var addPostButton: UIButton!
    var imagePicker = UIImagePickerController()
    var images = [UIImage]()
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var titleTextFiled: UITextField!
    var ref : DatabaseReference?
    var imageFileName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    //random name for image
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
    
    //getting the name of the current user from is email before the "@"
    func getEmailName() -> String {
        let emailName = Auth.auth().currentUser?.email?.split(separator: "@")[0]
        return emailName != nil ? (String(emailName!)) : "noNameEmail"
    }
    
    @IBAction func selectImageClicked(_ sender: Any) {
        self.imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker,animated: true,completion: nil)
      
    }
    
    @IBAction func addPostClicked(_ sender: Any) {
        uploadImageToStorageAndData(image: selectedImageView.image!)
      
     //   Model.instance.addNewPostToData(post: post)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageToStorageAndData(image: UIImage) {
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
               // let childUpdates = ["/\(String(describing: key))": image]
                
                let postTitle = self.titleTextFiled.text!
                let userEmail = Auth.auth().currentUser?.email
                let url = downloadURL.absoluteString
                let post = Post(_id: randomName as String,_email : userEmail!, _title: postTitle, _imageUrl: url)
                Model.instance.addNewPostToData(post:post)
               // self.ref?.updateChildValues(childUpdates)
            }
        }
    }

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
        self.selectedImageView.image = image
           // uploadImage(image: image)
        }
        dismiss(animated: true, completion: nil)
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
