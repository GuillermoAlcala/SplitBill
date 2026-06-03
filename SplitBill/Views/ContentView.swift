//
//  ContentView.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 26/05/26.
//

import SwiftUI
import SwiftData
@available(iOS 26.0, *)
struct ContentView: View {
    @Environment(\.modelContext) private var modelcontext
    @Query(sort:\Split_Model.currentDate, order: .reverse)
    private var splitQuery : [Split_Model]
    
    
    //actions
    @State private var isPresented : Bool = false

    var body: some View {
        NavigationStack{
            List{
                ForEach(splitQuery){ split in
                    // MARK: - RowSplit almacena solamente las filas en un Hstack
                    rowSplit(split: split)
                    
                    // MARK: - CustomSwipeActions es una extension para usar el swipe en cualquier parte del código
                        .customSwipeActionsDelete {
                   // MARK: - deleteRow, es una función para eliminar cada uno
                            deleteRow(split)
                        }
                        .customSwipActions_Undo_Share(
                            onDelete: {
                                //funcion deleteRow
                                deleteRow(split)
                        },
                            onUndo: UndoAction,
                            onShare: ShareAction)
                    
                }
                
            }
            .navigationTitle("Split Bill")
            .sheet(isPresented: $isPresented, content: {
                //CreateSplitBillView()
                CreateSplitView2()
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
            
            .overlay(content: {
                customOverLay
            })
            
        }//navigationStack
        
    }
    
    struct rowSplit:  View {
        let split : Split_Model
        var body: some View {
                HStack{
                    Text("\(split.totalAmount,format:.currency(code: Locale.current.currency?.identifier ?? "USD"))")
                    
                    Text("\(split.currentDate.formatted(date:.numeric, time: .omitted))")
                    .font(.subheadline).foregroundStyle(.secondary)
                }

        }
    }
    
    @ViewBuilder
    private var customOverLay: some View{
        if splitQuery.isEmpty{
            ContentUnavailableView("No data found", systemImage: "frying.pan",description: Text("Create a new Split on the plus button"))
        }
    }
    
    @ViewBuilder
    private var CustomButtonPlus: some View{
        Button("Plus", systemImage: "plus"){
            isPresented = true
        }.tint(components.ButtonColorGray)
    }
    
    //función para eliminar records
   private func deleteRow(_ split: Split_Model){
        modelcontext.delete(split)
        try? modelcontext.save()
        
    }
    
    
} //struct

extension View{
    func customSwipeActionsDelete(onDelete: @escaping() -> Void) -> some View{
        self.swipeActions(edge: .trailing, allowsFullSwipe: false){
            
            // MARK: - DELETE BUTTON
            Button("Delete",systemImage: "trash",role: .destructive){
                    onDelete()
            }.tint(.pink)
        }
    }
}

extension View{
    func customSwipActions_Undo_Share(
        onDelete: @escaping()-> Void,
        onUndo:   @escaping()-> Void,
        onShare:  @escaping()->Void) -> some View{
            
        self.swipeActions(edge: .leading, allowsFullSwipe: false){
            
            //delete
            Button("Delete", systemImage: "trash", role: .destructive){
                onDelete()
            }
            //undo
            Button("Undo",systemImage: "arrow.uturn.backward"){
                onUndo()
            }.tint(.mint)
            
            Button("Share", systemImage: "square.and.arrow.up"){
                onShare()
            }.tint(Color.indigo)
        }
    }
}

func UndoAction(){
    
}
func ShareAction(){
    
}

#Preview {
    if #available(iOS 26.0, *) {
        ContentView()
            .modelContainer(for: Split_Model.self, inMemory: true)
    } else {
        // Fallback on earlier versions
    }
}
