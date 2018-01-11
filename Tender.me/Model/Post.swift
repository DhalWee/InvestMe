//
//  Post.swift
//  Tender.me
//
//  Created by baytoor on 1/11/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import Foundation

class Post {
    private var _denomination: String
    private var _cost: String
    private var _income: String
    private var _tillTime: Date

    var denomination: String {
        return _denomination
    }
    var cost: String {
        return _cost
    }
    var income: String {
        return _income
    }
    var tillTime: Date {
        return _tillTime
    }
    
    init(denomination: String, cost: String, income: String, tillTime: Date) {
        _denomination = denomination
        _cost = cost
        _income = income
        _tillTime = tillTime
    }
    
}
