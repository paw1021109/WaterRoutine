import Foundation


// 물 섭취 기록(시간, 양, 출처, 되돌림 여부)
struct IntakeEntry: Identifiable, Codable {
    var id = UUID()
    var timestamp: Date
    var amountML: Int
    var source: String? = nil
    var isReverted = false
}

//사용자 환경설정(일일 목표, 경고 임계치, 자정 리셋 등)
struct UserSettings: Codable {
    var dailyGoalML = 2000
    var overIntakeWarningML = 3000
    var enableWarning = true
    var resetAtMidnight = true
    var timezoneIdentifier = TimeZone.current.identifier
}

// 빠른 추가 버튼 프리셋(버튼 제목/양/정렬/기본값)
struct ButtonPreset: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amountML: Int
    var order: Int
    var isDefault = false

    static let defaults: [ButtonPreset] = [
        .init(title: "+100", amountML: 100, order: 0, isDefault: true),
        .init(title: "+150", amountML: 150, order: 1, isDefault: true),
        .init(title: "+200", amountML: 200, order: 2, isDefault: true)
    ]
}

struct HydrationReminder: Identifiable, Codable {
    var id = UUID()
    var startTime: DateComponents
    var endTime: DateComponents   
    var intervalMinutes: Int     
    var minIntakeByCheckpointML: Int? = nil
    var isEnabled = true

    static func sampleDaily(start: Int = 9, end: Int = 21, every minutes: Int = 120) -> HydrationReminder {
        .init(startTime: .init(hour: start), endTime: .init(hour: end), intervalMinutes: minutes)
    }
}

struct TimeBucket: Identifiable, Codable {
    var id = UUID()
    var start: Date
    var end: Date
    var totalML: Int = 0
}

struct Summary: Codable {
    var periodStart: Date
    var periodEnd: Date
    var totalML: Int
    var progress: Double
    var buckets: [TimeBucket]
}
