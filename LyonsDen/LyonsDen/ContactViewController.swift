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
import MessageUI
import Contacts

class ContactViewController: UIViewController, MFMailComposeViewControllerDelegate {
    static var displayToast = false
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var navBar: UINavigationItem!
    var toast:ToastView!
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let titles = ["Propose\nAnnoun-\ncement", "Contact a\nTeacher", "Secret\nComing\nSoon!", "Emergency\nHotline"]
        for h in 0..<buttons.count {
            buttons[h].setTitle(titles[h], for: .normal)
            buttons[h].titleLabel?.numberOfLines = 0
            buttons[h].titleLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
            buttons[h].titleLabel?.textAlignment = NSTextAlignment.center
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
        let title = "Emergency Hotline"
        let subTitle = "Who would you like to talk to?"
        let options = UIAlertController(title: title, message: subTitle, preferredStyle: .actionSheet)
        
    // MARK: VISUAL COSTUMIZATIONS
        options.setValue(NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName : colorAccent]), forKey: "attributedTitle")
        options.setValue(NSAttributedString(string: subTitle, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName : colorAccent]), forKey: "attributedMessage")
        options.view.tintColor = colorAccent
        
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
    
    @IBAction func reportBug(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {  // We shall send mail
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            // Configure fields
            composeVC.setToRecipients(["TheLyonsKeeper@gmail.com"])
            composeVC.setSubject("Hey Keeper, I found a bug!")
            composeVC.setMessageBody("Before the bug occured I did this:", isHTML: false)
            
            // Present VC modally
            self.present(composeVC, animated: true, completion: nil)
        } else {    // We shan't send mail
            print ("Mail services not available on this device")
            // Present a LyonsAlert notifying the user that he cannot send mail on this device
            let alert = LyonsAlert(withTitle: "Mail Services Unavailable!", subtitle: "Unfortunately there are no mail services enabled on this device. Please enable mail service and try again.", style: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            alert.showIn(self)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        var toastMessage = "Report "
        
        if result == MFMailComposeResult.sent {
            toastMessage += "Sent!"
        } else if result == MFMailComposeResult.failed {
            toastMessage += "Failed to Send!"
        } else if result == MFMailComposeResult.cancelled {
            toastMessage += "Cancelled"
        }
        
        if let mailError = error {
            print ("Bug Reporting Error!")
            print (mailError.localizedDescription)
        }
        
        let toast = ToastView(inView: self.view, withText: toastMessage)
        self.view.addSubview(toast)
        
        // Dismiss the mail VC
        controller.dismiss(animated: true) {
            toast.initiate()
        }
    }
    
    fileprivate func phoneCall (_ phoneNumber: URL) {
        if UIApplication.shared.canOpenURL(phoneNumber) {
            UIApplication.shared.openURL(phoneNumber)
        }
    }
}
