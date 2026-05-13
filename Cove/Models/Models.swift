import SwiftUI
import Foundation

// MARK: - Tab

enum CoveTab: String, CaseIterable, Identifiable {
    case today, calendar, focus, habits, journal
    var id: String { rawValue }
    var label: String {
        switch self {
        case .today: "Today"
        case .calendar: "Calendar"
        case .focus: "Focus"
        case .habits: "Habits"
        case .journal: "Journal"
        }
    }
}

// MARK: - Day Layout

enum DayLayout: String {
    case timeline, list
}

// MARK: - Task

struct CoveTask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var notes: String = ""
    var done: Bool = false
    var tag: String = "Personal"
    var priority: Int = 0 // 0=normal, 1=high
    var dateStr: String = "Today"
    var earnMinutes: Int = 5

    static let defaults: [CoveTask] = [
        CoveTask(title: "Call dentist", tag: "Personal", priority: 0, earnMinutes: 5),
        CoveTask(title: "Send proposal to Lin", done: false, tag: "Work", priority: 1, earnMinutes: 7),
        CoveTask(title: "Pick up dry cleaning", tag: "Errand", priority: 0, earnMinutes: 5),
        CoveTask(title: "Pay electric bill", done: true, tag: "Personal", priority: 0, earnMinutes: 5),
        CoveTask(title: "Confirm hotel booking", tag: "Travel", priority: 1, earnMinutes: 3),
    ]
}

// MARK: - Calendar Event

struct CalendarEvent: Identifiable {
    var id = UUID()
    var time: String   // "09:30"
    var durationMins: Int
    var title: String
    var kind: EventKind
    var tint: EventTint
    var done: Bool = false

    enum EventKind { case habit, block, meeting }
    enum EventTint: String { case work, personal, movement }

    var tintColor: Color {
        switch tint {
        case .work:     return Color(hex: "5E5CE6")
        case .personal: return .coveAccent
        case .movement: return Color(hex: "34C759")
        }
    }

    var startHour: Double {
        let parts = time.split(separator: ":").compactMap { Double($0) }
        return parts.count == 2 ? parts[0] + parts[1] / 60.0 : 0
    }

    var endTime: String {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return time }
        let total = parts[0] * 60 + parts[1] + durationMins
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    static let today: [CalendarEvent] = [
        CalendarEvent(time: "07:00", durationMins: 60,  title: "Morning walk",              kind: .habit,   tint: .movement, done: true),
        CalendarEvent(time: "08:30", durationMins: 30,  title: "Breakfast & inbox triage",  kind: .block,   tint: .personal),
        CalendarEvent(time: "09:30", durationMins: 90,  title: "Deep work · Locket spec",   kind: .block,   tint: .work),
        CalendarEvent(time: "11:30", durationMins: 45,  title: "Standup",                   kind: .meeting, tint: .work),
        CalendarEvent(time: "13:00", durationMins: 60,  title: "Lunch with Sam",             kind: .block,   tint: .personal),
        CalendarEvent(time: "14:30", durationMins: 75,  title: "Design review",              kind: .meeting, tint: .work),
        CalendarEvent(time: "16:30", durationMins: 60,  title: "Run · 5k easy",              kind: .habit,   tint: .movement),
        CalendarEvent(time: "19:00", durationMins: 30,  title: "Read · 30 min",              kind: .habit,   tint: .personal),
    ]
}

// MARK: - Habit

struct Habit: Identifiable, Codable {
    var id = UUID()
    var name: String
    var emoji: String
    var streak: Int
    var weekHistory: [Bool] // 7 days, Sun–Sat
    var completedToday: Bool = false

    static let defaults: [Habit] = [
        Habit(name: "Morning walk",      emoji: "🚶", streak: 12, weekHistory: [true,true,true,true,true,true,false]),
        Habit(name: "Meditate · 10m",   emoji: "🧘", streak: 31, weekHistory: [true,true,true,true,true,true,true], completedToday: true),
        Habit(name: "Read · 30m",        emoji: "📖", streak: 4,  weekHistory: [true,true,false,true,true,false,false]),
        Habit(name: "No phone after 10", emoji: "🌙", streak: 7,  weekHistory: [true,true,true,true,true,true,false]),
        Habit(name: "Drink 2L water",    emoji: "💧", streak: 2,  weekHistory: [false,true,false,true,true,true,false], completedToday: true),
        Habit(name: "Run · 5k",          emoji: "🏃", streak: 0,  weekHistory: [false,false,false,false,true,false,false]),
    ]
}

// MARK: - Journal Entry

struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date = .now
    var title: String = ""
    var body: String = ""
    var mood: Int = 2 // 0–4 index
    var tags: [String] = []
}

// MARK: - Focus Session

struct FocusSession {
    var taskTitle: String = "Deep work · Locket spec"
    var totalSeconds: Int = 45 * 60
    var remainingSeconds: Int = 45 * 60
    var isRunning: Bool = false
    var blockedApps: [BlockedApp] = BlockedApp.defaults

    var progress: Double { 1.0 - Double(remainingSeconds) / Double(totalSeconds) }
}

struct BlockedApp: Identifiable {
    var id = UUID()
    var name: String
    var letter: String
    var bgColor: Color

    static let defaults: [BlockedApp] = [
        BlockedApp(name: "Instagram", letter: "I", bgColor: Color(hex: "D62976")),
        BlockedApp(name: "X",         letter: "X", bgColor: Color(hex: "000000")),
        BlockedApp(name: "TikTok",    letter: "T", bgColor: Color(hex: "010101")),
        BlockedApp(name: "YouTube",   letter: "Y", bgColor: Color(hex: "FF0033")),
        BlockedApp(name: "Netflix",   letter: "N", bgColor: Color(hex: "E50914")),
        BlockedApp(name: "Reddit",    letter: "R", bgColor: Color(hex: "FF4500")),
        BlockedApp(name: "Apple News",letter: "N", bgColor: Color(hex: "FF2D55")),
        BlockedApp(name: "Messages",  letter: "M", bgColor: Color(hex: "34C759")),
        BlockedApp(name: "Games",     letter: "G", bgColor: Color(hex: "5856D6")),
    ]
}

// MARK: - Routine

struct Routine: Identifiable {
    var id = UUID()
    var name: String
    var emoji: String
    var durationMins: Int
    var steps: [String]
    var isRunning: Bool = false
    var currentStep: Int = 0

    static let defaults: [Routine] = [
        Routine(name: "Morning",       emoji: "🌅", durationMins: 38,
                steps: ["Wake at 6:30","10 min stretch","Make coffee","Read · 20 min","Plan top 3"],
                isRunning: true, currentStep: 2),
        Routine(name: "Deep work day", emoji: "🎯", durationMins: 240,
                steps: ["Phone in drawer","Block social + news","90 min · spec","15 min walk"]),
        Routine(name: "Wind-down",     emoji: "🌙", durationMins: 45,
                steps: ["Lock everything at 22:00","Dim lights","Journal · 3 lines","Bed by 22:45"]),
        Routine(name: "Travel day",    emoji: "✈️", durationMins: 90,
                steps: ["Pack list","Charge devices","Lock work apps","Boarding pass ready","Snack","Water bottle"]),
    ]
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 128, 128, 128)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
