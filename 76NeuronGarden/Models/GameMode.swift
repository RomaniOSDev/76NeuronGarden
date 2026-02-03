//
//  GameMode.swift
//  76NeuronGarden
//
//  Game mode definitions for Neuron Garden
//

import SwiftUI

enum GameMode: String, CaseIterable, Identifiable {
    case campaign = "Campaign"
    case freeGrowth = "Free Growth"
    case dailyTasks = "Daily Tasks"
    case customLevels = "Custom Levels"
    case experiments = "Experiments"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .campaign: return "map.fill"
        case .freeGrowth: return "leaf.fill"
        case .dailyTasks: return "calendar"
        case .customLevels: return "pencil.and.outline"
        case .experiments: return "flask.fill"
        }
    }
    
    var description: String {
        switch self {
        case .campaign: return "Progressive levels with growing complexity"
        case .freeGrowth: return "Create networks without restrictions"
        case .dailyTasks: return "Random generated challenges"
        case .customLevels: return "Create and share custom tasks"
        case .experiments: return "Discover new mechanics"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .campaign: return NeuronGardenColors.neuralConnection
        case .freeGrowth: return NeuronGardenColors.neuronCore
        case .dailyTasks: return Color(hex: "3cc45b").opacity(0.8)
        case .customLevels: return Color(hex: "fcc418").opacity(0.9)
        case .experiments: return Color(hex: "9b59b6")
        }
    }
}
