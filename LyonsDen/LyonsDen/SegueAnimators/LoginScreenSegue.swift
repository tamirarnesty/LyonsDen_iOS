//
//  LoginScreenSegue.swift
//  LyonsDen
//
//  This Segue creates a fade-in/out effect, technicaly fading-in the destination ViewController.
//  Mostly used with the login screen.
//
//  Created by Inal Gotov on 2016-07-23.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//
//  Guide used: http://www.appcoda.com/custom-segue-animations/
//  

import UIKit

class LoginScreenSegue: UIStoryboardSegue {
    override func perform() {
        // The source and destination ViewControllers (VCs)
        let fromVCView = self.sourceViewController.view as UIView!
        let toVCView = self.destinationViewController.view as UIView!
        // Set the initial state of the destination VC
        toVCView.alpha = 0.0
        // Add the destination VC above the source
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(toVCView, aboveSubview: fromVCView)
        // The animation it self   |Duration           |Animator method declaration (read the whole chpater on 'functions' in the txtbook, there's some interesting stuff there, it'll fully make sense)
        UIView.animateWithDuration(0.35, animations: { () -> Void in
            toVCView.alpha = 1.0    // Basically, set the final state of the destination VC (the animation is handled by swift)
        }) { (Finished) -> Void in  // A closure statement for when the animation is complete
            self.sourceViewController.presentViewController(self.destinationViewController as UIViewController, animated: false, completion: nil)   // 'Present' the destination VC (Set it as main)
        }
    }
}
