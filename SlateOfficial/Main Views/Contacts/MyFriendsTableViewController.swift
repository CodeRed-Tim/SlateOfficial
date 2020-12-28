//
//  MyFriendsTableViewController.swift
//  SlateOfficial
//
//  Created by Timmy Van Cauwenberge on 12/14/20.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class MyFriendsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    //MARK: VAriables
    var allUsers: [User] = []
    var allUsersGrouped = NSDictionary() as! [String : [User]]
    var filteredUsers: [User] = []
    var sectionTitleList : [String] = []
    
    var isNumberNotFound = true
    var friendExists = false
    var isFriendAddedSuccessfully = false
    
    var currentFriendListIds = User.currentUser!.friendListIds
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CURRENT USER'S FRIENDS LIST::::::: \(User.currentUser?.friendListIds)")
        
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        tableView.tableFooterView = UIView()
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        //        createDummyUsers()
        loadFriends()
        setupButtons()
        setupSearchController()
        
        //show all users in database
//        downloadUsers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadFriends()
        tableView.reloadData()
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //MARK: IBActions
    
    @objc func addFriendButtonPressed() {
        print("addFriendButtonPressed")
        addFriend()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filteredUsers.count
        } else {
            //find section title
            let sectionTitle = self.sectionTitleList[section]
            
            // user for given title
            let users = self.allUsersGrouped[sectionTitle]
            
            return users!.count
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        } else {
            return allUsersGrouped.count
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyFriendsTableViewCell
        
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        
        cell.configure(user: user)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //MARK: - TableViewDelegates
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return ""
        } else {
            return sectionTitleList[section]
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        } else {
            return self.sectionTitleList
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        
        showUserProfile(user)
    }
    
    //MARK: DownloadUsers
    private func downloadUsers() {
        FirebaseUserListener.shared.downloadAllUsersFromFirebase { (allFirebaseUsers) in
            
            self.allUsers = allFirebaseUsers
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Add friends
    
    //    func addFriend() {
    //
    //        let alert = UIAlertController(title: NSLocalizedString("Add Friend", comment: ""), message: NSLocalizedString("Please enter phone number", comment: ""), preferredStyle: UIAlertController.Style.alert )
    //
    //        let add = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default) { (alertAction) in
    //            let textField = alert.textFields![0] as UITextField
    //            if textField.text != "" {
    //                self.checkPhoneNumberInDatabase(phoneNum: textField.text!)
    //            }
    //        }
    //
    //        alert.addTextField { (textField) in
    //
    //        }
    //
    //        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default) { (alertAction) in }
    //        alert.addAction(cancel)
    //        alert.addAction(add)
    //        self.present(alert, animated:true, completion: nil)
    //
    //    }
    
    func addFriend() {
        let alert = UIAlertController(title: "Add Friend", message: "Please enter phone number", preferredStyle: UIAlertController.Style.alert )
        
        let add = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if textField.text != "" {
                self.checkPhoneNumberInDatabase(phoneNum: textField.text!)
            }
        }
        
        alert.addTextField { (textField) in
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)
        alert.addAction(add)
        self.present(alert, animated:true, completion: nil)
    }
    
    func checkPhoneNumberInDatabase(phoneNum: String) {
        
        ProgressHUD.load()
        
        var query: Query!
        query = FirebaseReference(.User).order(by: "firstName", descending: false)
        
        // snapshot = each users data
        query.getDocuments { (snapshot, error) in
            
            self.allUsers = []
            self.allUsersGrouped = [:]
            
            if error != nil {
                print(error!.localizedDescription)
                
                ProgressHUD.showFailed("\(error!.localizedDescription)")
                
                self.tableView.reloadData()
                return
            }
            
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss()
                return
            }
            
            // if we have data then present it
            if !snapshot.isEmpty {
                
                for userDictionary in snapshot.documents {
                    
                    let userDictionary = userDictionary.data() as NSDictionary
                    
                    
                    // create an instance of the user's contacts in an array
//                    let user = try? document.data(as: User.self)
                    
                    let user = User(_dictionary: userDictionary)
                    
                    
                    // check to make sure the current user in the contacts
                    // is not the same as the current user logged in
                    if user.id != User.currentId {
                        if user.phoneNumber == phoneNum {
                            print("number added....")
                            self.isNumberNotFound = false
                            
                            if self.currentFriendListIds.contains(user.id) {
                                self.friendExists = true
                            } else {
                                self.currentFriendListIds.append(user.id)
                                self.isFriendAddedSuccessfully = true
                                FirebaseUserListener.shared.updateUserInFirebase(user)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            if self.isNumberNotFound {
                ProgressHUD.dismiss()
                self.numberNotFoundAlert()
                self.isNumberNotFound = true
                
            } else if self.friendExists {
                ProgressHUD.dismiss()
                self.friendAlreadyExistsAlert()
                self.friendExists = false
                self.isNumberNotFound = true
                
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.loadFriends()
                    ProgressHUD.dismiss()
                    if self.isFriendAddedSuccessfully {
                        self.friendAddedSuccessfullyAlert()
                        self.isFriendAddedSuccessfully = false
                    }
                }
            }
        }
    }
    
    func numberNotFoundAlert() {
        
        let alert = UIAlertController(title: "Not Found", message: "Phone Number not found.", preferredStyle: UIAlertController.Style.alert )
        
        let Ok = UIAlertAction(title: "Ok", style: .default) { (alertAction) in }
        alert.addAction(Ok)
        self.present(alert, animated:true, completion: nil)
    }
    
    func friendAlreadyExistsAlert() {
        
        let alert = UIAlertController(title: "Contact exists", message: "This contact number already exists.", preferredStyle: UIAlertController.Style.alert )
        
        let Ok = UIAlertAction(title: "Ok", style: .default) { (alertAction) in }
        alert.addAction(Ok)
        self.present(alert, animated:true, completion: nil)
    }
    
    func friendAddedSuccessfullyAlert() {
        
        let alert = UIAlertController(title: "Success!", message: "Contact Added Successfully.", preferredStyle: UIAlertController.Style.alert )
        
        let Ok = UIAlertAction(title: "Ok", style: .default) { (alertAction) in }
        alert.addAction(Ok)
        self.present(alert, animated:true, completion: nil)

    }

    
    func loadFriends() {
        
        if User.currentUser!.friendListIds.count > 0 {
            if User.currentUser!.friendListIds.count > 0 {
                
                ProgressHUD.load()
                
                FirebaseUserListener.shared.downloadUsersFromFirebase(withIds: User.currentUser!.friendListIds) { (allFriendUsers) in
                    
                    ProgressHUD.dismiss()
                    
                    self.allUsers = allFriendUsers
                    
                    self.splitDataIntoSections()
                    self.tableView.reloadData()
                    
                }
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
        }
        
    }
    
    //MARK: Search Controller
    private func setupSearchController() {
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder  = "Search user"
        searchController.searchResultsUpdater = self
        
        definesPresentationContext = true
    }
    
    private func filteredContentForSearchText(searchText: String) {
        
        filteredUsers = allUsers.filter({ (user) -> Bool in
            return user.fullName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    //MARK: Helper Functions
    
    fileprivate func splitDataIntoSections() {
        
        var sectionTitle: String = ""
        self.sectionTitleList.removeAll()
        self.allUsersGrouped.removeAll()
        //loop through all users
        for i in 0..<self.allUsers.count {
            
            let currentUser = self.allUsers[i]
            
            //get first character of user's name
            let firstChar = currentUser.firstName.first!
            
            let firstCharString = "\(firstChar)"
            
            sectionTitle = firstCharString
            if !sectionTitleList.contains(firstCharString) {
                
                self.allUsersGrouped[sectionTitle] = []
                
                self.sectionTitleList.append(sectionTitle)
                let array = self.sectionTitleList.sorted(by: <)
                self.sectionTitleList = array
            }
            
            self.allUsersGrouped[sectionTitle]?.append(currentUser)
        }
    }
    
    func setupButtons() {
        
//        let inviteButton = UIBarButtonItem(image: UIImage(named: "invite"), style: .plain, target: self, action: #selector(self.inviteButtonPressed))
        
//        self.navigationItem.rightBarButtonItems = [inviteButton]
        
        let addFriendButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(self.addFriendButtonPressed))
        
        self.navigationItem.leftBarButtonItems = [addFriendButton]
    }
    
    //MARK: Scroll view
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if self.refreshControl!.isRefreshing {
            self.downloadUsers()
            self.refreshControl!.endRefreshing()
        }
    }

    //MARK: - Navigation
    private func showUserProfile(_ user: User) {
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileView") as! ProfileTableViewController
        
        profileView.user = user
        self.navigationController?.pushViewController(profileView, animated: true)
        
    }
    
}

//extension MyFriendsTableViewController: UISearchResultsUpdating {
//
//    func updateSearchResults(for searchController: UISearchController) {
//
//        filteredContentForSearchText(searchText: searchController.searchBar.text!)
//
//    }
//}
