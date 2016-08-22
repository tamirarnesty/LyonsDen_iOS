//
//  ContactViewController.swift
//  LyonsDen
//
//  The ContactViewContrller will be used for controlling the contact screen.
//
//  Created by Inal Gotov on 2016-06-30.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit
import Contacts

class ContactViewController: UIViewController {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var navBar: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // for contacts
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                //let predicate = CNContact.predicateForContactsMatchingName(self.txtLastName.text!)
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey]
                var contacts = [CNContact]()
                var message: String!
            }
        }
        
        return true
    }
    

    @IBAction func hotlineSelected(sender: AnyObject) {
        let options = UIAlertController(title: "Emergency Hotline", message: "Who would you like to talk to?", preferredStyle: .ActionSheet)
        options.addAction(UIAlertAction(title: "Student Emergency Hotline", style: .Default, handler: { action in
            self.phoneCall(NSURL(string: "telprompt://1-800-668-6868")!) // find actual number
        }))
        options.addAction(UIAlertAction(title: "Emergency Contact", style: .Default, handler: { action in
            // for now
            self.phoneCall(NSURL(string: "telprompt://647-300-9301")!) // rachels
        })) // set emergency contact from contacts in phone. save to NSDefaults. figure out how
        options.addAction(UIAlertAction(title: "WLMCI", style: .Default, handler: { action in
            self.phoneCall(NSURL(string: "telprompt://416-395-3330")!)
        }))
        options.addAction(UIAlertAction(title: "911", style: .Default, handler: { action in
            self.phoneCall(NSURL(string: "telprompt://911")!)

        }))
        options.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(options, animated: true, completion: nil)
    }
    
    private func phoneCall (phoneNumber: NSURL) {
        if UIApplication.sharedApplication().canOpenURL(phoneNumber) {
            UIApplication.sharedApplication().openURL(phoneNumber)
        }
    }
    
}