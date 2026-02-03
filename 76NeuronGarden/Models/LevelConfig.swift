//
//  LevelConfig.swift
//  76NeuronGarden
//
//  Level configurations - different setups per level
//

import SwiftUI

struct LevelConfig {
    let levelNumber: Int
    let title: String
    let taskDescription: String
    let hint: String
    let neurons: [NeuronSetup]
    let requiredConnections: [(from: NeuronType, to: NeuronType)]?
    let successCondition: SuccessCondition
    
    enum SuccessCondition {
        case connectAllToMotor
        case andGate
        case orGate
        case custom(([Neuron], [Connection], [UUID]) -> Bool)
    }
}

struct NeuronSetup {
    let type: NeuronType
    let position: CGPoint
    let activationThreshold: Double?
    let outputStrength: Double?
    
    init(type: NeuronType, position: CGPoint, activationThreshold: Double? = nil, outputStrength: Double? = nil) {
        self.type = type
        self.position = position
        self.activationThreshold = activationThreshold
        self.outputStrength = outputStrength
    }
}

extension LevelConfig {
    
    static func config(for level: Int, fieldSize: CGSize) -> LevelConfig {
        let center = CGPoint(x: fieldSize.width / 2, y: fieldSize.height / 2)
        let r: CGFloat = min(fieldSize.width, fieldSize.height) * 0.35
        
        switch level {
        case 1:
            return LevelConfig(
                levelNumber: 1,
                title: "First Connection",
                taskDescription: "Create a connection from any sensory neuron to the motor neuron. Tap a sensory neuron to give it input, then press Activate.",
                hint: "Long press on a neuron, drag to another, release to connect.",
                neurons: [
                    NeuronSetup(type: .sensory, position: CGPoint(x: center.x - 50, y: center.y - 70)),
                    NeuronSetup(type: .motor, position: CGPoint(x: center.x, y: center.y + 60))
                ],
                requiredConnections: nil,
                successCondition: .connectAllToMotor
            )
            
        case 2:
            return LevelConfig(
                levelNumber: 2,
                title: "AND Gate",
                taskDescription: "Connect both sensory neurons to the motor. The motor must fire ONLY when BOTH inputs are active.",
                hint: "Two connections: Sensory 1 → Motor and Sensory 2 → Motor. Test with one input — motor should stay off.",
                neurons: [
                    NeuronSetup(type: .sensory, position: CGPoint(x: center.x - 70, y: center.y - 50), outputStrength: 0.5),
                    NeuronSetup(type: .sensory, position: CGPoint(x: center.x + 70, y: center.y - 50), outputStrength: 0.5),
                    NeuronSetup(type: .motor, position: CGPoint(x: center.x, y: center.y + 80), activationThreshold: 0.8)
                ],
                requiredConnections: nil,
                successCondition: .andGate
            )
            
        case 3:
            return LevelConfig(
                levelNumber: 3,
                title: "AND Gate",
                taskDescription: "Build AND logic: motor fires ONLY when BOTH sensory neurons receive input. Use an intermediate neuron.",
                hint: "Intermediate neurons process information. Both inputs must reach the motor.",
                neurons: [
                    NeuronSetup(type: .sensory, position: CGPoint(x: center.x - 80, y: center.y - 80), outputStrength: 0.5),
                    NeuronSetup(type: .sensory, position: CGPoint(x: center.x + 80, y: center.y - 80), outputStrength: 0.5),
                    NeuronSetup(type: .intermediate, position: CGPoint(x: center.x, y: center.y)),
                    NeuronSetup(type: .motor, position: CGPoint(x: center.x, y: center.y + 90), activationThreshold: 0.8)
                ],
                requiredConnections: nil,
                successCondition: .andGate
            )
            
        case 4:
            return LevelConfig(
                levelNumber: 4,
                title: "Choice",
                taskDescription: "Connect the sensory neuron to the motor. Try different connection paths.",
                hint: "Sometimes the simplest path is the best.",
                neurons: [
                    NeuronSetup(type: .sensory, position: CGPoint(x: center.x - 90, y: center.y)),
                    NeuronSetup(type: .intermediate, position: CGPoint(x: center.x, y: center.y - 40)),
                    NeuronSetup(type: .motor, position: CGPoint(x: center.x + 90, y: center.y))
                ],
                requiredConnections: nil,
                successCondition: .connectAllToMotor
            )
            
        case 5:
            return LevelConfig(
                levelNumber: 5,
                title: "Network",
                taskDescription: "Create a network where the motor fires when any sensory neuron is active. Use 2 sensory, 1 intermediate, 1 motor.",
                hint: "OR logic: either input can trigger the output.",
                neurons: [
                    NeuronSetup(type: .sensory, position: CGPoint(x: center.x - 75, y: center.y - 70)),
                    NeuronSetup(type: .sensory, position: CGPoint(x: center.x + 75, y: center.y - 70)),
                    NeuronSetup(type: .intermediate, position: CGPoint(x: center.x, y: center.y + 10)),
                    NeuronSetup(type: .motor, position: CGPoint(x: center.x, y: center.y + 90))
                ],
                requiredConnections: nil,
                successCondition: .orGate
            )
            
        default:
            return LevelConfig(
                levelNumber: level,
                title: "Level \(level)",
                taskDescription: "Connect neurons and complete the task.",
                hint: "Long press and drag to create connections.",
                neurons: [
                    NeuronSetup(type: .sensory, position: CGPoint(x: center.x - 60, y: center.y - 60)),
                    NeuronSetup(type: .sensory, position: CGPoint(x: center.x + 60, y: center.y - 60)),
                    NeuronSetup(type: .motor, position: CGPoint(x: center.x, y: center.y + 80))
                ],
                requiredConnections: nil,
                successCondition: .connectAllToMotor
            )
        }
    }
}
