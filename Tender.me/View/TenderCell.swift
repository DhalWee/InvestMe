//
//  PassengerCell.swift
//  SocialApp
//
//  Created by baytoor on 11/26/17.
//  Copyright © 2017 unicorn. All rights reserved.
//

import UIKit

class TenderCell: UITableViewCell {

    @IBOutlet weak var denomination: UILabel!
    @IBOutlet weak var tillTime: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var income: UILabel!
//    @IBOutlet weak var delBtn: UIButton!
    
    var tender: Tender?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        delBtn.setImage(delBtn.currentImage?.maskWithColor(color: UIColor(hex: red)), for: .normal)
//        delBtn.imageView?.contentMode = .scaleAspectFit
    }
    
//    @IBAction func delBtnPressed() {
//        DataService.ds.deletePost(<#String#>)
//    }
    
    func configureCell(tender: Tender) {
        denomination.text = tender.denomination
        tillTime.text = tender.tillTime
        cost.text = tender.cost
        income.text = tender.income
    }

}
