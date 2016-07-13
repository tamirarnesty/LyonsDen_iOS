//
//  SplashScreen.swift
//  Den
//
//  Created by Tamir Arnesty on 2016-06-24.
//  Copyright © 2016 Tamir Arnesty. All rights reserved.
//

import Foundation
import UIKit

class SplashScreen: UIViewController {
    
    var timer = NSTimer()
    var time = 0
    
    @IBOutlet var splash: UIView!
    
    @IBOutlet var skip: UITapGestureRecognizer!
    @IBOutlet var copyright: UILabel!
    @IBOutlet var lyon: UIImageView!
    
    func increaseTimer () {
        time += 1
        if (time == 3) {
            timer.invalidate()
            self.performSegueWithIdentifier ("splash", sender: nil)
        }
    }
    
    @IBAction func skipped(sender: AnyObject) {
        time = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.copyright.bringSubviewToFront(splash)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SplashScreen.increaseTimer), userInfo: nil, repeats: true)
    }
    
    
}