//
//  DateSelectorView.swift
//  nba
//
//  Today 상단 날짜 스트립. 선택 날짜의 월·요일·경기 수를 헤더로 보여주고,
//  칩 위의 "월 눈금(ruler)" 이 달이 바뀌는 지점마다 월 이름을 표시해 어느 달인지 바로 알 수 있게 함.
//

import SwiftUI

struct DateSelectorView: View {
    let games: [GamesModel]
    @Binding var selectedIndex: Int

    private static let parser: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static func formatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = format
        return f
    }

    private static let weekday = formatter("EEE")       // SUN
    private static let dayNumber = formatter("d")       // 25
    private static let monthShort = formatter("MMM")    // OCT
    private static let monthLong = formatter("MMMM")    // October
    private static let year = formatter("yyyy")
    private static let headline = formatter("EEEE, MMMM d") // Sunday, October 25

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
                .padding(.horizontal, 16)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(Array(games.enumerated()), id: \.element) { index, gameModel in
                            let date = Self.parser.date(from: gameModel.date ?? "")
                            VStack(spacing: 5) {
                                // 월 눈금: 리스트(최신순)에서 달이 바뀌는 첫 칩에만 월 이름 표시
                                monthRuler(index: index, date: date)
                                dayChip(index: index, date: date)
                            }
                            .id(index)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
                .onChange(of: selectedIndex) { newIndex in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
        }
    }

    // MARK: - Header (선택 날짜의 월 / 요일 / 경기 수)

    @ViewBuilder
    private var header: some View {
        let selected = games.indices.contains(selectedIndex) ? games[selectedIndex] : nil
        let date = Self.parser.date(from: selected?.date ?? "")
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(date.map { Self.monthLong.string(from: $0).uppercased() } ?? "")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .tracking(1)
            Text(date.map { Self.year.string(from: $0) } ?? "")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.4))

            Spacer()

            if let date {
                let count = selected?.items.count ?? 0
                HStack(spacing: 5) {
                    if Calendar.current.isDateInToday(date) {
                        Text("TODAY")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow)
                            .clipShape(Capsule())
                    }
                    Text(Self.headline.string(from: date))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    Text("· \(count) game\(count == 1 ? "" : "s")")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
    }

    // MARK: - Month ruler

    @ViewBuilder
    private func monthRuler(index: Int, date: Date?) -> some View {
        let isBoundary = isMonthBoundary(at: index)
        ZStack(alignment: .leading) {
            Color.clear.frame(height: 14)
            if isBoundary, let date {
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 1.5, height: 10)
                    Text(Self.monthShort.string(from: date).uppercased())
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(.white.opacity(0.75))
                        .tracking(0.6)
                        .fixedSize()
                }
            }
        }
        .frame(width: 54, alignment: .leading)
    }

    /// 리스트는 최신순이므로 index 의 달이 index-1(더 최신)과 다르면 그 달의 "첫 노출" 칩
    private func isMonthBoundary(at index: Int) -> Bool {
        guard let current = Self.parser.date(from: games[index].date ?? "") else { return false }
        if index == 0 { return true }
        guard let newer = Self.parser.date(from: games[index - 1].date ?? "") else { return true }
        let cal = Calendar.current
        return cal.component(.month, from: current) != cal.component(.month, from: newer)
            || cal.component(.year, from: current) != cal.component(.year, from: newer)
    }

    // MARK: - Day chip

    @ViewBuilder
    private func dayChip(index: Int, date: Date?) -> some View {
        let isSelected = index == selectedIndex
        let isToday = date.map { Calendar.current.isDateInToday($0) } ?? false
        let accent = Color(red: 0.12, green: 0.38, blue: 0.95)

        Button(action: {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                selectedIndex = index
            }
        }) {
            VStack(spacing: 4) {
                Text(isToday ? "TODAY" : (date.map { Self.weekday.string(from: $0).uppercased() } ?? ""))
                    .font(.system(size: isToday ? 9 : 11, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : (isToday ? .yellow : .white.opacity(0.55)))
                    .tracking(0.5)

                Text(date.map { Self.dayNumber.string(from: $0) } ?? "")
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.9))

                Circle()
                    .fill(isSelected ? Color.white : (isToday ? Color.yellow.opacity(0.8) : Color.clear))
                    .frame(width: 4, height: 4)
            }
            .frame(width: 54, height: 64)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        isSelected
                        ? LinearGradient(colors: [accent, Color(red: 0.05, green: 0.22, blue: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.white.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: isSelected ? accent.opacity(0.4) : Color.clear, radius: 8, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
