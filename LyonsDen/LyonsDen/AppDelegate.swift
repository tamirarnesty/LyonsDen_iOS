//
//  AppDelegate.swift
//  LyonsDen
//
//  Created by Inal Gotov on 2016-06-30.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit
import Firebase
import Contacts

let navigationBarColor:UIColor = UIColor(red: 0.023, green: 0.2980, blue: 0.6980, alpha: 1)
let foregroundColor:UIColor = UIColor(red: 0.0118, green: 0.2431, blue: 0.5765, alpha: 1)
let backgroundColor:UIColor = UIColor(red: 0.0078, green: 0.1647, blue: 0.3922, alpha: 1)
let accentColor:UIColor = UIColor(red: 0.9961, green: 0.7765, blue: 0.2784, alpha: 1)
let skyBlueColor:UIColor = UIColor(red: 0.6392, green: 0.7451, blue: 0.8980, alpha: 1)
var contactStore = CNContactStore()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
//    func application(application: UIApplication,
//                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        
//        // [START register_for_notifications]
//        if #available(iOS 10.0, *) {
//            let authOptions : UNAuthorizationOptions = [.Alert, .Badge, .Sound]
//            UNUserNotificationCenter.currentNotificationCenter().requestAuthorizationWithOptions(
//                authOptions,
//                completionHandler: {_,_ in })
//            
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.currentNotificationCenter().delegate = self
//            // For iOS 10 data message (sent via FCM)
//            FIRMessaging.messaging().remoteMessageDelegate = self
//            
//        } else {
//            let settings: UIUserNotificationSettings =
//                UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//            application.registerForRemoteNotifications()
//        }
//        
//        
//        // [END register_for_notifications]
//        
//        FIRApp.configure()
//        
//        // Add observer for InstanceID token refresh callback.
//        NSNotificationCenter.defaultCenter().addObserver(self,
//                                                         selector: #selector(self.tokenRefreshNotification),
//                                                         name: kFIRInstanceIDTokenRefreshNotification,
//                                                         object: nil)
//        
//        return true
//    }
    
    func displayError (_ title: String!, errorMsg: String!) {
        let alertController = UIAlertController(title: title, message: errorMsg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController!.present(alertController, animated: true, completion: nil)
        
    }

    // for contacts methods. used in ContactViewController for emergency contact setting
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    // same here
    func showMessage(_ message: String) {
        let alertController = UIAlertController(title: "Birthdays", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        
        let pushedViewControllers = (self.window?.rootViewController as! UINavigationController).viewControllers
        let presentedViewController = pushedViewControllers[pushedViewControllers.count - 1]
        
        presentedViewController.present(alertController, animated: true, completion: nil)
    }

    // and this
    func requestForAccess(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

