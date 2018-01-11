//
//  LoginVC.swift
//  Tender.me
//
//  Created by baytoor on 1/9/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var barBtn: UIBarButtonItem!
    @IBOutlet weak var errorLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLbl.textColor = UIColor(hex: red)
        resetBtn.tintColor = UIColor(hex: darkBlue)
        errorLbl.isHidden = true
        emailTF.becomeFirstResponder()
        
        emailTF.delegate = self
        passTF.delegate = self
    }
    
    @IBAction func loginBtnPressed() {
        view.endEditing(true)
        if isFilled(){
            disable()
            Auth.auth().signIn(withEmail: emailTF.text!, password: passTF.text!) { (user, error) in
                if error != nil {
                    self.enable()
                    self.errorDescription(handlingFirebaseError(AuthErrorCode(rawValue: (error?._code)!)))
                } else {
                    setUserDefaults(complition: {
                        self.isVerified(complition: {
                            self.completeSignIn(uid: (user?.uid)!)
                        })
                    })
                    print("MSG: User authenticated with firebase using email")
                    
                }
            }
        }
    }
    
    func isVerified(complition: (()->Void)!) {
        if (Auth.auth().currentUser?.isEmailVerified)! {
            complition()
        } else {
            let verifyAlert = UIAlertController(title: "Подтверждение почты", message: "Вы не подтвердили почту при регистрации, для продолжения работы вам необходимо подтвердить почту", preferredStyle: .alert)
            verifyAlert.addAction(UIAlertAction(title: "Отправить", style: .default, handler: { (alert) in
                self.enable()
                sendEmailVerification()
            }))
            verifyAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { (alert) in
                self.enable()

            }))
            present(verifyAlert, animated: true, completion: nil)
        }
    }
    
    func completeSignIn(uid: String) {
        let saveSuccessful: Bool = KeychainWrapper.standard.set(uid, forKey: keyUID)
        if saveSuccessful {
            print("MSG: Data saved to keychain")
        }
        enable()
        performSegue(withIdentifier: "MainPageVC", sender: nil)
    }
    
    @IBAction func resetPasswordBtnPressed() {
        let resetAlert = UIAlertController(title: "Забыли пароль?", message: "Введите вашу электронную почту, которую вы указали при регистрации ", preferredStyle: .alert)
        resetAlert.addTextField { (tf) in
            tf.placeholder = "Почта"
            tf.text = ""
        }
        resetAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        resetAlert.addAction(UIAlertAction(title: "Восстановить пароль", style: .default, handler: { (action) in
            Auth.auth().sendPasswordReset(withEmail: resetAlert.textFields![0].text!, completion: { (error) in
                if error != nil {
                    self.errorDescription(handlingFirebaseError(AuthErrorCode(rawValue: (error?._code)!)))
                    print("MSG: Password reset error")
                } else {
                    print("MSG: Password reset message was sent")
                }
            })
        }))
        present(resetAlert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTF:
            passTF.becomeFirstResponder()
            break
        case passTF:
            loginBtnPressed()
            passTF.resignFirstResponder()
            break
        default:
            emailTF.becomeFirstResponder()
        }
        return true
    }
    
    func isFilled() -> Bool {
        if emailTF.text == "" || emailTF.text == nil {
            errorDescription("Вы не заполнили поле \"Почта\"")
            return false
        } else if passTF.text == "" || passTF.text == nil {
            errorDescription("Вы не заполнили поле \"Пароль\"")
            return false
        } else {
            return true
        }
    }
    
    func errorDescription (_ message: String) {
        errorLbl.text = message
        errorLbl.isHidden = false
    }
    
    func noError() {
        errorLbl.text = ""
        errorLbl.isHidden = true
    }
    
    func enable() {
        self.barBtn.title = "Войти"
        view.alpha = 1
        emailTF.isEnabled = true
        passTF.isEnabled = true
        resetBtn.isEnabled = true
        barBtn.isEnabled = true
    }
    
    func disable() {
        self.barBtn.title = ""
        view.alpha = 0.5
        emailTF.isEnabled = false
        passTF.isEnabled = false
        resetBtn.isEnabled = false
        barBtn.isEnabled = false
    }
}

