//
//  SplashScreen.swift
//  Den
//
//  Created by Tamir Arnesty on 2016-06-24.
//  Modified by Inal Gotov 
//  Copyright © 2016 Tamir Arnesty. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SplashScreen: UIViewController {
    
    var timer:NSTimer?
    var time = 0
    
    @IBOutlet var splash: UIView!
    
    @IBOutlet var skip: UITapGestureRecognizer!
    @IBOutlet var copyright: UILabel!
    
    func increaseTimer () {
        time += 1
        if (time == 3) {
            timer!.invalidate()
            // Auto login
            if let username = NSUserDefaults.standardUserDefaults().objectForKey("uID") as! String?,    // If a username has been pre-saved and
                password = NSUserDefaults.standardUserDefaults().objectForKey("Pass") as! String? {     // a password has been pre-saved then
                if password.compare("SignedOut") == .OrderedSame {
                    self.performSegueWithIdentifier ("SplashScreenSegue", sender: self)
                    return
                }
                // Authenticate
                FIRAuth.auth()?.signInWithEmail(username, password: password, completion: { (user, error) in
                    if user != nil {
                        //Log in succesful
                        self.performSegueWithIdentifier("AutoLogInSegue", sender: self)
                        print()
                        print("Log In: Auto-Login Success!")
                        print()
                    } else if error != nil {
                        // Try comparing error to FIRAuthErrorCodes from https://firebase.google.com/docs/reference/ios/firebaseauth/interface_f_i_r_auth_errors.html#ab5026c267a1f5fee09466e5563aa3e69
                        // or from https://firebase.google.com/docs/auth/ios/errors
                    }
                })
            } else {
            self.performSegueWithIdentifier ("SplashScreenSegue", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.copyright.bringSubviewToFront(splash)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SplashScreen.increaseTimer), userInfo: nil, repeats: true)
    }
    
    
}