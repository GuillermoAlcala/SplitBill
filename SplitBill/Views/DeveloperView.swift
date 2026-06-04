//
//  settingView.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 26/05/26.
//

import SwiftUI

@available(iOS 18.0, *)
struct DeveloperView: View {
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
    struct CustomAppBackground: View {
        var body: some View {
            ZStack {
                LinearGradient(
                    colors: [
                        Color("0a1628"),
                        Color("0d1d36"),
                        Color("142847")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                RadialGradient(
                    colors: [Color("f4a261").opacity(0.08), .clear],
                    center: UnitPoint(x: 0.2, y: 0.15),
                    startRadius: 0,
                    endRadius: 400
                )
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    if #available(iOS 18.0, *) {
        DeveloperView()
    } else {
        // Fallback on earlier versions
    }
}
