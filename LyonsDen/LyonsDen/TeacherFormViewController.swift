//
//  TeacherFormViewController.swift
//  LyonsDen
//
//  Created by Tamir Arnesty on 2016-09-30.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class TeacherFormViewController: UIViewController, UITextFieldDelegate {
    // Firebase reference
    var ref = FIRDatabase.database().reference()
    
    // UITextFields containing information inputted by teachers
    @IBOutlet var teacherInformation: [UITextField]! // display name, department, email
    // The main view of the ViewController
    @IBOutlet var mainView: UIView!
    
    // Sets UITextField delegates and sets keyboard notifier
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for field in teacherInformation {
            field.delegate = self
        }
        
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
    
    // form submitted
    // Submits teacher information including name, department, and email into the databae. Changes the display name of the current user.
    @IBAction func buttonPressed(_ sender: AnyObject) {
        let alert = LyonsAlert(withTitle: "", subtitle: "", style: .alert)
        alert.addLoadingWheel()
        
        let currentUser = FIRAuth.auth()!.currentUser!
        ref.child("users").child("teachers").child(currentUser.uid).setValue(["deparment" : ((teacherInformation[1].text as String!) as NSString)])
        ref.child("users").child("teachers").child(currentUser.uid).setValue(["email" : ((teacherInformation[2].text as String!) as NSString)])
        ref.child("users").child("teachers").child(currentUser.uid).setValue(["name" : ((teacherInformation[0].text as String!) as NSString)])
//        ref.child("users").child("teachers").childByAutoId().setValue(["deparment" : ((teacherInformation[1].text as String!) as NSString)])
//        ref.child("users").child("teachers").childByAutoId().setValue(["email" : ((teacherInformation[2].text as String!) as NSString)])
//        ref.child("users").child("teachers").childByAutoId().setValue(["name" : ((teacherInformation[0].text as String!) as NSString)])
        
        let changeRequest = currentUser.profileChangeRequest()
        changeRequest.displayName = teacherInformation[0].text!
        changeRequest.commitChanges { error in
            if let error = error {
                print("Something went wrong.")
                print(error.localizedDescription)
            } else {
                print("Successful name update.")
            }
        }
        alert.stopAnimating()
        performSegue(withIdentifier: "tfSubmitSegue", sender: self)
    }
    
    // To make screen move up, when editing the lower textfields
    // Code credit to: Boris at http://stackoverflow.com/a/31124676
    // Modified by: Tamir Arnesty
    func keyboardWillShow(_ notification: Notification) {
        // If the teacher credential field or the location field are being edited, and are blocked by the keyboard, then shift the screen up
        if (teacherInformation[0].isEditing || teacherInformation[1].isEditing || teacherInformation[2].isEditing) {
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
        if (teacherInformation[0].isEditing || teacherInformation[1].isEditing || teacherInformation[2].isEditing) {
            if (((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                if self.mainView.frame.origin.y != 0 {
                    self.mainView.frame.origin.y = 0
                }
                else {
                    
                }
            }
        }
    }
    // End of Boris' code
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
