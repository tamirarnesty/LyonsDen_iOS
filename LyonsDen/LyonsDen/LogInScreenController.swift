//
//  LogInScreenController.swift
//  LyonsDen
//
//  Created by Tamir Arnesty on 2016-07-09.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import Foundation
import UIKit

class LogInScreenController: UIViewController, UITextFieldDelegate {

    
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
    
    @IBAction func buttonPressed(sender: AnyObject) {
        self.password = passwordField.text!
        self.username = userNameField.text!
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}