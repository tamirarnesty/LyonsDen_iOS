//
//  AnnouncementViewController.swift
//  LyonsDen
//
//  Created by Inal Gotov on 2016-07-06.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

// TODO: FIX ALL DATEVIEW ISSUES
// TODO: IMPLEMENT ALL INTERNET BASED ISSUE HANDLERS
// TODO: iPhone 5S SCROLLS ABOVE (0,0) TO DESCRIPTION

import UIKit
import FirebaseDatabase
// For more indepth visual modifications
import QuartzCore

// This class is used for proposing announcements
class AnnouncementViewController: UIViewController, UIScrollViewDelegate {
    // The container Scroll View
    @IBOutlet var scrollView: UIScrollView!
    // Title Text Field
    @IBOutlet var titleField: UITextField!
    // Description Label
    @IBOutlet var descriptionLabel: UILabel!
    // Description Text Field
    @IBOutlet var descriptionField: UITextView!
    // The container of Date views
    @IBOutlet var dateView: UIView!
    // Date Picker
    @IBOutlet var datePicker: UIDatePicker!
    // Date Label
    @IBOutlet var dateLabel: UILabel!
    // The container of Location and Teacher views
    @IBOutlet var bottomViews: UIView!
    // Location Field
    @IBOutlet var locationField: UITextField!
    // Teacher Login Field
    @IBOutlet var teacherCredential: UITextField!
    // The description UITextView placeholder
    @IBOutlet var descriptionPlaceHolder: UILabel!
    // An instance of the submit button
    @IBOutlet var submitButton: UIButton!
    
    // States whether the date drawer is open or not
    var dateViewOpen = true
    
    
    // Holder for the height of the date drawer in its opened state
    var dateViewOpenHeight:CGFloat = 0
    // Holder for the height of the date drawer in its closed state
    var dateViewClosedHeight:CGFloat = 0
    // Holder for the defualt vertical position of the bottom views container
    var bottomViewOpenY:CGFloat = 0
    // Holder for the content height of the scroll view
    var scrollViewOpenContentHeight:CGFloat = 0
    
    
    // States whether the proposal has been validated
    var proposalLocked = false
    // Holder for the database
    let database = FIRDatabase.database()
    // Cache of teacher IDs (for now redownloading it every time)
    var teacherIDCache:[String: String]?
    // The border color of invalid fields
    let invalidFieldStrokeColor = UIColor(red: 1, green: 0, blue: 0.18431373, alpha: 0.5)
    
    override func viewDidLoad() {
        // Super call
        super.viewDidLoad()
        // Set the view title text, at the Navigation Bar
        self.title = "Propose Announcement"
        // Set the scrollView's delegate
        self.scrollView.delegate = self
        
        // Make it so that, whenever the user taps on the description placeholder, descriptionPlaceHolderAction() function is called
        descriptionPlaceHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(descriptionPlaceHolderAction)))
        
        // Configure datePicker's colors
        datePicker.setValue(accentColor, forKey:"textColor")
        datePicker.perform(Selector("setHighlightsToday:"), with: accentColor)
        
        // Make it so that, whenever the user taps on the date view, switchDateCell() function is called
        dateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchDateCell)))
        
        // Set the initial text for the dateLabel
        datePickerValueChanged(datePicker)
        
        submitButton.isEnabled = false
        submitButton.alpha = 0
        
        // Make each appropriate view's borders rounded and coloured
        let fields:[UIView] = [titleField, descriptionField, locationField, teacherCredential, dateView]
        for field in fields {
            field.layer.cornerRadius = 5
            field.layer.masksToBounds = true
            field.layer.borderWidth = 2
            field.layer.borderColor = backgroundColor.cgColor
        }

        // To make screen move up, when editing the lower textfields
        // Code credit to: Dan Beaulieu at http://stackoverflow.com/a/32915049
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        // End of Dan's code
    }

    override func viewDidLayoutSubviews() {
        if !dateViewOpen {  // If the drawer should be closed then close it!
            self.scrollView.contentSize.height = self.scrollViewOpenContentHeight - (self.dateViewOpenHeight - self.dateViewClosedHeight)
            self.dateView.frame.size.height = self.dateViewClosedHeight
            self.bottomViews.frame.origin.y = self.bottomViewOpenY - (self.dateViewOpenHeight - self.dateViewClosedHeight)
        }
    }
    
// MARK: DEBUGGING HERE
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.dateViewOpenHeight == 0 {
            // Instantiate the 'default date cell height' holder, for the 'open' state of the date cell
            dateViewOpenHeight = dateView.frame.height
//            print ("dateViewOpenHeight: \(dateViewOpenHeight)")
            
            dateViewClosedHeight = dateViewOpenHeight - 216
//            print ("dateViewClosedHeight: \(dateViewClosedHeight)")
            
            // Instantiate the 'default vertical position of the bottom views' holder, for the 'open' state of the date cell
            bottomViewOpenY = bottomViews.frame.origin.y
//            print ("bottomViewOpenY: \(bottomViewOpenY)")
            
            // Instantiate the scrollView's defualt content height
            scrollViewOpenContentHeight = titleField.frame.height + descriptionLabel.frame.height + descriptionField.frame.height + dateViewOpenHeight + bottomViews.frame.height + 48
//            print ("scrollVoewOpenContentHeight: \(scrollViewOpenContentHeight)")
            
            switchDateCell()
        }
    }

    // Called whenever the description's placeholder is tapped
    func descriptionPlaceHolderAction () {
        descriptionField.becomeFirstResponder()     // Initiate the editing of description's UITextView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !dateViewOpen {  // If the drawer should be closed then close it!
            scrollView.layoutSubviews()
            self.scrollView.contentSize.height = self.scrollViewOpenContentHeight - (self.dateViewOpenHeight - self.dateViewClosedHeight)
            self.dateView.frame.size.height = self.dateViewClosedHeight
            self.bottomViews.frame.origin.y = self.bottomViewOpenY - (self.dateViewOpenHeight - self.dateViewClosedHeight)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !dateViewOpen {  // If the drawer should be closed then close it!
            scrollView.layoutSubviews()
            self.scrollView.contentSize.height = self.scrollViewOpenContentHeight - (self.dateViewOpenHeight - self.dateViewClosedHeight)
            self.dateView.frame.size.height = self.dateViewClosedHeight
            self.bottomViews.frame.origin.y = self.bottomViewOpenY - (self.dateViewOpenHeight - self.dateViewClosedHeight)
        }
    }
   
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if !dateViewOpen {  // If the drawer should be closed then close it!
            scrollView.layoutSubviews()
            self.scrollView.contentSize.height = self.scrollViewOpenContentHeight - (self.dateViewOpenHeight - self.dateViewClosedHeight)
            self.dateView.frame.size.height = self.dateViewClosedHeight
            self.bottomViews.frame.origin.y = self.bottomViewOpenY - (self.dateViewOpenHeight - self.dateViewClosedHeight)
        }
    }
    
// MARK: DEBUGGING HERE
    // Called whenever the dateView is tapped
    func switchDateCell () {
//        print ()
//        print ("Date Cell Switch Initiated")
        // Switch the state of the dateView
        dateViewOpen = !dateViewOpen
        
        // SEQUENCE:
        // What needs to change
        //     - Scroll View content height
        //     - Date view height
        //     - Date picker alpha
        //     - Bottom views position?
        
        
        if !dateViewOpen {  // If the new state of the dateView is closed, then close it
//            print ()
//            print ("Date Cell Open, Closing now!")
//            print ("Stats!")
//            print ("               Date Cell Y: \(self.dateView.frame.origin.y)")
//            print ("          Date Cell Height: \(self.dateView.frame.height)")
//            print ("            Bottom Views Y: \(self.bottomViews.frame.origin.y)")
//            print ("Scroll View Content Height: \(self.scrollView.contentSize.height)")
            // Close dateView
            UIView.animate(withDuration: 0.5, animations: {
                self.scrollView.contentSize.height = self.scrollViewOpenContentHeight - (self.dateViewOpenHeight - self.dateViewClosedHeight)
                self.dateView.frame.size.height = self.dateViewClosedHeight
                self.bottomViews.frame.origin.y = self.bottomViewOpenY - (self.dateViewOpenHeight - self.dateViewClosedHeight)
            })
//            print ("First animation initiated!")
            // Hide DatePicker
            UIView.animate(withDuration: 0.2, delay: 0.3, options: .allowAnimatedContent, animations: {
                self.datePicker.alpha = 0
                }, completion: nil)
            
//            print ("Second animation initiated!")
//            print ("New Stats!")
//            print ("               Date Cell Y: \(self.dateView.frame.origin.y)")
//            print ("          Date Cell Height: \(self.dateView.frame.height)")
//            print ("            Bottom Views Y: \(self.bottomViews.frame.origin.y)")
//            print ("Scroll View Content Height: \(self.scrollView.contentSize.height)")
//            print ()
        } else {            // Otherwise the state must be open, so open it
//            print ()
//            print ("Date Cell Closed, Opening now!")
//            print ("Stats!")
//            print ("               Date Cell Y: \(self.dateView.frame.origin.y)")
//            print ("          Date Cell Height: \(self.dateView.frame.height)")
//            print ("            Bottom Views Y: \(self.bottomViews.frame.origin.y)")
//            print ("Scroll View Content Height: \(self.scrollView.contentSize.height)")
            // Open dateView
            UIView.animate(withDuration: 0.5, animations: {
                self.scrollView.contentSize.height = self.scrollViewOpenContentHeight
                self.dateView.frame.size.height = self.dateViewOpenHeight
                self.bottomViews.frame.origin.y = self.bottomViewOpenY
            })
//            print ("First animation initiated!")
            // Show DatePicker
            UIView.animate(withDuration: 0.2, delay: 0.3, options: .allowAnimatedContent, animations: {
                self.datePicker.alpha = 1
                }, completion: nil)
//            print ("Second animation initiated!")
//            print ("New Stats!")
//            print ("               Date Cell Y: \(self.dateView.frame.origin.y)")
//            print ("          Date Cell Height: \(self.dateView.frame.height)")
//            print ("            Bottom Views Y: \(self.bottomViews.frame.origin.y)")
//            print ("Scroll View Content Height: \(self.scrollView.contentSize.height)")
//            print ()
        }
    }
    
    // Called whenever the value on the datePicker is changed
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        // Format the new date
        let format:DateFormatter = DateFormatter()
        format.dateFormat = "yyyy-MM-dd 'at' HH:mm"
        // Display the new date
        dateLabel.text = format.string(from: sender.date)
    }
    
    // This is used to make the keyboard go away, when a tap outside of the keyboard are has been made
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // This is used to make the keyboard go away, when the return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    // This is called whenever the Approve/Unlock button is pressed
    @IBAction func validateProposal(_ sender: UIButton) {
        if proposalLocked {
            lockUnlockProposal(sender)
            return
        }
        
        // Check for field validity
        guard fieldsAreValid() else {
            return
        }
        
// MARK: APPROVE
        // Generate the comparison key, from the inputted teacher credential
//        let key = encrypt(teacherCredential.text! as NSString)
        let key = teacherCredential.text!
        
        if let keyset = teacherIDCache {
            if keyset.values.contains(key) {
                lockUnlockProposal(sender)
                let toast = ToastView(inView: self.view, withText: "Proposal Locked")
                self.view.addSubview(toast)
                toast.initiate()
                print ("Approval: Success! Key Found!")
            } else {
                print ("Approval: Failed!")
            }
        } else {
            // Create a reference to the teacherID dictionary
            let ref = database.reference(withPath: "users").child("teacherIDs")
            // Initiate the download for the teacherID dictionary
            ref.observe(.value, with: { (snapshot) in
                if (snapshot.exists()) {
                    self.teacherIDCache = snapshot.value as? Dictionary
                    guard self.teacherIDCache != nil else {
                        print ("There has been an error with FIRDataSnapshot")
                        print ("Snapshot contents")
                        print (snapshot.description)
                        return
                    }
                    if self.teacherIDCache!.values.contains(key) {
                        self.lockUnlockProposal(sender)
                        let toast = ToastView(inView: self.view, withText: "Proposal Locked")
                        self.view.addSubview(toast)
                        toast.initiate()
                        print ("Approval: Success! Key Found!")
                    } else {
                        print ("Approval: Failed!")
                    }
                }
            })
        }
    }

// MARK: DEBUGGING HERE
    func lockUnlockProposal (_ sender: UIButton) {
//        print ()
//        print ((!proposalLocked) ? "Locking the proposal" : "Unlocking the proposal")
//        
        // Disable/Enable all components on screen
        titleField.isEnabled = proposalLocked
        descriptionField.isEditable = proposalLocked
        locationField.isEnabled = proposalLocked
        for recognizer:UIGestureRecognizer in dateView.gestureRecognizers! {
            recognizer.isEnabled = proposalLocked
        }
        teacherCredential.text = ""
        teacherCredential.isEnabled = proposalLocked
        // Show/Hide submit button
        UIView.animate(withDuration: 0.5) {
            self.submitButton.alpha = (self.proposalLocked) ? 0 : 1
        }
        
        // Switch proposal state
        proposalLocked = !proposalLocked
        
        // Enable/Disable submit button
        submitButton.isEnabled = proposalLocked
        // Switch Approve button title
        sender.setTitle((proposalLocked) ? "Unlock" : "Approve", for: UIControlState.normal)
    }
    
    // This is called whenever the Submit button is pressed
    @IBAction func submitAnnouncement(_ sender: UIButton) {
        let ref = database.reference(withPath: "announcements").childByAutoId()
        
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        let dateTime = format.string(from: datePicker.date)
        
        ref.child("title").setValue(titleField.text)
        ref.child("description").setValue(descriptionField.text)
        ref.child("dateTime").setValue(dateTime)
        if locationField.text == nil {
            ref.child("location").setValue("")
        } else {
            ref.child("location").setValue(locationField.text)
        }
        
        ContactViewController.displayToast = true
        // TODO: SEND NOTIFICATION TO SUBSCRIBED USERS//DEVICES
        performSegue(withIdentifier: "AnnouncementsUnwind", sender: self)
        print ("Submission: Success! Announcement Sumbitted!")
    }

    // This is used for checking if all the input fields are valid, returns true if they are
    func fieldsAreValid () -> Bool {
        // The final output, set to the 'allFieldsValid' value
        var fieldsAreValid = true
        
        if descriptionField.text == nil || descriptionField.text == "" {    // If the description field is empty, then change output to false and highlight it
            fieldsAreValid = false
            descriptionField.layer.borderColor = invalidFieldStrokeColor.cgColor
        } else {    // Otherwise de-highlight it, just in case
            descriptionField.layer.borderColor = backgroundColor.cgColor
        }
        
        // An array of UITextFields to check through
        let fields:[UITextField] = [titleField, teacherCredential]
        // For every UITextField that should be valid
        for field in fields {
            if (field.text == nil || field.text == "") {    // If the field is empty then change output to false and highlight it
                fieldsAreValid = false
                field.layer.borderColor = invalidFieldStrokeColor.cgColor
            } else {    // Otherwise de-highlight it, just in case
                field.layer.borderColor = backgroundColor.cgColor
            }
        }
        // Return the final output
        return fieldsAreValid
    }
    
    // To make screen move up, when editing the lower textfields
    // Code credit to: Boris at http://stackoverflow.com/a/31124676
    // Modified by: Inal Gotov
    func keyboardWillShow(_ notification: Notification) {
        // If the teacher credential field or the location field are being edited, and are blocked by the keyboard, then shift the screen up
        if (teacherCredential.isEditing || locationField.isEditing) {
            if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if view.frame.origin.y == 0{
                    self.scrollView.frame.origin.y -= keyboardSize.height
                }
                else {
                    
                }
            }
        }
        // If the description UITextView is being edited then hide the place holder
        if (!teacherCredential.isEditing && !locationField.isEditing && !titleField.isEditing) {
            descriptionPlaceHolder.isHidden = true    // It doesn't have a .editing property :(
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        // If the teacher credential field or the location field have been edited, while they would be blocked by the keyboard, shift the screen down
        if (teacherCredential.isEditing || locationField.isEditing) {
            if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if view.frame.origin.y != 0 {
                    self.scrollView.frame.origin.y += keyboardSize.height
                }
                else {
                    
                }
            }
        }
        // If the description UITextView has been edited and it does not have any text in it, show the placeholder
        if (!teacherCredential.isEditing && !locationField.isEditing && !titleField.isEditing) {
            if descriptionField.text == "" {
                descriptionPlaceHolder.isHidden = false   // It doesn't have a .editing property :(
                
            }
        }
    }
    // End of Boris' code
}

// The BigNumber structure
struct BigNumber: Equatable {
    var value:String
    // To implement for future use: negativity
    func multiply (_ right: BigNumber) -> BigNumber {
        // If any of the multiplicants are zero then return zero
        if value == "0" || right.value == "0" { return BigNumber(value: "0") }
        // Convert the left multiplicant into an array of digits
        var a1 = value.characters.reversed().map { Int(String($0))! }
        // Convert the right multiplicant into an array of digits
        var a2 = right.value.characters.reversed().map { Int(String($0))! }
        // Declare the product as an array of digits
        var product = [Int]()
        // Declare an index counter
        var currentIndex = 0
        // Declare the first digit
        product.append(0)
        // Declare the next digit for security
        product.append(0)
        
        // The following loop will multiply every digit of the right multiplicant with every digit on the left multiplicant
        // Therefore n = a1.count * a2.count
        
        // Iterate through the left multiplicant
        for iterator1 in 0..<a1.count {
            // Iterate through the right multiplicant
            for iterator2 in 0..<a2.count {
                // Declare the current index that is being calculated
                currentIndex = iterator1 + iterator2
                // Calculate the current index
                product[currentIndex] += a1[iterator1] * a2[iterator2]
                // If the extradigit was not enough, produce an extra one
                if (currentIndex + 1) > product.count - 1 { product.append(0) }
                // If a carry is produced, then carry it to the next index
                if product[currentIndex] > 9 {
                    product[currentIndex + 1] += (product[currentIndex] / 10)
                    product[currentIndex] -= (product[currentIndex] / 10) * 10
                }
            }
        }
        // If the extra digit was not used, then remove it
        if (product.last == 0) {
            product.removeLast()
        }
        // Flip the array frontwards
        product = Array(product.reversed())
        // Convert the array of digits into BigInt type and return
        return BigNumber(value: product.map { String($0) }.joined(separator: ""))
    }
    // To implement for future use: negativity
    func add(_ right:BigNumber) -> BigNumber {
        // Convert this BigInt to an array of integers, with each item containing a single digit. The whole array is reversed
        var a1 = value.characters.reversed().map { Int(String($0))! }
        // Convert the to be added BigInt to an array of integers, with each item containing a single digit. The whole array is reversed
        var a2 = right.value.characters.reversed().map { Int(String($0))! }
        // Declare the result
        var result = [Int]()
        // Declare an index counter for the result
        var indexCounter = 0
        
        // Make the two array equal in length
        var lesser = (a1.count < a2.count) ? a1 : a2
        for _ in 1...abs(a1.count - a2.count) {
            lesser.append(0)
        }
        if (a1.count < a2.count) {
            a1 = lesser
        } else {
            a2 = lesser
        }
        // Add 2 entries to the result (1st is the current entry, 2nd is an extry entry for carrying)
        result.append(0)
        result.append(0)
        
        // Calculate
        for iterator in 0..<a1.count {
            // Add the digits in at the current index, including a possible carry
            result[indexCounter] += a1[iterator] + a2[iterator]
            
            // If a carry is produced at this index then
            if result[indexCounter] > 9 {
                result[indexCounter + 1] = (result[indexCounter] / 10)      // Add it to the next index and
                result[indexCounter] -= (result[indexCounter] / 10) * 10    // Remove it from the current
            }
            // Create a new entry for the next iteration
            result.append(0)
            // Increase the indexCounter for the next iteration
            indexCounter += 1
        }
        
        // Two is necessary
        if (result.last == 0) {     // If the result did not increase in length (no carry at last iteration)
            result.removeLast()     // Then remove the last zero
        }
        if (result.last == 0) {     // And do that again because idk
            result.removeLast()
        }
        
        result = Array(result.reversed())    // Reverse the array to be in human deciaml direction
        return BigNumber(value: result.map { String($0) }.joined(separator: ""))   // Convert to BigInt and return
    }
}

func == (lhs:BigNumber, rhs:BigNumber) -> Bool {
    if lhs.value == rhs.value {
        return true
    }
    return false
}

// Override basic operator to work with BigInts
func + (left:BigNumber, right:BigNumber) -> BigNumber {
    return left.add(right)
}
// Override basic operator to work with BigInts
func * (left:BigNumber, right:BigNumber) -> BigNumber {
    return left.multiply(right)
}
