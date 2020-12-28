//
//  ProfileTableViewController.swift
//  SlateOfficial
//
//  Created by Timmy Van Cauwenberge on 12/16/20.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    
    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var phoneNumLabel: UILabel!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    //MARK: - Variables
    var user: User?
    var isFriendRemovedSuccessfully = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        setupUI()
    }
    
    //MARK: Tableview Delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "TableViewBackgroundColor")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            print("Start Chatting")
            //TODO: Go to chatroom
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            print("Block User")
            //TODO: Block user
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            print("Delete User")
            //TODO: Delete user from friends list
        }
    }
    
    //MARK: IBActions
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
    }
    
    @IBAction func blockButtonPressed(_ sender: Any) {
        
        print("This is user \(user!.id) Profile")
        print("This is the current user: \(User.currentUser!.id)")
        
        var currentBlockedIds = User.currentUser!.blockedUsers
        
        if currentBlockedIds.contains(user!.id) {
            
            // find the index of the currently blocked user in the blockedUsers array
            currentBlockedIds.remove(at: currentBlockedIds.firstIndex(of: user!.id)!)
            
            
        } else {
            
            // or add them to the blocked array
            currentBlockedIds.append(user!.id)
            print("Current User, \(User.currentUser!.id), blocked Ids list: \(User.currentUser!.fullName)")
        }
        
        FirebaseUserListener.shared.updateUserInFirebase(user!)
        updateBlockStatus()
        //TODO: once messaging is created
//        blockUser(userToBlock: user!)
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
        var currentFriends = User.currentUser!.friendListIds
               
               if currentFriends.contains(user!.id) {
                   isFriendRemovedSuccessfully = true
                   currentFriends.remove(at: currentFriends.firstIndex(of: user!.id)!)
               }
        
        FirebaseUserListener.shared.updateUserInFirebase(user!)
        updateDeleteStatus()

    }
    
    
    
    
    //MARK: Set up UI
    private func setupUI() {
        if user != nil {
            self.title = user!.fullName
            fullNameLabel.text = user!.fullName
            languageLabel.text = user!.language
            phoneNumLabel.text = user!.phoneNumber
            
            if user!.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: user!.avatarLink) { (avatarImage) in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
    //MARK: Helpers
    
    func updateBlockStatus() {
        
        // if it is not the current user logged in
        if user!.id != User.currentId {
            blockButton.isHidden = false
            sendMessageButton.isHidden = false
        } else {
            blockButton.isHidden = true
            sendMessageButton.isHidden = true
        }
        
        // if the user is in the current user's array of blocked users
        if User.currentUser!.blockedUsers.contains(user!.id) {
            blockButton.setTitle(NSLocalizedString("Unblock User", comment: ""), for: .normal)
        } else {
            blockButton.setTitle(NSLocalizedString("Block This User", comment: ""), for: .normal)
        }
    }
    
    func updateDeleteStatus() {
        
        // if it is not the current user logged in
        if user!.id != User.currentId {
            deleteButton.isHidden = false
            sendMessageButton.isHidden = false
        } else {
            deleteButton.isHidden = true
            sendMessageButton.isHidden = true
        }
        
        // if the user is in the current user's array of blocked users
        if User.currentUser!.friendListIds.contains(user!.id) {
            deleteButton.setTitle(NSLocalizedString("Remove User", comment: ""), for: .normal)
        } else {
            deleteButton.setTitle(NSLocalizedString("Removed", comment: ""), for: .normal)
            deleteButton.setTitleColor(.lightGray, for: .normal)
            sendMessageButton.setTitleColor(.lightGray, for: .normal)
            blockButton.setTitleColor(.lightGray, for: .normal)
        }
    }

}
