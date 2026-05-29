//
//  CreateSplitBillView.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 26/05/26.
//

import SwiftUI
import SwiftData
struct CreateSplitBillView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount: Double?
    @State private var numberOfPeople : Int = 1
    @State private var selection : Split_Model.Taxes = .ZeroPercent
    
    var previewSplit: Split_Model{
        Split_Model(id: UUID(),
                    amount: Double(amount ?? 0),
                    numberOfPeople: numberOfPeople,
                    tax: selection
        //            total: 0
        )
    }
    var body: some View {
        NavigationStack{
            VStack(){
                Text("Split the Bill")
                    .font(.system(size: 26))
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
                            Text("Total Bill + Taxes")
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
                            .frame(width: 400,height: 250)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        
                        
                    }
                    .scrollContentBackground(.hidden)
                    
                }
                VStack{
                    Text("Choose the tax")
                        .foregroundStyle(.pink.opacity(0.7))
                        .bold()
                        .padding()
                }
                ScrollView(.horizontal, showsIndicators: false,content: {
                    HStack(content: {
                        
                        ForEach(Split_Model.Taxes.allCases){ tax in
                            CardTaxes(tax: tax, isSelected: selection == tax)
                                .onTapGesture {
                                    selection = tax
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
        }
            .fontDesign(.monospaced)
            .tint(components.ButtonColorGray)
    }
    
    struct CardTaxes : View {
        let tax: Split_Model.Taxes
        let isSelected : Bool
        var body: some View {
            ZStack{
                Text("\(tax.rawValue)")
                HStack{
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            isSelected ? AnyShapeStyle(LinearGradient(colors: [.gray, .blue],startPoint: .topLeading,endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.indigo.opacity(0.2)),
                            lineWidth: 3)
                        .frame(width: 100, height: 100)
                    // MARK: - Sin gradient
//                        RoundedRectangle(cornerRadius: 20, style: .continuous)
//                        .strokeBorder(
//                            isSelected ?                              components.ButtonColorGray : Color.indigo.opacity(0.2),lineWidth: 3.0)
//                            .frame(width: 100, height: 100)
//
                }
            }
        }
    }
}

#Preview {
    CreateSplitBillView()
        .modelContainer(for: Split_Model.self, inMemory: true)
}
