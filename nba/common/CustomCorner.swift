//
//  CustomCorner.swift
//  minimal
//
//  Created by 1100690 on 2022/11/04.
//

import SwiftUI

// MARK: Custom corner Path Shape
struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
