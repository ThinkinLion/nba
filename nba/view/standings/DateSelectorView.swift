import SwiftUI

struct DateSelectorView: View {
    let games: [GamesModel]
    @Binding var selectedIndex: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(games.enumerated()), id: \.element) { index, gameModel in
                    let isSelected = index == selectedIndex
                    let isToday = checkIsToday(dateString: gameModel.date)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                            selectedIndex = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            // Day of Week (e.g., "SUN" or "TODAY")
                            Text(isToday ? "TODAY" : getDayOfWeek(from: gameModel.date))
                                .font(.system(size: isToday ? 9 : 11, weight: .bold, design: .rounded))
                                .foregroundColor(isSelected ? .white : (isToday ? .yellow : .white.opacity(0.55)))
                                .tracking(0.5)
                            
                            // Day Number (e.g., "28")
                            Text(getDayNumber(from: gameModel.date))
                                .font(.system(size: 19, weight: .black, design: .rounded))
                                .foregroundColor(isSelected ? .white : .white.opacity(0.9))
                            
                            // Bottom Active Indicator
                            Circle()
                                .fill(isSelected ? Color.white : (isToday ? Color.yellow.opacity(0.8) : Color.clear))
                                .frame(width: 4, height: 4)
                        }
                        .frame(width: 54, height: 64)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    isSelected ?
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.12, green: 0.38, blue: 0.95),
                                            Color(red: 0.05, green: 0.22, blue: 0.75)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(
                                    isSelected ? Color.white.opacity(0.4) : Color.white.opacity(0.1),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: isSelected ? Color(red: 0.12, green: 0.38, blue: 0.95).opacity(0.4) : Color.clear,
                            radius: 8,
                            x: 0,
                            y: 3
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }
    
    // Helper: "2026-10-25" -> "SUN"
    func getDayOfWeek(from dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "" }
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    // Helper: "2026-10-25" -> "25"
    func getDayNumber(from dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "" }
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    // Check if the date corresponds to today
    func checkIsToday(dateString: String?) -> Bool {
        guard let dateString = dateString else { return false }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return false }
        return Calendar.current.isDateInToday(date)
    }
}
