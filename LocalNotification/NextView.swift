//
//  NextView.swift
//  LocalNotification
//
//  Created by Đoàn Văn Khoan on 5/11/24.
//

import Foundation
import SwiftUI


enum NextView: String, Identifiable {

    var id: String {
        return rawValue
    }
    
    case promo, renew
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .promo:
            Text("Promotional Offer")
                .font(.largeTitle)
        case .renew:
            VStack {
                Text("Renew Subscription")
                    .font(.largeTitle)
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 128))
            }
        }
    }
}
