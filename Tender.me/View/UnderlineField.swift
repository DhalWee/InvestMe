//
//  UnderlineField.swift
//  SocialApp
//
//  Created by baytoor on 11/26/17.
//  Copyright © 2017 unicorn. All rights reserved.
//

import UIKit

class UnderlineField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let border = CALayer()
        let width = CGFloat(1.0)
        tintColor = UIColor(hex: darkBlue)
        border.borderColor = UIColor(hex: darkBlue).withAlphaComponent(1).cgColor
        border.frame = CGRect(x: 0, y: frame.size.height - width, width:  frame.size.width, height: frame.size.height)
        border.borderWidth = width
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
    }
    
}
