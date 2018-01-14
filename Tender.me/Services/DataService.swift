//
//  DataService.swift
//  SocialApp
//
//  Created by baytoor on 11/26/17.
//  Copyright © 2017 unicorn. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    static let ds = DataService()

    private var _refBase = dataBase
    private var _refPosts = dataBase.child("posts")
    private var _refUsers = dataBase.child("users")

    var refBase: DatabaseReference {
        return _refBase
    }
    var refPosts: DatabaseReference {
        return _refPosts
    }
    var refUsers: DatabaseReference {
        return _refUsers
    }

    func createPost(_ user: User, _ post: Post) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let info:[String: String] = [
            "phoneNumber": (user.phoneNumber),
            "position": (user.position),
            "displayName": (user.displayName),
            "photoUrl": "\(String(describing: user.photoUrl))",
            "email": (user.email),
            "denomination": (post.denomination),
            "cost": ("\(post.cost)"),
            "income": ("\(post.income)"),
            "tillTime": "\(post.tillTime)"
            // ₸
        ]
        refPosts.child("\(user.uid)&\(Date.init())").updateChildValues(info)
    }

    func createUser(_ info: [String: String]) {
        refUsers.child((Auth.auth().currentUser?.uid)!).updateChildValues(info)
    }
}

