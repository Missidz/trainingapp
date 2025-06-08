//
//  DesignSystem.swift
//  trainingapp
//
//  Created by Missi Cherifi on 08/06/2025.
//

import SwiftUI

// MARK: - Colors inspired by Solo Leveling
extension Color {
    // Primary colors
    static let primaryBackground = Color(hex: "0D0D0D") // Noir doux
    static let primaryAccent = Color(hex: "4F46E5") // Bleu-violet
    static let secondaryAccent = Color(hex: "9333EA") // Violet vif
    static let textPrimary = Color(hex: "F3F4F6") // Gris clair
    static let textSecondary = Color(hex: "9CA3AF") // Gris moyen
    static let successColor = Color(hex: "10B981") // Vert émeraude
    static let dangerColor = Color(hex: "EF4444") // Rouge
    
    // Gradient colors
    static let shadowGradient = LinearGradient(
        colors: [Color.primaryAccent.opacity(0.8), Color.secondaryAccent.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let levelUpGradient = LinearGradient(
        colors: [Color.secondaryAccent, Color.primaryAccent],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Convenience initializer for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Fonts
extension Font {
    static let titleFont = Font.custom("Exo 2", size: 28).weight(.bold)
    static let headerFont = Font.custom("Exo 2", size: 20).weight(.semibold)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .rounded)
    static let captionFont = Font.system(size: 14, weight: .medium, design: .rounded)
    static let levelFont = Font.system(size: 24, weight: .bold, design: .rounded)
}

// MARK: - Shadow and Glow Effects
extension View {
    func shadowGlow(color: Color = Color.primaryAccent, radius: CGFloat = 10) -> some View {
        self.shadow(color: color.opacity(0.3), radius: radius, x: 0, y: 0)
    }
    
    func cardStyle() -> some View {
        self
            .background(Color.black.opacity(0.3))
            .cornerRadius(16)
            .shadowGlow()
    }
    
    func primaryButtonStyle() -> some View {
        self
            .foregroundColor(.textPrimary)
            .padding()
            .background(Color.shadowGradient)
            .cornerRadius(12)
            .shadowGlow()
    }
    
    func levelUpAnimation() -> some View {
        self
            .scaleEffect(1.1)
            .animation(.easeInOut(duration: 0.3).repeatCount(3), value: true)
    }
}

// MARK: - Constants
struct AppConstants {
    static let cornerRadius: CGFloat = 16
    static let padding: CGFloat = 16
    static let cardPadding: CGFloat = 20
    static let buttonHeight: CGFloat = 50
    
    // XP and Level calculations
    static let baseXPPerLevel = 100
    static let xpMultiplier = 1.2
    
    // Animations
    static let springAnimation = Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)
    static let levelUpAnimation = Animation.easeInOut(duration: 0.8)
}

// MARK: - Custom Progress Bar
struct XPProgressBar: View {
    let currentXP: Int
    let maxXP: Int
    let level: Int
    
    var progress: Double {
        Double(currentXP) / Double(maxXP)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Level \(level)")
                    .font(.levelFont)
                    .foregroundColor(.textPrimary)
                Spacer()
                Text("\(currentXP) / \(maxXP) XP")
                    .font(.captionFont)
                    .foregroundColor(.textSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.3)
                        .foregroundColor(.textSecondary)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width), height: 8)
                        .foregroundColor(.primaryAccent)
                        .animation(.spring(), value: progress)
                        .shadowGlow(color: .primaryAccent, radius: 5)
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Difficulty Badge
struct DifficultyBadge: View {
    let difficulty: WorkoutDifficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.captionFont)
            .foregroundColor(.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(hex: difficulty.color).opacity(0.8))
            .cornerRadius(8)
            .shadowGlow(color: Color(hex: difficulty.color), radius: 3)
    }
}

// MARK: - Rarity Badge
struct RarityBadge: View {
    let rarity: AchievementRarity
    
    var body: some View {
        Text(rarity.rawValue)
            .font(.captionFont)
            .foregroundColor(.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(hex: rarity.color).opacity(0.8))
            .cornerRadius(6)
            .shadowGlow(color: Color(hex: rarity.color), radius: 2)
    }
}

// MARK: - Level Up Animation View
struct LevelUpView: View {
    @State private var showAnimation = false
    @State private var scale = 0.5
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("LEVEL UP!")
                    .font(.titleFont)
                    .foregroundColor(.textPrimary)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.secondaryAccent)
                    .rotationEffect(.degrees(showAnimation ? 360 : 0))
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .shadowGlow(color: .secondaryAccent, radius: 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                showAnimation = true
            }
        }
    }
} 