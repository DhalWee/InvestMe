//
//  AccountVC.swift
//  Tender.me
//
//  Created by baytoor on 1/11/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit

class AccountVC: UIViewController {
    
    @IBOutlet weak var profileIV: UIImageView!
    @IBOutlet weak var displayNameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var positionLbl: UILabel!
    @IBOutlet weak var barBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        profileIV.layer.cornerRadius = profileIV.frame.width/2
        profileIV.layer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUserInfo()
    }
    
    func setUserInfo() {
        let user = User.init()
        
        if let data = NSData(contentsOf: user.photoUrl) {
            profileIV.image = UIImage(data: data as Data)
        } else {
            self.profileIV.image = #imageLiteral(resourceName: "noPhoto")
        }
        
        displayNameLbl.text = user.displayName
        emailLbl.text = user.email
        phoneNumberLbl.text = user.phoneNumber
        positionLbl.text = user.position
        
        displayNameLbl.backgroundColor = UIColor.white
        phoneNumberLbl.backgroundColor = UIColor.white
        positionLbl.backgroundColor = UIColor.white
        emailLbl.backgroundColor = UIColor.white
        profileIV.backgroundColor = UIColor.white
        
    }
    
    @IBAction func settingsBtnPressed(_ sender: Any){
        performSegue(withIdentifier: "SettingsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SettingsVC
        destination.displayName = displayNameLbl.text
        destination.phoneNumber = phoneNumberLbl.text
        destination.position = positionLbl.text
        destination.photoData = UIImagePNGRepresentation(profileIV.image!)
    }

}
