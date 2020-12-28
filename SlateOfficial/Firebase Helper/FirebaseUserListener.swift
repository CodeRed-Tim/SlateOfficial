//
//  FirebaseUserListener.swift
//  SlateOfficial
//
//  Created by Timmy Van Cauwenberge on 12/1/20.
//

import Foundation
import Firebase

class FirebaseUserListener {
    
    static let shared = FirebaseUserListener()
        
    private init () {}
    
    //MARK: - Login
    func loginUserWithEmail(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            
            if error == nil {
                
                FirebaseUserListener.shared.downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                
                completion(error)
            } else {
                print("email is not verified")
                completion(error)
            }
        }
    }
    
    //MARK: - Register
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            
            completion(error)
            
            if error == nil {
                
                //send verification email
//                authDataResult!.user.sendEmailVerification { (error) in
//                    print("auth email sent with error: ", error?.localizedDescription)
//                }
                
                //create user and save it
                if authDataResult?.user != nil {

                    
                    let user = User(_id: authDataResult!.user.uid, _email: email, _firstname: "", _lastname: "", _avatarLink: "", _phoneNumber: "", _language: "", _languageCode: "", _pushId: "", _blockedUsers: [], _friendsListIds: [])
                    
                    User.saveUserLocally(user)
                    self.saveUserToFireStore(user)
                }
            }
        }
    }
    
    //MARK: - Resend link methods
    func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().currentUser?.reload(completion: { (error) in
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                completion(error)
            })
        })
    }

    
    func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        
        do {
            try Auth.auth().signOut()
            
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
        
    }
    
    //MARK: - Save users
    func saveUserToFireStore(_ user: User) {
        
        do {
            try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, "adding user")
        }
    }

    //MARK: - Download
    
    func downloadUserFromFirebase(userId: String, email: String? = nil) {
        
        FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
            
            guard let document = querySnapshot else {
                print("no document for user")
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    User.saveUserLocally(user)
                } else {
                    print(" Document does not exist")
                }
            case .failure(let error):
                print("Error decoding user ", error)
            }
        }
    }

    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers: [User]) -> Void ) {
        
        var users: [User] = []
        
        FirebaseReference(.User).limit(to: 500).getDocuments { (querySnapshot, error) in
            
            guard let document = querySnapshot?.documents else {
                print("no documents in all users")
                return
            }
            
            let allUsers = document.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            
            for user in allUsers {
                
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            completion(users)
        }
    }

    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ usersArray: [User]) -> Void) {
        
        var count = 0
        var usersArray: [User] = []
        
        //go through each user and download it from firestore
        for userId in withIds {
            
            FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else {  return }
                
                if snapshot.exists {
                    
                    let user = User(_dictionary: snapshot.data()! as NSDictionary)
                    count += 1
                    
                    //dont add if its current user
                    if user.id != User.currentId {
                        usersArray.append(user)
                    }
                    
                } else {
                    completion(usersArray)
                }
                
                if count == withIds.count {
                    //we have finished, return the array
                    completion(usersArray)
                }
                
            }
            
        }
    }
    
    //MARK: - Update
    
    func updateUserInFirebase(_ user: User) {
        
        do {
            let _ = try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, "updating user...")
        }
    }
    
    func updateCurrentUserInFirestore(withValues : [String : Any], completion: @escaping (_ error: Error?) -> Void) {
        
        if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
            
            var tempWithValues = withValues
            
            let currentUserId = User.currentId
            
//            let updatedAt = dateFormatter().string(from: Date())
//
//            tempWithValues[kUPDATEDAT] = updatedAt
            
            let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
            
            userObject.setValuesForKeys(tempWithValues)
            
            FirebaseReference(.User).document(currentUserId).updateData(withValues) { (error) in
                
                if error != nil {
                    
                    completion(error)
                    return
                }
                
                //update current user
                UserDefaults.standard.setValue(userObject, forKeyPath: kCURRENTUSER)
                UserDefaults.standard.synchronize()
                
                completion(error)
            }
            
        }
    }
    
//    func getUsersFromFirestore(withIds: [String], completion: @escaping (_ usersArray: [User]) -> Void) {
//
//        var count = 0
//        var usersArray: [User] = []
//
//        //go through each user and download it from firestore
//        for userId in withIds {
//
//            FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
//
//                guard let snapshot = snapshot else {  return }
//
//                if snapshot.exists {
//
//                    let user = User(_dictionary: snapshot.data()! as NSDictionary)
//                    count += 1
//
//                    //dont add if its current user
//                    if user.id != User.currentId() {
//                        usersArray.append(user)
//                    }
//
//                } else {
//                    completion(usersArray)
//                }
//
//                if count == withIds.count {
//                    //we have finished, return the array
//                    completion(usersArray)
//                }
//
//            }
//
//        }
//    }

    
}
