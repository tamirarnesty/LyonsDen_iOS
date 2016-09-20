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

// TODO: AUTO_LOGIN PERFORMS TWICE FROM TIME TO TIME< WHICH CAUSES A THROW BACK INTO HOME SCREEN, PUT AUTO_LOG IN A DIFFERENT PLACE

class LogInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var segmentedController: UISegmentedControl!
    @IBOutlet var signUpKeyField: UITextField!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var logoToSegmentConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var logInButton: UIButton!
    
    var entranceOption:Int = 0
    var password = ""
    var username = ""
    let signUpKey = "MacLyonsRule"  // idk, this should be something symbolic or patriotic... or secretive
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColor.white.cgColor, accentColor.cgColor]
        self.view.layer.insertSublayer(gradient, at: 0)
        self.userNameField.delegate = self
        self.passwordField.delegate = self
        
        // To make screen move up, when editing the lower textfields
        // Code credit to: Dan Beaulieu at http://stackoverflow.com/a/32915049
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        // End of Dan's code
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func buttonPressed(_ sender: AnyObject) {
        self.password = passwordField.text!
        self.username = userNameField.text!
        var alert:LyonsAlert = LyonsAlert(withTitle: "", subtitle: "", style: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if (passwordField.text?.isEmpty)! || (userNameField.text?.isEmpty)! {
            alert = LyonsAlert(withTitle: "Missing Information", subtitle: "Please fill in all the requirements.", style: .alert)
            alert.showIn(self)
//                (UIApplication.shared.delegate as! AppDelegate).displayError("Missing Information", errorMsg: "Please fill in all the requirements.")
            return
        }
        
        if entranceOption == 0 {
            if signUpKeyField.text == "MacLyonsTeacher" { // TEACHER CHECK
                let ref:FIRDatabaseReference = FIRDatabase.database().reference()
                ref.child("users/teacherIDs/").childByAutoId().setValue(password)
                
            } else {
                if signUpKeyField.text == signUpKey {
                FIRAuth.auth()?.createUser(withEmail: self.username, password: self.password, completion: {(user, error) in
                    if error != nil {
                        if let code = FIRAuthErrorCode(rawValue: error!._code) {
                            switch code {
                            case .errorCodeEmailAlreadyInUse: // user exists
                                alert = LyonsAlert(withTitle: "Sorry!", subtitle: "This email is already in use. Please log in, or use another email to sign up.", style: .alert)
                                alert.showIn(self)
//                                (UIApplication.shared.delegate as! AppDelegate).displayError("Sorry!", errorMsg: "This email is already in use. Please log in, or use another email to sign up.")
                            case .errorCodeInvalidEmail: // self explanatory
                                alert = LyonsAlert(withTitle: "Invalid Email", subtitle: "Please make sure your email is typed in correctly.", style: .alert)
                                alert.showIn(self)
//                                (UIApplication.shared.delegate as! AppDelegate).displayError("Invalid Email", errorMsg: "Please make sure your email is typed in correctly.")
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
                }) // createUserWithEmail close
            } else {
                (UIApplication.shared.delegate as! AppDelegate).displayError("Incorrect Sign Up Key", errorMsg: "Please try again.")
            } // close of else { if {
            }// close of TEACHER CHECK
        } else if entranceOption == 1 {
            // Authentication
            FIRAuth.auth()?.signIn(withEmail: username, password: self.password) { (user, error) in
                // ...
                if error != nil {
                    if let code = FIRAuthErrorCode(rawValue: error!._code) {
                        switch code {
                        case .errorCodeWrongPassword: // wrong password
                            (UIApplication.shared.delegate as! AppDelegate).displayError("Invalid Password", errorMsg: "The password you entered is incorrect. Please try again.")
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
            if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
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
