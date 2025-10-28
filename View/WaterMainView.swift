import SwiftUI

struct WaterMainView: View {
    @StateObject private var vm = WaterViewModel()
    @State private var showingSettings = false
    @State private var showingStats = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                header
                progressCard
                quickAddRow
                entriesList
            }
            .padding()
            .navigationTitle("Water Routine")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showingSettings = true } label: { Image(systemName: "gearshape") }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingStats = true } label: { Image(systemName: "chart.bar") }
                }
            }
            .sheet(isPresented: $showingSettings) { SettingsView(vm: vm) }
            .sheet(isPresented: $showingStats) { StatsView(vm: vm) }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(todayString(Date()))
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("총 섭취량: \(vm.todayTotalML) mL / \(vm.settings.dailyGoalML) mL")
                .font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressCard: some View {
        VStack(spacing: 8) {
            ProgressView(value: vm.progress)
            Text(String(format: "달성률 %.0f%%", vm.progress * 100))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var quickAddRow: some View {
        HStack(spacing: 12) {
            ForEach(vm.quickAddValues, id: \.self) { ml in
                Button("+\(ml)") { vm.add(amount: ml) }
                    .buttonStyle(.borderedProminent)
            }
            Spacer()
            Button {
                vm.undoLast()
            } label: {
                Label("되돌리기", systemImage: "arrow.uturn.backward")
            }
            .buttonStyle(.bordered)
        }
    }

    private var entriesList: some View {
        List(vm.todayEntries) { entry in
            HStack {
                Text(timeString(entry.timestamp))
                Spacer()
                Text("\(entry.amountML) mL")
            }
        }
        .listStyle(.plain)
    }

    private func todayString(_ date: Date) -> String {
        let f = DateFormatter(); f.locale = .current; f.dateFormat = "yyyy.MM.dd (E)"; return f.string(from: date)
    }
    private func timeString(_ date: Date) -> String {
        let f = DateFormatter(); f.locale = .current; f.dateFormat = "HH:mm"; return f.string(from: date)
    }
}

#Preview { WaterMainView() }
