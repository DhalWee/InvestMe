//
//  ViewPostVC.swift
//  Tender.me
//
//  Created by baytoor on 1/14/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit
import Firebase

class ViewPostVC: UIViewController {
    
    @IBOutlet weak var profileIV: UIImageView!
    @IBOutlet weak var displayNameLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var positionLbl: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var denominationLbl: UILabel!
    @IBOutlet weak var costLbl: UILabel!
    @IBOutlet weak var incomeLbl: UILabel!
    @IBOutlet weak var tillTimeLbl: UILabel!
    
    var tenderUID: String?
    var tender: Tender?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        callBtn.isEnabled = false
        profileIV.layer.cornerRadius = profileIV.frame.width/2
        profileIV.layer.masksToBounds = true
        
        getPost {
            self.setInfo()
        }
    }
    
    func setInfo() {
        if let data = NSData(contentsOf: URL(string: (tender?.photoURL)!)!){
            profileIV.image = UIImage(data: data as Data)
        } else {
            profileIV.image = #imageLiteral(resourceName: "noPhoto")
        }
        displayNameLbl.text = tender?.displayName
        phoneNumberLbl.text = tender?.phoneNumber
        positionLbl.text = tender?.position
        denominationLbl.text = tender?.denomination
        costLbl.text = tender?.cost
        incomeLbl.text = tender?.income
        tillTimeLbl.text = tender?.tillTime
        
        callBtn.isEnabled = true
        
        displayNameLbl.backgroundColor = UIColor.white
        phoneNumberLbl.backgroundColor = UIColor.white
        positionLbl.backgroundColor = UIColor.white
        denominationLbl.backgroundColor = UIColor.white
        costLbl.backgroundColor = UIColor.white
        incomeLbl.backgroundColor = UIColor.white
        tillTimeLbl.backgroundColor = UIColor.white
    }
    
    func getPost(completion: (()->Void)!) {
        DataService.ds.refPosts.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key == self.tenderUID {
                        if let userData = snap.value as? Dictionary<String, Any> {
                            let uid = snap.key
                            self.tender = Tender.init(full: uid, userData)
                            
                        }
                    }
                }
            }
            completion()
        }
    }
    
    @IBAction func callBtnPressed(_ sender: Any){
        if let url = URL(string: "TEL://\(tender!.phoneNumber)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let urlString = "telprompt:\(tender!.phoneNumber)";
                let url = NSURL(fileURLWithPath: urlString);
                if UIApplication.shared.canOpenURL(url as URL) {
                    UIApplication.shared.openURL(url as URL)
                }
            }
        }
    }
    
    func noInternetConnectionError() {
        let refreshAlert = UIAlertController(title: "No internet connection", message: "Please check your internet connection", preferredStyle: .alert)
        refreshAlert.addAction(UIAlertAction(title: "Okay", style: .default))
        present(refreshAlert, animated: true, completion: nil)
    }
}
