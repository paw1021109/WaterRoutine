import SwiftUI

struct StatsView: View {
    @ObservedObject var vm: WaterViewModel
    @State private var tab: Tab = .day

    enum Tab: String, CaseIterable { case day = "일", week = "주", month = "월" }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("범위", selection: $tab) {
                    ForEach(Tab.allCases, id: \.self) { t in Text(t.rawValue).tag(t) }
                }
                .pickerStyle(.segmented)

                listSection
            }
            .padding()
            .navigationTitle("통계")
        }
    }

    @ViewBuilder private var listSection: some View {
        switch tab {
        case .day:
            let items = vm.totalsByDay(last: 7)
            StatList(items.map { (label: dateString($0.date, format: "MM/dd"), value: $0.total) }, goal: vm.settings.dailyGoalML)
        case .week:
            let items = vm.totalsByWeek(last: 4)
            StatList(items.map { (label: dateString($0.start, format: "MM/dd"), value: $0.total) }, goal: vm.settings.dailyGoalML * 7)
        case .month:
            let items = vm.totalsByMonth(last: 6)
            StatList(items.map { (label: dateString($0.start, format: "yyyy/MM"), value: $0.total) }, goal: vm.settings.dailyGoalML * 30)
        }
    }

    private func dateString(_ date: Date, format: String) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = format
        return f.string(from: date)
    }
}

private struct StatList: View {
    let data: [(label: String, value: Int)]
    let goal: Int

    var body: some View {
        List(data, id: \.label) { item in
            HStack(spacing: 12) {
                Text(item.label).frame(width: 64, alignment: .leading)
                GeometryReader { geo in
                    let maxWidth = geo.size.width
                    let ratio = clamp(Double(item.value) / Double(max(goal, 1)), 0, 1)
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: maxWidth * ratio, height: 10)
                        .foregroundStyle(.tint)
                        .animation(.easeOut(duration: 0.25), value: ratio)
                }
                .frame(height: 10)
                Text("\(item.value) mL").frame(width: 90, alignment: .trailing)
            }
        }
        .listStyle(.plain)
    }

    private func clamp(_ x: Double, _ a: Double, _ b: Double) -> Double { max(a, min(b, x)) }
}

#Preview {
    StatsView(vm: WaterViewModel())
}
