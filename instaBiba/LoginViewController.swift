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
   
   
    @IBOutlet weak var signUpProgressItem: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signinProgressItem: UIActivityIndicatorView!
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameSignup: UITextField!
    @IBOutlet weak var passwordSignup: UITextField!
    @IBOutlet weak var emailSignup: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signinProgressItem.isHidden = true
        signUpProgressItem.isHidden = true
        imagePicker.delegate = self
        if Auth.auth().currentUser != nil{
            do{
                try Auth.auth().signOut()
            }catch let SignOutError as NSError{
                print("Error SignOut: %@",SignOutError)
            }
        }
        self.hideKeyboardWhenTappedAround() 
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
        
        if(emailSignup.text != "" && passwordSignup.text != "" && nameSignup.text != "" && self.profileImg.image != nil)
        {
            signUpButton.isHidden = true
            signUpProgressItem.isHidden = false
            signUpProgressItem.startAnimating()
            Auth.auth().createUser(withEmail: (emailSignup.text ?? ""), password: (passwordSignup.text ?? "")) { (result, error) in
                if let _eror = error {
                    //something bad happning
                    print(_eror.localizedDescription )
                    
                }else{
                    Model.instance.uploadProfileImageToStorageAndData(image: self.profileImg.image!,name: self.nameSignup.text!,email: self.emailSignup.text!,completion:{
                      //  ViewController.viewController
                        self.signUpProgressItem.stopAnimating()
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                    })
                    print(result ?? "register Success")
                }
            }
           
        }
    }
    
    //login user Auth with firebase
    @IBAction func loginClickButton(_ sender: Any) {
        print("Login buttin Clicked")
        if(userNameTextField.text != "" && passwordTextField.text != "")
        {
            loginButton.isHidden = true
            signinProgressItem.isHidden = false
            signinProgressItem.startAnimating()
            Auth.auth().signIn(withEmail: userNameTextField.text!, password: passwordTextField.text!) { (user, error) in
                if(user != nil) {
                print("user Authenticated")
                    self.signinProgressItem.stopAnimating()
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
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
