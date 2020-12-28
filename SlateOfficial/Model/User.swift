//
//  User.swift
//  SlateOfficial
//
//  Created by Timmy Van Cauwenberge on 12/1/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


class User: Codable, Equatable {
    
    var id = ""
    var email = ""
    var firstName = ""
    var lastName = ""
    var fullName = ""
    var phoneNumber = ""
    var language = ""
    var languageCode = ""
    var pushId = ""
    var avatarLink = ""
    
    var blockedUsers: [String]
    var friendListIds: [String]
    
    //MARK: Initializers
    
    init(_id: String, _email: String, _firstname: String, _lastname: String, _avatarLink: String = "",  _phoneNumber: String, _language: String, _languageCode: String, _pushId: String, _blockedUsers: [String], _friendsListIds: [String]) {
        
        id = _id
        email = _email
        firstName = _firstname
        lastName = _lastname
        fullName = _firstname + " " + _lastname
        phoneNumber = _phoneNumber
        language = _language
        languageCode = _languageCode
        pushId = _pushId
        avatarLink = _avatarLink
        blockedUsers = []
        friendListIds = []
    }
    
    // save users in a dctionary
    
    init(_dictionary: NSDictionary) {
        
        id = _dictionary[kID] as! String
        pushId = (_dictionary[kPUSHID] as? String)!
        
        if let mail = _dictionary[kEMAIL] {
            email = mail as! String
        } else {
            email = ""
        }
        if let fname = _dictionary[kFIRSTNAME] {
            firstName = fname as! String
        } else {
            firstName = ""
        }
        if let lname = _dictionary[kLASTNAME] {
            lastName = lname as! String
        } else {
            lastName = ""
        }
        fullName = firstName + " " + lastName
        if let avat = _dictionary[kAVATARLINK] {
            avatarLink = avat as! String
        } else {
            avatarLink = ""
        }
        if let phoneNum = _dictionary[kPHONENUMBER] {
            phoneNumber = phoneNum as! String
        } else {
            phoneNumber = ""
        }
        if let block = _dictionary[kBLOCKEDUSERID] {
            blockedUsers = block as! [String]
        } else {
            blockedUsers = []
        }
        if let lang = _dictionary[kLANGUAGE] {
            language = lang as! String
        } else {
            language = ""
        }
        if let langC = _dictionary[kLANGUAGECODE] {
            languageCode = langC as! String
        } else {
            languageCode = ""
        }
        if let friends = _dictionary[kFRIENDSLISTIDS] {
            friendListIds = friends as! [String]
        } else {
            friendListIds = []
        }
    }
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                
                let decoder = JSONDecoder()
                
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch {
                    print("Error decoding user from user defaults ", error.localizedDescription)
                }
                
            }
        }
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    class func saveUserLocally(_ user: User) {
    
        //encde into a dictionary using JSONEncoder
        let encoder = JSONEncoder()
    
        do {
            let data = try encoder.encode(user)
            UserDefaults.standard.set(data, forKey: kCURRENTUSER)
        } catch {
            print("error saving user locally ", error.localizedDescription)
        }
    }
    
    //MARK: Delete user
    
    class func deleteUser(completion: @escaping (_ error: Error?) -> Void) {
        
        let user = Auth.auth().currentUser
        
        user?.delete(completion: { (error) in
            
            completion(error)
        })
        
    }

}

//struct User: Codable, Equatable {
//    // equatable compares two users to eachother
//
//    var id = ""
//    var email = ""
//    var firstName = ""
//    var lastName = ""
//    var fullName = ""
//    var phoneNumber = ""
//    var language = ""
//    var languageCode = ""
//    var pushId = ""
//    var avatarLink = ""
//
//    var blockedUsers: [String]
//    var friendListIds: [String]
//
//    static var currentId: String {
//        return Auth.auth().currentUser!.uid
//    }
//
//    static var currentUser: User? {
//        if Auth.auth().currentUser != nil {
//
//            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
//
//                let decoder = JSONDecoder()
//
//                do {
//                    let userObject = try decoder.decode(User.self, from: dictionary)
//                    return userObject
//                } catch {
//                    print("Error decoding user from user defaults ", error.localizedDescription)
//                }
//
//            }
//        }
//        return nil
//    }
//
//    static func == (lhs: User, rhs: User) -> Bool {
//        lhs.id == rhs.id
//    }
//
////    //save users in dictionary
////    init(_dictionary: NSDictionary) {
////
////    }
//
//}
//
//func saveUserLocally(_ user: User) {
//
//    //encde into a dictionary using JSONEncoder
//    let encoder = JSONEncoder()
//
//    do {
//        let data = try encoder.encode(user)
//        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
//    } catch {
//        print("error saving user locally ", error.localizedDescription)
//    }
//}
//
////MARK: Delete user
//
//func deleteUser(completion: @escaping (_ error: Error?) -> Void) {
//
//    let user = Auth.auth().currentUser
//
//    user?.delete(completion: { (error) in
//
//        completion(error)
//    })
//
//}
//
//func createDummyUsers() {
//    print("creating dummy users...")
//
//    let firstNames = ["Alison", "Inayah", "Alfie", "Rachelle", "Anya", "Juanita"]
//    let lastNames = ["Stamp", "Duggan", "Thornton", "Neale", "Gates", "Bate"]
//    let fullNames = ["Alison Stamp", "Inayah Duggan", "Alfie Thornton", "Rachelle Neale", "Anya Gates", "Juanita Bate"]
//    let phoneNums = ["111", "222", "333", "444", "555", "666"]
//
//    var imageIndex = 1
//    var userIndex = 1
//
//    for i in 0..<5 {
//
//        let id = UUID().uuidString
//
//        let fileDirectory = "Avatars/" + "_\(id)" + ".jpd"
//
//        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { (avatarLink) in
//
//            let user = User(id: id, email: "user\(userIndex)@mail.com", firstName: firstNames[i], lastName: lastNames[i], fullName: fullNames[i], phoneNumber: phoneNums[i], language: "Chinese", languageCode: "zh", pushId: "", avatarLink: avatarLink ?? "", blockedUsers: [], friendListIds: [])
//
//
//            userIndex += 1
//            FirebaseUserListener.shared.saveUserToFireStore(user)
//        }
//
//        imageIndex += 1
//        if imageIndex == 5 {
//            imageIndex = 1
//        }
//    }
//
//}
//
//
