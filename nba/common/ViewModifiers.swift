//
//  ViewModifiers.swift
//  nba
//
//  Created by 1100690 on 1/3/24.
//

import SwiftUI

struct TextViewModifier: ViewModifier {
    let color: Color
    let font: Font
    let weight: Font.Weight

    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .font(font)
            .fontWeight(weight)
    }
}

extension View {
    func textStyle(color: Color = .black, font: Font = .body, weight: Font.Weight = .regular) -> some View {
        modifier(TextViewModifier(color: color, font: font, weight: weight))
    }
}
