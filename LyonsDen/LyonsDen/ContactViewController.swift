//
//  ContactViewController.swift
//  LyonsDen
//
//  The ContactViewContrller will be used for controlling the contact screen.
//
//  Created by Inal Gotov on 2016-06-30.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Contacts

class ContactViewController: UIViewController {
    static var displayToast = false
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var navBar: UINavigationItem!
    var toast:ToastView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ContactViewController.displayToast {
            toast = ToastView(inView: self.view, withText: "Proposal Submitted!")
            self.view.addSubview(toast)
            ContactViewController.displayToast = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let toastView = toast {
            toastView.initiate()
        }
    }
    
    @IBAction func displayTeacherList(_ sender: UIButton) {
        PeopleList.listRef = FIRDatabase.database().reference(withPath: "users").child("teachers")
        PeopleList.title = "Teachers"
        performSegue(withIdentifier: "TeacherListSegue", sender: self)
    }
    
    // This is required for a successful unwind to this View Controller
    // It just needs to be present, so don't mind it at all
    @IBAction func myUnwindAction (_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    // This is called whenever people get too curious
    @IBAction func curiosityWon(_ sender: UIButton) {
        let anim = CAKeyframeAnimation( keyPath:"transform" )
        anim.values = [NSValue(caTransform3D:CATransform3DMakeTranslation(-5, 0, 0)), NSValue(caTransform3D: CATransform3DMakeTranslation(5, 0, 0))]
        anim.autoreverses = true
        anim.repeatCount = 2
        anim.duration = 7/100
        for view in self.view.subviews {
            view.layer.add(anim, forKey: nil)
        }
    }
    
    // for contacts
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
            if accessGranted {
//                let predicate = CNContact.predicateForContactsMatchingName(self.txtLastName.text!)
//                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey]
//                var contacts = [CNContact]()
//                var message: String!
            }
        }
        
        return true
    }
    

    @IBAction func hotlineSelected(_ sender: AnyObject) {
        let options = UIAlertController(title: "Emergency Hotline", message: "Who would you like to talk to?", preferredStyle: .actionSheet)
        options.addAction(UIAlertAction(title: "Student Emergency Hotline", style: .default, handler: { action in
            self.phoneCall(URL(string: "telprompt://1-800-668-6868")!) // kids help phone
        }))
        options.addAction(UIAlertAction(title: "Emergency Contact", style: .default, handler: { action in
            // for now
            self.phoneCall(URL(string: "telprompt://647-300-9301")!) // rachels
        })) // set emergency contact from contacts in phone. save to NSDefaults. figure out how
        options.addAction(UIAlertAction(title: "WLMCI", style: .default, handler: { action in
            self.phoneCall(URL(string: "telprompt://416-395-3330")!) // school's phone
        }))
        options.addAction(UIAlertAction(title: "911", style: .default, handler: { action in
            self.phoneCall(URL(string: "telprompt://911")!) // obvious

        }))
        options.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(options, animated: true, completion: nil)
    }
    
    fileprivate func phoneCall (_ phoneNumber: URL) {
        if UIApplication.shared.canOpenURL(phoneNumber) {
            UIApplication.shared.openURL(phoneNumber)
        }
    }
}


class ToastView: UIView {
    // The text displayed in the toast
    var displayText:String
    let parentCenter:CGPoint
    
    // The method that draws the view
    override func draw(_ rect: CGRect) {
        // Declare and setup the label
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = label.font.withSize(22)
        label.text = displayText
        label.sizeToFit()
        // Configure toast size
        self.frame.size.width = label.frame.width + 16
        self.frame.size.height = label.frame.height + 16
        // Add label
        self.addSubview(label)
        // Position label
        label.frame.origin.x = 8
        label.frame.origin.y = 8
        // Position Toast
        self.center.x = parentCenter.x
        self.center.y = parentCenter.y
        // Configure colors
        self.backgroundColor = UIColor(white: 0, alpha: 0.25)
        self.alpha = 0
        label.alpha = 0.7
    }
    
    func initiate () {
        // Initiate display animation
        UIView.animate(withDuration: 0.1, animations: { self.alpha = 1 }) 
        UIView.animate(withDuration: 0.1, delay: 1.1, options: .allowAnimatedContent, animations: { self.alpha = 0 }, completion: { (completed) in if completed { self.removeFromSuperview() } })
    }
    
    convenience init(inView view:UIView, withText text:String) {
        // Create the view with an empty frame (overriden later anyway)
        self.init(frame: CGRect.zero, inView: view, withText: text)
    }
    
    init(frame: CGRect, inView view:UIView, withText text:String) {
        // Set variables
        displayText = text
        parentCenter = view.center
        // Crate view with default frame
        super.init(frame: CGRect(x: (view.center.x - (135/2)), y: (view.center.y - (45/2)), width: 135, height: 45))
    }
    
    // This is required
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
