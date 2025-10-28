import SwiftUI

@MainActor final class WaterViewModel: ObservableObject {
    @Published var settings = UserSettings()
    @Published private(set) var entries: [IntakeEntry] = []
    @Published var presets: [ButtonPreset] = ButtonPreset.defaults()
    @Published var reminders: [HydrationReminder] = []

    private var calendar: Calendar { .current }
    private var midnightTimer: Timer?

    init() {
        scheduleMidnightTimer()
    }

    var todayEntries: [IntakeEntry] {
        entries.filter { calendar.isDateInToday($0.timestamp) && !$0.isReverted }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var todayTotalML: Int { todayEntries.reduce(0) { $0 + $1.amountML } }

    var progress: Double {
        guard settings.dailyGoalML > 0 else { return 0 }
        return min(Double(todayTotalML) / Double(settings.dailyGoalML), 1.0)
    }

    var quickAddValues: [Int] {
        presets.sorted { $0.order < $1.order }.prefix(3).map { $0.amountML }
    }

    func add(amount: Int) {
        guard amount > 0 else { return }
        entries.append(IntakeEntry(timestamp: Date(), amountML: amount))
    }

    func undoLast() {
        guard let idx = entries.lastIndex(where: { calendar.isDateInToday($0.timestamp) && !$0.isReverted }) else { return }
        entries[idx].isReverted = true
        objectWillChange.send()
    }

    private func scheduleMidnightTimer() {
        midnightTimer?.invalidate()
        guard settings.resetAtMidnight else { return }
        let now = Date()
        if let next = calendar.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 1), matchingPolicy: .nextTime) {
            let interval = max(1, next.timeIntervalSince(now))
            midnightTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
                self?.handleMidnight()
            }
        }
    }
    // 다음 날이 시작될 때(00:00) 내부 상태를 초기화/갱신하여 오늘 통계를 다시 계산
    private func handleMidnight() {
        objectWillChange.send()
        scheduleMidnightTimer()
    }

    // 일자별 총 섭취량 계산 함수
    func totalsByDay(last days: Int) -> [(date: Date, total: Int)] {
        guard days > 0 else { return [] }
        let start = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -(days-1), to: Date())!)
        let filtered = entries.filter { $0.timestamp >= start && !$0.isReverted }
        var dict: [Date: Int] = [:]
        for e in filtered {
            let day = calendar.startOfDay(for: e.timestamp)
            dict[day, default: 0] += e.amountML
        }
        return (0..<days).compactMap { offset in
            let d = calendar.date(byAdding: .day, value: offset, to: start)!
            return (d, dict[d, default: 0])
        }
    }

    // 주간 총 섭취량 계산 함수
    func totalsByWeek(last weeks: Int) -> [(start: Date, total: Int)] {
        guard weeks > 0 else { return [] }
        let now = Date()
        let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)!.start
        let start = calendar.date(byAdding: .weekOfYear, value: -(weeks-1), to: thisWeekStart)!
        let filtered = entries.filter { $0.timestamp >= start && !$0.isReverted }
        var dict: [Date: Int] = [:]
        for e in filtered {
            let wk = calendar.dateInterval(of: .weekOfYear, for: e.timestamp)!.start
            dict[wk, default: 0] += e.amountML
        }
        return (0..<weeks).compactMap { i in
            let s = calendar.date(byAdding: .weekOfYear, value: i, to: start)!
            return (s, dict[s, default: 0])
        }
    }

    // 월간 총 섭취량 계산 함수
    func totalsByMonth(last months: Int) -> [(start: Date, total: Int)] {
        guard months > 0 else { return [] }
        let now = Date()
        let thisMonthStart = calendar.dateInterval(of: .month, for: now)!.start
        let start = calendar.date(byAdding: .month, value: -(months-1), to: thisMonthStart)!
        let filtered = entries.filter { $0.timestamp >= start && !$0.isReverted }
        var dict: [Date: Int] = [:]
        for e in filtered {
            let m = calendar.dateInterval(of: .month, for: e.timestamp)!.start
            dict[m, default: 0] += e.amountML
        }
        return (0..<months).compactMap { i in
            let s = calendar.date(byAdding: .month, value: i, to: start)!
            return (s, dict[s, default: 0])
        }
    }
}
