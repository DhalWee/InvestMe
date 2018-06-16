//
//  MainViewVC.swift
//  Tender.me
//
//  Created by baytoor on 1/11/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class MainViewVC: UIViewController {

    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var popUp: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var denominationTF: UITextField!
    @IBOutlet weak var costTF: UITextField!
    @IBOutlet weak var incomeTF: UITextField!
    @IBOutlet weak var timeTillDP: UIDatePicker!
    @IBOutlet weak var errorLbl: UILabel!
    
    var tenders = [Tender]()
    var refreshControl: UIRefreshControl!
    var bottomConstraints: NSLayoutConstraint?
    var favList: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().updateCurrentUser(Auth.auth().currentUser!) { (error) in
            if error != nil {
                print("MSG: \(String(describing: error))")
            } else {
                self.refresh(sender: self)
            }
        }
        
        errorLbl.isHidden = true
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(sender: )), for: UIControlEvents.valueChanged)

        refresh(sender: self)
        closePopUp()
        view.backgroundColor = UIColor(hex: darkBlue)

        tableView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
        denominationTF.delegate = self
        costTF.delegate = self
        incomeTF.delegate = self
        
        //Constaints and keyboard notification for popUp
        bottomConstraints = NSLayoutConstraint(item: popUp, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraints!)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        positionFunc()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh(sender: self)
        positionFunc()
    }
    
    @objc func handleKeyboardNotification(notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let isKeyboardShowing = notification.name == Notification.Name.UIKeyboardWillShow

            if isKeyboardShowing {
                bottomConstraints?.constant = -keyboardFrame!.height + (self.tabBarController?.tabBar.frame.size.height)!
            } else {
                bottomConstraints?.constant = +keyboardFrame!.height - (self.tabBarController?.tabBar.frame.size.height)!
            }
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @objc func refresh(sender: AnyObject) {
        if !isInternetAvailable() {
            refreshControl.attributedTitle = NSAttributedString(string: "Проверьте соединение с интернетом")
            refreshControl.endRefreshing()
        } else {
            refreshControl.attributedTitle = NSAttributedString(string: "")
            updateList {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func addTenderBtnPressed(_ sender: Any){
        if isFilled() {
            DataService.ds.createPost(User.init(), Post.init(denomination: denominationTF.text!, cost: costTF.text!, income: incomeTF.text!, tillTime: timeTillDP.date))
            closePopUp()
            print("MSG: New tender was posted")
        }
    }

    func updateList(completion: (()->Void)!) {
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
    
    func getFavoriteList() {
        DataService.ds.refUsers.observeSingleEvent(of: .value) { (snapshot) in
            self.favList.removeAll()
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key == Auth.auth().currentUser?.uid {
                        if let userData = snap.value as? Dictionary<String, Any> {
                            if let favorites = userData["favorites"] as? Dictionary<String, Bool> {
                                for fav in favorites {
                                    self.favList.append(fav.key)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func isFilled() -> Bool {
        if denominationTF.text == "" || denominationTF.text == nil {
            errorDescription("Вы не заполнили поле \"Товар\"")
            return false
        } else if costTF.text == "" || costTF.text == nil {
            errorDescription("Вы не заполнили поле \"Сумма\"")
            return false
        } else if incomeTF.text == "" || incomeTF.text == nil {
            errorDescription("Вы не заполнили поле \"Маржа\"")
            return false
        } else if !isInternetAvailable() {
            errorDescription("Проверьте соединение с интернетом")
            return false
        } else {
            noError()
            return true
        }
    }
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        openPopUp()
    }
    
    @IBAction func closeBtnPressed(_ sender: UIButton) {
        closePopUp()
    }

    func openPopUp() {
        denominationTF.becomeFirstResponder()
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = false
        tableView.alpha = 0.5
        popUp.isHidden = false
        addBtn.isEnabled = false
    }

    func closePopUp() {
        self.view.endEditing(true)
        tableView.isScrollEnabled = true
        tableView.isUserInteractionEnabled = true
        tableView.alpha = 1
        popUp.isHidden = true
        addBtn.isEnabled = true
        denominationTF.text = ""
        costTF.text = ""
        incomeTF.text = ""
        timeTillDP.date = Date.init()
        noError()
    }
    
    func errorDescription (_ message: String) {
        errorLbl.text = message
        errorLbl.isHidden = false
    }
    
    func noError() {
        errorLbl.text = ""
        errorLbl.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination: ViewPostVC = segue.destination as! ViewPostVC
        let tenderUID = tenders[(tableView.indexPathForSelectedRow?.row)!].uid
        destination.tenderUID = tenderUID
        if favList.contains(tenderUID) {
            destination.isFav = true
        }
    }
    
    func noInternetConnectionError() {
        let refreshAlert = UIAlertController(title: "No internet connection", message: "Please check your internet connection", preferredStyle: .alert)
        refreshAlert.addAction(UIAlertAction(title: "Okay", style: .default))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func positionFunc() {
        if User.init().position == "Инвестор" {
            addBtn.isEnabled = false
            addBtn.tintColor = UIColor.clear
            self.tabBarController?.tabBar.items![1].image = #imageLiteral(resourceName: "emptyStarIcon")
            self.tabBarController?.tabBar.items![1].selectedImage = #imageLiteral(resourceName: "emptyStarIcon")
            getFavoriteList()
        } else {
            addBtn.isEnabled = true
            addBtn.tintColor = UIColor.white
            self.tabBarController?.tabBar.items![1].image = #imageLiteral(resourceName: "myListIcon")
            self.tabBarController?.tabBar.items![1].selectedImage = #imageLiteral(resourceName: "myListIcon")
        }
    }

    
}

//Delegate and DataSource functions
extension MainViewVC: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case denominationTF:
            costTF.becomeFirstResponder()
            break
        case costTF:
            incomeTF.becomeFirstResponder()
            break
        case incomeTF:
            timeTillDP.becomeFirstResponder()
            break
        default:
            textField.resignFirstResponder()
        }
        return true
    }

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
            self.performSegue(withIdentifier: "ViewPostVC", sender: self)
        } else {
            noInternetConnectionError()
        }
    }

}
