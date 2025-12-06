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
                            y: .value("Rank", -item.rank) // 1위가 위로 가도록 음수 변환
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
                .chartYScale(domain: yAxisDomain) // 동적 도메인 적용
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                        if let intValue = value.as(Int.self) {
                            AxisValueLabel("\(abs(intValue))") // 음수를 양수로 표시
                        }
                    }
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
    
    // Y축 도메인 계산
    var yAxisDomain: ClosedRange<Int> {
        guard !history.isEmpty else { return -30...(-1) }
        
        let ranks = history.map { $0.rank }
        let minRank = ranks.min() ?? 1
        let maxRank = ranks.max() ?? 30
        
        // 순위 변화가 없거나 적은 경우를 위해 여유 공간 확보
        var domainMin = max(1, minRank - 2)
        var domainMax = min(30, maxRank + 2)
        
        // 순위가 모두 동일한 경우 (예: 계속 1위)
        if domainMin == domainMax {
            if domainMin == 1 {
                domainMax = 5 // 1위인 경우 1~5위까지 표시
            } else {
                domainMin = max(1, domainMin - 2)
                domainMax = min(30, domainMax + 2)
            }
        }
        
        // 최소 범위 보장 (그래프가 너무 평평해지는 것 방지)
        if domainMax - domainMin < 4 {
            domainMax = min(30, domainMin + 4)
            if domainMax - domainMin < 4 {
                domainMin = max(1, domainMax - 4)
            }
        }
        
        // 음수 범위 반환 (작은 숫자가 위로 가도록)
        return (-domainMax)...(-domainMin)
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
