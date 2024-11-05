//
//  LocalNotification.swift
//  LocalNotification
//
//  Created by Đoàn Văn Khoan on 4/11/24.
//

import Foundation

struct LocalNotification {
    
    // MARK: - Init
    
    /// Init TimeInterval
    init(
        identifier: String,
        title: String,
        body: String,
        timeInterval: Double,
        repeats: Bool
    ) {
        self.identifier = identifier
        self.scheduleType = .time
        self.title = title
        self.body = body
        self.timeInterval = timeInterval
        self.dateComponents = nil
        self.repeats = repeats
    }
    /// Init Calendar
    init(
        identifier: String,
        title: String,
        body: String,
        dateComponents: DateComponents,
        repeats: Bool
    ) {
        self.identifier = identifier
        self.scheduleType = .calendar
        self.title = title
        self.body = body
        self.timeInterval = nil
        self.dateComponents = dateComponents
        self.repeats = repeats
    }
    
    // MARK: - Enum
    enum ScheduleType {
        case time, calendar
    }
    
    // MARK: - Properties
    var identifier: String
    var scheduleType: ScheduleType
    var title: String
    var body: String
    var repeats: Bool
    var subtitle: String?
    var bundleImageName: String?
    var userInfo: [AnyHashable : Any]?
    var timeInterval: Double?
    var dateComponents: DateComponents?
    var categoryIdentifier: String?
}
