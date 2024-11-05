//
//  ContentView.swift
//  LocalNotification
//
//  Created by Đoàn Văn Khoan on 4/11/24.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var lnManager: LocalNotificationManager
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationStack {
            VStack {
                
                /// Check granted
                if lnManager.isGranted {
                    
                    GroupBox("Schedule") {
                        Button("Interval Notification") {
                            Task {
                                let localNotification = LocalNotification(
                                    identifier: UUID().uuidString,
                                    title: "Some title",
                                    body: "Some body",
                                    timeInterval: 10,
                                    repeats: false
                                )
                                
                                await lnManager.schedule(localNotification: localNotification)
                            }
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Calendar Notification") {
                            
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(width: 300)
                    
                } else {
                    Button("Enable Notification") {
                        lnManager.openSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Local Notifcation")
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
    ContentView()
        .environmentObject(LocalNotificationManager())
}
