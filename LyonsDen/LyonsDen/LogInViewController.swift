//
//  LogInScreenController.swift
//  LyonsDen
//
//  Created by Tamir Arnesty on 2016-07-09.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import Foundation
import UIKit
import Firebase


// TODO: FIX LOGO WHEN TEXTFIELD PRESSED
// TODO: AUTO_LOGIN PERFORMS TWICE FROM TIME TO TIME< WHICH CAUSES A THROW BACK INTO HOME SCREEN, PUT AUTO_LOG IN A DIFFERENT PLACE

class LogInViewController: UIViewController, UITextFieldDelegate {
    // Input field for account email
    @IBOutlet var userNameField: UITextField!
    // Input field for account password
    @IBOutlet var passwordField: UITextField!
    // Segmented controller for Sign Up or Log In
    @IBOutlet var segmentedController: UISegmentedControl!
    // Input field for Sign Up Key
    @IBOutlet var signUpKeyField: UITextField!
    // The main view in ViewController
    @IBOutlet var mainView: UIView!
    // Lyon's Den Logo
    @IBOutlet weak var logo: UIImageView!
    // Input button to submit account
    @IBOutlet weak var logInButton: UIButton!
    
    var entranceOption:Int = 0
    var password = ""
    var username = ""
    var alert:LyonsAlert = LyonsAlert(withTitle: "", subtitle: "", style: .alert)
    var loadingWheel = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    @IBAction func optionSwitched(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // sign up
            entranceOption = 0
            print(entranceOption)
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.5, animations: {
                self.signUpKeyField.alpha = 1
                self.logInButton.frame.origin.y += self.signUpKeyField.frame.height/2
                self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    self.signUpKeyField.isHidden = false // textfield shows up
            })
        case 1: // log in
            entranceOption = 1
            print(entranceOption)
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, animations: {
                self.signUpKeyField.alpha = 0
                self.logInButton.frame.origin.y -= self.signUpKeyField.frame.height/2
                self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    self.signUpKeyField.isHidden = true // textfield disappears
            })
        default:
            break
        }
    }
    
    // Sets UITextField delegates and sets keyboard notifier
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let gradient: CAGradientLayer = CAGradientLayer()
        //gradient.frame = self.view.bounds
        //gradient.colors = [UIColor.white.cgColor, accentColor.cgColor]
        //self.view.layer.insertSublayer(gradient, at: 0)
        self.userNameField.delegate = self
        self.passwordField.delegate = self
        
        // To make screen move up, when editing the lower textfields
        // Code credit to: Dan Beaulieu at http://stackoverflow.com/a/32915049
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        // End of Dan's code
    }
    
    // Ends editing of UITextFields when touched anywhere in the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    // Removes firstResponder attribute to current UITextField when done editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.beginFloatingCursor(at: CGPoint(x: 0, y: 0))
    }
    
    func createNewUser (keys: [String]) {
        var alert = self.alert
        FIRAuth.auth()?.createUser(withEmail: self.username, password: self.password, completion: {(user, error) in
            if self.signUpKeyField.text == keys[1] { // TEACHER CHECK
                FIRDatabase.database().reference(withPath: "users").child("teacherIDs").childByAutoId().setValue(self.password) // adds a teachers password to the database for announcements proof
            }
            if error != nil {
                if let code = FIRAuthErrorCode(rawValue: error!._code) {
                    self.alert.stopAnimating()
                    switch code {
                    case .errorCodeEmailAlreadyInUse: // user exists
                        alert = LyonsAlert(withTitle: "Sorry!", subtitle: "This email is already in use. Please log in, or use another email to sign up.", style: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        alert.showIn(self)
                    case .errorCodeInvalidEmail: // self explanatory
                        alert = LyonsAlert(withTitle: "Invalid Email", subtitle: "Please make sure your email is typed in correctly.", style: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        alert.showIn(self)
                    case .errorCodeWeakPassword:
                        alert = LyonsAlert(withTitle: "Weak Password", subtitle: "Please come up with a more secure password.", style: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        alert.showIn(self)
                    default:
                        break
                    }
                }
            } else {
                if user != nil {
                    alert.stopAnimating()
                    //Log in succesfull
                    UserDefaults.standard.setValue(self.password, forKey: "Pass")   // Memorize the password for next login
                    UserDefaults.standard.setValue(self.username, forKey: "uID")    // Memorize the username for next login
                    if self.signUpKeyField.text == keys[1] {
                        self.performSegue(withIdentifier: "teacherFormSegue", sender: self)
                    } else {
                        self.performSegue(withIdentifier: "LogInSuccess", sender: self)
                    }
                }
            }
        }) // createUserWithEmail close
    }
    
    @IBAction func buttonPressed(_ sender: AnyObject) {
        var signUpKeys = ["", ""]
        
        self.password = passwordField.text!
        self.username = userNameField.text!
        alert.addLoadingWheel()
        alert.showIn(self)
        
        if (passwordField.text?.isEmpty)! || (userNameField.text?.isEmpty)! {
            alert = LyonsAlert(withTitle: "Missing Information", subtitle: "Please fill in all the requirements.", style: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.showIn(self)
            return
        }
        
        if entranceOption == 0 { // sign up
            let reference = FIRDatabase.database().reference(withPath: "java")
            reference.observeSingleEvent(of: .value, with: {(snapshot) in
                if snapshot.exists() {
                    let data = (snapshot.value as! NSDictionary).allValues as NSArray
                    signUpKeys[0] = (data.object(at: 0) as! String)
                    signUpKeys[1] = (data.object(at: 1) as! String)
                    if self.signUpKeyField.text == signUpKeys[0] || self.signUpKeyField.text == signUpKeys[1] {
                        self.createNewUser(keys: signUpKeys)
                    } else {
                        self.alert.stopAnimating()
                        self.alert = LyonsAlert(withTitle: "Incorrect Sign Up Key", subtitle: "Please try again. It is case sensitive.", style: .alert)
                        self.alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.alert.showIn(self)
                    } // close of else { if {
                }
            })
            //            if signUpKeyField.text == signUpKeys[0] || signUpKeyField.text == signUpKeys[1] {
            //                FIRAuth.auth()?.createUser(withEmail: self.username, password: self.password, completion: {(user, error) in
            //                    if self.signUpKeyField.text == signUpKeys[1] { // TEACHER CHECK
            //                        FIRDatabase.database().reference(withPath: "users").child("teacherIDs").childByAutoId().setValue(self.password) // adds a teachers password to the database for announcements proof
            //                    }
            //                    if error != nil {
            //                        if let code = FIRAuthErrorCode(rawValue: error!._code) {
            //                            switch code {
            //                            case .errorCodeEmailAlreadyInUse: // user exists
            //                                alert = LyonsAlert(withTitle: "Sorry!", subtitle: "This email is already in use. Please log in, or use another email to sign up.", style: .alert)
            //                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            //                                alert.showIn(self)
            //                            case .errorCodeInvalidEmail: // self explanatory
            //                                alert = LyonsAlert(withTitle: "Invalid Email", subtitle: "Please make sure your email is typed in correctly.", style: .alert)
            //                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            //                                alert.showIn(self)
            //                            default:
            //                                break
            //                            }
            //                        }
            //                    } else {
            //                        if user != nil {
            //                            //Log in succesfull
            //                            UserDefaults.standard.setValue(self.password, forKey: "Pass")   // Memorize the password for next login
            //                            UserDefaults.standard.setValue(self.username, forKey: "uID")    // Memorize the username for next login
            //                            self.performSegue(withIdentifier: "LogInSuccess", sender: self)
            //                        }
            //                    }
            //                }) // createUserWithEmail close
            //            } else {
            //                alert = LyonsAlert(withTitle: "Incorrect Sign Up Key", subtitle: "Please try again. It is case sensitive.", style: .alert)
            //                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            //                alert.showIn(self)
            //
            //            } // close of else { if {
        } else if entranceOption == 1 { // log in
            // Authentication
            FIRAuth.auth()?.signIn(withEmail: username, password: self.password) { (user, error) in
                if error != nil {
                    if let code = FIRAuthErrorCode(rawValue: error!._code) {
                        switch code {
                        case .errorCodeWrongPassword: // wrong password
                            self.alert = LyonsAlert(withTitle: "Invalid Password", subtitle: "The password you entered is incorrect. Please try again.", style: .alert)
                            self.alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.alert.showIn(self)
                        default:
                            break
                        }
                    }
                } else {
                    if user != nil {
                        //Log in succesfull
                        UserDefaults.standard.setValue(self.password, forKey: "Pass")   // Memorize the password for next login
                        UserDefaults.standard.setValue(self.username, forKey: "uID")    // Memorize the username for next login
                        self.performSegue(withIdentifier: "LogInSuccess", sender: self)
                    }
                }
            } // signInWIthEmail close
        } else {
            print("Something is very wrong...")
        }
    }
    
    // To make screen move up, when editing the lower textfields
    // Code credit to: Boris at http://stackoverflow.com/a/31124676
    // Modified by: Inal Gotov
    func keyboardWillShow(_ notification: Notification) {
        // If the teacher credential field or the location field are being edited, and are blocked by the keyboard, then shift the screen up
        if (userNameField.isEditing || passwordField.isEditing || signUpKeyField.isEditing) {
            if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.mainView.frame.origin.y == 0{
                    self.mainView.frame.origin.y -= keyboardSize.height
                }
                else {
                    
                }
            }
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        // If the teacher credential field or the location field have been edited, while they would be blocked by the keyboard, shift the screen down
        if (userNameField.isEditing || passwordField.isEditing || signUpKeyField.isEditing) {
            if (((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                if self.mainView.frame.origin.y != 0 {
                    self.mainView.frame.origin.y = 0
                    self.segmentedController.frame.origin.y += 20
                }
                else {
                    
                }
            }
        }
    }
    // End of Boris' code
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
