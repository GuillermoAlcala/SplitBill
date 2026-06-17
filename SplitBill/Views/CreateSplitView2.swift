//
//  CreateSplitView2.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 31/05/26.
//

import SwiftUI
import SwiftData
@available(iOS 26.0, *)
struct CreateSplitView2: View {
    
    @State private var TotalAmount : Double?
    @State private var NumberOfPeople : Int = 1
    @State private var tipSelection : Split_Model.Tip = .ZeroPercent
    
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelcontext
    
    @FocusState private var AmountFocus : Bool
    
    
    var previewSplit: Split_Model{
        Split_Model(id: UUID(),
                    amount: TotalAmount ?? 0,
                    numberOfPeople: NumberOfPeople,
                    tip: tipSelection
        //            total: 0
        )
    }
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(alignment: .center){
                    Text("Total Amount")
                        .padding()
                        .font(.headline)
                    TextField(
                        "0.00",
                        value: $TotalAmount,
                        format: .currency(
                            code: Locale.current.currency?.identifier ?? "USD"
                        )
                    )
                    .focused($AmountFocus)
                    .keyboardType(.decimalPad)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .padding(.bottom,24)
                    .onAppear{
                        AmountFocus = true
                    } // probando RowSplitView2
                    CardPerson(CounterPerson: $NumberOfPeople)
                    
                    Spacer()
                    Text("Selecciona la propina").padding(8)
                    LazyVGrid(columns: [
                        GridItem(.flexible(),spacing: 8),
                        GridItem(.flexible(),spacing: 8)],spacing: 12){
                            
                            ForEach(Split_Model.Tip.allCases){ tip in
                                CardTaxes(tip: tip, isSelected: tipSelection == tip)
                                    .onTapGesture {
                                        tipSelection = tip
                                    }
                            }
                        }
                        .frame(maxWidth:220)
                    
                    Spacer()
                    Spacer()
                    Divider()
                    VStack(spacing:12){
                        Text("Total + Propina")
                            .font(.headline)
                        //  Text("$\(previewSplit.totalAmount,specifier:"%.2f")")
                        Text("\(previewSplit.totalAmount,format:.currency(code: Locale.current.currency?.identifier ?? "USD"))")
                            .font(.system(size: 38))
                            .foregroundStyle(.indigo).bold()
                        
                        Text("Por persona: \(previewSplit.totalPerson,format:.currency(code: Locale.current.currency?.identifier ?? "USD"))")
                        
                            .font(.system(size: 20))
                            .foregroundStyle(components.ButtonColorGray)
                            .bold()
                    }.padding(60)
                       
                } //VStack
                //.frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .top)
                
                //   .navigationSubtitle("New Split")
                    .toolbar(content: {
                        ToolbarItem(placement: .topBarTrailing, content: {
                            customSaveButton
                        })
                        
                        ToolbarItem(placement: .topBarLeading, content: {
                            customXmarkButton
                        })
                        
                        ToolbarItemGroup(placement: .keyboard){
                            Spacer()
                            Button("Done"){
                                AmountFocus = false
                            }
                        }
                    })
            }
        }//navigations
        
        
        
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
            
       //     save()
            SaveSplit()
            haptic.impactOccurred()
            dismiss()
        }
        .disabled(TotalAmount == nil || TotalAmount == 0)
            .fontDesign(.monospaced)
            .tint(components.ButtonColorGray)
    }
    
    private func SaveSplit(){
        let model = Split_Model(id: UUID(), amount:TotalAmount ?? 0,
                                 numberOfPeople: NumberOfPeople,
                                 tip: tipSelection,
                                 currentDate: .now)
        modelcontext.insert(model)
        
        do{
            try modelcontext.save()
            print("Datos guardados")
        }
        catch{
            print(error.localizedDescription)
        }
        
    }
   
    struct CardTaxes : View {
        let tip: Split_Model.Tip
        let isSelected : Bool
        var body: some View {
            ZStack{
            
         //    Text("\(tip.rawValue)")
          //      HStack{
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            isSelected ? AnyShapeStyle(LinearGradient(colors: [.gray, .blue],startPoint: .topLeading,endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.indigo.opacity(0.2)),
                            lineWidth: 3)
                        .frame(width: 90, height: 90)
                
                    Text("\(tip.rawValue)")
                        .font(.title2.bold())
                        .overlay(alignment:.topTrailing){
                            if isSelected{
                                Image(systemName: "checkmark.circle")
                                    .font(.title3)
                                    .foregroundStyle(.green)
                                    .offset(x:20,y: -20)
                                    
                                
                            }
                        }
                
                

           //     }
            }
            
        }
        
    }
    
    
}

#Preview {
    if #available(iOS 26.0, *) {
        CreateSplitView2()
    } else {
        // Fallback on earlier versions
    }
}
