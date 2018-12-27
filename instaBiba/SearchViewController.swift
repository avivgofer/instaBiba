//
//  SearchViewController.swift
//  instaBiba
//
//  Created by    aviv gofer on 10/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class SearchViewController: UITableViewController,UISearchBarDelegate{
    
    
    @IBOutlet weak var searchItem: UISearchBar!
    var users = [User]()
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchItem.delegate = self
        self.myTableView.separatorStyle = .none
        self.tableView.separatorStyle = .none
    }
    
    var dataBaseRef: DatabaseReference! {
        return Database.database().reference()
    }
    var storageRef: Storage {
        return Storage.storage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUsers()

    }

    func loadUsers(){
        Model.instance.getAllUsers(){(allUsers) in
            self.users = allUsers
            self.myTableView.reloadData()
        }
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.myTableView.reloadData()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "peopleViewController") as? peopleViewController
        {
            vc.user = self.users[indexPath[1]] 
            present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! TestTableViewCell
        if tableView == self.myTableView {
            cell.watcherName.text = users[indexPath.row].name
            Model.instance.downloadImage(url:URL(string: users[indexPath.row].profileImgUrl)!){(profileImage) in
                cell.memberImage.image = profileImage
            }
            
//            storageRef.reference(forURL: users[indexPath.row].profileImgUrl).getData(maxSize: 10 * 1024 * 1024) { (imgData, error) in
//                if let error = error {
//                    let alertView = UIAlertView(title: "Erreur", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
//                    alertView.show()
//                } else {
//                    DispatchQueue.main.async(execute: {
//                        if let data = imgData {
//                            cell.memberImage.image = UIImage(data: data)
//                        }
//                    })
//                }
//            }
        }
        return cell
    }
    
    
}
