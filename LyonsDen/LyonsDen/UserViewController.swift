//
//  UserViewController.swift
//  LyonsDen
//
//  Created by Tamir Arnesty on 2016-08-22.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import Foundation
import FirebaseAuth

class UserViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var userInfo: [UITextView]!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    //------------ fix constraints and make it work
    var displayNameText:String! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        for text in userInfo {
            text.editable = false
            text.layer.borderWidth = 0.5
            text.layer.borderColor = UIColor.yellowColor().CGColor
        }
        
        
        if let displayName = NSUserDefaults.standardUserDefaults().objectForKey("displayName") as? String {
            displayNameText = displayName
        }
        userInfo[0].text = (FIRAuth.auth()?.currentUser?.displayName != nil) ? FIRAuth.auth()?.currentUser?.displayName : displayNameText
        userInfo[1].text = FIRAuth.auth()?.currentUser?.email
    }
    
    @IBAction func signOutPressed(sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
        NSUserDefaults.standardUserDefaults().setValue("SignedOut", forKey: "Pass") // reset password key to prevent automatic log in.
        self.performSegueWithIdentifier("signOutSegue", sender: self)
    }

    @IBAction func deleteAccount(sender: AnyObject) {
        FIRAuth.auth()?.currentUser?.deleteWithCompletion { error in
            if let error = error {
                print("Something went wrong")
            } else {
               (UIApplication.sharedApplication().delegate as! AppDelegate).displayError("Success", errorMsg: "\(FIRAuth.auth()?.currentUser?.displayName) has been deleted.")
            }
        }
    }
    
    @IBAction func resetPassword(sender: AnyObject) {
        
        FIRAuth.auth()?.sendPasswordResetWithEmail((FIRAuth.auth()?.currentUser?.email)!) { error in
            if let error = error {
                print ("Something went wrong")
            } else {
                (UIApplication.sharedApplication().delegate as! AppDelegate).displayError("Success", errorMsg: "A password reset email was sent to \(FIRAuth.auth()?.currentUser?.displayName)")
            }
        }
    }
    
    @IBAction func updateUser(sender: AnyObject) {
        let user = FIRAuth.auth()?.currentUser
        if let user = user {
            let changeRequest = user.profileChangeRequest()
            changeRequest.displayName = userInfo[0].text!
            changeRequest.commitChangesWithCompletion { error in
                if let error = error {
                    print("Something went wrong.")
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(self.userInfo[0].text, forKey: "displayName")
                    print("Successful name update.")
                }
            }
            user.updateEmail(userInfo[1].text!) { error in
                if let error = error {
                    print("Something went wrong.")
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(self.userInfo[1].text, forKey: "uID")
                    print("Successful email update.")
                }
            }
            if userInfo[2].text != "Secure Information" {
            user.updatePassword(userInfo[2].text!) { error in
                if let error = error {
                    print("Something went wrong.")
                } else {
                    NSUserDefaults.standardUserDefaults().setObject(self.userInfo[2].text, forKey: "Pass")
                    print("Successful password update.")
                }
            }
            }
            
            for text in userInfo {
                text.editable = false
            }
            
            (UIApplication.sharedApplication().delegate as! AppDelegate).displayError("Success", errorMsg: "All updates have been submitted.")
        }
    }
    
    @IBAction func editInfo(sender: AnyObject) {
        // make edit have to verify with touchID or current password.
        for text in userInfo {
            text.editable = true
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textView: UITextView) -> Bool{
        textView.resignFirstResponder()
        return true
    }
    
    func applyClubLeaderWithKey (key:String) {
        print ("Attempting to apply club leader")
        print ("Failed! Not Supported!")
        print (key)
        
        
        // Idea:
        // Use the regular club key but 'salt' it with the uid of the registering user
        // Problem:
        // No way of letting the user know about his key, unless we have administering app, through which the key can be generated and given :(
    }
    
    // This is universality example
    @IBAction func clubLeadershipApplication(sender: UIButton) {
        let alert:LyonsAlert = LyonsAlert(withTitle: "Club Leadership", subtitle: "Enter the club code to be assigned as its leader", style: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default) { (action) in
            self.applyClubLeaderWithKey((alert.alertView.textFields?.first?.text!)!)
            })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addTextFieldWithPlaceHolder("Enter club code here")
        alert.showIn(self)
    }
}

class LyonsAlert {
    var alertView:UIAlertController
    
    init (withTitle title:String, subtitle:String, style:UIAlertControllerStyle) {
        alertView = UIAlertController(title: title, message: subtitle, preferredStyle: style)
    // MARK: VISUAL CUSTOMIZATIONS
        // Change background color, gets rid of rounded corners
        (alertView.view.subviews.first!.subviews.first! as UIView).backgroundColor = foregroundColor
        // Reapply rounded corners
        alertView.view.layer.cornerRadius = 15
        alertView.view.layer.masksToBounds = true
        // Change text colors (you can change font too!)
        alertView.setValue(NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17), NSForegroundColorAttributeName : accentColor]), forKey: "attributedTitle")
        alertView.setValue(NSAttributedString(string: subtitle, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14), NSForegroundColorAttributeName : accentColor]), forKey: "attributedMessage")
        
        
    }

    func showIn (initiator:UIViewController) {
        initiator.presentViewController(alertView, animated: true, completion:  nil)
        // Change text color of buttons, has to be done after added, otherwise color changes back after first press
        alertView.view.tintColor = accentColor
        
        if let textFields = alertView.textFields {
            for textField in textFields {
                // To make the textfield have no background (code specific to UIAlertController)
                let container:UIView! = textField.superview!
                let effectView = container.superview?.subviews.first
                if effectView is UIVisualEffectView {
                    container.backgroundColor = UIColor.clearColor()
                    effectView?.removeFromSuperview()
                }
            }
        }
    }
    
    func addAction (action:UIAlertAction) {
        alertView.addAction(action)
    }
    
    func addTextFieldWithPlaceHolder (placeHolder:String) {
        alertView.addTextFieldWithConfigurationHandler { (textField) in
            textField.keyboardAppearance = UIKeyboardAppearance.Dark
            textField.borderStyle = UITextBorderStyle.None
            textField.placeholder = placeHolder
            textField.autocorrectionType = UITextAutocorrectionType.No
            textField.textColor = accentColor
            textField.textAlignment = NSTextAlignment.Center
        }
    }
}






