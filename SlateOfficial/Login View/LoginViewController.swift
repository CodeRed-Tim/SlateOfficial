//
//  ViewController.swift
//  SlateOfficial
//
//  Created by Timmy Van Cauwenberge on 11/24/20.
//

import UIKit
import ProgressHUD
import PasswordTextField
import Firebase

class LoginViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    //Labels
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    
    @IBOutlet weak var dontHaveAnAccountLabel: UILabel!
    
    //TextFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    //Buttons
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var resendEmailButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    //Views
    @IBOutlet weak var confirmPasswordLineView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    //MARK: - Variables
    var isLogin = true
    var user: User?
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUIFor(login: true)
        setUpTextFieldDelegates()
        setupBackgroundTap()
    }
    
    //MARK: - IBActions
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if isDataInputedFor(type: isLogin ? "login" : "register") {
            //login or register
            isLogin ? loginUser() : registerUser()
            
        } else {
            ProgressHUD.showFailed("All Fields are Required!") //localise
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        updateUIFor(login: (sender as AnyObject).titleLabel?.text == "Login")
        isLogin.toggle()
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: "password") {
            //reset password
            resetPassword()
        } else {
            ProgressHUD.showFailed("Email is Required!") //localis
        }
    }
    
    //    @IBAction func resendEmailButtonPressed(_ sender: Any) {
    //        if isDataInputedFor(type: "password") {
    //            //resend verification email
    //            resendVerificationEmail()
    //        } else {
    //            ProgressHUD.showFailed("Email is Required!") //localise
    //        }
    //    }
    
    @IBAction func termsButtonPressed(_ sender: Any) {
        
    }
    
    //MARK: - Setup
    private func setUpTextFieldDelegates() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updatePlaceholderLabels(textField: textField)
    }
    
    private func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap() {
        view.endEditing(false)
    }
    
    //MARK: - Animations
    
    private func updateUIFor(login: Bool) {
        
        //change button image
        loginButton.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        
        //change button label
        signUpButton.setTitle(login ? "Sign Up" : "Login", for: .normal)
        
        dontHaveAnAccountLabel.text = login ? "Don't have an account?" : "Have an account?"
        
        UIView.animate(withDuration: 0.5) {
            self.confirmPasswordTextField.isHidden = login
            self.confirmPasswordLabel.isHidden = login
            self.confirmPasswordLineView.isHidden = login
            
        }
    }
    
    private func updatePlaceholderLabels(textField: UITextField) {
        
        switch textField {
        
        case emailTextField:
            emailLabel.text = textField.hasText ? "Email" : "" //localize
        
        case passwordTextField:
            passwordLabel.text = textField.hasText ? "Password" : "" //localize
        
        default:
            confirmPasswordLabel.text = textField.hasText ? "Confirm Password" : "" //localize
        }
        
    }
    
    //MARK: - HELPERS
    
    private func isDataInputedFor(type: String) -> Bool {
        
        switch type {
        case "login":
            return emailTextField.text != "" && passwordTextField.text != ""
        case "registration":
            return emailTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != ""
        default:
            return emailTextField.text != ""
        }
    }
    
    private func loginUser() {
        
        var user: User?
        
        FirebaseUserListener.shared.loginUserWithEmail(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
        
            if error == nil {
                
//                if user?.firstName != "" {
                
                
                    self.goToApp()
                    
//                } else {
//                    self.goToFinishRegistration()
//                }
                
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
            
        }
        
    }
    
    private func registerUser() {
        
        if passwordTextField.text! == confirmPasswordTextField.text! {
            
            FirebaseUserListener.shared.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
                
                if error == nil {
                    //                    ProgressHUD.showSuccess("Verification Email Sent!") //localise
                    //                    self.resendEmailButton.isHidden = false
                    
                    self.goToFinishRegistration()
                } else {
                    ProgressHUD.showFailed(error!.localizedDescription)
                }
                
            }
            
        } else {
            ProgressHUD.showFailed("Passwords don't match!") // localise
        }
        
    }
    
    private func resetPassword() {
        FirebaseUserListener.shared.resetPasswordFor(email: emailTextField.text!) { (error) in
            
            if error == nil {
                ProgressHUD.showSuccess("Reset link sent to email!") //localise
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    //    private func resendVerificationEmail() {
    //        FirebaseUserListener.shared.resendVerificationEmail(email: emailTextField.text!) { (error) in
    //
    //            if error == nil {
    //                ProgressHUD.showSuccess("New verification email sent!") //localise
    //            } else {
    //                ProgressHUD.showFailed(error!.localizedDescription)
    //                print(error!.localizedDescription)
    //            }
    //        }
    //    }
    
    //MARK: - Navigation
    private func goToApp() {
        
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
        
    }
    
    private func goToFinishRegistration() {
        
        let finishRegView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "FinishRegistration")
        
        finishRegView.modalPresentationStyle = .fullScreen
        self.present(finishRegView, animated: true, completion: nil)
        
    }
    
    
    
    
    
}

