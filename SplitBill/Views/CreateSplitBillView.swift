//
//  CreateSplitBillView.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 26/05/26.
//

import SwiftUI
import SwiftData
@available(iOS 26.0, *)
struct CreateSplitBillView: View {
    @Environment(\.modelContext) private var modelcontext
    @Environment(\.dismiss) private var dismiss
    @State private var amount: Double?
    @State private var numberOfPeople : Int = 1
    @State private var tipSelection : Split_Model.Tip = .ZeroPercent
    
    var previewSplit: Split_Model{
        Split_Model(id: UUID(),
                    amount: amount ?? 0,
                    numberOfPeople: numberOfPeople,
                    tip: tipSelection
        //            total: 0
        )
    }
    var body: some View {
        NavigationStack{
            VStack(){
               // Text("Split the Bill")
               //     .font(.system(size: 26))
                VStack{
                    Form{
                        TextField("Add the amount", value: $amount,
                                  format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .keyboardType(.decimalPad)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                        Stepper("Number of People: \(numberOfPeople)", value: $numberOfPeople,in: 1...100)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        VStack(spacing:12){
                            Text("Total Bill + Tip")
                                .font(.headline)
                            
                          //  Text("$\(previewSplit.totalAmount,specifier:"%.2f")")
                            Text("\(previewSplit.totalAmount,format:.currency(code: Locale.current.currency?.identifier ?? "USD"))")
                                .font(.system(size: 38))
                                .foregroundStyle(.indigo).bold()
                            Divider()
                        //    Text("Per person:\(previewSplit.totalPerson,specifier:"%.2f")")
                            Text("Per person: \(previewSplit.totalPerson,format:.currency(code: Locale.current.currency?.identifier ?? "USD"))")
                                .font(.system(size: 20))
                                .foregroundStyle(components.ButtonColorGray)
                                .bold()
                        }
                           // .frame(width: 400,height: 250)
                        .frame(maxWidth:.infinity)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        
                        
                    }
                    .scrollContentBackground(.hidden)
                    
                }
                VStack{
                    Text("Choose the tip")
                        .foregroundStyle(.pink.opacity(0.7))
                        .bold()
                        .padding()
                }
                ScrollView(.horizontal, showsIndicators: false,content: {
                    HStack(content: {
                        ForEach(Split_Model.Tip.allCases){ tip in
                            CardTaxes(tip: tip, isSelected: tipSelection == tip)
                                .onTapGesture {
                                    tipSelection = tip
                                }
                        }
                    })
                })
                
                
                
            }
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing, content: {
                       customSaveButton
                    })
                    
                    ToolbarItem(placement: .topBarLeading, content: {
                        customXmarkButton
                    })
                })
                .navigationSubtitle("New Split")
        }
        
    }
    
    
    @ViewBuilder
    private var customXmarkButton: some View{
        Button("Close",systemImage: "xmark"){
        dismiss()
        }.tint(.red)
    }
    
    @ViewBuilder
    private var customSaveButton: some View{
        Button("Save"){
            
            //implementar func
            save()
            dismiss()
        }.disabled(amount == nil || amount == 0)
            .fontDesign(.monospaced)
            .tint(components.ButtonColorGray)
    }
    
    struct CardTaxes : View {
        let tip: Split_Model.Tip
        let isSelected : Bool
        var body: some View {
            ZStack{
                Text("\(tip.rawValue)")
                HStack{
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            isSelected ? AnyShapeStyle(LinearGradient(colors: [.gray, .blue],startPoint: .topLeading,endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.indigo.opacity(0.2)),
                            lineWidth: 3)
                        .frame(width: 100, height: 100)
                }
            }
        }
    }
    
    
  private func save(){
        let split = Split_Model(id: UUID(),
                                amount: amount ?? 0 ,
                                numberOfPeople: numberOfPeople,
                                tip: tipSelection, currentDate: .now)
    
        modelcontext.insert(split)
        do{
            try modelcontext.save() // se usa try: propaga el error, try? = si falla no entra al catch y se ignora el error
            print("Data saved,\(split.totalAmount),\(split.tip)")
        }
        catch{
            print(error.localizedDescription)
        }

    }
}

#Preview {
    if #available(iOS 26.0, *) {
        CreateSplitBillView()
            .modelContainer(for: Split_Model.self, inMemory: true)
    } else {
        // Fallback on earlier versions
    }
}

