//
//  ContentView2.swift
//  SplitBill
//
//  Created by GuillermoChaconAlcala on 31/05/26.
//

import SwiftUI
import SwiftData

@available(iOS 26.0, *)
struct ContentView2: View {
    @Environment(\.modelContext) private var modelcontext
    @Query(sort: \Split_Model.currentDate, order: .reverse)
    private var splitQuery: [Split_Model]
    
    @State private var isPresented: Bool = false
    
    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
    
    // MARK: - Dashboard data
    
    private var monthSplits: [Split_Model] {
        splitQuery.filter {
            Calendar.current.isDate($0.currentDate, equalTo: .now, toGranularity: .month)
        }
    }
    
    private var monthTotal: Double {
        monthSplits.reduce(0) { $0 + $1.totalAmount }
    }
    
    private var monthCount: Int {
        monthSplits.count
    }
    
    private var monthAverage: Double {
        guard monthCount > 0 else { return 0 }
        return monthTotal / Double(monthCount)
    }
    
    private var totalPeople: Int {
        monthSplits.reduce(0) { $0 + $1.numberOfPeople }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !splitQuery.isEmpty {
                        heroSection
                        sectionHeader
                        splitsList
                    }
                }
                .padding(.horizontal, 20)
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top) { customHeader }
            .sheet(isPresented: $isPresented) {
                CreateSplitView2()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(.automatic)
                    .presentationBackground(.thinMaterial)
            }
            .overlay { customOverlay }
        }
    } //body
    
    // MARK: - Custom Header
    
    private var customHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(monthYearLabel)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .tracking(0.8)
                Text("Mis Splits")
                    .font(.system(size: 28, weight: .heavy))
                    .tracking(-0.5)
            }
            Spacer()
            plusButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.background)
    }
    
    private var monthYearLabel: String {
        let formatter = DateFormatter()
      //  formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "MMMM · yyyy"
        return formatter.string(from: .now).uppercased()
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("TOTAL ACUMULADO")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .tracking(1)
                .padding(.top, 8)
            
            heroNumber
            
            HStack(spacing: 8) {
                Text("\(monthCount) splits")
                Text("·").foregroundStyle(.tertiary)
                Text("Promedio \(monthAverage, format: .currency(code: currencyCode))")
                Text("·").foregroundStyle(.tertiary)
                Text("\(totalPeople) personas")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.top, 4)
            .padding(.bottom, 18)
        }
    }
    
    /// Número hero con decimales en menor tamaño/opacidad
    private var heroNumber: some View {
        let parts = formattedAmount(monthTotal)
        return (
            Text(parts.integer)
                .font(.system(size: 44, weight: .heavy))
                .foregroundStyle(.indigo)
            + Text(parts.decimal)
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(.indigo.opacity(0.35))
        )
        .tracking(-1.5)
    }
    
    /// Separa el monto en parte entera y decimal: "$2,847" y ".50"
    private func formattedAmount(_ value: Double) -> (integer: String, decimal: String) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        let full = formatter.string(from: NSNumber(value: value)) ?? "$0.00"
        
        if let dotRange = full.range(of: ".") {
            let integerPart = String(full[..<dotRange.lowerBound])
            let decimalPart = String(full[dotRange.lowerBound...])
            return (integerPart, decimalPart)
        }
        return (full, "")
    }
    
    // MARK: - Section header
    
    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Recientes")
                .font(.subheadline.weight(.bold))
            Spacer()
            Text("\(splitQuery.count) splits")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.bottom, 6)
    }
    
    // MARK: - Flat list (List configurado como flat)
    
    private var splitsList: some View {
        List {
            ForEach(splitQuery) { split in
                SplitFlatRow(split: split)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                    .overlay(alignment: .bottom) {
                        // Divider manual, solo si no es el último row
                        if split.id != splitQuery.last?.id {
                            Divider()
                                .padding(.leading, 4)
                        }
                    }
                    .customSwipeActionsDelete {
                        deleteRow(split)
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)  // el ScrollView padre maneja el scroll
        .frame(minHeight: CGFloat(splitQuery.count) * 60)
    }
    
    // MARK: - Empty state
    
    @ViewBuilder
    private var customOverlay: some View {
        if splitQuery.isEmpty {
            ContentUnavailableView(
                "Sin splits aún",
                systemImage: "fork.knife",
                description: Text("Toca el botón + para crear tu primer split")
            )
        }
    }
    
    // MARK: - Plus button
    
    private var plusButton: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.indigo, in: Circle())
        }
    }
    
    // MARK: - Actions
    
    private func deleteRow(_ split: Split_Model) {
        modelcontext.delete(split)
        try? modelcontext.save()
    }
}

// MARK: - SplitFlatRow

@available(iOS 26.0, *)
struct SplitFlatRow: View {
    let split: Split_Model
    
    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(split.totalAmount, format: .currency(code: currencyCode))
                    .font(.system(size: 15, weight: .semibold))
                
                Text("\(split.numberOfPeople) personas · \(split.tip.rawValue) propina")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(split.totalPerson, format: .currency(code: currencyCode))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.indigo)
                
                Text(relativeDate(split.currentDate))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
    }
    
    /// "Hoy", "Ayer", o fecha corta
    private func relativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Hoy" }
        if calendar.isDateInYesterday(date) { return "Ayer" }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        ContentView2()
            .modelContainer(for: Split_Model.self, inMemory: true)
    }
}
