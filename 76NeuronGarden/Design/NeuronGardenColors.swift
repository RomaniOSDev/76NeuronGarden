//
//  NeuronGardenColors.swift
//  76NeuronGarden
//
//  Color palette for Neuron Garden
//

import SwiftUI

enum NeuronGardenColors {
    /// Deep blue-violet — lab glass, petri dish background
    static let labBackground = Color(hex: "3e4464")
    
    /// Golden — neuron cores, synapses, activation impulses
    static let neuronCore = Color(hex: "fcc418")
    
    /// Green — axons/dendrites, living connections
    static let neuralConnection = Color(hex: "3cc45b")
    
    /// Brighter variants for active states
    static let neuronCoreActive = Color(hex: "ffd84d")
    static let neuralConnectionActive = Color(hex: "5ce680")
    
    /// UI accents
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.8)
    static let glassPanel = Color.white.opacity(0.12)
    static let glassBorder = Color.white.opacity(0.25)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
