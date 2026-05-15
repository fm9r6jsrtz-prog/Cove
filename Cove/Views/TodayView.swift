import SwiftUI

// MARK: - TodayView

struct TodayView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    var body: some View {
        ZStack(alignment: .bottom) {
            t.bg.ignoresSafeArea()

            if store.dayLayout == .timeline {
                TodayTimeline()
            } else {
                TodayList()
            }
        }
        .sheet(isPresented: $store.showTaskSheet) {
            TaskSheetView()
                .environmentObject(store)
                .environment(\.coveTheme, t)
        }
        .sheet(isPresented: $store.showQuickCapture) {
            QuickCaptureView()
                .environmentObject(store)
                .environment(\.coveTheme, t)
        }
    }
}

// MARK: - TodayHeader

struct TodayHeader: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("TODAY")
                    .font(.sfPro(size: 13, weight: .semibold))
                    .foregroundColor(t.accent)
                    .kerning(0.8)

                Text("Wednesday, May 13")
                    .font(.sfRounded(size: 30, weight: .bold))
                    .foregroundColor(t.text)
            }

            Spacer()

            HStack(spacing: 10) {
                CovePillButton(systemImage: "magnifyingglass") {}

                Button {
                    store.showTaskSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(t.accent)
                        .clipShape(Circle())
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - DayRailView

struct DayRailView: View {
    @Environment(\.coveTheme) var t

    private let days = ["S", "M", "T", "W", "T", "F", "S"]
    private let numbers = [10, 11, 12, 13, 14, 15, 16]
    private let todayIndex = 3
    private let dotDays: Set<Int> = [1, 4]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                VStack(spacing: 4) {
                    Text(days[i])
                        .font(.sfPro(size: 12, weight: .medium))
                        .foregroundColor(i == todayIndex ? t.accent : t.text2)

                    ZStack {
                        if i == todayIndex {
                            Circle()
                                .fill(t.accent)
                                .frame(width: 30, height: 30)
                        }

                        Text("\(numbers[i])")
                            .font(.sfRounded(size: 15, weight: i == todayIndex ? .bold : .regular))
                            .foregroundColor(i == todayIndex ? .white : t.text)
                    }
                    .frame(width: 30, height: 30)

                    Circle()
                        .fill(dotDays.contains(i) ? t.accent : Color.clear)
                        .frame(width: 5, height: 5)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}

// MARK: - TodayTimeline

struct TodayTimeline: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    let hourPx: CGFloat = 64
    let startHour: CGFloat = 6
    let endHour: CGFloat = 21
    let nowHour: CGFloat = 11 + 47.0 / 60.0

    var hours: [Int] { Array(6...21) }

    private var pendingTasksLabel: String {
        let pending = store.tasks.filter { !$0.done }
        let count = pending.count
        let preview = pending.prefix(2).map(\.title).joined(separator: ", ")
        let extra = count > 2 ? " +\(count - 2)" : ""
        return "\(count) tasks · \(preview)\(extra)"
    }

    var body: some View {
        VStack(spacing: 0) {
            TodayHeader()
            DayRailView()
            CoveFocusBanner()

            ScrollView {
                VStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        // Hour grid
                        VStack(spacing: 0) {
                            ForEach(hours, id: \.self) { hour in
                                HStack(alignment: .top, spacing: 8) {
                                    Text(hourLabel(hour))
                                        .font(.sfPro(size: 11, weight: .medium))
                                        .foregroundColor(t.text3)
                                        .frame(width: 40, alignment: .trailing)
                                        .offset(y: -7)

                                    Rectangle()
                                        .fill(t.sep.opacity(0.4))
                                        .frame(height: 0.5)
                                        .frame(maxWidth: .infinity)
                                }
                                .frame(height: hourPx)
                            }
                        }

                        let eventAreaX: CGFloat = 48 + 8

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

                    Divider()
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                    // Task strip
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(t.accent)

                        Text(pendingTasksLabel)
                            .font(.sfPro(size: 13))
                            .foregroundColor(t.text2)
                            .lineLimit(1)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(t.surface)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                )
                .padding(.horizontal, 14)
                .padding(.bottom, 100)
            }

            Spacer(minLength: 0)
        }
    }

    private func hourLabel(_ hour: Int) -> String {
        if hour == 12 { return "12 PM" }
        if hour < 12 { return "\(hour) AM" }
        return "\(hour - 12) PM"
    }
}

// MARK: - TimelineEventBlock

struct TimelineEventBlock: View {
    @Environment(\.coveTheme) var t
    let event: CalendarEvent
    let height: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(event.tintColor)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 1.5))

            VStack(alignment: .leading, spacing: 1) {
                Text(event.title)
                    .font(.sfPro(size: 12, weight: .semibold))
                    .foregroundColor(event.done ? t.text2 : t.text)
                    .strikethrough(event.done)
                    .lineLimit(height > 40 ? 2 : 1)

                if height > 40 {
                    Text("\(event.time) – \(event.endTime)")
                        .font(.sfPro(size: 11))
                        .foregroundColor(t.text2)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            Spacer(minLength: 0)
        }
        .frame(height: height - 2, alignment: .top)
        .background(event.tintColor.opacity(event.done ? 0.07 : 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .opacity(event.done ? 0.5 : 1)
    }
}

// MARK: - TodayList

struct TodayList: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    private let currentEvent = CalendarEvent.today.first { $0.time == "11:30" }
    private var upcomingEvents: [CalendarEvent] {
        CalendarEvent.today.filter { !$0.done && $0.startHour > 11.78 }.prefix(3).map { $0 }
    }
    private var doneEvents: [CalendarEvent] {
        CalendarEvent.today.filter(\.done)
    }

    var body: some View {
        VStack(spacing: 0) {
            TodayHeader()
            DayRailView()
            CoveFocusBanner()

            ScrollView {
                VStack(spacing: 16) {
                    if let current = currentEvent {
                        NowCard(event: current)
                    }

                    UpNextSection(events: upcomingEvents)

                    DoneSection(events: doneEvents)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 100)
            }

            Spacer(minLength: 0)
        }
    }
}

// MARK: - NowCard

private struct NowCard: View {
    @Environment(\.coveTheme) var t
    let event: CalendarEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Now · 11:47")
                    .font(.sfPro(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .kerning(0.4)

                Spacer()

                Text("\(event.time) – \(event.endTime)")
                    .font(.sfPro(size: 12))
                    .foregroundColor(.white.opacity(0.75))
            }

            Text(event.title)
                .font(.sfRounded(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [t.accent, t.accent.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        )
        .shadow(color: t.accent.opacity(0.35), radius: 10, y: 4)
    }
}

// MARK: - UpNextSection

private struct UpNextSection: View {
    @Environment(\.coveTheme) var t
    let events: [CalendarEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Up next")
                .font(.sfPro(size: 15, weight: .semibold))
                .foregroundColor(t.text2)

            VStack(spacing: 8) {
                ForEach(events) { event in
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(event.tintColor)
                            .frame(width: 4)
                            .clipShape(RoundedRectangle(cornerRadius: 2))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.title)
                                .font(.sfPro(size: 15, weight: .medium))
                                .foregroundColor(t.text)

                            Text(event.time)
                                .font(.sfPro(size: 13))
                                .foregroundColor(t.text2)
                        }

                        Spacer()

                        Text("\(event.durationMins)m")
                            .font(.sfPro(size: 13))
                            .foregroundColor(t.text3)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(t.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(event.tintColor.opacity(0.07))
                            )
                    )
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
                }
            }
        }
    }
}

// MARK: - DoneSection

private struct DoneSection: View {
    @Environment(\.coveTheme) var t
    let events: [CalendarEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Done · \(events.count)")
                    .font(.sfPro(size: 15, weight: .semibold))
                    .foregroundColor(t.text2)
                Spacer()
            }

            VStack(spacing: 6) {
                ForEach(events) { event in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(t.green)

                        Text(event.title)
                            .font(.sfPro(size: 15))
                            .foregroundColor(t.text2)
                            .strikethrough(true, color: t.text3)

                        Spacer()

                        Text(event.time)
                            .font(.sfPro(size: 13))
                            .foregroundColor(t.text3)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(t.surface)
                    )
                }
            }
        }
    }
}

// MARK: - TaskSheetView

struct TaskSheetView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    @Environment(\.dismiss) private var dismiss

    @State private var cursorVisible = true
    @State private var isHighPriority = true

    private let optionRows: [(String, String, String)] = [
        ("calendar", "Date", "Today"),
        ("clock", "Time", "11:00 AM"),
        ("arrow.clockwise", "Repeat", "Never"),
        ("tray", "List", "Personal"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Title field with blinking cursor
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(store.newTaskText.isEmpty ? "Call dentist about Tuesday" : store.newTaskText)
                        .font(.sfPro(size: 20, weight: .regular))
                        .foregroundColor(store.newTaskText.isEmpty ? t.text3 : t.text)

                    Rectangle()
                        .fill(t.accent)
                        .frame(width: 2, height: 22)
                        .opacity(cursorVisible ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(), value: cursorVisible)
                        .onAppear { cursorVisible = false }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                .onTapGesture {
                    if store.newTaskText.isEmpty {
                        store.newTaskText = "Call dentist about Tuesday"
                    }
                }

                Divider()

                // Option rows
                VStack(spacing: 0) {
                    ForEach(Array(optionRows.enumerated()), id: \.offset) { index, row in
                        HStack(spacing: 14) {
                            Image(systemName: row.0)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(t.accent)
                                .frame(width: 24)

                            Text(row.1)
                                .font(.sfPro(size: 16))
                                .foregroundColor(t.text)

                            Spacer()

                            Text(row.2)
                                .font(.sfPro(size: 16))
                                .foregroundColor(t.text2)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(t.text3)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 13)

                        if index < optionRows.count - 1 {
                            Divider().padding(.leading, 58)
                        }
                    }
                }
                .background(t.surface)

                Divider()

                // Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        TaskChipButton(
                            label: isHighPriority ? "High priority" : "Normal priority",
                            systemImage: "flag.fill",
                            isActive: isHighPriority,
                            color: isHighPriority ? t.orange : t.text2
                        ) {
                            isHighPriority.toggle()
                        }

                        TaskChipButton(
                            label: "No reminder",
                            systemImage: "bell.slash",
                            isActive: false,
                            color: t.text2
                        ) {}

                        TaskChipButton(
                            label: "Add subtask",
                            systemImage: "plus",
                            isActive: false,
                            color: t.accent
                        ) {}
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }

                Spacer()

                // Mock keyboard
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(UIColor.systemGray5))
                    .frame(height: 260)
                    .overlay(
                        Text("Keyboard")
                            .font(.sfPro(size: 14))
                            .foregroundColor(t.text3)
                    )
            }
            .background(t.bg.ignoresSafeArea())
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(t.accent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let title = store.newTaskText.isEmpty
                            ? "Call dentist about Tuesday"
                            : store.newTaskText
                        store.addTask(title: title)
                        store.newTaskText = ""
                        dismiss()
                    }
                    .font(.sfPro(size: 16, weight: .semibold))
                    .foregroundColor(t.accent)
                }
            }
        }
    }
}

// MARK: - TaskChipButton

private struct TaskChipButton: View {
    @Environment(\.coveTheme) var t
    let label: String
    let systemImage: String
    let isActive: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
                    .font(.sfPro(size: 13, weight: .medium))
            }
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
                    .overlay(Capsule().stroke(color.opacity(isActive ? 0.3 : 0.15), lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - QuickCaptureView

struct QuickCaptureView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    @Environment(\.dismiss) private var dismiss

    @State private var inputText = ""
    @State private var selectedMode = 0
    @State private var selectedList = "Personal"

    private let modes = ["Task", "Event", "Note", "Voice"]
    private let lists = ["Personal", "Work", "Errands", "Travel", "Reading"]

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(t.text3)
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 16)

            // Header
            Text("QUICK CAPTURE")
                .font(.sfPro(size: 11, weight: .semibold))
                .foregroundColor(t.accent)
                .kerning(1.0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 14)

            // Text input
            HStack(spacing: 12) {
                Image(systemName: "text.cursor")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(t.text3)

                TextField("What's on your mind?", text: $inputText)
                    .font(.sfPro(size: 18))
                    .foregroundColor(t.text)
                    .tint(t.accent)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            Divider().padding(.horizontal, 20)

            // Mode selector
            Picker("Mode", selection: $selectedMode) {
                ForEach(Array(modes.enumerated()), id: \.offset) { i, mode in
                    Text(mode).tag(i)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            // List selector
            VStack(alignment: .leading, spacing: 10) {
                Text("LIST")
                    .font(.sfPro(size: 11, weight: .semibold))
                    .foregroundColor(t.text3)
                    .kerning(0.8)
                    .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(lists, id: \.self) { list in
                            Button {
                                selectedList = list
                            } label: {
                                Text(list)
                                    .font(.sfPro(size: 14, weight: selectedList == list ? .semibold : .regular))
                                    .foregroundColor(selectedList == list ? .white : t.text2)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule()
                                            .fill(selectedList == list ? t.accent : t.surface2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 20)

            Divider().padding(.horizontal, 20)

            // Action buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .font(.sfPro(size: 16, weight: .medium))
                .foregroundColor(t.text2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(t.surface2)
                )

                Button {
                    if !inputText.trimmingCharacters(in: .whitespaces).isEmpty {
                        store.addTask(title: inputText, tag: selectedList)
                        inputText = ""
                    }
                } label: {
                    Text("Save & add another")
                        .font(.sfPro(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(t.accent)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 24)
        }
        .background(t.surface.ignoresSafeArea())
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .presentationDetents([.fraction(0.55)])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Preview

#Preview {
    TodayView()
        .environmentObject(AppStore())
        .environment(\.coveTheme, CoveTheme(dark: false, accentName: "sage"))
}
