//
//  AppDelegate.swift
//  SkaterBrad
//
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, TAGContainerOpenerNotifier {
    
    var window: UIWindow?
    var tagManager: TAGManager!
    var tagContainer: TAGContainer?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.tagManager = TAGManager.instance()
        self.tagManager.logger.setLogLevel(kTAGLoggerLogLevelVerbose)
        TAGContainerOpener.openContainerWithId("GTM-MGSTLS", tagManager: self.tagManager, openType: kTAGOpenTypePreferNonDefault, timeout: nil, notifier: self)
        self.tagManager.dispatchInterval = 1
        
        return true
    }
    
    func containerAvailable(container: TAGContainer!) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tagContainer = container
            let screenViewDictionary = ["event" : "screen-open", "screen-name" : "Start Screen"]
            var dataLayer : TAGDataLayer = TAGManager.instance().dataLayer
            dataLayer.push(NSDictionary(dictionary: screenViewDictionary))
            
            container.refresh()
        })
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {

    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}


