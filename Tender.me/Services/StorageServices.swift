//
//  StorageServices.swift
//  SocialApp
//
//  Created by baytoor on 11/27/17.
//  Copyright © 2017 unicorn. All rights reserved.
//

import Foundation
import Firebase

class StorageServices {
    static let ss = StorageServices()

    private var _refProfilePhoto = storage.child("profilePhoto")
    
    var refProfilePhoto: StorageReference {
        return _refProfilePhoto
    }

    func uploadMedia(uid: String, image: UIImage, completion: @escaping (_ url: URL?) -> Void) {
        let refImage = refProfilePhoto.child("\(uid).jpg")
        if let uploadData = UIImagePNGRepresentation(image) {
            refImage.putData(uploadData, metadata: nil) { (storageMetadata, error) in
                if error != nil {
                    print("MSG: Uploading error")
                    completion(nil)
                } else {
                    print("MSG: Uploading completed")
                    completion(storageMetadata?.downloadURL()?.absoluteURL)
                }
            }
        }
    }

}


