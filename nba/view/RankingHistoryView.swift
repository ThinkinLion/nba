//
//  RankingHistoryView.swift
//  nba
//
//  Created by 1100690 on 12/05/24.
//

import SwiftUI
import Charts

struct RankingHistoryView: View {
    let history: [(week: String, rank: Int)]
    let teamColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("RANKING HISTORY")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            if history.isEmpty {
                Text("No ranking history available")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(history, id: \.week) { item in
                        LineMark(
                            x: .value("Week", item.week),
                            y: .value("Rank", item.rank)
                        )
                        .foregroundStyle(teamColor)
                        .symbol {
                            Circle()
                                .fill(teamColor)
                                .frame(width: 8, height: 8)
                        }
                        .interpolationMethod(.catmullRom) // 부드러운 곡선
                    }
                }
                .chartYScale(domain: .automatic(includesZero: false, reversed: true)) // 1위가 위로 가도록 반전
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 5))
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        if let week = value.as(String.self) {
                            // "Week 1" -> "W1" 축약
                            let label = week.replacingOccurrences(of: "Week ", with: "W")
                            AxisValueLabel(label)
                        }
                    }
                }
                .frame(height: 200)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    RankingHistoryView(
        history: [
            ("Week 1", 5),
            ("Week 2", 3),
            ("Week 3", 8),
            ("Week 4", 2),
            ("Week 5", 1)
        ],
        teamColor: .blue
    )
    .preferredColorScheme(.dark)
}
