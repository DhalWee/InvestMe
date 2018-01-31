//
//  SettingsVC.swift
//  SocialApp
//
//  Created by baytoor on 11/26/17.
//  Copyright © 2017 unicorn. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class SettingsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var surNameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var positionSC: UISegmentedControl!
    @IBOutlet weak var mainView: UIScrollView!

    var imageUpdated = false
    var imagePicker: UIImagePickerController!
    
    var photoData: Data?
    var displayName: String?
    var phoneNumber: String?
    var position: String?
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfoFromSegue()

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        nameField.delegate = self
        surNameField.delegate = self
        phoneNumberField.delegate = self
        
        bgView.layer.cornerRadius = bgView.frame.width/2
        bgView.layer.opacity = 0.7
        
        positionSC.layer.cornerRadius = 0.0;
        positionSC.layer.borderColor = UIColor.white.cgColor
        positionSC.layer.borderWidth = 1.0
        positionSC.layer.masksToBounds = true
        
        profilePhotoView.layer.cornerRadius = profilePhotoView.frame.width/2
        profilePhotoView.layer.masksToBounds = true
        
        noError()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageUpdated = true
            profilePhotoView.image = image.resizeImage(targetSize: CGSize(width: 100, height: 100))
        } else {
            print("MSG: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func updateDisplayName(completionHandler: (() -> Void)!) {
        let authUser = Auth.auth().currentUser
        let changeRequest = authUser?.createProfileChangeRequest()
        if let name = self.nameField.text, let surname = self.surNameField.text {
            let newName = "\(name) \(surname)"
            if newName != "" && newName != User.init().displayName {
                changeRequest?.displayName = newName
                changeRequest?.commitChanges { error in
                    if error == nil {
                        completionHandler()
                    } else {
                        self.errorDescription("Невозможно обновить данные, попробуйте позже")
                        completionHandler()
                    }
                }
            } else {
                completionHandler()
            }
        }
    }

    func updateImage(completionHandler: (() -> Void)!) {
        let authUser = Auth.auth().currentUser
        let changeRequest = authUser?.createProfileChangeRequest()
            if let data = NSData(contentsOf: User.init().photoUrl) {
                if data as Data != UIImagePNGRepresentation(profilePhotoView.image!) {
                    StorageServices.ss.uploadMedia(uid: User.init().uid, image: profilePhotoView.image!, completion:{ (url) in
                        changeRequest?.photoURL = url
                        changeRequest?.commitChanges { error in
                            if error == nil {
                                self.updateDisplayName(completionHandler: {
                                    completionHandler()
                                })
                            } else {
                                self.errorDescription("Невозможно обновить данные, попробуйте позже")
                            }
                        }
                })
            } else {
                self.updateDisplayName(completionHandler: {
                    completionHandler()
                })
            }
        }
    }

    func updatePosts() {
        DataService.ds.refPosts.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key.contains(User.init().uid) {
                        if let userData = snap.value as? Dictionary<String, Any> {
                            if let _ = userData["photoUrl"] {
                                DataService.ds.refPosts.child(snap.key).updateChildValues(["photoUrl": "\(User.init().photoUrl)"])
                            }
                            if let _ = userData["displayName"] {
                                DataService.ds.refPosts.child(snap.key).updateChildValues(["displayName": "\(User.init().displayName)"])
                            }
                            if let _ = userData["phoneNumber"] {
                                DataService.ds.refPosts.child(snap.key).updateChildValues(["phoneNumber": "\(User.init().phoneNumber)"])
                            }
                            if let _ = userData["email"] {
                                DataService.ds.refPosts.child(snap.key).updateChildValues(["email": "\(User.init().email)"])
                            }
                            if let _ = userData["position"] {
                                DataService.ds.refPosts.child(snap.key).updateChildValues(["position": "\(User.init().position)"])
                            }
                        }
                    }
                }
            }
        })
    }

    func updateInfo() {
        if self.phoneNumberField.text?.count == 11  {
            let index = phoneNumberField.text!.index(phoneNumberField.text!.startIndex, offsetBy: 2)
            if String(self.phoneNumberField.text![..<index]) == "87" {
                defaults.set(self.phoneNumberField.text, forKey: "phoneNumber")
            }
        }
        if positionSC.titleForSegment(at: positionSC.selectedSegmentIndex) != User.init().position {
            defaults.set(positionSC.titleForSegment(at: positionSC.selectedSegmentIndex), forKey: "position")
        }
    }

    @IBAction func addImageBtnPressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func logout() {
        signOut()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FirstPageVC")
        self.show(vc!, sender: self)
    }

    @IBAction func doneBtnPressed(_ sender: Any) {
        view.endEditing(true)
        noError()
        if isFilled() {
            inProcess()
            loadShows {
                self.outProcess()
                let user = User.init()
                let info: [String: String] = [
                    "phoneNumber": self.phoneNumberField.text!,
                    "position": self.positionSC.titleForSegment(at: self.positionSC.selectedSegmentIndex)!,
                    "displayName": (user.displayName),
                    "photoUrl": "\(String(describing: user.photoUrl))",
                    "email": (user.email)
                ]
                DataService.ds.createUser(info)
                self.updatePosts()
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        if User.init().position == "Инвестор" {
            self.tabBarController?.tabBar.items![1].image = #imageLiteral(resourceName: "emptyStarIcon")
            self.tabBarController?.tabBar.items![1].selectedImage = #imageLiteral(resourceName: "emptyStarIcon")
        } else {
            self.tabBarController?.tabBar.items![1].image = #imageLiteral(resourceName: "myListIcon")
            self.tabBarController?.tabBar.items![1].selectedImage = #imageLiteral(resourceName: "myListIcon")
        }
    }

    func loadShows(completionHandler: (() -> Void)!) {
        updateImage {
            completionHandler()
        }
        updateInfo()
    }


    func getInfoFromSegue() {
        if photoData != nil {
            profilePhotoView.image = UIImage(data: photoData!)
        }
        let ns = displayName?.components(separatedBy: " ")
        if ns!.count > 1 {
            nameField.text = ns?[0]
            surNameField.text = ns?[1]
        }
        phoneNumberField.text = phoneNumber ?? ""
        if position == "Тендерщик" {
            positionSC.selectedSegmentIndex = 0
        } else {
            positionSC.selectedSegmentIndex = 1
        }
    }

    func isFilled() -> Bool {
        if nameField.text == "" || nameField.text == nil {
            errorDescription("Вы не заполнили поле \"Имя\"")
            return false
        } else if surNameField.text == "" || surNameField.text == nil {
            errorDescription("Вы не заполнили поле \"Фамилия\"")
            return false
        } else if phoneNumberField.text == "" || phoneNumberField.text == nil {
            errorDescription("Вы не заполнили поле \"Номер\"")
            return false
        } else if positionSC.isSelected == true {
            errorDescription("Вы не выбрали позицию")
            return false
        } else if profilePhotoView.image == nil{
            errorDescription("Вы не выбрали фото для аккаунта")
            return false
        } else if !isInternetAvailable() {
            errorDescription("Проверьте соединение с интернетом")
            return false
        } else {
            noError()
            return true
        }
    }

    func inProcess() {
        let uiBusy = UIActivityIndicatorView(activityIndicatorStyle: .white)
        uiBusy.hidesWhenStopped = true
        uiBusy.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
        view.layer.opacity = 0.5
        view.isExclusiveTouch = false

        nameField.isEnabled = false
        surNameField.isEnabled = false
        phoneNumberField.isEnabled = false
        positionSC.isEnabled = false
        signOutBtn.isEnabled = false
    }

    func outProcess() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
        view.layer.opacity = 1

        nameField.isEnabled = true
        surNameField.isEnabled = true
        phoneNumberField.isEnabled = true
        positionSC.isEnabled = true
        signOutBtn.isEnabled = true
    }
    
    func errorDescription (_ message: String) {
        errorLbl.text = message
        errorLbl.isHidden = false
    }
    
    func noError() {
        errorLbl.text = ""
        errorLbl.isHidden = true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
