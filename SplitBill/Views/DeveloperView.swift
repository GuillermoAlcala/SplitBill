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
                ZStack{
                    gradientBackground
                    VStack(spacing:10){
                    customText
                }
                }.ignoresSafeArea(.all)
                .navigationTitle("Developer")
              
        }
    }
    
    @ViewBuilder
    private var gradientBackground: some View{
        RoundedRectangle(cornerRadius: 40,style: .continuous)
        (LinearGradient(colors: [.gray,.gray.opacity(0.7)], startPoint: .top, endPoint: .bottom))
    }
    @ViewBuilder
    private var customText: some View{
        Text("Dale un vistazo a mi portafolio en la App Store, para que explores mis desarrollos más recientes.")
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity)
            .fontDesign(.monospaced)
            .shadow(radius: 1.0)
            .padding()
        Link(destination: URL(string: "https://apps.apple.com/mx/iphone/search?term=guillermo%20chacon")!, label: {
            Text("Mis Apps")
                .font(.largeTitle)
                .underline()
                .foregroundStyle(.white)
                .bold()
                .shadow(radius: 5.0)
            Image(systemName: "apple.terminal")
                .font(.system(.title))
                .foregroundStyle(.white.secondary)
                .bold()
                
                
        })
    }
}

#Preview {
    if #available(iOS 18.0, *) {
        DeveloperView()
    } else {
        // Fallback on earlier versions
    }
}
