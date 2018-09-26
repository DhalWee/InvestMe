//
//  ViewController.swift
//  Tender.me
//
//  Created by baytoor on 1/9/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import UIKit

extension Int {
    func square() -> Int {
        return self*self
    }
}

class LaunchVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    @IBAction func loginBtnPressed() {
        performSegue(withIdentifier: "LoginVC", sender: nil)
    }
    
    @IBAction func regBtnPressed() {
        performSegue(withIdentifier: "Registration1VC", sender: nil)
    }
    
}

