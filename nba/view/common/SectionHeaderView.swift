
import SwiftUI

struct SectionHeaderView: View {
    let title: String
    var showArrow: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            // Accent Line (Optional, decorative)
            Capsule()
                .fill(Color.orange) // NBA Orange accent
                .frame(width: 4, height: 16)
            
            Text(title)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(.white) // Brighter than gray
                .tracking(0.5) // Slight letter spacing
            
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }
}

#Preview {
    ZStack {
        Color.black
        VStack {
            SectionHeaderView(title: "PERFORMANCE OF THE NIGHT")
            SectionHeaderView(title: "STANDINGS")
            SectionHeaderView(title: "RECENT GAMES")
        }
    }
}
