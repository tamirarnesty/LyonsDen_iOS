//
//  AnnouncementViewController.swift
//  LyonsDen
//
//  Created by Inal Gotov on 2016-07-06.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit

class AnnouncementViewController: UIViewController {
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var infoTextField: UITextField!
    @IBOutlet var teacherUserName: UITextField!
    @IBOutlet var teacherPass: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view title text, at the Navigation Bar
        self.title = "Propose Announcement"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
