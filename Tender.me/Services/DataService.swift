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
        let calendar = Calendar.current
        let year = calendar.component(.year, from: post.tillTime)
        let month = calendar.component(.month, from: post.tillTime)
        let day = calendar.component(.day, from: post.tillTime)
        let tillTime = "\(String(format: "%02d", day))-\(String(format: "%02d", month))-\(String(format: "%04d", year))"
        let info:[String: String] = [
            "phoneNumber": (user.phoneNumber),
            "position": (user.position),
            "displayName": (user.displayName),
            "photoUrl": "\(String(describing: user.photoUrl))",
            "email": (user.email),
            "denomination": (post.denomination),
            "cost": ("\(post.cost)"),
            "income": ("\(post.income)"),
            "tillTime": "\(tillTime)"
            // ₸
        ]
        refPosts.child("\(user.uid)&\(Date.init())").updateChildValues(info)
    }
    
    func deletePost(_ postUid: String) {
        refPosts.child(postUid).removeValue()
    }

    func createUser(_ info: [String: String]) {
        refUsers.child((Auth.auth().currentUser?.uid)!).updateChildValues(info)
    }
}

