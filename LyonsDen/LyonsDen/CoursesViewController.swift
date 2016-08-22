//
//  Courses.swift
//  LyonsDen
//
//  Created by Tamir Arnesty on 2016-08-03.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import Foundation
import UIKit

class CoursesViewController: UIViewController {
    
    @IBOutlet var courseName: UITextField!
    @IBOutlet var courseCode: UITextField!
    @IBOutlet var teacherName: UITextField!
    @IBOutlet var roomNumber: UITextField!
    @IBOutlet var periodNumber: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        for var i in 0...labels.count-1 {
            if labels[identifierIndex!][i] != defaultLabels[i]
            {
                if i == 0 { courseName.text = labels[identifierIndex!][i] }
                else if i == 1 { courseCode.text = labels[identifierIndex!][i] }
                else if i == 2 { teacherName.text = labels[identifierIndex!][i] }
                else {
                    if i == 3 {
                        roomNumber.text = labels[identifierIndex!][i]
                    }
                }
            }
        }
        if checkInfo () {
            
        }
    }
    
    func checkInfo () -> Bool {
        
        return true // true if info is different
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        periodNumber.text = "Period " + String(identifierIndex! + 1)
    }
    
    @IBAction func submitted(sender: AnyObject) {
        labels[identifierIndex!][0] = courseName.text!
        labels[identifierIndex!][1] = courseCode.text!
        labels[identifierIndex!][2] = teacherName.text!
        labels[identifierIndex!][3] = roomNumber.text!
        
        NSUserDefaults.standardUserDefaults().setObject(labels, forKey: "labels")
        if !((NSUserDefaults.standardUserDefaults().objectForKey("infoStored") as? Bool)!) {
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "infoStored") }
        for var i in 0...labels.count-1 {
            print (labels[identifierIndex!][i])
        }
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
    }
}