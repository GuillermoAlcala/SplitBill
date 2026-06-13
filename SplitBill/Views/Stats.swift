//
//  Stats.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 08/06/26.
//

import SwiftUI
import SwiftData
import Charts
@available(iOS 26.0, *)
struct Stats: View {
    @State private var selectedDate : Date?
    @State private var selectedFiltered : Split_Model.FilterType = .all //estado para filtrar mediante un picker
    
    @Query(sort:\Split_Model.currentDate, order: .forward)
    private var GetStats : [Split_Model]
    
    //variable para filtrar por semana, mes, año, todo
    var filteredBills: [Split_Model]{
        let calendar = Calendar.current
        let today    = Date()
        
        //usamos el switch con la variable de estado selectedFiltered para cada caso del enum
        switch selectedFiltered {
        
        case .week:
            return GetStats.filter{
                calendar.isDate($0.currentDate, equalTo: today, toGranularity: .weekOfYear)
            }
        case .month:
            return GetStats.filter{
                calendar.isDate($0.currentDate, equalTo: today, toGranularity: .month)
            }
            
        case .year:
            return GetStats.filter{
                calendar.isDate($0.currentDate, equalTo: today, toGranularity: .year)
            }
            
        case .all:
            return GetStats
        }
    }
    //calculo de numero de splits
    var TotalSplits: Int{
        filteredBills.count
    }
    
    var TotalAmount: Double{
        filteredBills.reduce(0){ $0 + $1.totalAmount}
    }
    
    var averageTotalAmount: Double{
        guard !filteredBills.isEmpty else{return 0}
        let avgTotal = filteredBills.reduce(0){
            $0 + $1.totalAmount
        }
        return Double(avgTotal) / Double(filteredBills.count)
    }
    
    
    var averagePeople: Double{
        guard !filteredBills.isEmpty else{return 0}
        let totalPeople = filteredBills.reduce(0){
            $0 + $1.numberOfPeople
        }
        return Double(totalPeople) / Double(filteredBills.count)
    }
    
    var averageTip: Double {
        guard !filteredBills.isEmpty else { return 0 }
        let totalTips = filteredBills.reduce(0) {
            $0 + $1.tip.percentage
        }
        return Double(totalTips) / Double(filteredBills.count)
    }
    
    var body: some View {
        NavigationStack{
            VStack(){
                if filteredBills.isEmpty{
                    ContentUnavailableView("No hay Datos para graficar",
                                           systemImage: components.iconStats,
                                           description: Text("Agregalos desde Home"))
                }else{
                    Picker("Filter", systemImage: components.iconStats, selection: $selectedFiltered){
                        ForEach(Split_Model.FilterType.allCases,id:\.self){ bills in
                            Text(LocalizedStringKey(bills.rawValue))
                                .tag(bills)
                        }
                    }.pickerStyle(.segmented)
                        .glassEffectTransition(.identity)
                        .padding(.horizontal)
                    Chart(filteredBills){ data in
                        AreaMark(x: .value("Date", data.currentDate),
                                 y: .value("Total Amount", data.totalAmount))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.indigo.opacity(0.2))
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        
                        LineMark(x: .value("Date", data.currentDate),
                                 y: .value("Amount", data.totalAmount))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.indigo.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 4.5))
                        
                        PointMark(x: .value("Date", data.currentDate),
                                  y: .value("Amount", data.totalAmount))
                        //                .annotation(content: {
                        //                    Text("Tips: \(data.tip.rawValue)")
                        //                        .font(.caption2)
                        //
                        //                })
                        .symbolSize(30)
                        .foregroundStyle(.indigo.secondary)
                        
                        RuleMark(y:.value("Average", TotalAmount/Double(TotalSplits)))
                            .foregroundStyle(.orange)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                            .interpolationMethod(.catmullRom)
                            .annotation(position: .automatic, alignment: .center) {
                                Text("Prom \(String(format:"%.1f",averageTotalAmount))★")
                                    .font(.caption2).foregroundStyle(.red).bold()
                            }

                        
                        
                    }
                    
                    .padding(.horizontal)
                    .frame(height: 250)
                    .background(.ultraThinMaterial)
                    .chartXAxis {
                        AxisMarks(values: .automatic) { value in
                            AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        }
                    }
                    
                    .chartYScale(range: .plotDimension)
                    .chartXSelection(value: $selectedDate)
                    if let selectedDate {
                        Text(selectedDate.formatted(
                            date: .abbreviated,
                            time: .omitted
                        ))
                        .font(.headline)
                    }
                    LazyVGrid(columns: [
                        GridItem(.flexible(),spacing: 5),
                        GridItem(.flexible(), spacing: 5),
                    ]){
                        
                        StatCards(title: "Total Amount",
                                  value: TotalAmount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")), systemName: "")
                        
                        StatCards(title: "Splits",
                                  value:"\(TotalSplits)",
                                  systemName: "fork.knife")
                        
                        
                        StatCards(title:"People",
                                  value: "\(Int(averagePeople))",
                                  systemName: "person.2")
                        
                        StatCards(title: "Tip",
                                  value: "\(Int(averageTip))",
                                  systemName: "percent")
                        
                    }.padding()
                    
                 
                }
                    
            }
            .navigationTitle("Stats")
            //.navigationSubtitle("Period:\(Date().formatted(.dateTime.month(.abbreviated).year()))")
        }//NavigationStack
        
    }
}
//
//#Preview {
//    if #available(iOS 26.0, *) {
//        Stats()
//    } else {
//        // Fallback on earlier versions
//    }
//}
