//
//  SplitBillApp.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 26/05/26.
//

import SwiftUI
import SwiftData

@available(iOS 18.0, *)
@main
struct SplitBillApp: App {
    var body: some Scene {
        WindowGroup {
            Tabs_View()
        }
        .modelContainer(for: Split_Model.self)
    }
}
