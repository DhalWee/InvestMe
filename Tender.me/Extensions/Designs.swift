//
//  Designs.swift
//  SocialApp
//
//  Created by baytoor on 11/12/17.
//  Copyright © 2017 unicorn. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedBtn: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {setUpView()}
    }
    override func prepareForInterfaceBuilder() {
        setUpView()
    }
    func setUpView() {
        layer.cornerRadius = self.cornerRadius
    }
}

