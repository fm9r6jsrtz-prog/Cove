import SwiftUI

// MARK: - JournalView

struct JournalView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    @State private var showNewEntry = false

    private let moodOptions: [(emoji: String, label: String)] = [
        ("😌", "Calm"),
        ("🙂", "Okay"),
        ("🤔", "Mixed"),
        ("🥲", "Tender"),
        ("⚡️", "Wired"),
    ]

    private var dateString: String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d · HH:mm"
        return formatter.string(from: now).uppercased()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Navigation bar area
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dateString)
                                .font(.sfPro(size: 12, weight: .semibold))
                                .foregroundColor(t.accent)
                                .tracking(0.5)
                            Text("Journal")
                                .font(.sfRounded(size: 30, weight: .bold))
                                .foregroundColor(t.text)
                        }
                        Spacer()

                        HStack(spacing: 10) {
                            CovePillButton(systemImage: "calendar") {}
                            CovePillButton(systemImage: "bookmark") {}
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)
                    .padding(.bottom, 20)

                    // Today's entry
                    VStack(alignment: .leading, spacing: 20) {
                        // Entry title
                        Text("A quieter morning than expected.")
                            .font(.sfRounded(size: 28, weight: .bold))
                            .foregroundColor(t.text)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 20)

                        // Mood selector
                        MoodSelector(moodOptions: moodOptions)
                            .padding(.horizontal, 20)

                        // Text editor
                        ZStack(alignment: .topLeading) {
                            if store.journalBody.isEmpty {
                                Text(store.journalEntries.first?.body ?? "What's on your mind?")
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(store.journalEntries.isEmpty ? t.text3 : t.text.opacity(0.85))
                                    .padding(14)
                                    .allowsHitTesting(false)
                                    .lineSpacing(5)
                            }

                            TextEditor(text: $store.journalBody)
                                .font(.system(.body, design: .serif))
                                .foregroundColor(t.text)
                                .scrollContentBackground(.hidden)
                                .padding(10)
                                .lineSpacing(5)
                        }
                        .frame(minHeight: 220)
                        .background(t.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 16)

                        // Tomorrow's prompt card
                        TomorrowPromptCard()
                            .padding(.horizontal, 16)

                        // Footer
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(t.text3)
                            Text("Saved on device · Face ID required")
                                .font(.sfPro(size: 12))
                                .foregroundColor(t.text3)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)

                        // Past entries
                        if !store.journalEntries.isEmpty {
                            PastEntriesSection()
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            .background(t.bg)

            // Bottom bar with tab + compose button
            ZStack(alignment: .top) {
                CoveTabBar()

                HStack {
                    Spacer()
                    Button {
                        showNewEntry = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(t.accent)
                            .clipShape(Circle())
                            .shadow(color: t.accent.opacity(0.35), radius: 10, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 72)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showNewEntry) {
            NewJournalEntrySheet()
                .environmentObject(store)
                .environment(\.coveTheme, t)
        }
        .overlay {
            if store.showEnergyCheckin {
                EnergyCheckinView()
                    .environmentObject(store)
                    .environment(\.coveTheme, t)
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }
        }
        .animation(.spring(duration: 0.3), value: store.showEnergyCheckin)
    }
}

// MARK: - MoodSelector

private struct MoodSelector: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    let moodOptions: [(emoji: String, label: String)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(moodOptions.indices, id: \.self) { i in
                let active = store.currentJournalMood == i
                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        store.currentJournalMood = i
                    }
                } label: {
                    VStack(spacing: 5) {
                        Text(moodOptions[i].emoji)
                            .font(.system(size: 24))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(active ? t.accentSoft : Color.clear)
                                    .overlay(
                                        Circle()
                                            .stroke(active ? t.accent : Color.clear, lineWidth: 1.5)
                                    )
                            )

                        Text(moodOptions[i].label)
                            .font(.sfPro(size: 11, weight: active ? .semibold : .regular))
                            .foregroundColor(active ? t.accent : t.text2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - TomorrowPromptCard

private struct TomorrowPromptCard: View {
    @Environment(\.coveTheme) var t

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "star.fill")
                .font(.system(size: 18))
                .foregroundColor(t.accent)
                .frame(width: 36, height: 36)
                .background(t.accentSoft)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text("Tomorrow's prompt")
                    .font(.sfPro(size: 12, weight: .semibold))
                    .foregroundColor(t.text2)
                Text("One small thing you noticed today.")
                    .font(.sfPro(size: 15, weight: .medium))
                    .foregroundColor(t.text)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(t.text3)
        }
        .padding(16)
        .background(t.accentTint)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - PastEntriesSection

private struct PastEntriesSection: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    private var pastEntries: [JournalEntry] {
        Array(store.journalEntries.dropFirst())
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    private func moodEmoji(_ index: Int) -> String {
        let emojis = ["😌", "🙂", "🤔", "🥲", "⚡️"]
        guard index >= 0 && index < emojis.count else { return "🙂" }
        return emojis[index]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PAST ENTRIES")
                .font(.sfPro(size: 12, weight: .semibold))
                .foregroundColor(t.text2)
                .tracking(0.4)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(pastEntries.indices, id: \.self) { i in
                    let entry = pastEntries[i]
                    HStack(spacing: 12) {
                        Text(moodEmoji(entry.mood))
                            .font(.system(size: 20))
                            .frame(width: 36, height: 36)
                            .background(t.surface2)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.title.isEmpty ? "Untitled" : entry.title)
                                .font(.sfPro(size: 15, weight: .medium))
                                .foregroundColor(t.text)
                                .lineLimit(1)
                            Text(formattedDate(entry.date))
                                .font(.sfPro(size: 12))
                                .foregroundColor(t.text2)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(t.text3)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .overlay(alignment: .bottom) {
                        if i < pastEntries.count - 1 {
                            Divider().padding(.leading, 62)
                        }
                    }
                }
            }
            .background(t.surface.cornerRadius(16))
        }
    }
}

// MARK: - NewJournalEntrySheet

private struct NewJournalEntrySheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t
    @Environment(\.dismiss) var dismiss
    @FocusState private var bodyFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack(alignment: .topLeading) {
                        if store.journalBody.isEmpty {
                            Text("What's on your mind?")
                                .font(.system(.body, design: .serif))
                                .foregroundColor(t.text3)
                                .padding(14)
                        }

                        TextEditor(text: $store.journalBody)
                            .font(.system(.body, design: .serif))
                            .foregroundColor(t.text)
                            .scrollContentBackground(.hidden)
                            .padding(10)
                            .lineSpacing(5)
                            .focused($bodyFocused)
                    }
                    .frame(minHeight: 300)
                    .background(t.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(t.bg)
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { bodyFocused = true }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(t.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        store.saveJournalEntry()
                        dismiss()
                    }
                    .font(.sfPro(size: 17, weight: .semibold))
                    .foregroundColor(t.accent)
                    .disabled(store.journalBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - EnergyCheckinView

struct EnergyCheckinView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.coveTheme) var t

    private let energyOptions: [(emoji: String, label: String)] = [
        ("😴", "Drained"),
        ("😕", "Low"),
        ("🙂", "Okay"),
        ("😌", "Good"),
        ("⚡️", "Sharp"),
    ]

    private let tagOptions: [(label: String, active: Bool)] = [
        ("caffeinated", false),
        ("slept well", true),
        ("workout done", false),
        ("rushed", false),
    ]

    @State private var selectedEnergy: Int = 3
    @State private var activeTags: Set<String> = ["slept well"]

    var body: some View {
        ZStack {
            // Semi-transparent blur overlay
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .blur(radius: 2)
                .onTapGesture {
                    withAnimation { store.showEnergyCheckin = false }
                }

            // Card
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 6) {
                    Text("Before Deep work · 9:30")
                        .font(.sfPro(size: 13, weight: .semibold))
                        .foregroundColor(t.accent)
                        .tracking(0.2)

                    Text("How's your energy right now?")
                        .font(.sfRounded(size: 22, weight: .bold))
                        .foregroundColor(t.text)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 26)
                .padding(.horizontal, 24)
                .padding(.bottom, 22)

                // Energy options
                HStack(spacing: 0) {
                    ForEach(energyOptions.indices, id: \.self) { i in
                        let active = selectedEnergy == i
                        Button {
                            withAnimation(.spring(duration: 0.22)) {
                                selectedEnergy = i
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Text(energyOptions[i].emoji)
                                    .font(.system(size: 26))
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(active ? t.accentSoft : Color.clear)
                                            .overlay(Circle().stroke(active ? t.accent : Color.clear, lineWidth: 1.5))
                                    )

                                Text(energyOptions[i].label)
                                    .font(.sfPro(size: 10, weight: active ? .semibold : .regular))
                                    .foregroundColor(active ? t.accent : t.text2)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)

                Divider()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // Tag chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(activeTags.union(tagOptions.map { $0.label })), id: \.self) { tag in
                            let active = activeTags.contains(tag)
                            Button {
                                withAnimation(.spring(duration: 0.2)) {
                                    if active {
                                        activeTags.remove(tag)
                                    } else {
                                        activeTags.insert(tag)
                                    }
                                }
                            } label: {
                                Text(tag)
                                    .font(.sfPro(size: 13, weight: active ? .semibold : .regular))
                                    .foregroundColor(active ? t.accent : t.text2)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule()
                                            .fill(active ? t.accentSoft : t.systemFill)
                                            .overlay(Capsule().stroke(active ? t.accent.opacity(0.4) : Color.clear, lineWidth: 1))
                                    )
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            // Add tag
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("add tag…")
                                    .font(.sfPro(size: 13))
                            }
                            .foregroundColor(t.text3)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(t.systemFill))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 22)

                // Action buttons
                VStack(spacing: 10) {
                    Button {
                        withAnimation { store.showEnergyCheckin = false }
                    } label: {
                        Text("Save & start block")
                            .font(.sfPro(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(t.accent)
                            .clipShape(Capsule())
                    }

                    Button {
                        withAnimation { store.showEnergyCheckin = false }
                    } label: {
                        Text("Skip")
                            .font(.sfPro(size: 16, weight: .medium))
                            .foregroundColor(t.text2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                // Footnote
                Text("Stored on this device.")
                    .font(.sfPro(size: 11))
                    .foregroundColor(t.text3)
                    .padding(.bottom, 20)
            }
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(t.bg)
                    .shadow(color: .black.opacity(0.18), radius: 28, y: 10)
            )
            .padding(.horizontal, 16)
            .padding(.top, 80)
        }
    }
}

// MARK: - Preview

#Preview {
    JournalView()
        .environmentObject(AppStore())
        .environment(\.coveTheme, CoveTheme(dark: false, accentName: "sage"))
}
