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
    var filteredData: [User]!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchItem.delegate = self
        self.myTableView.separatorStyle = .none
        self.tableView.separatorStyle = .none
        
        
        // Do any additional setup after loading the view.
    }
    
//    @IBAction func seeProfileClicked(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "peopleViewController")
//        self.present(controller, animated: true, completion: nil)
//       // let f = self.users[IndexPath].name
//        // Safe Present
//        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "peopleViewController") as? peopleViewController
//        {
//            vc.x = "yalllla"
//            present(vc, animated: true, completion: nil)
//        }
//
//    }
    var dataBaseRef: DatabaseReference! {
        return Database.database().reference()
    }
    var storageRef: Storage {
        return Storage.storage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let usersRef = dataBaseRef.child("Users")
        usersRef.observe(.value, with: { (snapshot) in
            var allusers = [User]()
            for user in snapshot.children {
                let newUser = User(snapshot: user as! DataSnapshot)
                allusers.append(newUser)
            }
            self.users = allusers
            print(self.users)
            self.myTableView.reloadData()
        }) { (error) in
            let alertView = UIAlertView(title: "Erreur", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        }
        filteredData = users
    }

    
    @IBAction func backClicked(_ sender: Any) {
        self.myTableView.reloadData()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     //   let storyboard = UIStoryboard(name: "Main", bundle: nil)
       // let controller = storyboard.instantiateViewController(withIdentifier: "peopleViewController")
       // self.present(controller, animated: true, completion: nil)
        // let f = self.users[IndexPath].name
        // Safe Present
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "peopleViewController") as? peopleViewController
        {
            vc.user = self.users[indexPath[1]] 
            present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! TestTableViewCell
        
        if tableView == self.myTableView {
         //   cell.watcherName.text = " df"
            cell.watcherName.text = users[indexPath.row].name
            storageRef.reference(forURL: users[indexPath.row].profileImgUrl).getData(maxSize: 10 * 1024 * 1024) { (imgData, error) in
                if let error = error {
                    let alertView = UIAlertView(title: "Erreur", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                } else {
                    DispatchQueue.main.async(execute: {
                        if let data = imgData {
                            cell.memberImage.image = UIImage(data: data)
                        }
                    })
                }
            }
        }
        return cell
    }
    
    
}
