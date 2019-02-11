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

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    var users = [User]()
    var filteredUsers = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //searchItem.delegate = self
        self.myTableView.separatorStyle = .none
       // myTableView.separatorStyle = .none
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movie"
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredUsers = users.filter({( user : User) -> Bool in
            return user.name.lowercased().contains(searchText.lowercased())
        })
        myTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredUsers.count
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "peopleViewController") as? peopleViewController
        {
            vc.user = self.users[indexPath[1]] 
            present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! TestTableViewCell
        if tableView == self.myTableView {
            let user: User
            if isFiltering() {
                user = filteredUsers[indexPath.row]
            } else {
                user = users[indexPath.row]
            }
            cell.watcherName.text = user.name
            Model.instance.downloadImage(url:URL(string: user.profileImgUrl)!){(profileImage) in
                cell.memberImage.image = profileImage
            }
        }
        return cell
    }
}

extension SearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

