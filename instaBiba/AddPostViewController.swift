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
    
    @IBOutlet weak var addPostProgressItem: UIActivityIndicatorView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var addPostButton: UIButton!
    var imagePicker = UIImagePickerController()
    var images = [UIImage]()
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var titleTextFiled: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        addPostProgressItem.isHidden = true
        self.hideKeyboardWhenTappedAround()
        openImagePicker()
        // Do any additional setup after loading the view.
    }
    
        //getting the name of the current user from is email before the "@" and "."
    func getEmailName() -> String {
        return  Model.instance.getNameFromEmail()
    }
    
    @IBAction func selectImageClicked(_ sender: Any) {
        openImagePicker()
      
    }
    
    func openImagePicker(){
        self.imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker,animated: true,completion: nil)
    }
    
    @IBAction func addPostClicked(_ sender: Any) {
        addPostButton.isHidden = true
        addPostProgressItem.isHidden = false
        addPostProgressItem.startAnimating()
    Model.instance.uploadPostToStorageAndData(image:self.selectedImageView.image!,title:self.titleTextFiled.text!,completion:{
            self.addPostProgressItem.stopAnimating()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        self.tabBarController?.selectedIndex = 0
         self.titleTextFiled.text = ""
        self.addPostButton.isHidden = false
        self.addPostProgressItem.isHidden = true
        self.selectedImageView.image = nil
//        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
//        {
//          //  vc.user = self.users[indexPath[1]]
//            self.present(vc, animated: true, completion: nil)
//        }
        })
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
        self.selectedImageView.image = image
           // uploadImage(image: image)
        }
        dismiss(animated: true, completion: nil)
    }
 

}
