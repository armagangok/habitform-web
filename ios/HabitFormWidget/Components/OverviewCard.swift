//
//  OverviewCard.swift
//  Runner
//
//  Created by Armagan Gok on 6.10.2025.
//

import SwiftUI


struct OverviewStatCard: View {
    let title: String
    let value: Int
    let unit: String
    let icon: String
    let color: Color
    

    var body: some View {
        VStack(spacing: 6) {
            // Top section with icon and value
            HStack {
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    

                Spacer()

                // Value and unit on the right
                VStack(alignment: .trailing, spacing: 1) {
                    Text("\(value)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        
                    
                    
                }
            }

            
            // Title at the bottom
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.background)
        )
    }
        
        
}
