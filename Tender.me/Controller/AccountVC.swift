//
//  AccountVC.swift
//  Tender.me
//
//  Created by baytoor on 1/11/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit

class AccountVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logout() {
        signOut()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FirstPageVC")
        self.show(vc!, sender: self)
    }

}
