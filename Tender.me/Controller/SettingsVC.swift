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
    
    @IBOutlet weak var verifyEmailBtn: UIButton!
    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var surNameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var isDriverSC: UISegmentedControl!
    @IBOutlet weak var mainView: UIScrollView!

    var imageUpdated = false
    var imagePicker: UIImagePickerController!
    
    var photoData: Data?
    var displayName: String?
    var phoneNumber: String?
    var info: String?
    var isDriver: Int?
    var isVerified: Bool?
    var email: String?
    var bottomConstraints: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        getInfoFromSegue()
//
//        isVerificationNeeded()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        nameField.delegate = self
        surNameField.delegate = self
        phoneNumberField.delegate = self
//        facultyField.delegate = self
//        courseField.delegate = self
        
        bgView.layer.cornerRadius = bgView.frame.width/2
        bgView.layer.opacity = 0.7
        
        isDriverSC.layer.cornerRadius = 0.0;
        isDriverSC.layer.borderColor = UIColor.white.cgColor
        isDriverSC.layer.borderWidth = 1.0
        isDriverSC.layer.masksToBounds = true
        
        profilePhotoView.layer.cornerRadius = profilePhotoView.frame.width/2
        profilePhotoView.layer.masksToBounds = true
        
        bottomConstraints = NSLayoutConstraint(item: mainView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraints!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @objc func handleKeyboardNotification(notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let isKeyboardShowing = notification.name == Notification.Name.UIKeyboardWillShow
            
            if mainView.layer.frame.height - keyboardFrame!.height < 420 {
                if isKeyboardShowing {
//                    bottomConstraints?.constant = +keyboardFrame!.height + (self.tabBarController?.tabBar.frame.size.height)!
                    mainView.bounces = true
                } else {
//                    bottomConstraints?.constant = -keyboardFrame!.height - (self.tabBarController?.tabBar.frame.size.height)!
                    mainView.bounces = false
                }
                UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadUser()
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
//            imageUpdated = true
//            profilePhotoView.image = resizeImage(image: image, targetSize: CGSize(width: 100, height: 100))
//        } else {
//            print("MSG: A valid image wasn't selected")
//        }
//        imagePicker.dismiss(animated: true, completion: nil)
//    }
    
//    func updateDisplayName(completionHandler: (() -> Void)!) {
//        let authUser = Auth.auth().currentUser
//        let changeRequest = authUser?.createProfileChangeRequest()
//        if let name = self.nameField.text, let surname = self.surNameField.text {
//            let newName = "\(name) \(surname)"
//            if newName != "" && newName != User.init().displayName {
//                changeRequest?.displayName = newName
//                changeRequest?.commitChanges { error in
//                    if error == nil {
//                        completionHandler()
//                    } else {
//                        self.alert(message: "Now it's not available to update profile name")
//                        completionHandler()
//                    }
//                }
//            } else {
//                completionHandler()
//            }
//        }
//    }
//
//    func updateImage(completionHandler: (() -> Void)!) {
//        let authUser = Auth.auth().currentUser
//        let changeRequest = authUser?.createProfileChangeRequest()
//            if let data = NSData(contentsOf: URL(string: User.init().photoURL)!){
//                if data as Data != UIImagePNGRepresentation(profilePhotoView.image!) {
//                    StorageServices.ss.uploadMedia(uid: User.init().uid, image: profilePhotoView.image!, completion:{ (url) in
//                        changeRequest?.photoURL = url
//                        changeRequest?.commitChanges { error in
//                            if error == nil {
//                                self.updateDisplayName(completionHandler: {
//                                    self.setProfileImage()
//                                    completionHandler()
//                                })
//                            } else {
//                                self.alert(message: "Now it's not available to update profile image")
//                            }
//                        }
//                })
//            } else {
//                self.updateDisplayName(completionHandler: {
//                    completionHandler()
//                })
//            }
//        }
//    }
//
//    func setProfileImage() {
//        DataService.ds.refPassangers.observe(.value, with: { (snapshot) in
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for snap in snapshot {
//                    if snap.key == User.init().uid {
//                        if let userData = snap.value as? Dictionary<String, Any> {
//                            if let _ = userData["photoURL"] {
//                                DataService.ds.refPassangers.child(snap.key).updateChildValues(["photoURL": "\(User.init().photoURL)"])
//                            }
//                        }
//                    }
//                }
//            }
//        })
//        DataService.ds.refDrivers.observe(.value, with: { (snapshot) in
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for snap in snapshot {
//                    if snap.key == User.init().uid {
//                        if let userData = snap.value as? Dictionary<String, Any> {
//                            if let _ = userData["photoURL"] {
//                                DataService.ds.refDrivers.child(snap.key).updateChildValues(["photoURL": "\(User.init().photoURL)"])
//                            }
//                        }
//                    }
//                }
//            }
//        })
//    }
//
//    func updateInfo() {
//        if self.phoneNumberField.text?.count==11  {
//            let index = phoneNumberField.text!.index(phoneNumberField.text!.startIndex, offsetBy: 2)
//            if String(self.phoneNumberField.text![..<index]) == "87" {
//                defaults.set(self.phoneNumberField.text, forKey: "phoneNumber")
//            }
//        }
//        if self.isDriverSC.selectedSegmentIndex != User.init().isDriver {
//            defaults.set(isDriverSC.selectedSegmentIndex, forKey: "isDriver")
//        }
//        if self.facultyField.text != "" && self.courseField.text != "" {
//            defaults.set("\(self.facultyField.text!),\(self.courseField.text!)", forKey: "info")
//        }
//    }
//
//    @IBAction func verifyEmailBtnPressed(_ sender: Any) {
//        sendEmailVerification()
//        alert(message: "Verification was send to \((Auth.auth().currentUser?.email)!)")
//    }
//
//    @IBAction func addImageBtnPressed(_ sender: Any) {
//        present(imagePicker, animated: true, completion: nil)
//    }
//
//    @IBAction func checkMaxLength() {
//        if (courseField.text?.count)! > 1 {
//            courseField.deleteBackward()
//        }
//        if (phoneNumberField.text?.count)! > 11 {
//            phoneNumberField.deleteBackward()
//        }
//    }
//
//    @IBAction func signOutBtnPressed(_ sender: Any) {
//        signOut()
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func doneBtnPressed(_ sender: Any) {
//        view.endEditing(true)
//        inProcess()
//        loadShows {
//            self.outProcess()
//            let user = User.init()
//            DataService.ds.createUser(user)
//            _ = self.navigationController?.popViewController(animated: true)
//        }
//    }
//
//    func loadShows(completionHandler: (() -> Void)!) {
//        updateImage {
//            completionHandler()
//        }
//        updateInfo()
//    }
//
//
//    func getInfoFromSegue() {
//        if photoData != nil {
//            profilePhotoView.image = UIImage(data: photoData!)
//        }
//        let ns = displayName?.components(separatedBy: " ")
//        if ns!.count > 1 {
//            nameField.text = ns?[0]
//            surNameField.text = ns?[1]
//        }
//        let information = info?.components(separatedBy: ",")
//        if information!.count > 1 {
//            facultyField.text = information?[0]
//            courseField.text = information?[1]
//        }
//        phoneNumberField.text = phoneNumber ?? ""
//        isDriverSC.selectedSegmentIndex = isDriver ?? 0
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        switch textField {
////            case nameField:
////                surNameField.becomeFirstResponder()
////                break
////            case surNameField:
////                phoneNumberField.becomeFirstResponder()
////                break
////            case phoneNumberField:
////                facultyField.becomeFirstResponder()
////                break
////            case facultyField:
////                courseField.becomeFirstResponder()
////                break
//            default:
//                textField.resignFirstResponder()
//            }
//        return true
//    }
//
//
//    func getInfo(){
//        let user = User.init()
//        if let data = NSData(contentsOf: URL(string: User.init().photoURL)!){
//            profilePhotoView.image = UIImage(data: data as Data)
//        }
//        profilePhotoView.layer.cornerRadius = profilePhotoView.frame.width/2
//        profilePhotoView.layer.masksToBounds = true
//
//        if user.displayName != ""{
//            let displayName = user.displayName.components(separatedBy: " ")
//            nameField.text = displayName[0]
//            surNameField.text = displayName[1]
//        } else {
//            nameField.placeholder = "Name"
//            surNameField.placeholder = "Surname"
//        }
//
//        if user.info != ""{
//            let info = user.info.components(separatedBy: ",")
//            facultyField.text = info[0]
//            courseField.text = info[1]
//        } else {
//            nameField.placeholder = "Name"
//            surNameField.placeholder = "Surname"
//        }
//        if user.phoneNumber != "" {
//            phoneNumberField.text = user.phoneNumber
//        } else {
//            phoneNumberField.placeholder = "87*******"
//        }
//        isDriverSC.selectedSegmentIndex = user.isDriver
//    }
//
//    func isVerificationNeeded() {
//        if User.init().isVerified == true {
//            verifyEmailBtn.isEnabled = false
//            verifyEmailBtn.isHidden = true
//            verifyEmailBtn.setTitle("Email verified", for: .normal)
//            verifyEmailBtn.layer.opacity = 0.5
//        } else {
//            verifyEmailBtn.layer.opacity = 1
//            verifyEmailBtn.isEnabled = true
//            verifyEmailBtn.setTitle("Send verification", for: .normal)
//        }
//    }
//
//    func inProcess() {
//        let uiBusy = UIActivityIndicatorView(activityIndicatorStyle: .white)
//        uiBusy.hidesWhenStopped = true
//        uiBusy.startAnimating()
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
//        view.layer.opacity = 0.5
//        view.isExclusiveTouch = false
//
//        nameField.isEnabled = false
//        surNameField.isEnabled = false
//        phoneNumberField.isEnabled = false
//        facultyField.isEnabled = false
//        courseField.isEnabled = false
//        verifyEmailBtn.isEnabled = false
//        isDriverSC.isEnabled = false
//        signOutBtn.isEnabled = false
//    }
//
//    func outProcess() {
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
//        view.layer.opacity = 1
//
//        nameField.isEnabled = true
//        surNameField.isEnabled = true
//        phoneNumberField.isEnabled = true
//        facultyField.isEnabled = true
//        courseField.isEnabled = true
//        verifyEmailBtn.isEnabled = true
//        isDriverSC.isEnabled = true
//        signOutBtn.isEnabled = true
//    }
//
//    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
//        let size = image.size
//
//        let widthRatio  = targetSize.width  / size.width
//        let heightRatio = targetSize.height / size.height
//
//        // Figure out what our orientation is, and use that to form the rectangle
//        var newSize: CGSize
//        if(widthRatio > heightRatio) {
//            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
//        } else {
//            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
//        }
//
//        // This is the rect that we've calculated out and this is what is actually used below
//        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
//
//        // Actually do the resizing to the rect using the ImageContext stuff
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
//        image.draw(in: rect)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return newImage!
//    }
//
//    func alert(message: String) {
//        let refreshAlert = UIAlertController(title: "SDU companion", message: message, preferredStyle: UIAlertControllerStyle.alert)
//        refreshAlert.addAction(UIAlertAction(title: "Okay", style: .cancel))
//        present(refreshAlert, animated: true, completion: nil)
//        view.endEditing(true)
//    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
