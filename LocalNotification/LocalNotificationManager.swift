//
//  LocalNotificationManager.swift
//  LocalNotification
//
//  Created by Đoàn Văn Khoan on 4/11/24.
//

import Foundation
import NotificationCenter

/// NSObject, UNUserNotificationCenterDelegate using to receive the notification when you're using the app (by default: the notification still working in the background, not into the app)
@MainActor
class LocalNotificationManager: NSObject, ObservableObject {
    
    // MARK: - Properties
    let notificationCenter = UNUserNotificationCenter.current()
    @Published var isGranted = false
    @Published var pendingRequests: [UNNotificationRequest] = []
    @Published var nextView: NextView?
    
    // MARK: - Init
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    /// Request Authorization
    func requestAuthorization() async throws {
        /// Request Authorization
        try await notificationCenter.requestAuthorization(options: [.sound, .badge, .alert])
        
        /// Register Action Notification
        registerActions()
        await getCurrentSettings()
    }
    
    /// Get current settings
    func getCurrentSettings() async {
        let currentSettings = await notificationCenter.notificationSettings()
        isGranted = currentSettings.authorizationStatus == .authorized
    }
    
    /// Open Settings
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
    
    /// Schedule
    func schedule(localNotification: LocalNotification) async {
        
        /// Content notification
        let content = UNMutableNotificationContent()
        content.title = localNotification.title
        content.body = localNotification.body
        content.sound = .default
        if let subtitle = localNotification.subtitle {
            content.subtitle = subtitle
        }
        if let bundleImageName = localNotification.bundleImageName {
            if let url = Bundle.main.url(forResource: bundleImageName, withExtension: "") {
                if let attachment = try? UNNotificationAttachment(identifier: bundleImageName, url: url) {
                    content.attachments = [attachment]
                }
            }
        }
        if let userInfo = localNotification.userInfo {
            content.userInfo = userInfo
        }
        if let categoryIdentifier = localNotification.categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        
        switch localNotification.scheduleType {
        case .time:
            guard let timeInterval = localNotification.timeInterval else { return }
            /// Trigger
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: timeInterval,
                repeats: localNotification.repeats
            )
            /// Request
            let request = UNNotificationRequest(identifier: localNotification.identifier, content: content, trigger: trigger)
            /// Add notification to queue
            try? await notificationCenter.add(request)
            
        case .calendar:
            guard let dateComponents = localNotification.dateComponents else { return }
            /// Trigger
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: localNotification.repeats)
            /// Request
            let request = UNNotificationRequest(identifier: localNotification.identifier, content: content, trigger: trigger)
            /// Add notificaiton to queue
            try? await notificationCenter.add(request)
        }
        
        
        await getPendingRequest()
    }
    
    /// Get number of requests notification
    func getPendingRequest() async {
        pendingRequests = await notificationCenter.pendingNotificationRequests()
        print("Peding: \(pendingRequests.count)")
    }
    
    /// Remove the request
    func removeRequest(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        if let index = pendingRequests.firstIndex(where: { $0.identifier == identifier }) {
            pendingRequests.remove(at: index)
            print("Peding: \(pendingRequests.count)")
        }
    }
    
    /// Clear requests
    func clearRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
        pendingRequests.removeAll()
        print("Peding: \(pendingRequests.count)")
    }
}


extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    /// Delegate function - conform UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        await getPendingRequest()
        return [.sound, .banner]
    }
    
    /// Delegate function - conform UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        
        if let value = response.notification.request.content.userInfo["nextView"] as? String {
            nextView = NextView(rawValue: value)
        }
        
        /// Respond to snooze action
        var snoozeInterval: Double?
        if response.actionIdentifier == "snooze10" {
            snoozeInterval = 10
        } else {
            if response.actionIdentifier == "snooze60" {
                snoozeInterval = 60
            }
        }
        
        if let snoozeInterval {
            let content = response.notification.request.content
            /// New content notification be copied from content current
            let newContent = content.mutableCopy() as! UNMutableNotificationContent
            /// New trigger
            let newTrigger = UNTimeIntervalNotificationTrigger(timeInterval: snoozeInterval, repeats: false)
            /// New request
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: newContent,
                trigger: newTrigger
            )
            
            do {
                try await notificationCenter.add(request)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            
            await getPendingRequest()
        }
    }
    
    /// Custom function
    func registerActions() {
        let snooze10Action = UNNotificationAction(identifier: "snooze10", title: "Snooze 10 seconds")
        let snooze60Action = UNNotificationAction(identifier: "snooze60", title: "Snooze 60 seconds")
        
        let snoozeCategory = UNNotificationCategory(
            identifier: "snooze",
            actions: [snooze10Action, snooze60Action],
            intentIdentifiers: []
        )
        
        notificationCenter.setNotificationCategories([snoozeCategory])
    }
}
