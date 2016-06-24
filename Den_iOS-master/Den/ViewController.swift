//
//  ViewController.swift
//  Den
//
//  Created by Tamir Arnesty on 2016-06-22.
//  Copyright © 2016 Tamir Arnesty. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var button: UIButton!
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    var userName = "", password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func clickBait(sender: AnyObject) {
        userName = userNameField.text!
        password = passwordField.text!
    }
}

