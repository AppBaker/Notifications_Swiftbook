//
//  Notifications.swift
//  Notifications
//
//  Created by Ivan Nikitin on 01/08/2019.
//  Copyright © 2019 Alexey Efimov. All rights reserved.
//

import UIKit
import UserNotifications

class Notifications: NSObject {
    
    let notificationCenter = UNUserNotificationCenter.current()
    var bage = 0
    
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
            
            guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func scheduelNotification(notificationType: String) {
        bage += 1
        let content = UNMutableNotificationContent()
        let userAction = "User Action"
        
        content.title = notificationType
        content.body = "This is example how to create \(notificationType)"
        content.sound = .default
        content.badge = bage as NSNumber
        content.categoryIdentifier = userAction
        
        guard let path = Bundle.main.path(forResource: "diamond", ofType: "png") else { return }
        
        let url = URL(fileURLWithPath: path)
        
        do {
           
            let attachment = try UNNotificationAttachment(identifier: "icon", url: url, options: nil)
            content.attachments = [attachment]
        } catch {
            print("The attachment can not be loaded")
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let identifire = notificationType
        
        let request = UNNotificationRequest(identifier: identifire, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
        
        let category = UNNotificationCategory(identifier: userAction,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        notificationCenter.setNotificationCategories([category])
    }
}

extension Notifications: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("BODY: " + notification.request.content.body)
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("BODY: " + response.notification.request.content.body)
        //            let alertController = UIAlertController(title: "Notification", message: response.notification.request.identifier, preferredStyle: .alert)
        //            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        //            alertController.addAction(okAction)
        
        
        print ("Handling notification with the \(response.notification.request.identifier)")
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
            scheduelNotification(notificationType: "Reminder")
        case "Delete":
            print(response.notification.request.content.attachments)
            
            
            scheduelNotification(notificationType: "Delete")
        default:
            print("Unknown action")
        }
        
        completionHandler()
    }

}
