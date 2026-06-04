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
                if #available(iOS 26.0, *) {
                    ContentView2()
                } else {
                    // Fallback on earlier versions
                }
            })
            
            Tab("Settings", systemImage: components.iconSettings){
                SettingsView()
            }
            Tab("Developer",systemImage: components.iconDeveloper,content: {
                DeveloperView()
                })
    
        }
        .tint(components.ButtonColorGray)
        .tabViewStyle(.automatic)
    }
}

