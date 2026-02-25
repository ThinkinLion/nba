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
                chartContent
                    .frame(height: 200)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
    
    private var chartContent: some View {
        Chart {
            ForEach(Array(history.enumerated()), id: \.element.week) { index, item in
                LineMark(
                    x: .value("Week", index),
                    y: .value("Rank", -item.rank) // 1위가 위로 가도록 음수 변환
                )
                .foregroundStyle(teamColor)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .symbol {
                    Circle()
                        .fill(teamColor)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1.5) // 흰색 테두리 추가
                        )
                }
                .interpolationMethod(.catmullRom) // 부드러운 곡선
            }
        }
        .chartYScale(domain: yAxisDomain) // 동적 도메인 적용
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                if let intValue = value.as(Int.self), intValue < 0 {
                    AxisValueLabel("\(abs(intValue))") // 음수를 양수로 표시
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                if let index = value.as(Int.self), index >= 0 && index < history.count {
                    // "Week 1" -> "W1" 축약
                    let week = history[index].week
                    let label = week.replacingOccurrences(of: "Week ", with: "W")
                    AxisValueLabel(label)
                }
            }
        }
    }
    
    // Y축 도메인 계산
    var yAxisDomain: ClosedRange<Int> {
        guard !history.isEmpty else { return -30...(-1) }
        
        let ranks = history.map { $0.rank }
        let minRank = ranks.min() ?? 1
        let maxRank = ranks.max() ?? 30
        
        // 상단(1위)이 잘리지 않도록 최소값을 0까지 허용 (0위는 없지만 패딩 역할)
        var domainMin = max(0, minRank - 2)
        var domainMax = min(30, maxRank + 2)
        
        // 최소 범위 보장 (그래프가 너무 평평해지는 것 방지)
        if domainMax - domainMin < 4 {
            domainMax = min(30, domainMin + 4)
            if domainMax - domainMin < 4 {
                domainMin = max(0, domainMax - 4)
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
