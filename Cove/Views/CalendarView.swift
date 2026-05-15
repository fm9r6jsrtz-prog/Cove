import SwiftUI

// MARK: - CalendarView

struct CalendarView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    var body: some View {
        ZStack(alignment: .bottom) {
            t.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                CalendarHeader()

                Divider()
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                Group {
                    switch store.calendarMode {
                    case .week:
                        WeekGridView()
                    case .month:
                        MonthGridView()
                    case .day:
                        DayTimelineView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - CalendarHeader

private struct CalendarHeader: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    var modeLabel: String {
        switch store.calendarMode {
        case .week: return "WEEK 20"
        case .month: return "MAY 2026"
        case .day: return "TODAY"
        }
    }

    var rangeLabel: String {
        switch store.calendarMode {
        case .week: return "May 11–17"
        case .month: return "May 2026"
        case .day: return "Wednesday, May 13"
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(modeLabel)
                        .font(.sfPro(size: 13, weight: .semibold))
                        .foregroundColor(t.accent)
                        .kerning(0.8)

                    Text(rangeLabel)
                        .font(.sfRounded(size: 30, weight: .bold))
                        .foregroundColor(t.text)
                }

                Spacer()

                HStack(spacing: 6) {
                    Button {
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(t.text2)
                            .frame(width: 36, height: 36)
                            .background(t.systemFill)
                            .clipShape(Circle())
                    }

                    Button {
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(t.text2)
                            .frame(width: 36, height: 36)
                            .background(t.systemFill)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // Segmented control
            Picker("Mode", selection: Binding(
                get: { store.calendarMode },
                set: { store.calendarMode = $0 }
            )) {
                Text("Day").tag(AppStore.CalendarMode.day)
                Text("Week").tag(AppStore.CalendarMode.week)
                Text("Month").tag(AppStore.CalendarMode.month)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - WeekGridView

struct WeekGridView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let weekNumbers = [11, 12, 13, 14, 15, 16, 17]
    private let todayColumn = 2 // Wednesday
    private let hourPx: CGFloat = 56
    private let startHour = 7
    private let endHour = 21
    private let nowHour: CGFloat = 11 + 47.0 / 60.0

    private var hours: [Int] { Array(startHour...endHour) }

    // Events grouped by approximate day column (0=Mon..6=Sun)
    private var eventsByColumn: [Int: [CalendarEvent]] {
        var dict: [Int: [CalendarEvent]] = [:]
        for i in 0..<7 { dict[i] = [] }
        // All sample events fall on Wednesday (column 2 = today)
        dict[2] = CalendarEvent.today
        return dict
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Day header row
                HStack(spacing: 0) {
                    // Spacer for hour labels
                    Color.clear.frame(width: 44)

                    ForEach(0..<7, id: \.self) { i in
                        VStack(spacing: 3) {
                            Text(weekDays[i])
                                .font(.sfPro(size: 11, weight: .medium))
                                .foregroundColor(i == todayColumn ? t.accent : t.text2)

                            ZStack {
                                if i == todayColumn {
                                    Circle()
                                        .fill(t.accent)
                                        .frame(width: 26, height: 26)
                                }
                                Text("\(weekNumbers[i])")
                                    .font(.sfRounded(size: 14, weight: i == todayColumn ? .bold : .regular))
                                    .foregroundColor(i == todayColumn ? .white : t.text)
                            }
                            .frame(width: 26, height: 26)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
                .background(t.surface)

                Divider()

                // Grid body
                ZStack(alignment: .topLeading) {
                    // Hour rows
                    VStack(spacing: 0) {
                        ForEach(hours, id: \.self) { hour in
                            HStack(alignment: .top, spacing: 0) {
                                Text(weekHourLabel(hour))
                                    .font(.sfPro(size: 10, weight: .medium))
                                    .foregroundColor(t.text3)
                                    .frame(width: 44, alignment: .trailing)
                                    .padding(.trailing, 6)
                                    .offset(y: -6)

                                Rectangle()
                                    .fill(t.sep.opacity(0.35))
                                    .frame(height: 0.5)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(height: hourPx)
                        }
                    }

                    // Column separators
                    HStack(spacing: 0) {
                        Color.clear.frame(width: 44)
                        ForEach(0..<7, id: \.self) { i in
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(t.sep.opacity(0.2))
                                    .frame(width: 0.5)
                                    .frame(maxHeight: .infinity)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }

                    // Events
                    GeometryReader { geo in
                        let colWidth = (geo.size.width - 44) / 7
                        ForEach(0..<7, id: \.self) { col in
                            let colEvents = eventsByColumn[col] ?? []
                            ForEach(colEvents) { event in
                                let topOffset = CGFloat(event.startHour - Double(startHour)) * hourPx
                                let height = max(CGFloat(event.durationMins) / 60.0 * hourPx, 20)
                                let xPos = 44 + CGFloat(col) * colWidth + 2

                                WeekEventBlock(event: event, height: height)
                                    .frame(width: colWidth - 4)
                                    .offset(x: xPos, y: topOffset)
                            }
                        }

                        // Now line — only on today's column
                        let nowY = CGFloat(nowHour - Double(startHour)) * hourPx
                        let todayX = 44 + CGFloat(todayColumn) * colWidth
                        HStack(spacing: 0) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 7, height: 7)
                                .offset(x: -3.5)
                            Rectangle()
                                .fill(Color.red)
                                .frame(height: 1.5)
                                .frame(width: colWidth)
                        }
                        .offset(x: todayX, y: nowY)
                    }
                }
                .frame(height: CGFloat(hours.count) * hourPx)
                .padding(.bottom, 100)
            }
        }
    }

    private func weekHourLabel(_ hour: Int) -> String {
        if hour == 12 { return "12p" }
        if hour < 12 { return "\(hour)a" }
        return "\(hour - 12)p"
    }
}

// MARK: - WeekEventBlock

private struct WeekEventBlock: View {
    @Environment(\.coveTheme) var t
    let event: CalendarEvent
    let height: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(event.tintColor)
                .frame(width: 2.5)
                .clipShape(RoundedRectangle(cornerRadius: 1.25))

            Text(event.title)
                .font(.sfPro(size: 10, weight: .semibold))
                .foregroundColor(event.done ? t.text2 : t.text)
                .strikethrough(event.done)
                .lineLimit(2)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)

            Spacer(minLength: 0)
        }
        .frame(height: height - 2, alignment: .top)
        .background(event.tintColor.opacity(event.done ? 0.06 : 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .opacity(event.done ? 0.5 : 1)
    }
}

// MARK: - MonthGridView

struct MonthGridView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    @State private var selectedDay: Int = 13

    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    // May 2026 starts on Friday (index 5 in Sun-based week)
    private let startOffset = 5
    private let daysInMonth = 31

    // Days with events (use CalendarEvent.today, all on the 13th)
    private let eventDays: Set<Int> = [7, 11, 13, 14, 20, 22, 27]

    // Number of dots per event day
    private let eventDotCounts: [Int: Int] = [7: 1, 11: 2, 13: 3, 14: 2, 20: 1, 22: 3, 27: 2]

    // All cells: nil = padding, Int = day number
    private var cells: [Int?] {
        var result: [Int?] = Array(repeating: nil, count: startOffset)
        result += (1...daysInMonth).map { Optional($0) }
        // Pad to full rows
        while result.count % 7 != 0 { result.append(nil) }
        return result
    }

    private var rows: [[Int?]] {
        stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<min($0+7, cells.count)]) }
    }

    // Sample events for selected day
    private var selectedDayEvents: [CalendarEvent] {
        if selectedDay == 13 { return CalendarEvent.today.filter { !$0.done } }
        return []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Day-of-week header
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { i in
                        Text(dayLabels[i])
                            .font(.sfPro(size: 13, weight: .medium))
                            .foregroundColor(t.text2)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)

                Divider()

                // Month grid
                VStack(spacing: 2) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: 2) {
                            ForEach(0..<7, id: \.self) { col in
                                let day = row[col]
                                MonthDayCell(
                                    day: day,
                                    isToday: day == 13,
                                    isSelected: day == selectedDay,
                                    dotCount: day.flatMap { eventDotCounts[$0] } ?? 0,
                                    t: t
                                )
                                .onTapGesture {
                                    if let d = day { selectedDay = d }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // Selected day event list
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(selectedDayHeaderText)
                            .font(.sfPro(size: 15, weight: .semibold))
                            .foregroundColor(t.text)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                    if selectedDayEvents.isEmpty {
                        Text("No events")
                            .font(.sfPro(size: 15))
                            .foregroundColor(t.text2)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(selectedDayEvents) { event in
                                HStack(spacing: 12) {
                                    Rectangle()
                                        .fill(event.tintColor)
                                        .frame(width: 4)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(event.title)
                                            .font(.sfPro(size: 15, weight: .medium))
                                            .foregroundColor(t.text)
                                        Text("\(event.time) · \(event.durationMins)m")
                                            .font(.sfPro(size: 13))
                                            .foregroundColor(t.text2)
                                    }

                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 11)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(t.surface)
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
        }
    }

    private var selectedDayHeaderText: String {
        if selectedDay == 13 { return "Wed, May 13" }
        let dayOfWeek = dayOfWeekName(for: selectedDay)
        return "\(dayOfWeek), May \(selectedDay)"
    }

    private func dayOfWeekName(for day: Int) -> String {
        // May 2026: 1st = Friday
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let firstDow = 5 // Friday index in Sun-based array
        let dow = (firstDow + day - 1) % 7
        return dayNames[dow]
    }
}

// MARK: - MonthDayCell

private struct MonthDayCell: View {
    let day: Int?
    let isToday: Bool
    let isSelected: Bool
    let dotCount: Int
    let t: CoveTheme

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isToday {
                    Circle()
                        .fill(t.accent)
                        .frame(width: 32, height: 32)
                } else if isSelected {
                    Circle()
                        .fill(t.accentSoft)
                        .frame(width: 32, height: 32)
                }

                if let d = day {
                    Text("\(d)")
                        .font(.sfRounded(size: 15, weight: isToday ? .bold : .regular))
                        .foregroundColor(isToday ? .white : (isSelected ? t.accent : t.text))
                }
            }
            .frame(width: 32, height: 32)

            // Event dots
            HStack(spacing: 3) {
                ForEach(0..<min(dotCount, 4), id: \.self) { dotIndex in
                    Circle()
                        .fill(isToday ? Color.white.opacity(0.8) : t.accent)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}

// MARK: - DayTimelineView

struct DayTimelineView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    let hourPx: CGFloat = 64
    let startHour: CGFloat = 6
    let nowHour: CGFloat = 11 + 47.0 / 60.0

    private var hours: [Int] { Array(6...21) }

    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                // Hour grid
                VStack(spacing: 0) {
                    ForEach(hours, id: \.self) { hour in
                        HStack(alignment: .top, spacing: 8) {
                            Text(hourLabel(hour))
                                .font(.sfPro(size: 11, weight: .medium))
                                .foregroundColor(t.text3)
                                .frame(width: 44, alignment: .trailing)
                                .offset(y: -7)

                            Rectangle()
                                .fill(t.sep.opacity(0.4))
                                .frame(height: 0.5)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(height: hourPx)
                    }
                }

                let eventAreaX: CGFloat = 52 + 8

                // Events
                ForEach(store.events) { event in
                    let topOffset = CGFloat(event.startHour - startHour) * hourPx
                    let height = max(CGFloat(event.durationMins) / 60.0 * hourPx, 28)

                    TimelineEventBlock(event: event, height: height)
                        .padding(.trailing, 12)
                        .offset(x: eventAreaX, y: topOffset)
                }

                // Now line
                let nowOffset = (nowHour - startHour) * hourPx
                HStack(spacing: 0) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: -4)
                    Rectangle()
                        .fill(Color.red)
                        .frame(height: 1.5)
                        .frame(maxWidth: .infinity)
                }
                .offset(x: eventAreaX - 4, y: nowOffset)
            }
            .frame(height: CGFloat(hours.count) * hourPx)
            .padding(.top, 8)
            .padding(.horizontal, 12)
            .padding(.bottom, 100)
        }
    }

    private func hourLabel(_ hour: Int) -> String {
        if hour == 12 { return "12 PM" }
        if hour < 12 { return "\(hour) AM" }
        return "\(hour - 12) PM"
    }
}

// MARK: - Preview

#Preview {
    CalendarView()
        .environmentObject(AppStore())
        .environment(\.coveTheme, CoveTheme(dark: false, accentName: "sage"))
}
