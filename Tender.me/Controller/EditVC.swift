//
//  EditVC.swift
//  Tender.me
//
//  Created by baytoor on 1/29/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit

class EditVC: UIViewController {
    
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var denominationTF: UITextField!
    @IBOutlet weak var costTF: UITextField!
    @IBOutlet weak var incomeTF: UITextField!
    @IBOutlet weak var date: UIDatePicker!
    
    var tender: Tender?

    override func viewDidLoad() {
        super.viewDidLoad()
        setInfo()
        errorLbl.isHidden = true
    }
    
    func setInfo() {
        denominationTF.text = tender?.denomination
        costTF.text = tender?.cost
        incomeTF.text = tender?.income
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateFromString = dateFormatter.date(from: (tender?.tillTime)!)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: dateFromString)
        let finalDate = calendar.date(from:components)
        date.date = finalDate!
        
    }
    
    @IBAction func saveBtnPressed() {
        if isFilled() {
            DataService.ds.refPosts.child((tender?.uid)!).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    self.errorDescription("Невозможно обновить, повторите попытку позже")
                } else {
                    DataService.ds.createPost(User.init(), Post.init(denomination: self.denominationTF.text!, cost: self.costTF.text!, income: self.incomeTF.text!, tillTime: self.date.date))
                    _ = self.navigationController?.popViewController(animated: true)
                    print("MSG: Tender was modified")
                }
            })
        }
    }
    
    @IBAction func deleteBtnPressed() {
        DataService.ds.refPosts.child((tender?.uid)!).removeValue(completionBlock: { (error, ref) in
            if error != nil {
                self.errorDescription("Невозможно обновить, повторите попытку позже")
            } else {
                _ = self.navigationController?.popViewController(animated: true)
                print("MSG: Tender was deleted")
            }
        })
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
    
    func errorDescription (_ message: String) {
        errorLbl.text = message
        errorLbl.isHidden = false
    }
    
    func noError() {
        errorLbl.text = ""
        errorLbl.isHidden = true
    }
    
}
