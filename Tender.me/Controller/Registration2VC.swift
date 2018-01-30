//
//  Registration2.swift
//  Tender.me
//
//  Created by baytoor on 1/9/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class Registration2VC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var retryPassTF: UITextField!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var barBtn: UIBarButtonItem!
    
    var isVerified: Bool = false
    var name: String?
    var surname: String?
    var phoneNumber: String?
    var position: String?
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        isVerified = false
        barBtn.title = "Готово"
        errorLbl.isHidden = true
        emailTF.becomeFirstResponder()
        
        emailTF.delegate = self
        passTF.delegate = self
        retryPassTF.delegate = self
        
    }
    
    func isFilled() -> Bool {
        if emailTF.text == "" || emailTF.text == nil {
            errorDescription("Вы не заполнили поле \"Почта\"")
            return false
        } else if passTF.text == "" || passTF.text == nil {
            errorDescription("Вы не заполнили поле \"Пароль\"")
            return false
        } else if retryPassTF.text == "" || retryPassTF.text == nil {
            errorDescription("Вы не заполнили поле \"Пароль\"")
            return false
        } else {
            return true
        }
    }
    
    func isSamePwd() -> Bool {
        if passTF.text == retryPassTF.text {
            return true
        } else {
            errorDescription("Пароли не совподают")
            return false
        }
    }

    @IBAction func loginBtnPressed() {
        view.endEditing(true)
        if !isVerified {
            if isFilled() && isSamePwd() {
                registerting()
            }
        } else {
            completeSignIn(uid: (Auth.auth().currentUser?.uid)!)
            performSegue(withIdentifier: "MainPageVC", sender: nil)
        }
    }

    func registerting() {
        Auth.auth().createUser(withEmail: emailTF.text!, password: passTF.text!) { (user, error) in
            if error != nil {
                self.errorDescription(handlingFirebaseError(AuthErrorCode(rawValue: (error?._code)!)))
                print("MSG: Unable to authenticate with firebase using email")
            } else {
                print("MSG: New user was created using email")
                self.setDisplayName(complition: {
                    self.setProfileImage(complition: {
                        //Setting new user to firebase database
                        let user = Auth.auth().currentUser
                        let info: [String: String] = [
                            "phoneNumber": self.phoneNumber!,
                            "position": self.position!,
                            "displayName": (user!.displayName)!,
                            "photoUrl": "\(String(describing: user!.photoURL!))",
                            "email": (user!.email)!
                        ]
                        DataService.ds.createUser(info)
                        defaults.set(self.position, forKey: "position")
                        defaults.set(self.phoneNumber, forKey: "phoneNumber")
                        self.newUser()
                    })
                })
            }
        }
    }
    
    func completeSignIn(uid: String) {
        let saveSuccessful: Bool = KeychainWrapper.standard.set(uid, forKey: keyUID)
        if saveSuccessful {
            print("MSG: Data saved to keychain")
        }
    }
    
    func newUser() {
        sendEmailVerification()
        let verifyAlert = UIAlertController(title: "Подтверждение почты", message: "Вам на почту было отправлено письмо с кодом подтверждения. Пройдите по присланной ссылке и войдите в учетную запись.", preferredStyle: .alert)
        verifyAlert.addAction(UIAlertAction(title: "Понятно", style: .default, handler: { (alert) in
            while true {
                //Cheking if user verified email or not
                reloadUser()
                if (Auth.auth().currentUser?.isEmailVerified)! {
                    self.barBtn.title = "Войти"
                    self.view.alpha = 1
                    self.isVerified = true
                    self.wasVerified()
                    break
                }
                sleep(2)
            }
        }))
        self.barBtn.title = ""
        view.alpha = 0.5
        errorDescription("После подтверждения почты, приложение закончит регистарцию")
        present(verifyAlert, animated: true, completion: nil)
    }
    
    func setDisplayName(complition: (()->Void)! ){
        let user = Auth.auth().currentUser
        let changeRequest = user?.createProfileChangeRequest()
        if let name = name, let surname = surname {
            let fullName = "\(name) \(surname)"
            changeRequest?.displayName = fullName
            changeRequest?.commitChanges { error in
                if error != nil {
                    self.errorDescription("Не известная ошибка, повторите позже")
                } else {
                    complition()
                }
            }
        } else {
            errorDescription("Не известная ошибка, повторите позже")
        }
    }
    
    func setProfileImage(complition: (()->Void)! ) {
        let user = Auth.auth().currentUser
        let changeRequest = user?.createProfileChangeRequest()
        StorageServices.ss.uploadMedia(uid: (user?.uid)!, image: image!) { (url) in
            changeRequest?.photoURL = url
            changeRequest?.commitChanges(completion: { (error) in
                if error != nil {
                    //handling errors
                    self.errorDescription("Не известная ошибка, повторите позже")
                } else {
                    //photo was updated
                    complition()
                }
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTF:
            passTF.becomeFirstResponder()
            break
        case passTF:
            retryPassTF.becomeFirstResponder()
            break
        case retryPassTF:
            loginBtnPressed()
            break
        default:
            emailTF.becomeFirstResponder()
        }
        return true
    }
    
    func errorDescription (_ message: String) {
        errorLbl.text = message
        errorLbl.textColor = UIColor(hex: red)
        errorLbl.isHidden = false
    }
    
    func noError() {
        errorLbl.text = ""
        errorLbl.isHidden = true
    }
    
    func wasVerified() {
        errorLbl.text = "Ваша почта была подтверждена"
        errorLbl.textColor = UIColor(hex: green)
        errorLbl.isHidden = false
    }

}
