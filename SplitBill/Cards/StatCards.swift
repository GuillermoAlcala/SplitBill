//
//  StatCards.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 09/06/26.
//

import SwiftUI

struct StatCards: View {
    let title : String
    let value: String
    let systemName: String?
    
    var body: some View {
        
        VStack{
            HStack{
                Image(systemName: systemName ?? "")
                
                Text(LocalizedStringKey(value))
                    //.font()
                    .multilineTextAlignment(.center)
                
                Text(LocalizedStringKey(title))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }.frame(maxWidth: .infinity)
         .padding()
         .background(.thinMaterial)
         .clipShape(RoundedRectangle(cornerRadius: 10))
        
    }
}


