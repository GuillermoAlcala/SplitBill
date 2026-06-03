//
//  CardPerson.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 30/05/26.
//

import SwiftUI

@available(iOS 26.0, *)
struct CardPerson: View {
    //@State private var CounterPerson : Int = 1
    @Binding  var CounterPerson : Int
    let haptic = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20,style: .continuous)
                .strokeBorder(LinearGradient(colors: [.gray,.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 300, height: 100)
                .foregroundStyle(.gray.opacity(0.3))
                .shadow(radius: 1)
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
              //      .frame(width: .infinity,height: 1)
                
            }.frame(width: 250,alignment: .leading)
            
        }
    }
    @ViewBuilder
    private var customButtonView: some View{
        Button{
            if CounterPerson > 1{
         //       haptic.impactOccurred()
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
            
        //    haptic.impactOccurred()
           // withAnimation(.spring()){
                CounterPerson += 1
           // }
            
        }label: {
            Image(systemName: "plus")
                .frame(width: 15, height: 15)
         //     .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.borderedProminent)
        .tint(.indigo)

    }
}

// TODO: - AGREGAR EL ESTADO DEL COUNTER POR FUERA EN UN BINDING









//
//#Preview {
//    if #available(iOS 26.0, *) {
//        CardPerson()
//    } else {
//        // Fallback on earlier versions
//    }
//}
