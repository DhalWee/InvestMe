//
//  Globals.swift
//  SocialApp
//
//  Created by baytoor on 11/12/17.
//  Copyright © 2017 unicorn. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper
import SystemConfiguration

let white = 0xFAFAFA
let darkBlue = 0x4F515C
let lightBlue = 0x1DB4DD
let lightGray = 0xD1D1D1
let red = 0xEF7072
let green = 0x2ED07C

let dataBase = Database.database().reference()
let storage = Storage.storage().reference()

let keyUID = "tenderme"

let defaults = UserDefaults.standard

func setUserDefaults(complition: (()->Void)!) {
    DataService.ds.refUsers.observeSingleEvent(of: .value) { (snapshot) in
        if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
            for snap in snapshot {
                if snap.key == Auth.auth().currentUser?.uid {
                    if let userData = snap.value as? Dictionary<String, Any> {
                        if let phoneNumber = userData["phoneNumber"] {
                            defaults.set(phoneNumber, forKey: "phoneNumber")
                        } else {
                            defaults.set("", forKey: "phoneNumber")
                        }
                        if let position = userData["position"] {
                            defaults.set(position, forKey: "position")
                        } else {
                            defaults.set("", forKey: "position")
                        }
                        complition()
                    } else {
                        print("MSG: Can't get here 1")
                        complition()
                    }
                } else {
                    print("MSG: Can't get here 2")
                    complition()
                }
            }
        } else {
            print("MSG: Can't get here 3")
            complition()
        }
    }
}

func signOut() {
    KeychainWrapper.standard.removeObject(forKey: keyUID)
    try! Auth.auth().signOut()
    defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    print("MSG: Signed out")
}

func handlingFirebaseError (_ errorCode: AuthErrorCode?) -> String {
    if let errorCode = errorCode {
        switch errorCode {
        case .userNotFound:
            return "Аккаунт не cуществует"
        case .wrongPassword:
            return "Неправильный пароль"
        case .invalidEmail:
            return "Не корректная электронная почта"
        case .userDisabled:
            return "Аккаунт заблакирован"
        case .emailAlreadyInUse:
            return ("Почта уже используется")
        case .networkError:
            return ("Нет соединении с интернетом")
        case .weakPassword:
            return ("Слабый пароль")
        default:
            return ""
        }
    }
    return ""
}

func reloadUser() {
    Auth.auth().currentUser?.reload(completion: { (error) in
        if error != nil {
            print("MSG: Unable to reload user")
        } else {
            return
        }
    })
}

func sendEmailVerification() {
    if !(Auth.auth().currentUser?.isEmailVerified)! {
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            if error != nil {
                print("MSG: Enable to send verification message")
            } else {
                print("MSG: Verification letter was sent")
            }
        })
    }
}

func isInternetAvailable() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    return (isReachable && !needsConnection)
}











