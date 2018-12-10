//
//  LoginViewController.swift
//  instaBiba
//
//  Created by    aviv gofer on 20/11/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class LoginViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    var imagePicker = UIImagePickerController()
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameSignup: UITextField!
    @IBOutlet weak var passwordSignup: UITextField!
    @IBOutlet weak var emailSignup: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var ref: DatabaseReference!
    static var isAlreadyLaunchedOnce = false
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    @IBAction func selectImgClicked(_ sender: Any) {
        self.imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker,animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.profileImg.image = image
            // uploadImage(image: image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    //signUp user with firebase auth and data
    @IBAction func signupClickButton(_ sender: Any) {
        if(emailSignup.text != "" && passwordSignup.text != "" && nameSignup.text != "")
        {
            Auth.auth().createUser(withEmail: (emailSignup.text ?? ""), password: (passwordSignup.text ?? "")) { (result, error) in
                if let _eror = error {
                    //something bad happning
                    print(_eror.localizedDescription )
                    
                }else{
                    //user registered successfully
                   // let userID = Auth.auth().currentUser?.uid
//                    let user = User(_id: userID!, _name: self.nameSignup.text!, _email: self.emailSignup.text!,_profileImgUrl:"temp",_followingList:nil,_followersList:nil)
//                    Model.instance.addNewUserToData(user: user)
                    self.uploadImageToStorageAndData(image: self.profileImg.image!)
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                    print(result ?? "register Success")
                }
            }
           
        }
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
    
    
    func uploadImageToStorageAndData(image: UIImage) {
        
        let imageData = image.jpegData(compressionQuality: 10)
        //let imageData = image.pngData()
        
        
        let uploadRef = Storage.storage().reference().child("images/\(getEmailName())/profileImg.jpg")
        _ = uploadRef.putData(imageData!, metadata: nil) { (metadata, error) in
            uploadRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
               // let key = self.ref?.childByAutoId().key
              //  let image = ["url" : downloadURL.absoluteString]
               // let childUpdates = ["/\(String(describing: key))": image]
                 let randomName = self.randomStringWithLength(length: 10)
//                let postTitle = "profileImage"
//                let userEmail = Auth.auth().currentUser?.email
                 let url = downloadURL.absoluteString
                let user = User(_id: randomName as String, _name: self.nameSignup.text!, _email: self.emailSignup.text!, _profileImgUrl: url, _followingList: nil, _followersList: nil)
//                let post = Post(_id: randomName as String,_email : userEmail!, _title: postTitle, _imageUrl: url)
//                Model.instance.addNewPostToData(post:post)
                Model.instance.addNewUserToData(user: user)
               //  self.ref?.updateChildValues(childUpdates)
            }
        }
    }
    
    
    //login user Auth with firebase
    @IBAction func loginClickButton(_ sender: Any) {
        print("Login buttin Clicked")
        if(userNameTextField.text != "" && passwordTextField.text != "")
        {
            Auth.auth().signIn(withEmail: userNameTextField.text!, password: passwordTextField.text!) { (user, error) in
                if(user != nil) {
                print("user Authenticated")
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                else{
                    print("there was an error with Authentication")
                    self.errorLabel.isHidden = false
                }
            }
        }
        else{
            print("there was an error with Authentication")
            self.errorLabel.isHidden = false
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

}
