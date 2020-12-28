//
//  EditProfileTableViewController.swift
//  SlateOfficial
//
//  Created by Timmy Van Cauwenberge on 12/3/20.
//

import UIKit
import ProgressHUD
import Gallery

class EditProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var editMessageLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //MARK: Variables
    
    var gallery: GalleryController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
//        configureTextField()
        
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
        
        return section == 0 ? 0.0 : 30.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - IBActions
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
        showImageGallery()
        
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if firstNameTextField.text != "" && lastNameTextField.text != "" {
            
            ProgressHUD.showProgress(0.5)
            
            //block save button
            saveButton.isEnabled = false
            
            let fullName = firstNameTextField.text! + " " + lastNameTextField.text!
            
            if var user = User.currentUser {
                user.firstName = firstNameTextField.text!
                user.lastName = lastNameTextField.text!
                user.fullName = fullName
                User.saveUserLocally(user)
                FirebaseUserListener.shared.saveUserToFireStore(user)
            }
            self.saveButton.isEnabled = true
            self.navigationController?.popViewController(animated: true)
            ProgressHUD.showSuccess("Saved!")
            
        } else {
            
            ProgressHUD.showFailed("All Fields Required!")
            
            
        }
    }
    
    
    //MARK: UpdateUI
    private func showUserInfo() {
        
        if var user = User.currentUser {
            firstNameTextField.text = user.firstName
            lastNameTextField.text = user.lastName
            user.fullName = user.firstName + " " + user.lastName
            
            if user.avatarLink != "" {
                //set avatar
                FileStorage.downloadImage(imageUrl: user.avatarLink) { (avatarImage) in
                    
                    self.avatarImageView.image = avatarImage?.circleMasked
                    
                }
            }
        }
    }
    
    //MARK: Gallery
    
    private func showImageGallery() {
        
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(gallery, animated: true, completion: nil)
        
    }
    
    //MARK: Upload Images
    private func uploadAvatarImage(_ image: UIImage) {
        
        let fileDirectory = "Avatars/" + "_\(User.currentId)" + ".jpg"
        
        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in
            
            if var user = User.currentUser {
                user.avatarLink = avatarLink ?? ""
                User.saveUserLocally(user)
                FirebaseUserListener.shared.saveUserToFireStore(user)
            }
            
            //save locally
            FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: User.currentId)
        }
    }
    
    
    
    //MARK: - COnfigure
//    private func configureTextField() {
//
//        firstNameTextField.delegate = self
//        lastNameTextField.delegate = self
//    }
    
}

extension EditProfileTableViewController : GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            
            images.first!.resolve { (avatarImage) in

                if avatarImage != nil {
                    
                    self.uploadAvatarImage(avatarImage!)
                    self.avatarImageView.image = avatarImage?.circleMasked
                } else {
                    ProgressHUD.showError("Couldn't select image!")
                }
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

//extension EditProfileTableViewController : UITextFieldDelegate {
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//
//        if textField == firstNameTextField {
//
//            if textField.text != "" {
//
//                if var user = User.currentUser {
//                    user.firstName = textField.text!
//                    saveUserLocally(user)
//                    FirebaseUserListener.shared.saveUserToFireStore(user)
//                }
//
//            }
//
//            textField.resignFirstResponder()
//            return false
//        } else if textField == lastNameTextField {
//
//            if textField.text != "" {
//
//                if var user = User.currentUser {
//                    user.lastName = textField.text!
//                    saveUserLocally(user)
//                    FirebaseUserListener.shared.saveUserToFireStore(user)
//                }
//
//            }
//            textField.resignFirstResponder()
//            return false
//
//        }
//        return true
//    }
//}
