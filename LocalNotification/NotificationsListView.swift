//
//  ContentView.swift
//  LocalNotification
//
//  Created by Đoàn Văn Khoan on 4/11/24.
//

import SwiftUI

struct NotificationsListView: View {
    
    @EnvironmentObject var lnManager: LocalNotificationManager
    @Environment(\.scenePhase) var scenePhase
    @State private var scheduleDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                
                /// Check granted
                if lnManager.isGranted {
                    
                    GroupBox("Schedule") {
                        
                        /// Interval Time
                        Button("Interval Notification") {
                            Task {
                                var localNotification = LocalNotification(
                                    identifier: UUID().uuidString,
                                    title: "Some title",
                                    body: "Some body",
                                    timeInterval: 10, /// time interval must be at least 60 if repeating
                                    repeats: false
                                )
                                localNotification.subtitle = "This is a subtitle"
                                localNotification.bundleImageName = "Swift.png"
                                localNotification.userInfo = ["nextView" : NextView.renew.rawValue]
                                localNotification.categoryIdentifier = "snooze"
                                
                                await lnManager.schedule(localNotification: localNotification)
                            }
                        }
                        .buttonStyle(.bordered)
                        
                        /// Calendar
                        GroupBox {
                            DatePicker("", selection: $scheduleDate)
                            Button("Calendar Notification") {
                                Task {
                                    let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: scheduleDate)
                                    let localNotification = LocalNotification(
                                        identifier: UUID().uuidString,
                                        title: "Calendar Notification",
                                        body: "Some Body",
                                        dateComponents: dateComponents,
                                        repeats: false
                                    )
                                    
                                    await lnManager.schedule(localNotification: localNotification)
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .frame(width: 300)
                    
                    /// List requests
                    List {
                        ForEach(lnManager.pendingRequests, id: \.identifier) { request in
                            VStack(alignment: .leading) {
                                Text(request.content.title)
                                HStack {
                                    Text(request.identifier)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    lnManager.removeRequest(withIdentifier: request.identifier)
                                }
                            }
                        }
                    }
                    
                } else {
                    Button("Enable Notification") {
                        lnManager.openSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Local Notifcation")
            .sheet(item: $lnManager.nextView) { nextView in
                nextView.view()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        lnManager.clearRequests()
                    } label: {
                        Image(systemName: "clear.fill")
                            .imageScale(.large)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .task {
            try? await lnManager.requestAuthorization()
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            /// Checking again authorized because afterward you change the settings and come back the app then it's not change the ui
            if newValue == .active {
                Task {
                    await lnManager.getCurrentSettings()
                    await lnManager.getPendingRequest()
                }
            }
        }
    }
}

#Preview {
    NotificationsListView()
        .environmentObject(LocalNotificationManager())
}
