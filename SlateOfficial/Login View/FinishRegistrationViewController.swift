//
//  FinishRegistrationViewController.swift
//  SlateOfficial
//
//  Created by Timmy Van Cauwenberge on 12/3/20.
//

import UIKit
import ActionSheetPicker_3_0
import Gallery
import ProgressHUD

class FinishRegistrationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, GalleryControllerDelegate  {
    
    @IBOutlet weak var finishRegistrationLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var selectProfilePictureLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    @IBOutlet weak var languagePicker: UIPickerView!
    
    var startIndex: Int?
    var gallery: GalleryController!
    
    var languageList: [String] = [String]()
    //    var languageList = [NSLocalizedString("Arabic", comment: ""), NSLocalizedString("Standard Chinese (Mandarin)", comment: ""), NSLocalizedString("English", comment: ""), NSLocalizedString("French", comment: ""), NSLocalizedString("German", comment: ""),  NSLocalizedString("Hindi", comment: ""), NSLocalizedString("Italian", comment: ""), NSLocalizedString("Japanese", comment: ""), NSLocalizedString("Korean", comment: ""),  NSLocalizedString("Portuguese", comment: ""),  NSLocalizedString("Russian", comment: ""), NSLocalizedString("Spanish", comment: "")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        phoneNumberTextField.keyboardType = .numberPad
        setUpTextFieldDelegates()
        setupBackgroundTap()
        setUpImage()
        
        
        // Do any additional setup after loading the view.
        languagePicker.delegate = self
        languagePicker.dataSource = self
        
        languageList = ["Arabic", "Standard Chinese (Mandarin)", "English", "French", "German", "Hindi", "Italian", "Japanese", "Korean", "Portuguese", "Russian", "Spanish"]
        
        
        startIndex = languageList.count / 2
        
        languagePicker.selectRow(startIndex!, inComponent: 0, animated: true)
    }
    
    //MARK: Picker menu functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languageList[row]
    }
    // change text color
    //    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    //        return NSAttributedString(string: languageList[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    //    }
    //
    
    
    //MARK: - IBActions
    @IBAction func finsihRegistrationButtonPressed(_ sender: Any) {
        
        let fullName = firstNameTextField.text! + " " + lastNameTextField.text!
        let languageIndex = languagePicker.selectedRow(inComponent: 0)
        let languageCode = languageCodeSelect(langIndex: languageIndex)
        let language = languageSelect(langIndex: languageIndex)
        
        if firstNameTextField.text != "" && lastNameTextField.text != "" && phoneNumberTextField.text != "" {
            
            if validatePhone(value: phoneNumberTextField.text!) == true {
                
                
                if var user = User.currentUser {
                    user.firstName = firstNameTextField.text!
                    user.lastName = lastNameTextField.text!
                    user.phoneNumber = phoneNumberTextField.text!
                    user.fullName = fullName
                    user.languageCode = languageCode
                    user.language = language
                    
                    User.saveUserLocally(user)
                    FirebaseUserListener.shared.updateUserInFirebase(user)
                    FirebaseUserListener.shared.saveUserToFireStore(user)
                }
                
                goToApp()
                
            } else {
                ProgressHUD.showFailed("Please enter a valid phone number!") //localize
            }
            
        } else {
            
            ProgressHUD.showFailed("All Fields Required!") //localize
        }
        
    }
    
    private func setUpImage() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        avatarImageView.addGestureRecognizer(tapGesture)
        avatarImageView.isUserInteractionEnabled = true
    }
    
    @objc func imageTapped() {
        
        showImageGallery()
        
    }
    
    @IBAction func avatarImageTapped(_ sender: Any) {
        
        //        showImageGallery()
        //
    }
    
    
    //MARK: Set Up & Animations
    
    private func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap() {
        view.endEditing(false)
    }
    
    private func setUpTextFieldDelegates() {
        firstNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updatePlaceholderLabels(textField: textField)
    }
    
    private func updatePlaceholderLabels(textField: UITextField) {
        
        switch textField {
        
        case firstNameTextField:
            firstNameLabel.text = textField.hasText ? "First Name" : "" //localize
        
        case lastNameTextField:
            lastNameLabel.text = textField.hasText ? "Last Name" : "" //localize
        
        default:
            phoneNumberLabel.text = textField.hasText ? "Phone Number" : "" //localize
        }
    }
    
    //MARK: - Validation
    func validatePhone(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}\\d{3}\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with: value)
        return result
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
    
    func languageCodeSelect(langIndex: Int) -> String {
        
        //        ["Arabic", "Bengali", "Chinese", "Dutch", "English", "French", "German", "Haitian", "Hindi", "Italian", "Japenese", "Korean", "Malay", "Porteguese", "Romanian", "Russian", "Spanish"]
        
        var langIndex = langIndex
        //
        langIndex = languagePicker.selectedRow(inComponent: 0)
        
        var languageValue = ""
        
        if langIndex == 0 {
            //arabic
            languageValue = "ar"
        } else if langIndex == 1 {
            //chinese
            languageValue = "zh"
        } else if langIndex == 2 {
            //english
            languageValue = "en"
        } else if langIndex == 3 {
            //french
            languageValue = "fr"
        } else if langIndex == 4 {
            //german
            languageValue = "de"
        } else if langIndex == 5 {
            //hindi
            languageValue = "hi"
        } else if langIndex == 6 {
            //italian
            languageValue = "it"
        } else if langIndex == 7 {
            //japense
            languageValue = "ja"
        } else if langIndex == 8 {
            //korean
            languageValue = "ko"
        } else if langIndex == 9 {
            //porteguese
            languageValue = "pt"
        } else if langIndex == 10 {
            //russian
            languageValue = "ru"
        } else if langIndex == 11 {
            //spanish
            languageValue = "es"
        }
        
        print("Language Code is....... " + languageValue)
        return languageValue
    }
    
    func languageSelect(langIndex: Int) -> String {
        
        //        ["Arabic", "Bengali", "Chinese", "Dutch", "English", "French", "German", "Haitian", "Hindi", "Italian", "Japenese", "Korean", "Malay", "Porteguese", "Romanian", "Russian", "Spanish"]
        
        var langIndex = langIndex
        //
        langIndex = languagePicker.selectedRow(inComponent: 0)
        
        var language = ""
        
        if langIndex == 0 {
            //arabic
            language = "Arabic"
        } else if langIndex == 1 {
            //chinese
            language = "Chinese"
        } else if langIndex == 2 {
            //english
            language = "English"
        } else if langIndex == 3 {
            //french
            language = "French"
        } else if langIndex == 4 {
            //german
            language = "German"
        } else if langIndex == 5 {
            //hindi
            language = "Hindi"
        } else if langIndex == 6 {
            //italian
            language = "Italian"
        } else if langIndex == 7 {
            //japense
            language = "Japanese"
        } else if langIndex == 8 {
            //korean
            language = "Korean"
        } else if langIndex == 9 {
            //porteguese
            language = "Portuguese"
        } else if langIndex == 10 {
            //russian
            language = "Russian"
        } else if langIndex == 11 {
            //spanish
            language = "Spanish"
        }
        
        print("Language is....... " + language)
        return language
    }
    
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
    
    //MARK: - Navigation
    private func goToApp() {
        
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
        
    }
}
