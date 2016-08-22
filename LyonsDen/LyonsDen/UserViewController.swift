//
//  UserViewController.swift
//  LyonsDen
//
//  Created by Tamir Arnesty on 2016-08-22.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import Foundation
import FirebaseAuth

class UserViewController: UIViewController {
    
    @IBAction func signOutPressed(sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
        NSUserDefaults.standardUserDefaults().setValue("SignedOut", forKey: "Pass") // reset password key to prevent automatic log in.
        self.performSegueWithIdentifier("signOutSegue", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
