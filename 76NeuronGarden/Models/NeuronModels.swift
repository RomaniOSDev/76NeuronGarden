//
//  NeuronModels.swift
//  76NeuronGarden
//
//  Core data models for neural network simulation
//

import SwiftUI

enum NeuronType: String, CaseIterable, Codable {
    case sensory      // Input neurons
    case motor        // Output neurons
    case intermediate // Hidden layer
    case modulator    // Modulate connection properties
    
    var color: Color {
        switch self {
        case .sensory: return Color(hex: "fcc418")      // Golden — input
        case .motor: return Color(hex: "3cc45b")       // Green — output
        case .intermediate: return Color(hex: "5dade2") // Light blue — hidden
        case .modulator: return Color(hex: "9b59b6")   // Purple — modulate
        }
    }
    
    var icon: String {
        switch self {
        case .sensory: return "arrow.down.to.line"
        case .motor: return "arrow.up.from.line"
        case .intermediate: return "gearshape.fill"
        case .modulator: return "waveform.path"
        }
    }
    
    var displayName: String {
        switch self {
        case .sensory: return "Sensory"
        case .motor: return "Motor"
        case .intermediate: return "Intermediate"
        case .modulator: return "Modulator"
        }
    }
}

struct Neuron: Identifiable, Equatable {
    let id: UUID
    var type: NeuronType
    var position: CGPoint
    var activationThreshold: Double  // 0.0-1.0
    var outputStrength: Double      // 0.0-1.0
    var isActive: Bool
    var recoveryTime: Double        // Time to recover after activation
    
    init(
        id: UUID = UUID(),
        type: NeuronType,
        position: CGPoint = .zero,
        activationThreshold: Double = 0.5,
        outputStrength: Double = 1.0,
        isActive: Bool = false,
        recoveryTime: Double = 0.5
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.activationThreshold = activationThreshold
        self.outputStrength = outputStrength
        self.isActive = isActive
        self.recoveryTime = recoveryTime
    }
}

struct Connection: Identifiable, Equatable {
    let id: UUID
    let fromNeuronID: UUID
    let toNeuronID: UUID
    var weight: Double          // 0.0-1.0, connection strength
    var delay: Double           // 0.0-1.0, transmission delay
    var isExcitatory: Bool      // Excitatory vs inhibitory
    var age: Int                // For neuroplasticity (strengthens with use)
    
    init(
        id: UUID = UUID(),
        fromNeuronID: UUID,
        toNeuronID: UUID,
        weight: Double = 1.0,
        delay: Double = 0.2,
        isExcitatory: Bool = true,
        age: Int = 0
    ) {
        self.id = id
        self.fromNeuronID = fromNeuronID
        self.toNeuronID = toNeuronID
        self.weight = weight
        self.delay = delay
        self.isExcitatory = isExcitatory
        self.age = age
    }
}

// MARK: - Game Task Types

enum TaskCategory: String, CaseIterable {
    case binaryClassification = "Binary Classification"
    case patterns = "Patterns & Sequences"
    case logic = "Logic Operations"
    case adaptive = "Adaptive Learning"
    case complex = "Complex Architectures"
}

struct NetworkTask: Identifiable {
    let id: UUID
    let category: TaskCategory
    let levelNumber: Int
    let title: String
    let description: String
    let expectedBehavior: String
    let isUnlocked: Bool
    
    init(
        id: UUID = UUID(),
        category: TaskCategory,
        levelNumber: Int,
        title: String,
        description: String,
        expectedBehavior: String,
        isUnlocked: Bool = false
    ) {
        self.id = id
        self.category = category
        self.levelNumber = levelNumber
        self.title = title
        self.description = description
        self.expectedBehavior = expectedBehavior
        self.isUnlocked = isUnlocked
    }
}

struct TaskResult {
    let isSuccess: Bool
    let efficiency: Double
    let elegance: Double
    let speed: Double
    let energyConsumption: Double
    let feedbackMessage: String
}
