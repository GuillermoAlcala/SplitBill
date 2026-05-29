//
//  TabsView.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 26/05/26.
//

import SwiftUI
@available(iOS 18.0, *)
struct Tabs_View: View {
    var body: some View {
        TabView{
            Tab("Home",systemImage: components.iconHome, content: {
                ContentView()
            })
            
            Tab("Settings",systemImage: components.iconSettings,content: {
                SettingView()
                })
    
        }
        .tint(components.ButtonColorGray)
        .tabViewStyle(.automatic)
    }
}

