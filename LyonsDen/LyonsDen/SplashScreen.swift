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
            self.performSegueWithIdentifier ("splash", sender: nil)
        }
    }
    
    @IBAction func skipped(sender: AnyObject) {
        timer!.invalidate()
        timer = nil
        self.performSegueWithIdentifier ("splash", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.copyright.bringSubviewToFront(splash)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SplashScreen.increaseTimer), userInfo: nil, repeats: true)
    }
    
    
}