//
//  CardPerson.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 30/05/26.
//

import SwiftUI

@available(iOS 26.0, *)
struct CardPerson: View {
    @State private var CounterPerson : Int = 1
    var body: some View {
        ZStack{
        RoundedRectangle(cornerRadius: 20,style: .continuous)
                .frame(width: 300, height: 100)
                .foregroundStyle(.indigo.opacity(0.5))
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: "person.2")
                    Text("Personas")
                    Spacer()
                    HStack() {
                       customButtonView
                    }
                    .frame(maxWidth: .infinity,
                           alignment: .trailing)
                }
                Text("\(CounterPerson)")
                    .font(.title2.bold())
                    .frame(width: .infinity,height: 1)
                
            }.frame(width: 250,alignment: .leading)
            
        }
    }
    @ViewBuilder
    private var customButtonView: some View{
        Button{
            if CounterPerson > 1{
                CounterPerson -= 1
            }
        }label: {
            Image(systemName: "minus")
                .frame(width: 15, height: 15)
            //  .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.borderedProminent)
        .tint(.pink.opacity(0.8))
        Button{
            CounterPerson += 1
        }label: {
            Image(systemName: "plus")
                .frame(width: 15, height: 15)
         //     .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.borderedProminent)
        .tint(.purple)

    }
}












#Preview {
    if #available(iOS 26.0, *) {
        CardPerson()
    } else {
        // Fallback on earlier versions
    }
}
