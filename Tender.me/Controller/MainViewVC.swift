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
    @IBOutlet weak var timeTillTF: UITextField!

    var tenders = [Tender]()
    var refreshControl: UIRefreshControl!
    var bottomConstraints: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        if !isInternetAvailable() {
            refreshControl.attributedTitle = NSAttributedString(string: "")
        } else {
            refreshControl.attributedTitle = NSAttributedString(string: "")
        }
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)

        refresh(sender: self)

        closePopUp()
        view.backgroundColor = UIColor(hex: darkBlue)

        tableView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
        denominationTF.delegate = self
        costTF.delegate = self
        incomeTF.delegate = self
        timeTillTF.delegate = self

        bottomConstraints = NSLayoutConstraint(item: popUp, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraints!)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: Notification.Name.UIKeyboardWillHide, object: nil)

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
            refreshControl.endRefreshing()
        } else {
            refreshControl.attributedTitle = NSAttributedString(string: "")
        }
        updateList {
            self.refreshControl.endRefreshing()
            if (Auth.auth().currentUser?.isEmailVerified)! {
                self.tableView.reloadData()
            } else {
            }
        }
    }

    @IBAction func addTenderBtnPressed(_ sender: Any){
        
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
            completion()
        }
    }

    @IBAction func addBtnPressed(_ sender: Any) {
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
        timeTillTF.text = ""
    }

    func errorAlert(message: String) {
        let refreshAlert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        refreshAlert.addAction(UIAlertAction(title: "Окей", style: .default))
        present(refreshAlert, animated: true, completion: nil)
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
            timeTillTF.becomeFirstResponder()
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
//        self.performSegue(withIdentifier: "PassengerVC", sender: self)
    }

}


















