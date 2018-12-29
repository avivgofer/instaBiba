//
//  chatViewController.swift
//  instaBiba
//
//  Created by    aviv gofer on 27/12/2018.
//  Copyright © 2018 aviv gofer. All rights reserved.
//

import UIKit
import Firebase
//
class chatViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    var hisUser:User?
    var allMessages = [Message]()
   
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var newMessageFiled: UITextField!
    override func viewDidLoad() {
         self.hideKeyboardWhenTappedAround()
        super.viewDidLoad()
//        self.myTableView.separatorStyle = .singleLine
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.titleLabel.text = cutEmailName(email: (hisUser?.email)!)
        loadChat()
    }
    
    func loadChat(){
      //  hisNameLabel.text = cutEmailName(email: (hisUser?.email)!) 
        Model.instance.getAllChat(user:hisUser!){(result) -> () in
            self.allMessages.removeAll()
            for mes in result{
                self.allMessages.append(mes)
            }
            self.allMessages.sort(by: { $0.date.compare($1.date) == .orderedAscending })
            self.myTableView.reloadData()
        }
    }
    
    @IBAction func returnButtonClicked(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func sendButtonClicked(_ sender: Any) {
        if newMessageFiled.text != ""
        {
            var myProfileImageUrl = ""
            Model.instance.getProfileImageUrlByEmailName(emailName: cutEmailName(email: (Auth.auth().currentUser?.email)!)){ (email) in
                myProfileImageUrl = email
                let newMessage = Message(_userEmailName:self.cutEmailName(email: (Auth.auth().currentUser?.email)!), _userProfileImageUrl:myProfileImageUrl, _message: self.newMessageFiled.text!)
                
                Model.instance.addMessage(message: newMessage,user: self.hisUser!)
                self.newMessageFiled.text = ""
            }
            
           
        }
        
    }
    
    func circleImageView(image: UIImageView)
    {
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.black.cgColor
        //image.layer.cornerRadius = userProfileImage.frame.height/2
        image.clipsToBounds = true
    }
    
    func getTimeIntervalFromStringDate(string:String) -> TimeInterval{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = dateFormatter.date(from: string) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        return date.timeIntervalSinceNow
    }
    
    func getTimestringFromTimeInterval(interval:TimeInterval) -> String {
        let ti = NSInteger(interval)
        let seconds = Int((ti % 60) * (-1))
        let minutes = Int(((ti / 60) % 60) * (-1))
        let hours = Int(((ti / 3600)) * (-1))
        if(hours >= 24){
            return String(hours / 24)+"d"
        }else if(hours >= 1){
            return String(hours)+"h"
        }else if(minutes >= 1){
            return String(minutes)+"m"
        }else{
            return String(seconds)+" sec"
        }
    }
    
    func cutEmailName(email:String) -> String{
        let emailName = email.split(separator: "@")[0].split(separator: ".")[0]
        return emailName != "" ? (String(emailName)) : "noNameEmail"
    }
    
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return (allMessages.count)
            //return 0
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! chatTableViewCell
    
            if tableView == self.myTableView {
                let tempMes = allMessages[indexPath.row]
                if tempMes.userEmailName == cutEmailName(email:(self.hisUser?.email)!){
                    Model.instance.downloadImage(url: URL(string:tempMes.userProfileImageUrl)!){(image) in
                        //cell.profileImage.image = image
                        cell.hisProfileImage.image = image
                    }
                    cell.hisTimeLabel.text = self.getTimestringFromTimeInterval(interval: self.getTimeIntervalFromStringDate(string: tempMes.date))
                    cell.messageLabel.textAlignment = .left
                    cell.messageLabel.text = tempMes.message
                  //  cell.hisNameLabel.text = tempMes.userEmailName
                }else{
                    Model.instance.downloadImage(url: URL(string:tempMes.userProfileImageUrl)!){(image) in
                        //cell.profileImage.image = image
                        cell.myProfileImage.image = image
                    }
                    cell.myTimeLabel.text = self.getTimestringFromTimeInterval(interval: self.getTimeIntervalFromStringDate(string: tempMes.date))
                   // cell.myTimeLabel.text = tempMes.date
                    cell.messageLabel.textAlignment = .right
                    cell.messageLabel.text = tempMes.message
                   // cell.myNameLabel.text = tempMes.userEmailName
                }
            }
    
            return cell
        }
}
