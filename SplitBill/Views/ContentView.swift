//
//  ContentView.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 26/05/26.
//

import SwiftUI
import SwiftData
struct ContentView: View {
    @Environment(\.modelContext) private var modelcontext
    @Query(sort:\Split_Model.currentDate, order: .reverse)
    private var splitModel : [Split_Model]
    
    
    //actions
    @State private var isPresented : Bool = false

    var body: some View {
        NavigationStack{
            
            // MARK: - ADD DATA
            customOverLay
            .navigationTitle("Split Bill")
            .sheet(isPresented: $isPresented, content: {
                CreateSplitBillView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.automatic)
                .presentationBackground(.thinMaterial)
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing, content: {
                    CustomButtonPlus
                })
            })
            
            
        }
        
    }
    @ViewBuilder
    private var customOverLay: some View{
        if splitModel.isEmpty{
            ContentUnavailableView("No data found", systemImage: "frying.pan",description: Text("Create a new Split on the plus button"))
        }
    }
    
    @ViewBuilder
    private var CustomButtonPlus: some View{
        Button("Plus", systemImage: "plus"){
            isPresented = true
        }.tint(components.ButtonColorGray)
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        ContentView()
            .modelContainer(for: Split_Model.self, inMemory: true)
    } else {
        // Fallback on earlier versions
    }
}
