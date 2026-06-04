//
//  settingView.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 26/05/26.
//

import SwiftUI

@available(iOS 18.0, *)
struct SettingView: View {
    var body: some View {
        NavigationStack{
            VStack{
                Text("Dale un vistazo a mi portafolio en la App Store, para que explores un poco mis desarrollos más recientes.")
                    .multilineTextAlignment(.leading)
                    .padding()
                Link(destination: URL(string: "https://apps.apple.com/mx/iphone/search?term=guillermo%20chacon")!, label: {
                    Text("Mis Apps")
                        .font(.title)
                        .underline()
                        .foregroundStyle(.indigo)
                        .bold()
                })
            }
                .navigationTitle("Developer")
        }
    }
}

#Preview {
    if #available(iOS 18.0, *) {
        SettingView()
    } else {
        // Fallback on earlier versions
    }
}
