//
//  AnnouncementViewController.swift
//  LyonsDen
//
//  Created by Inal Gotov on 2016-07-06.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit

class AnnouncementViewController: UIViewController {
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var infoTextView: UITextView!
    @IBOutlet var teacherUserName: UITextField!
    @IBOutlet var teacherPass: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view title text, at the Navigation Bar
        self.title = "Propose Announcement"
        
        // Set the Title Text Field width appropriate to the current screen size
        titleTextField.addConstraint(NSLayoutConstraint(item: titleTextField, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: view.bounds.width - 83))

        // To make screen move up, when editing the lower textfields
        // Code credit to: Dan Beaulieu in http://stackoverflow.com/a/32915049
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name:UIKeyboardWillHideNotification, object: self.view.window)
        // End of Dan's code
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // To make screen move up, when editing the lower textfields
    // Code credit to: Boris in http://stackoverflow.com/a/31124676
    // Modified by: Inal Gotov
    func keyboardWillShow(notification: NSNotification) {
        if (teacherPass.editing || teacherUserName.editing) {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                if view.frame.origin.y == 0{
                    self.view.frame.origin.y -= keyboardSize.height
                }
                else {
                    
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (teacherPass.editing || teacherUserName.editing) {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                if view.frame.origin.y != 0 {
                    self.view.frame.origin.y += keyboardSize.height
                }
                else {
                    
                }
            }
        }
    }
    // End of Boris' code
}
