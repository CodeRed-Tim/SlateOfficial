//
//  SettingsTableViewController.swift
//  SlateOfficial
//
//  Created by Timmy Van Cauwenberge on 12/3/20.
//

import UIKit
import ProgressHUD

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var tellAFriendButton: UIButton!
    @IBOutlet weak var termsAndConditionsButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        versionLabel.text = "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUserInfo()
    }
    
    //MARK: - TableView Delegates
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableViewBackgroundColor")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0.0 : 15.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
//        if indexPath.section == 0 && indexPath.row == 0 {
//            performSegue(withIdentifier: "settingsToEditProfile", sender: self)
//        }
    }
    
    //MARK: - IBActions
    @IBAction func tellAFriendButtonPressed(_ sender: Any) {
        //implement translation for message
        let text = NSLocalizedString("Hey! Lets chat on Slate ", comment: "") + " \(kAPPURL)"
//        "Hey! Lets chat on Slate \(kAPPURL)"
        let objectsToShare : [Any] = [text]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.setValue(NSLocalizedString("Hey! Lets chat on Slate ", comment: ""), forKey: "subject")
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func termsAndConditionsButtonPressed(_ sender: Any) {
        let urlComponents = URLComponents (string: "http://www.slateofficial.com/terms.html")!
        UIApplication.shared.open (urlComponents.url!)
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        
        FirebaseUserListener.shared.logOutCurrentUser { (error) in
            if error == nil {
                
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        //implement translation
        let firstTitle = NSLocalizedString("Delete Account", comment: "")
        let message = NSLocalizedString("Are You Sure", comment: "")
        let secondTitle = NSLocalizedString("Delete", comment: "")
        
        let optionMenu = UIAlertController(title: firstTitle, message: message, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: secondTitle, style: .destructive) { (alert) in
            
            self.deleteUser()
            
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (alert) in
            
        }
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        // ipad bug fix (required for app store success
        // check if it an ipad
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            if let currentPopoverPresentationcontroller = optionMenu.popoverPresentationController {
                
                // changes option menu location
                currentPopoverPresentationcontroller.sourceView = deleteAccountButton
                currentPopoverPresentationcontroller.sourceRect = deleteAccountButton.bounds
                currentPopoverPresentationcontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            // if its an iphone
            self.present(optionMenu, animated: true, completion: nil)
        }
        // end bug fix
    }
    
    //MARK: - UpdateUI
    
    private func showUserInfo() {
        
        if let user = User.currentUser {
            fullNameLabel.text = user.fullName
            languageLabel.text = user.language
            
            if user.avatarLink != "" {
                //download and set avatar image
                FileStorage.downloadImage(imageUrl: user.avatarLink) { (avatarImage) in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
    //MARK: Delete User
    
    func deleteUser() {
        
        //delete locally
//        userDefaults.removeObject(forKey: kPUSHID)
        userDefaults.removeObject(forKey: kCURRENTUSER)
        //saves changes
        userDefaults.synchronize()
        
        //delete from firebase
        FirebaseReference(.User).document(User.currentId).delete()
        
        User.deleteUser { (error) in
            
            //when user is delete do this...
            if error != nil {
                
                //if we can't delete user
                DispatchQueue.main.async {
                    
                    ProgressHUD.showFailed("Couldn't delete user")
                }
                return
            }
            //user was deleted successfully
            let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
            
            DispatchQueue.main.async {
                loginView.modalPresentationStyle = .fullScreen
                self.present(loginView, animated: true, completion: nil)
            }
            
        }
        
    }
    
}
