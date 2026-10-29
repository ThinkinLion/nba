//
//  PlayerBioGridView.swift
//  nba
//
//  선수 상세 "BIO" 섹션: 상단 바이탈 타일 3개(키·몸무게·나이) + 하단 키-값 행(출생·국적·드래프트·경력·출신교)
//

import SwiftUI

struct PlayerBioGridView: View {
    let player: PlayerSummaryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "person.text.rectangle.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                Text("BIO")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(0.5)
                Spacer()
            }

            // 1. 바이탈 타일
            HStack(spacing: 8) {
                vitalTile(title: "HEIGHT", primary: BioFormat.heightPrimary(player.height), secondary: BioFormat.heightSecondary(player.height))
                vitalTile(title: "WEIGHT", primary: BioFormat.weightPrimary(player.weight), secondary: BioFormat.weightSecondary(player.weight))
                vitalTile(title: "AGE", primary: BioFormat.ageNumber(player.age), secondary: "years")
            }

            // 2. 키-값 행
            let rows: [(String, String)] = [
                ("Born", player.birthdate),
                ("From", player.countryWithFlag),
                ("Draft", BioFormat.draft(player.draft)),
                ("Experience", BioFormat.experience(player.experience, isRookie: player.isRookie)),
                ("School", player.lastAttended),
            ].filter { !$0.1.trimmingCharacters(in: .whitespaces).isEmpty }

            if !rows.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { idx, row in
                        HStack(alignment: .firstTextBaseline) {
                            Text(row.0)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                            Spacer(minLength: 12)
                            Text(row.1)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.92))
                                .multilineTextAlignment(.trailing)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 10)
                        if idx < rows.count - 1 {
                            Divider().background(Color.white.opacity(0.08))
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
                )
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func vitalTile(title: String, primary: String, secondary: String) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .tracking(0.6)
            Text(primary.isEmpty ? "-" : primary)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(secondary)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.45))
                .lineLimit(1)
                .opacity(primary.isEmpty ? 0 : 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.35))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 1))
        )
    }
}

/// nba.com 원문("6'11\" (2.11m)", "271lb (123kg)", "24 years", "5 Years", "2021 R1 Pick 16")을 표시용으로 정리
enum BioFormat {
    /// "6'11\" (2.11m)" → "6'11\""
    static func heightPrimary(_ raw: String) -> String {
        raw.split(separator: "(").first.map { String($0).trimmingCharacters(in: .whitespaces) } ?? raw
    }
    /// "6'11\" (2.11m)" → "2.11 m"
    static func heightSecondary(_ raw: String) -> String {
        inParens(raw).replacingOccurrences(of: "m", with: " m")
    }
    /// "271lb (123kg)" → "271"
    static func weightPrimary(_ raw: String) -> String {
        let head = raw.split(separator: "(").first.map(String.init) ?? raw
        return head.replacingOccurrences(of: "lb", with: "").replacingOccurrences(of: "lbs", with: "").trimmingCharacters(in: .whitespaces)
    }
    /// "271lb (123kg)" → "lb · 123 kg"
    static func weightSecondary(_ raw: String) -> String {
        let kg = inParens(raw).replacingOccurrences(of: "kg", with: " kg")
        return kg.isEmpty ? "lb" : "lb · \(kg)"
    }
    /// "24 years" → "24"
    static func ageNumber(_ raw: String) -> String {
        raw.filter { $0.isNumber }
    }
    /// "2021 R1 Pick 16" → "2021 · Round 1 · Pick 16", "Undrafted" 그대로
    static func draft(_ raw: String) -> String {
        let t = raw.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return "" }
        let parts = t.split(separator: " ").map(String.init)
        guard parts.count >= 4, parts[1].hasPrefix("R"), parts[2].lowercased() == "pick" else { return t }
        return "\(parts[0]) · Round \(parts[1].dropFirst()) · Pick \(parts[3])"
    }
    /// "5 Years" → "5th season", 루키 → "Rookie"
    static func experience(_ raw: String, isRookie: Bool) -> String {
        if isRookie { return "Rookie" }
        let n = raw.filter { $0.isNumber }
        guard let years = Int(n) else { return raw }
        return "\(String(years + 1).ordinal) season"
    }

    private static func inParens(_ raw: String) -> String {
        guard let open = raw.firstIndex(of: "("), let close = raw.firstIndex(of: ")"), open < close else { return "" }
        return String(raw[raw.index(after: open)..<close]).trimmingCharacters(in: .whitespaces)
    }
}
