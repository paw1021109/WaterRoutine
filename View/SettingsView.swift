import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm: WaterViewModel
    @State private var goalText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("일일 목표") {
                    HStack {
                        TextField("목표 mL", text: $goalText).keyboardType(.numberPad)
                        Text("mL").foregroundStyle(.secondary)
                    }
                    Stepper(value: $vm.settings.dailyGoalML, in: 0...10000, step: 50) {
                        Text("현재 목표: \(vm.settings.dailyGoalML) mL")
                    }
                }
            }
            .navigationTitle("설정")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("완료") { dismiss() } } }
            .onAppear { goalText = String(vm.settings.dailyGoalML) }
        }
    }
}
