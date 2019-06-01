//
//  AppDelegate.swift
//  makeitapp
//
//  Created by David on 2019-04-01.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
 
    

    var window: UIWindow?
   

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Setting up Firebase
        FirebaseApp.configure()
        
        //Setting up GoogleSingin
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        //Setting up database
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        //Setting up Facebook Core
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Setting up Realm persistance container
       
        do {
            _ = try Realm()
        } catch {
            print("Error initialising realm, \(error)")
        }
         //print(Realm.Configuration.defaultConfiguration.fileURL)
        
        //Setup UI programmatically 
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let categoryVC = CategoryViewController()
        let navigationController = UINavigationController(rootViewController: categoryVC)
        window?.rootViewController = navigationController
        let navigationBarApperance = UINavigationBar.appearance()
        navigationBarApperance.tintColor = UIColor.white
        navigationBarApperance.barTintColor = UIColor.black
        navigationBarApperance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 32)!]
        return true
    }
    
    //delegate method for GoolgeSignIn
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print("Error signing in ",error)
            return
        }
        
        guard let authentication = user.authentication else {return}
        let credentials = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print("Error disconecting from app ",error)
            return
        }
        
        print("Disconnected from app")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        let handled: Bool = ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        
        
        return handled
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

