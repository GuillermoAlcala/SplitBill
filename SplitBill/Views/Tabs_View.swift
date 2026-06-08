//
//  TabsView.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 26/05/26.
//

import SwiftUI
@available(iOS 18.0, *)
struct Tabs_View: View {
    @State private var showTab : Bool = true
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
                SettingsView(mostrarVista: $showTab)
            }
            if showTab{
                Tab("Developer",systemImage: components.iconDeveloper,content: {
                    DeveloperView()
                })
            }
            
        
        }//TabView
        .tint(components.ButtonColorGray)
        .tabViewStyle(.automatic)
    }//View
    
}

struct HiddenFeatures: View {
    //DarkMode
    //hiddden TabView Developer
    //Delete all your information - Button - sheet
    @Binding  var isDeveloperTabVisible : Bool
    
    var body: some View {
        VStack{
                Toggle(isDeveloperTabVisible ? "Ocultar Vista" : "Mostrar Vista",
                       systemImage: isDeveloperTabVisible ? "eye" : "eye.slash",
                       isOn: $isDeveloperTabVisible)
                .toggleStyle(.switch)
                .tint(.green)
               // .contentTransition(.symbolEffect)
                .contentTransition(.symbolEffect(.replace)) // Animate symbol smoothly
        }
    }
}
