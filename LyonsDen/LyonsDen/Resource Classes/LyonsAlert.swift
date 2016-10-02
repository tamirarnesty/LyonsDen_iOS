//
//  LyonsAlert.swift
//  LyonsDen
//
//  Created by Inal Gotov on 2016-10-01.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import Foundation

class LyonsAlert {
    var alertView:UIAlertController
    
    init (withTitle title:String, subtitle:String, style:UIAlertControllerStyle) {
        alertView = UIAlertController(title: title, message: subtitle, preferredStyle: style)
        // MARK: VISUAL CUSTOMIZATIONS
        // Change text colors (you can change font too!)
        alertView.setValue(NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName : colorAccent]), forKey: "attributedTitle")
        alertView.setValue(NSAttributedString(string: subtitle, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName : colorAccent]), forKey: "attributedMessage")
    }
    
    func showIn (_ initiator:UIViewController) {
        initiator.present(alertView, animated: true, completion:  nil)
        // Change text color of buttons, has to be done after added, otherwise color changes back after first press
        alertView.view.tintColor = colorAccent
        
        if let textFields = alertView.textFields {
            for textField in textFields {
                // To make the textfield have no background (code specific to UIAlertController)
                let container:UIView! = textField.superview!
                let effectView = container.superview?.subviews.first
                if effectView is UIVisualEffectView {
                    container.backgroundColor = UIColor.clear
                    effectView?.removeFromSuperview()
                }
            }
        }
    }
    
    func addAction (_ action:UIAlertAction) {
        alertView.addAction(action)
    }
    
    func addTextFieldWithPlaceHolder (_ placeHolder:String) {
        alertView.addTextField { (textField) in
            textField.keyboardAppearance = UIKeyboardAppearance.dark
            textField.borderStyle = UITextBorderStyle.none
            textField.placeholder = placeHolder
            textField.autocorrectionType = UITextAutocorrectionType.no
            textField.textColor = accentColor
            textField.textAlignment = NSTextAlignment.center
        }
    }
}
