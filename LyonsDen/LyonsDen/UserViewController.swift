//
//  UserViewController.swift
//  LyonsDen
//
//  Created by Tamir Arnesty on 2016-08-22.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import Foundation
import FirebaseAuth

class UserViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var userInfo: [UITextView]!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var identityPicker: UIPickerView!
    @IBOutlet weak var departmentPicker: UIPickerView!
    @IBOutlet weak var extraCurricularPicker: UIPickerView!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var extraCurricularLabel: UILabel!
    
    //------------ fix constraints and make it work
    var displayNameText:String! = nil
    var identityData = ["None Of The Above", "Student", "Teacher", "Administrator"]
    var departmentData = ["None Of The Above", "Switch"]
    var clubsData = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up picker views
        self.identityPicker.dataSource = self
        self.departmentPicker.dataSource = self
        self.identityPicker.delegate = self
        self.departmentPicker.delegate = self
        self.departmentPicker.hidden = true
        
        self.identityPicker.setValue(accentColor, forKey: "textColor")
        self.departmentPicker.setValue(accentColor, forKey: "textColor")
        
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
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == departmentPicker {
            return departmentData.count
        }
        return identityData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == departmentPicker {
            return departmentData[row]
        }
        return identityData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView == identityPicker {
        switch row {
        case 0:
            departmentPicker.hidden = true
            identityPicker.hidden = false
            userInfo[userInfo.count-1].text = "Nil"
        case 1: // student
            departmentPicker.hidden = false
            identityPicker.hidden = true
            userInfo[userInfo.count-1].text = identityData[row]
            departmentData += ["Club President", "Student Council Member"]
        case 2: // teacher
            departmentPicker.hidden = false
            identityPicker.hidden = true
            userInfo[userInfo.count-1].text = identityData[row]
            departmentData += ["Math", "English", "Social Science", "Science", "Arts"]
        case 3: // admin
            departmentPicker.hidden = false
            identityPicker.hidden = true
            userInfo[userInfo.count-1].text = identityData[row]
            departmentData += ["Principal", "Vice Principal"]
        default:
            break;
        }
        } else {
            if row == 1 {
                departmentPicker.hidden = true
                identityPicker.hidden = false
            }
            print("extra picker")
        }
        
    }
    
    @IBAction func signOutPressed(sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
        NSUserDefaults.standardUserDefaults().setValue("SignedOut", forKey: "Pass") // reset password key to prevent automatic log in.
        updatePeriods!.invalidate()
        self.performSegueWithIdentifier("signOutSegue", sender: self)
    }

    @IBAction func deleteAccount(sender: AnyObject) {
        FIRAuth.auth()?.currentUser?.deleteWithCompletion { error in
            if error != nil {
                print("Something went wrong")
            } else {
               (UIApplication.sharedApplication().delegate as! AppDelegate).displayError("Success", errorMsg: "\(FIRAuth.auth()?.currentUser?.displayName) has been deleted.")
            }
        }
    }
    
    @IBAction func resetPassword(sender: AnyObject) {
        FIRAuth.auth()?.sendPasswordResetWithEmail((FIRAuth.auth()?.currentUser?.email)!) { error in
            if error != nil {
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
            self.rightBarButton.title = "Edit"
            
            //(UIApplication.sharedApplication().delegate as! AppDelegate).displayError("Success", errorMsg: "All updates have been submitted.")
            let toast = ToastView(inView: self.view, withText: "All updates have been submitted")
            self.view.addSubview(toast)
            toast.initiate()

        }
    }
    
    @IBAction func editInfo(sender: AnyObject) {
        // make edit have to verify with touchID or current password.
        self.rightBarButton.title = "Done"
        if self.rightBarButton.title == "Done" {
            self.view.endEditing(true)
            for text in userInfo {
                text.resignFirstResponder()
            }
        }
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






