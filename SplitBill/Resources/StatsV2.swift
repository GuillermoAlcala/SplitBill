//
//  StatsV2.swift
//  SplitBill
//
//  Versión expandida de Stats con múltiples charts e interactividad avanzada.
//  Requiere iOS 26.0+
//
//  Mejoras vs Stats.swift original:
//  • Lollipop selection con RuleMark + annotation en el chart principal
//  • BarMark horizontal "Top 5 días" con gradiente y annotation
//  • SectorMark donut con distribución por rango de monto
//  • Stacked BarMark: subtotal vs propina
//  • RectangleMark heatmap día-de-semana × semana
//  • LineMark multi-serie: comparativa periodo actual vs anterior
//  • StatCards con mini-sparklines inline
//  • chartScrollableAxes para datasets grandes
//

import SwiftUI
import SwiftData
import Charts

// MARK: - Vista principal

@available(iOS 26.0, *)
struct StatsV2: View {

// MARK: Estado

@State private var selectedDate: Date?
@State private var selectedFilter: Split_Model.FilterType = .month
@State private var chartTab: ChartTab = .trend

@Query(sort: \Split_Model.currentDate, order: .forward)
private var allBills: [Split_Model]

// MARK: Tipos auxiliares

/// Pestañas para alternar entre los charts secundarios (mantiene el scroll corto).
enum ChartTab: String, CaseIterable, Identifiable {
    case trend       = "Tendencia"
    case top         = "Top días"
    case distribution = "Distribución"
    case composition = "Composición"
    case heatmap     = "Heatmap"
    case compare     = "Comparativa"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .trend:        "chart.xyaxis.line"
        case .top:          "trophy.fill"
        case .distribution: "chart.pie.fill"
        case .composition:  "chart.bar.fill"
        case .heatmap:      "square.grid.3x3.fill"
        case .compare:      "rectangle.lefthalf.inset.filled.arrow.left"
        }
    }
}

/// Categorías de monto para SectorMark / agrupación.
enum AmountBucket: String, CaseIterable, Identifiable {
    case bajo    = "Bajo (<$300)"
    case medio   = "Medio ($300–800)"
    case alto    = "Alto ($800–2K)"
    case premium = "Premium (>$2K)"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .bajo:    .green
        case .medio:   .blue
        case .alto:    .orange
        case .premium: .pink
        }
    }
    
    static func bucket(for amount: Double) -> AmountBucket {
        switch amount {
        case ..<300:        .bajo
        case 300..<800:     .medio
        case 800..<2_000:   .alto
        default:            .premium
        }
    }
}

// MARK: Datos derivados

/// Aplica el filtro temporal seleccionado.
var filteredBills: [Split_Model] {
    let cal = Calendar.current
    let today = Date()
    switch selectedFilter {
    case .week:  return allBills.filter { cal.isDate($0.currentDate, equalTo: today, toGranularity: .weekOfYear) }
    case .month: return allBills.filter { cal.isDate($0.currentDate, equalTo: today, toGranularity: .month) }
    case .year:  return allBills.filter { cal.isDate($0.currentDate, equalTo: today, toGranularity: .year) }
    case .all:   return allBills
    }
}

/// Cuentas del periodo *anterior* equivalente — para la comparativa.
var previousPeriodBills: [Split_Model] {
    let cal = Calendar.current
    let today = Date()
    guard let prev = cal.date(byAdding: prevPeriodComponent(), to: today) else { return [] }
    switch selectedFilter {
    case .week:  return allBills.filter { cal.isDate($0.currentDate, equalTo: prev, toGranularity: .weekOfYear) }
    case .month: return allBills.filter { cal.isDate($0.currentDate, equalTo: prev, toGranularity: .month) }
    case .year:  return allBills.filter { cal.isDate($0.currentDate, equalTo: prev, toGranularity: .year) }
    case .all:   return []
    }
}

private func prevPeriodComponent() -> DateComponents {
    switch selectedFilter {
    case .week:  DateComponents(weekOfYear: -1)
    case .month: DateComponents(month: -1)
    case .year:  DateComponents(year: -1)
    case .all:   DateComponents()
    }
}

// Métricas agregadas
var totalSplits: Int       { filteredBills.count }
var totalAmount: Double    { filteredBills.reduce(0) { $0 + $1.totalAmount } }
var averageAmount: Double  { filteredBills.isEmpty ? 0 : totalAmount / Double(totalSplits) }
var averagePeople: Double {
    guard !filteredBills.isEmpty else { return 0 }
    return Double(filteredBills.reduce(0) { $0 + $1.numberOfPeople }) / Double(totalSplits)
}
var averageTip: Double {
    guard !filteredBills.isEmpty else { return 0 }
    return Double(filteredBills.reduce(0) { $0 + $1.tip.percentage }) / Double(totalSplits)
}

/// Cuenta seleccionada vía `chartXSelection` (lollipop).
var selectedBill: Split_Model? {
    guard let selectedDate else { return nil }
    let cal = Calendar.current
    return filteredBills.min(by: {
        abs($0.currentDate.timeIntervalSince(selectedDate)) <
            abs($1.currentDate.timeIntervalSince(selectedDate))
    }).flatMap { cal.isDate($0.currentDate, inSameDayAs: selectedDate) ? $0 : $0 }
}

// MARK: Body

var body: some View {
    NavigationStack {
        ScrollView {
            VStack(spacing: 20) {
                if filteredBills.isEmpty {
                    ContentUnavailableView(
                        "No hay datos para graficar",
                        systemImage: "chart.line.downtrend.xyaxis",
                        description: Text("Agrégalos desde Home")
                    )
                    .padding(.top, 60)
                } else {
                    filterPicker
                    summaryGrid
                    chartTabPicker
                    chartSection
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.vertical)
            .animation(.smooth(duration: 0.35), value: chartTab)
            .animation(.smooth(duration: 0.35), value: selectedFilter)
        }
        .navigationTitle("Stats")
        .background(.background.tertiary)
    }
}

@ChartContentBuilder
private func heatmapCell(_ cell: HeatCell) -> some ChartContent {
    RectangleMark(
        xStart: .value("Semana", cell.weekStart),
        xEnd:   .value("Semana fin", cell.weekEnd),
        yStart: .value("Día", cell.yStart),
        yEnd:   .value("Día fin", cell.yEnd)
    )
    .foregroundStyle(by: .value("Monto", cell.value))
    .opacity(cell.value == 0 ? 0.08 : 1)
}

// MARK: - Sub-vistas: header

/// Picker segmentado de filtro temporal con efecto glass.
private var filterPicker: some View {
    Picker("Filter", selection: $selectedFilter) {
        ForEach(Split_Model.FilterType.allCases, id: \.self) { f in
            Text(LocalizedStringKey(f.rawValue)).tag(f)
        }
    }
    .pickerStyle(.segmented)
    .glassEffect(.regular, in: .rect(cornerRadius: 12))
    .padding(.horizontal)
    .sensoryFeedback(.selection, trigger: selectedFilter)
}

/// Cuatro StatCards con mini-sparkline inline.
private var summaryGrid: some View {
    LazyVGrid(columns: [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ], spacing: 12) {
        SparklineCard(
            title: "Total",
            value: totalAmount.formatted(.currency(code: currencyCode)),
            icon: "dollarsign.circle.fill",
            tint: .indigo,
            values: filteredBills.map(\.totalAmount)
        )
        SparklineCard(
            title: "Splits",
            value: "\(totalSplits)",
            icon: "fork.knife",
            tint: .orange,
            values: filteredBills.map { Double($0.numberOfPeople) }
        )
        SparklineCard(
            title: "Personas",
            value: String(format: "%.1f", averagePeople),
            icon: "person.2.fill",
            tint: .teal,
            values: filteredBills.map { Double($0.numberOfPeople) }
        )
        SparklineCard(
            title: "Propina prom.",
            value: "\(Int(averageTip))%",
            icon: "percent",
            tint: .pink,
            values: filteredBills.map { Double($0.tip.percentage) }
        )
    }
    .padding(.horizontal)
}

/// Picker horizontal scrollable para elegir el chart secundario.
private var chartTabPicker: some View {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
            ForEach(ChartTab.allCases) { tab in
                Button {
                    chartTab = tab
                } label: {
                    Label(tab.rawValue, systemImage: tab.icon)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            chartTab == tab
                            ? AnyShapeStyle(.tint)
                            : AnyShapeStyle(.regularMaterial)
                        )
                        .foregroundStyle(chartTab == tab ? .white : .primary)
                        .clipShape(.capsule)
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: chartTab)
            }
        }
        .padding(.horizontal)
    }
}

@ViewBuilder
private var chartSection: some View {
    switch chartTab {
    case .trend:        trendChart
    case .top:          topDaysChart
    case .distribution: distributionDonut
    case .composition:  compositionChart
    case .heatmap:      heatmapChart
    case .compare:      comparisonChart
    }
}

// MARK: - 1) Trend chart con lollipop selection

/// Chart principal: AreaMark + LineMark + PointMark.
/// Al seleccionar una fecha, aparece RuleMark vertical + annotation con detalle.
private var trendChart: some View {
    ChartCard(title: "Tendencia de gastos", subtitle: "Selecciona un punto para ver detalles") {
        Chart {
            ForEach(filteredBills) { bill in
                AreaMark(
                    x: .value("Fecha", bill.currentDate),
                    y: .value("Monto", bill.totalAmount)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.indigo.opacity(0.35), .indigo.opacity(0.02)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("Fecha", bill.currentDate),
                    y: .value("Monto", bill.totalAmount)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.indigo)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                
                PointMark(
                    x: .value("Fecha", bill.currentDate),
                    y: .value("Monto", bill.totalAmount)
                )
                .symbolSize(30)
                .foregroundStyle(.indigo)
            }
            
            // Línea de promedio
            RuleMark(y: .value("Promedio", averageAmount))
                .foregroundStyle(.orange.opacity(0.7))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                .annotation(position: .top, alignment: .leading) {
                    Text("Prom \(averageAmount.formatted(.currency(code: currencyCode)))")
                        .font(.caption2.bold())
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(.orange.opacity(0.12), in: .capsule)
                }
            
            // LOLLIPOP: aparece solo cuando hay selección.
            if let bill = selectedBill {
                RuleMark(x: .value("Sel", bill.currentDate))
                    .foregroundStyle(.gray.opacity(0.4))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3]))
                    .annotation(
                        position: .top,
                        alignment: .center,
                        spacing: 0,
                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
                    ) {
                        lollipopAnnotation(for: bill)
                    }
                
                PointMark(
                    x: .value("Fecha", bill.currentDate),
                    y: .value("Monto", bill.totalAmount)
                )
                .symbolSize(120)
                .foregroundStyle(.indigo)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine().foregroundStyle(.gray.opacity(0.15))
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    .font(.caption2)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine().foregroundStyle(.gray.opacity(0.15))
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(v.formatted(.number.notation(.compactName)))
                            .font(.caption2)
                    }
                }
            }
        }
        .chartXSelection(value: $selectedDate)
        .frame(height: 260)
    }
}

/// Tarjeta flotante que muestra detalle de la cuenta seleccionada.
@ViewBuilder
private func lollipopAnnotation(for bill: Split_Model) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(bill.currentDate, format: .dateTime.day().month(.abbreviated).year())
            .font(.caption2)
            .foregroundStyle(.secondary)
        Text(bill.totalAmount.formatted(.currency(code: currencyCode)))
            .font(.headline.bold())
            .foregroundStyle(.indigo)
        HStack(spacing: 8) {
            Label("\(bill.numberOfPeople)", systemImage: "person.2.fill")
            Label("\(bill.tip.percentage)%", systemImage: "percent")
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
    .padding(8)
    .background(.regularMaterial, in: .rect(cornerRadius: 10))
    .overlay(
        RoundedRectangle(cornerRadius: 10)
            .stroke(.indigo.opacity(0.3), lineWidth: 1)
    )
    .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
}

// MARK: - 2) Top 5 días — BarMark horizontal

/// Top 5 días con mayor gasto. BarMark horizontal + gradient + annotation.
private var topDaysChart: some View {
    let top = topDaysData()
    return ChartCard(title: "Top 5 días", subtitle: "Los días con mayor gasto total") {
        Chart(top) { item in
            BarMark(
                x: .value("Monto", item.amount),
                y: .value("Fecha", item.label)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.indigo, .purple],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .annotation(position: .trailing, alignment: .leading) {
                Text(item.amount.formatted(.currency(code: currencyCode)))
                    .font(.caption2.bold())
                    .foregroundStyle(.indigo)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks { _ in
                AxisValueLabel().font(.caption2)
            }
        }
        .frame(height: CGFloat(top.count) * 44 + 20)
    }
}

/// Agrupa por día y devuelve los 5 con mayor monto acumulado.
private func topDaysData() -> [LabeledAmount] {
    let cal = Calendar.current
    let grouped = Dictionary(grouping: filteredBills) {
        cal.startOfDay(for: $0.currentDate)
    }
    return grouped
        .map { (day, bills) in
            LabeledAmount(
                id: day,
                label: day.formatted(.dateTime.day().month(.abbreviated)),
                amount: bills.reduce(0) { $0 + $1.totalAmount }
            )
        }
        .sorted { $0.amount > $1.amount }
        .prefix(5)
        .map { $0 }
}

// MARK: - 3) Donut por rango de monto — SectorMark

/// SectorMark con buckets de monto. Anillo (donut) con leyenda lateral.
private var distributionDonut: some View {
    let buckets = bucketDistribution()
    return ChartCard(title: "Distribución por monto", subtitle: "¿Cómo se reparten tus cuentas?") {
        HStack(spacing: 20) {
            Chart(buckets) { bucket in
                SectorMark(
                    angle: .value("Cuentas", bucket.count),
                    innerRadius: .ratio(0.62),
                    angularInset: 1.5
                )
                .cornerRadius(4)
                .foregroundStyle(by: .value("Rango", bucket.label))
                .annotation(position: .overlay) {
                    if bucket.count > 0 {
                        Text("\(bucket.count)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                    }
                }
            }
            .chartForegroundStyleScale(
                domain: AmountBucket.allCases.map(\.rawValue),
                range: AmountBucket.allCases.map(\.color)
            )
            .chartLegend(.hidden)
            .frame(width: 160, height: 160)
            .overlay {
                VStack(spacing: 0) {
                    Text("\(totalSplits)")
                        .font(.title2.bold())
                    Text("cuentas")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Leyenda custom — más legible que la default.
            VStack(alignment: .leading, spacing: 8) {
                ForEach(buckets) { b in
                    HStack(spacing: 8) {
                        Circle().fill(b.color).frame(width: 10, height: 10)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(b.label).font(.caption2)
                            Text("\(b.count) (\(b.percent)%)")
                                .font(.caption2.bold())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 200)
    }
}

private func bucketDistribution() -> [BucketDatum] {
    let grouped = Dictionary(grouping: filteredBills) { AmountBucket.bucket(for: $0.totalAmount) }
    let total = max(totalSplits, 1)
    return AmountBucket.allCases.map { b in
        let count = grouped[b]?.count ?? 0
        return BucketDatum(
            id: b,
            label: b.rawValue,
            color: b.color,
            count: count,
            percent: Int(round(Double(count) / Double(total) * 100))
        )
    }
}

// MARK: - 4) Composición: subtotal vs propina — Stacked BarMark

/// Stacked BarMark: descompone cada día en subtotal y propina.
/// Asume que `totalAmount` ya incluye la propina; calcula subtotal a partir del %.
private var compositionChart: some View {
    let data = compositionData()
    return ChartCard(title: "Subtotal vs Propina", subtitle: "Composición de cada cuenta") {
        Chart(data) { d in
            BarMark(
                x: .value("Fecha", d.date, unit: .day),
                y: .value("Monto", d.subtotal)
            )
            .foregroundStyle(by: .value("Tipo", "Subtotal"))
            .position(by: .value("Tipo", "Subtotal"))
            
            BarMark(
                x: .value("Fecha", d.date, unit: .day),
                y: .value("Monto", d.tip)
            )
            .foregroundStyle(by: .value("Tipo", "Propina"))
            .position(by: .value("Tipo", "Propina"))
        }
        .chartForegroundStyleScale([
            "Subtotal": Color.indigo,
            "Propina":  Color.pink
        ])
        .chartLegend(position: .top, alignment: .leading)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6)) { _ in
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    .font(.caption2)
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: visibleDomainSeconds())
        .frame(height: 240)
    }
}

private struct CompositionDatum: Identifiable {
    let id = UUID()
    let date: Date
    let subtotal: Double
    let tip: Double
}

private func compositionData() -> [CompositionDatum] {
    filteredBills.map { bill in
        // total = subtotal * (1 + tip%/100)  →  subtotal = total / (1 + tip%/100)
        let factor = 1.0 + Double(bill.tip.percentage) / 100.0
        let subtotal = factor > 0 ? bill.totalAmount / factor : bill.totalAmount
        let tipAmt = bill.totalAmount - subtotal
        return CompositionDatum(date: bill.currentDate, subtotal: subtotal, tip: tipAmt)
    }
}

// MARK: - 5) Heatmap día × semana — RectangleMark

/// Heatmap: día-de-semana (eje Y) × semana del año (eje X), color = monto.
private var heatmapChart: some View {
    let data = heatmapData()
    let maxV = data.map(\.value).max() ?? 1
    return ChartCard(title: "Heatmap de gasto", subtitle: "Intensidad por día de la semana") {
        Chart(data) { cell in
            
            heatmapCell(cell)
        }
        .chartForegroundStyleScale(range: Gradient(colors: [
            .indigo.opacity(0.15), .indigo, .purple, .pink
        ]))
        .chartYAxis {
            AxisMarks(position: .leading, values: Array(1...7)) { value in
                AxisValueLabel {
                    if let d = value.as(Int.self) {
                        Text(weekdayShort(d)).font(.caption2)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6)) { _ in
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    .font(.caption2)
            }
        }
        .chartYScale(domain: 0.5...7.5)
        .chartLegend(position: .bottom, alignment: .center, spacing: 6) {
            HStack(spacing: 6) {
                Text("Menos").font(.caption2).foregroundStyle(.secondary)
                ForEach(0..<5) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.indigo.opacity(0.15 + Double(i) * 0.2))
                        .frame(width: 14, height: 10)
                }
                Text("Más").font(.caption2).foregroundStyle(.secondary)
                Text("· máx \(Int(maxV))").font(.caption2).foregroundStyle(.tertiary)
            }
        }
        .frame(height: 220)
    }
}
private struct HeatCell: Identifiable {
    let id = UUID()
    let weekStart: Date
    let weekEnd: Date
    let weekday: Int
    let value: Double
    
    // Pre-computados → quita trabajo al type-checker
    var yStart: Double { Double(weekday) - 0.5 }
    var yEnd: Double   { Double(weekday) + 0.5 }
}

private func heatmapData() -> [HeatCell] {
    let cal = Calendar.current
    // Agrupar por (inicio-de-semana, día-de-semana)
    var dict: [String: (start: Date, weekday: Int, total: Double)] = [:]
    for bill in filteredBills {
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear, .weekday], from: bill.currentDate)
        guard let start = cal.date(from: DateComponents(
            weekOfYear: comps.weekOfYear, yearForWeekOfYear: comps.yearForWeekOfYear
        )) else { continue }
        let key = "\(comps.yearForWeekOfYear ?? 0)-\(comps.weekOfYear ?? 0)-\(comps.weekday ?? 0)"
        dict[key, default: (start, comps.weekday ?? 1, 0)].total += bill.totalAmount
    }
    return dict.values.map { entry in
        let end = cal.date(byAdding: .day, value: 7, to: entry.start) ?? entry.start
        return HeatCell(weekStart: entry.start, weekEnd: end, weekday: entry.weekday, value: entry.total)
    }
}

private func weekdayShort(_ d: Int) -> String {
    // 1=Domingo (locale-dependent). Usamos los símbolos cortos del calendar.
    let symbols = Calendar.current.shortWeekdaySymbols
    let idx = (d - 1).clamped(to: 0...(symbols.count - 1))
    return symbols[idx]
}

// MARK: - 6) Comparativa periodo actual vs anterior

/// Dos LineMark con `foregroundStyle(by:)` para distinguir series.
/// Eje X = offset de día dentro del periodo (0...n), no la fecha real.
private var comparisonChart: some View {
    let (current, previous) = comparisonData()
    let series: [ComparisonPoint] = current + previous
    
    return ChartCard(
        title: "Periodo actual vs anterior",
        subtitle: comparisonSubtitle(current: current, previous: previous)
    ) {
        Chart(series) { point in
            LineMark(
                x: .value("Día", point.dayOffset),
                y: .value("Monto acum.", point.cumulative)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(by: .value("Serie", point.series))
            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
            .symbol(by: .value("Serie", point.series))
        }
        .chartForegroundStyleScale([
            "Actual":   Color.indigo,
            "Anterior": Color.pink.opacity(0.7)
        ])
        .chartSymbolScale([
            "Actual":   .circle,
            "Anterior": .square
        ])
        .chartLegend(position: .top, alignment: .leading)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6)) { value in
                AxisGridLine().foregroundStyle(.gray.opacity(0.12))
                AxisValueLabel {
                    if let d = value.as(Int.self) {
                        Text("D\(d + 1)").font(.caption2)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine().foregroundStyle(.gray.opacity(0.12))
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(v.formatted(.number.notation(.compactName))).font(.caption2)
                    }
                }
            }
        }
        .frame(height: 240)
    }
}

private struct ComparisonPoint: Identifiable {
    let id = UUID()
    let series: String
    let dayOffset: Int
    let cumulative: Double
}

private func comparisonData() -> ([ComparisonPoint], [ComparisonPoint]) {
    func accumulate(_ bills: [Split_Model], series: String) -> [ComparisonPoint] {
        let cal = Calendar.current
        let sorted = bills.sorted { $0.currentDate < $1.currentDate }
        guard let first = sorted.first?.currentDate else { return [] }
        var running = 0.0
        return sorted.map { bill in
            running += bill.totalAmount
            let day = cal.dateComponents([.day], from: first, to: bill.currentDate).day ?? 0
            return ComparisonPoint(series: series, dayOffset: day, cumulative: running)
        }
    }
    return (
        accumulate(filteredBills,      series: "Actual"),
        accumulate(previousPeriodBills, series: "Anterior")
    )
}

private func comparisonSubtitle(current: [ComparisonPoint], previous: [ComparisonPoint]) -> String {
    let curTotal = current.last?.cumulative ?? 0
    let prevTotal = previous.last?.cumulative ?? 0
    guard prevTotal > 0 else { return "Sin datos del periodo anterior" }
    let delta = (curTotal - prevTotal) / prevTotal * 100
    let arrow = delta >= 0 ? "▲" : "▼"
    return "\(arrow) \(String(format: "%.1f", abs(delta)))% vs periodo anterior"
}

// MARK: - Helpers

private var currencyCode: String {
    Locale.current.currency?.identifier ?? "USD"
}

/// Para `chartXVisibleDomain` en segundos según el filtro.
private func visibleDomainSeconds() -> TimeInterval {
    switch selectedFilter {
    case .week:  return 7 * 86_400
    case .month: return 14 * 86_400
    case .year:  return 60 * 86_400
    case .all:   return 90 * 86_400
    }
}

// Tipos auxiliares
private struct LabeledAmount: Identifiable {
    let id: Date
    let label: String
    let amount: Double
}

private struct BucketDatum: Identifiable {
    let id: AmountBucket
    let label: String
    let color: Color
    let count: Int
    let percent: Int
}
}

// MARK: - Componentes reutilizables

/// Card contenedora con título, subtítulo y contenido (un chart).
@available(iOS 26.0, *)
struct ChartCard<Content: View>: View {
let title: String
let subtitle: String
@ViewBuilder let content: Content

var body: some View {
    VStack(alignment: .leading, spacing: 12) {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        content
    }
    .padding(16)
    .background(.background.secondary, in: .rect(cornerRadius: 16))
    .padding(.horizontal)
}
}

/// StatCard con mini-sparkline (LineMark inline).
@available(iOS 26.0, *)
struct SparklineCard: View {
let title: String
let value: String
let icon: String
let tint: Color
let values: [Double]

var body: some View {
    VStack(alignment: .leading, spacing: 8) {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.bold())
                .foregroundStyle(tint)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        Text(value)
            .font(.title3.bold())
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        
        // Sparkline
        if values.count > 1 {
            Chart {
                ForEach(Array(values.enumerated()), id: \.offset) { i, v in
                    LineMark(
                        x: .value("i", i),
                        y: .value("v", v)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(tint.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 1.8, lineCap: .round))
                    
                    AreaMark(
                        x: .value("i", i),
                        y: .value("v", v)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [tint.opacity(0.3), tint.opacity(0.0)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartLegend(.hidden)
            .frame(height: 32)
        } else {
            Rectangle().fill(.clear).frame(height: 32)
        }
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.background.secondary, in: .rect(cornerRadius: 14))
}
}

// MARK: - Pequeñas extensiones

private extension Comparable {
func clamped(to limits: ClosedRange<Self>) -> Self {
    min(max(self, limits.lowerBound), limits.upperBound)
}
}

// MARK: - Preview

#Preview("StatsV2") {
if #available(iOS 26.0, *) {
    StatsV2()
        .modelContainer(for: Split_Model.self, inMemory: true)
} else {
    Text("Requiere iOS 26.0+")
}
}
