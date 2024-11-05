//
//  LocalNotificationApp.swift
//  LocalNotification
//
//  Created by Đoàn Văn Khoan on 4/11/24.
//

import SwiftUI

@main
struct AppEntry: App {
    
    @StateObject var lnManager = LocalNotificationManager()
    
    var body: some Scene {
        WindowGroup {
            NotificationsListView()
                .environmentObject(lnManager)
        }
    }
}
