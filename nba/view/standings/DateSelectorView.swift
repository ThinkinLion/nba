import SwiftUI

struct DateSelectorView: View {
    let games: [GamesModel]
    @Binding var selectedIndex: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(games.enumerated()), id: \.element) { index, gameModel in
                    let isSelected = index == selectedIndex
                    
                    Button(action: {
                        withAnimation {
                            selectedIndex = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            // Day of Week (e.g., "SUN")
                            Text(getDayOfWeek(from: gameModel.date))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(isSelected ? .black : .gray)
                            
                            // Day Number (e.g., "28")
                            Text(getDayNumber(from: gameModel.date))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(isSelected ? .black : .white)
                        }
                        .frame(width: 50, height: 60)
                        .background(isSelected ? Color.white : Color(white: 0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // Helper: "2023-12-30" -> "SAT"
    func getDayOfWeek(from dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "" }
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    // Helper: "2023-12-30" -> "30"
    func getDayNumber(from dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "" }
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
