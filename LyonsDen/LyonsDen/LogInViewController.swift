//
//  LogInScreenController.swift
//  LyonsDen
//
//  Created by Tamir Arnesty on 2016-07-09.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

/*
 So here's my thought on it
 When there's login selected it just does it the regular way
 When they choose signup, an extra textfield appears and the button's text changes
 The first two fields act the same way, but the third one is where they enter the signup key
 The keys will be compared so as to prevent the wrong audience from signing up
 You can find instructions on the firebase website on how to login and how to create users
 Also make sure that after the first log in, you add the credential to NSUserDefaults (i can explain how to do it if you need)
 This is so that the login screen doesnt show up everytime
 On second launch it will just check if the credentials already exist and use those
 You can also try doing the auto login in splashscreen, so as to be able to integrate it with a loadingWheelThing
 You can do it differently if you like
 */

// I needed to test things with authentication so... sry, i made the basics of login
class LogInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var switcher: UISegmentedControl!
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var segmentedController: UISegmentedControl!
    @IBOutlet var signUpKeyField: UITextField!
    
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var bottomDenConstraint: NSLayoutConstraint!
    @IBOutlet var passwordFieldConstraint: NSLayoutConstraint!
    
    var entranceOption:Int!
    var password = ""
    var username = ""
    let signUpKey = "MacLyonsRule"  // idk, this should be something symbolic or patriotic... or secretive
    
    override func viewDidAppear(animated: Bool) {
        // Auto login
        if let username = NSUserDefaults.standardUserDefaults().objectForKey("uID") as! String?,    // If a username has been pre-saved and
            password = NSUserDefaults.standardUserDefaults().objectForKey("Pass") as! String? {     // a password has been pre-saved then
            if password.compare("SignedOut") == .OrderedSame {
                return
            }
            // Authenticate
            FIRAuth.auth()?.signInWithEmail(username, password: password, completion: { (user, error) in
                if user != nil {
                    //Log in succesful
//                    user?.profileChangeRequest().displayName = "Tamir Arnesty"
                    self.performSegueWithIdentifier("LogInSuccess", sender: self)
                } else if error != nil {
                    // Try comparing error to FIRAuthErrorCodes from https://firebase.google.com/docs/reference/ios/firebaseauth/interface_f_i_r_auth_errors.html#ab5026c267a1f5fee09466e5563aa3e69
                    // or from https://firebase.google.com/docs/auth/ios/errors
                }
            })
        }
    }
    
    @IBAction func optionSwitched(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // sign up
            entranceOption = 0
            print(entranceOption)
            self.view.layoutIfNeeded()
            UIView.animateWithDuration(1, animations: {
                self.signUpKeyField.hidden = false // textfield shows up
                self.bottomConstraint.constant -= 15
                self.topConstraint.constant += 10
                self.bottomDenConstraint.constant -= 10
                self.passwordFieldConstraint.constant += 10
                self.view.layoutIfNeeded()
            })
        case 1: // log in
            entranceOption = 1
            print(entranceOption)
            self.view.layoutIfNeeded()
            UIView.animateWithDuration(1, animations: {
                self.signUpKeyField.hidden = true // textfield disappears
                self.bottomConstraint.constant += 15
                self.topConstraint.constant -= 10
                self.bottomDenConstraint.constant += 10
                self.passwordFieldConstraint.constant -= 10
                self.view.layoutIfNeeded()
            })
        default:
            break
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColor.whiteColor().CGColor, accentColor.CGColor]
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        self.userNameField.delegate = self
        self.passwordField.delegate = self
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func buttonPressed(sender: AnyObject) {
        self.password = passwordField.text!
        self.username = userNameField.text!
    
        if (passwordField.text?.isEmpty)! || (userNameField.text?.isEmpty)! {
            (UIApplication.sharedApplication().delegate as! AppDelegate).displayError("Missing Information", errorMsg: "Please fill in all the requirements.")
            return
        }
        
        if entranceOption == 0 {
            if signUpKeyField.text == signUpKey {
                FIRAuth.auth()?.createUserWithEmail(self.username, password: self.password, completion: {(user, error) in
                    if error != nil {
                        if let code = FIRAuthErrorCode(rawValue: error!.code) {
                            switch code {
                            case .ErrorCodeEmailAlreadyInUse: // user exists
                                (UIApplication.sharedApplication().delegate as! AppDelegate).displayError("Sorry!", errorMsg: "This email is already in use. Please log in, or use another email to sign up.")
                            case .ErrorCodeInvalidEmail: // self explanatory
                                (UIApplication.sharedApplication().delegate as! AppDelegate).displayError("Invalid Email", errorMsg: "Please make sure your email is typed in correctly.")
                            default:
                                break
                            }
                        }
                    } else {
                        if user != nil {
                            //Log in succesfull
                            NSUserDefaults.standardUserDefaults().setValue(self.password, forKey: "Pass")   // Memorize the password for next login
                            NSUserDefaults.standardUserDefaults().setValue(self.username, forKey: "uID")    // Memorize the username for next login
                            self.performSegueWithIdentifier("LogInSuccess", sender: self)
                        }
                    }
                }) // createUserWithEmail close
            } else {
                (UIApplication.sharedApplication().delegate as! AppDelegate).displayError("Incorrect Sign Up Key", errorMsg: "Please try again.")
            } // first if close
        } else if entranceOption == 1 {
            // Authentication
            FIRAuth.auth()?.signInWithEmail(self.username, password: self.password, completion: { (user, error) in
                if error != nil {
                    if let code = FIRAuthErrorCode(rawValue: error!.code) {
                        switch code {
                        case .ErrorCodeWrongPassword: // wrong password
                            (UIApplication.sharedApplication().delegate as! AppDelegate).displayError("Invalid Password", errorMsg: "The password you entered is incorrect. Please try again.")
                        default:
                            break
                        }
                    }
                } else {
                    if user != nil {
                        //Log in succesfull
                        NSUserDefaults.standardUserDefaults().setValue(self.password, forKey: "Pass")   // Memorize the password for next login
                        NSUserDefaults.standardUserDefaults().setValue(self.username, forKey: "uID")    // Memorize the username for next login
                        self.performSegueWithIdentifier("LogInSuccess", sender: self)
                    }
                }
            }) // signInWIthEmail close
        } else {
            print("Something is very wrong...")
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}