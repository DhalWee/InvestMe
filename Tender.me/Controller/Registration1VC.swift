//
//  RegistrationVC.swift
//  Tender.me
//
//  Created by baytoor on 1/9/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit

class Registration1VC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var surnameTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var barBtn: UIBarButtonItem!
    @IBOutlet weak var positionSC: UISegmentedControl!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var profileIV: UIImageView!
    @IBOutlet weak var choosePhotoIV: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        
        errorLbl.textColor = UIColor(hex: red)
        positionSC.tintColor = UIColor(hex: darkBlue)
        errorLbl.isHidden = true
        profileIV.layer.cornerRadius = profileIV.frame.width/2
        bgView.layer.cornerRadius = bgView.frame.width/2
        bgView.layer.opacity = 0.7
        choosePhotoIV.image = choosePhotoIV.image?.maskWithColor(color: UIColor(hex: white))
        nameTF.becomeFirstResponder()
        
        nameTF.delegate = self
        surnameTF.delegate = self
        phoneNumberTF.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileIV.image = image.resizeImage(targetSize: CGSize(width: 100, height: 100))
        } else {
            print("MSG: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageBtnPressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func nextBtnPressed() {
        if isFilled() {
            performSegue(withIdentifier: "Registration2VC", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination: Registration2VC = segue.destination as! Registration2VC
        destination.name = nameTF.text!
        destination.surname = surnameTF.text!
        destination.phoneNumber = phoneNumberTF.text!
        destination.position = positionSC.titleForSegment(at: positionSC.selectedSegmentIndex)
        destination.image = profileIV.image!
    }
    
    func isFilled() -> Bool {
        if nameTF.text == "" || nameTF.text == nil {
            errorDescription("Вы не заполнили поле \"Имя\"")
            return false
        } else if surnameTF.text == "" || surnameTF.text == nil {
            errorDescription("Вы не заполнили поле \"Фамилия\"")
            return false
        } else if phoneNumberTF.text == "" || phoneNumberTF.text == nil {
            errorDescription("Вы не заполнили поле \"Номер\"")
            return false
        } else if positionSC.isSelected == true {
            errorDescription("Вы не выбрали позицию")
            return false
        } else if profileIV.image == nil{
            errorDescription("Вы не выбрали фото для аккаунта")
            return false
        } else {
            noError()
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTF:
            surnameTF.becomeFirstResponder()
            break
        case surnameTF:
            phoneNumberTF.becomeFirstResponder()
            break
        case phoneNumberTF:
            nextBtnPressed()
            break
        default:
            nameTF.becomeFirstResponder()
        }
        return true
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
