//
//  User.swift
//  Tender.me
//
//  Created by baytoor on 1/11/18.
//  Copyright © 2018 unicorn. All rights reserved.
//

import Foundation
import Firebase

class User {
    private var _uid: String
    private var _displayName: String
    private var _email: String
    private var _position: String
    private var _phoneNumber: String
    private var _photoUrl: URL
    
    var uid: String {
        return _uid
    }
    var displayName: String {
        return _displayName
    }
    var email: String {
        return _email
    }
    var position: String {
        return _position
    }
    var phoneNumber: String {
        return _phoneNumber
    }
    var photoUrl: URL {
        return _photoUrl
    }
    
    init() {
        let user = Auth.auth().currentUser
        if let position = defaults.string(forKey: "position")  {
            _position = position
        } else {
            _position = ""
        }
        if let phoneNumber = defaults.string(forKey: "phoneNumber")  {
            _phoneNumber = phoneNumber
        } else {
            _phoneNumber = ""
        }
        if let uid = user?.uid {
            _uid = uid
        } else {
            _uid = ""
        }
        if let displayName = user?.displayName{
            _displayName = displayName
        } else {
            _displayName = ""
        }
        if let email = user?.email{
            _email = email
        } else {
            _email = ""
        }
        if let photoUrl = user?.photoURL{
            _photoUrl = photoUrl
        } else {
            _photoUrl = URL(string: "https://firebasestorage.googleapis.com/v0/b/tenderme-99df0.appspot.com/o/noPhoto.png?alt=media&token=9d937e10-8d91-4e03-9ed6-afcb6d8270d7")!
        }
        
    }
    
}
