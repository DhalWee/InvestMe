//
//  User.swift
//  SocialApp
//
//  Created by baytoor on 11/25/17.
//  Copyright © 2017 unicorn. All rights reserved.
//

//let uid = user.uid
//let email = user.email
//let photoURL = user.photoURL
//let name = user.displayName
//let phoneNumber = user.phoneNumber

import Foundation
import Firebase
import SwiftKeychainWrapper

class Tender {

    private var _uid: String
    private var _displayName: String
    private var _email: String
    private var _photoURL: String
    private var _phoneNumber: String
    private var _position: String
    
    private var _denomination: String
    private var _cost: String
    private var _income: String
    private var _tillTime: String

    var uid: String {
        return _uid
    }
    var displayName: String {
        return _displayName
    }
    var email: String {
        return _email
    }
    var photoURL: String {
        return _photoURL
    }
    var phoneNumber: String {
        return _phoneNumber
    }
    var position: String {
        return _position
    }
    var denomination: String {
        return _denomination
    }
    var cost: String {
        return _cost
    }
    var income: String {
        return _income
    }
    var tillTime: String {
        return _tillTime
    }
    
    init(full uid: String, _ userData: Dictionary<String, Any>) {
        self._uid = uid
        if let displayName = userData["displayName"] as? String {
            self._displayName = displayName
        } else {
            self._displayName = ""
        }
        if let email = userData["email"] as? String {
            self._email = email
        } else {
            self._email = ""
        }
        if let phoneNumber = userData["phoneNumber"] as? String {
            self._phoneNumber = phoneNumber
        } else {
            self._phoneNumber = ""
        }
        if let photoURL = userData["photoURL"] as? String {
            self._photoURL = photoURL
        } else {
            self._photoURL = "https://firebasestorage.googleapis.com/v0/b/socialapp-242da.appspot.com/o/noPhoto.png?alt=media&token=47ff2717-8c38-4347-8b68-dc166ac9130a"
        }
        if let position = userData["position"] as? String {
            self._position = position
        } else {
            self._position = ""
        }
        if let denomination = userData["denomination"] as? String {
            self._denomination = denomination
        } else {
            self._denomination = ""
        }
        if let cost = userData["cost"] as? String {
            self._cost = cost
        } else {
            self._cost = ""
        }
        if let income = userData["income"] as? String {
            self._income = income
        } else {
            self._income = ""
        }
        if let tillTime = userData["tillTime"] as? String {
            self._tillTime = tillTime
        } else {
            self._tillTime = ""
        }
    }
    
    init(forСell uid: String, _ userData: Dictionary<String, Any>) {
        self._uid = uid
        if let displayName = userData["displayName"] as? String {
            self._displayName = displayName
        } else {
            self._displayName = ""
        }
        self._email = ""
        self._phoneNumber = ""
        self._photoURL = "https://firebasestorage.googleapis.com/v0/b/socialapp-242da.appspot.com/o/noPhoto.png?alt=media&token=47ff2717-8c38-4347-8b68-dc166ac9130a"
        self._position = ""
        if let denomination = userData["denomination"] as? String {
            self._denomination = denomination
        } else {
            self._denomination = ""
        }
        if let cost = userData["cost"] as? String {
            self._cost = cost
        } else {
            self._cost = ""
        }
        if let income = userData["income"] as? String {
            self._income = income
        } else {
            self._income = ""
        }
        if let tillTime = userData["tillTime"] as? String {
            self._tillTime = tillTime
        } else {
            self._tillTime = ""
        }
    }



}


