//
//  ViewController.swift
//  Tester
//
//  Created by Tamir Arnesty on 2016-06-23.
//  Copyright © 2016 Tamir Arnesty. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var switcher: UISegmentedControl!
    @IBOutlet var enterButton: UIButton!
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    var password = ""
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameField.delegate = self
        self.passwordField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logIn(sender: AnyObject) {
        username = userNameField.text!
        password = passwordField.text!
        print(username)
        print(password)
    }
    
}

