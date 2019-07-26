//
//  AppDelegate.swift
//  Notifications
//
//  Created by Alexey Efimov on 21.06.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var bage = 0
    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        requestAutorization()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        bage = 0
       UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func requestAutorization() {
        notificationCenter.requestAuthorization(options: [.alert,.badge,.sound]) { (granted, error) in
            print("Permition granted :", granted)
            
            guard granted else { return }
            self.getNotificationSettings()
            
        }
    }
    
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { (settings) in
            print("Nottification settings \(settings)")
        }
    }
    
    func sheduelNotification(notificationType: String) {
        bage += 1
        let content = UNMutableNotificationContent()
        content.title = notificationType
        content.body = "This is example how to create \(notificationType)"
        content.sound = .default
        content.badge = bage as NSNumber
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let identifire = "\(UUID())"
        
        let request = UNNotificationRequest(identifier: identifire, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }


}

