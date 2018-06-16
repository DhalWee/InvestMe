//
//  MyList.swift
//  Tender.me
//
//  Created by baytoor on 1/13/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import Firebase

class MyListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tenders = [Tender]()
    var refreshControl: UIRefreshControl!
    var list: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        
        refresh(sender: self)
        
        tableView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
        
        if Auth.auth().currentUser?.email == "tendermeapp@gmail.com" {
            self.navigationController?.navigationBar.topItem?.title = "Админ"
        } else {
            if User.init().position == "Инвестор" {
                self.navigationController?.navigationBar.topItem?.title = "Избранные"
            } else {
                self.navigationController?.navigationBar.topItem?.title = "Мои тендеры"
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh(sender: self)
        if Auth.auth().currentUser?.email == "tendermeapp@gmail.com" {
            self.navigationController?.navigationBar.topItem?.title = "Админ"
        } else {
            if User.init().position == "Инвестор" {
                self.navigationController?.navigationBar.topItem?.title = "Избранные"
            } else {
                self.navigationController?.navigationBar.topItem?.title = "Мои тендеры"
            }
        }
    }
    
    @objc func refresh(sender: AnyObject) {
        if !isInternetAvailable() {
            refreshControl.endRefreshing()
        } else {
            refreshControl.attributedTitle = NSAttributedString(string: "")
        }
        updatingCorrectList()
    }
    
    //Function for update Tender's list or favorite list for investor
    func updatingCorrectList() {
        if Auth.auth().currentUser?.email == "tendermeapp@gmail.com"{
            updateAdminList {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        } else {
            let user = User.init()
            if user.position == "Тендерщик" {
                updateMyList {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                }
            } else {
                getFavoriteList(completion: {
                    print("MSG: getting favorite list")
                    self.updateFavoriteList(completion: {
                        self.refreshControl.endRefreshing()
                        self.tableView.reloadData()
                    })
                })
            }
        }
    }
    
    func updateAdminList(completion: (()->Void)!) {
        DataService.ds.refPosts.observeSingleEvent(of: .value) { (snapshot) in
            self.tenders.removeAll()
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let userData = snap.value as? Dictionary<String, Any> {
                        let uid = snap.key
                        let tender = Tender.init(forСell: uid, userData)
                        self.tenders.append(tender)
                    }
                
                }
            }
            self.tenders.reverse()
            completion()
        }
    }
    
    func updateMyList(completion: (()->Void)!) {
        DataService.ds.refPosts.observeSingleEvent(of: .value) { (snapshot) in
            self.tenders.removeAll()
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if (snap.key.split(separator: "&"))[0].description == Auth.auth().currentUser?.uid {
                        if let userData = snap.value as? Dictionary<String, Any> {
                            let uid = snap.key
                            let tender = Tender.init(forСell: uid, userData)
                            self.tenders.append(tender)
                        }
                    }
                }
            }
            self.tenders.reverse()
            completion()
        }
    }
    
    func getFavoriteList(completion: (()->Void)!) {
        DataService.ds.refUsers.observeSingleEvent(of: .value) { (snapshot) in
            self.list.removeAll()
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key == Auth.auth().currentUser?.uid {
                        if let userData = snap.value as? Dictionary<String, Any> {
                            if let favorites = userData["favorites"] as? Dictionary<String, Bool> {
                                for fav in favorites {
                                    self.list.append(fav.key)
                                }
                            }
                        }
                    }
                }
            }
            completion()
        }
    }

    func updateFavoriteList(completion: (()->Void)!) {
        DataService.ds.refPosts.observeSingleEvent(of: .value) { (snapshot) in
            self.tenders.removeAll()
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if self.list.contains(snap.key) {
                        if let userData = snap.value as? Dictionary<String, Any> {
                            let uid = snap.key
                            let tender = Tender.init(forСell: uid, userData)
                            self.tenders.append(tender)
                        }
                    }
                }
            }
            self.tenders.reverse()
            completion()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if User.init().position == "Инвестор" {
            let destination: ViewPostVC = segue.destination as! ViewPostVC
            destination.tenderUID = tenders[(tableView.indexPathForSelectedRow?.row)!].uid
            destination.isFav = true
        } else {
            let destination: EditVC = segue.destination as! EditVC
            destination.tender = tenders[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
}

//Delegate and DataSource functions
extension MyListVC: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tenders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TenderCell") as? TenderCell {
            cell.configureCell(tender: tenders[indexPath.row])
            return cell
        }
        return TenderCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isInternetAvailable() {
            if User.init().position == "Инвестор" {
                self.performSegue(withIdentifier: "FavoriteVC", sender: self)
            } else {
                self.performSegue(withIdentifier: "EditVC", sender: self)
            }
        } else {
//            noInternetConnectionError()
        }
    }
    
}
