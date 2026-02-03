//
//  NetworkSimulator.swift
//  76NeuronGarden
//
//  Simulates activation propagation through the network
//

import Foundation

struct ActivationState {
    var neuronActivity: [UUID: Double]  // neuron ID -> activation level 0...1
    var connectionActive: [UUID: Bool]  // connection ID -> is transmitting
}

struct NetworkSimulator {
    
    /// Propagate activation from sensory neurons with input through the network.
    /// Returns updated neurons and which connections are active.
    static func propagate(
        neurons: [Neuron],
        connections: [Connection],
        sensoryInputs: Set<UUID>
    ) -> (updatedNeurons: [Neuron], activationState: ActivationState) {
        var activity: [UUID: Double] = [:]
        var connectionActive: [UUID: Bool] = [:]
        
        // Initialize: sensory neurons with input = 1, others = 0
        for n in neurons {
            if n.type == .sensory && sensoryInputs.contains(n.id) {
                activity[n.id] = 1.0
            } else {
                activity[n.id] = 0
            }
        }
        
        // Simple propagation: sum weighted inputs, threshold
        var changed = true
        var iterations = 0
        let maxIterations = 20
        
        while changed && iterations < maxIterations {
            changed = false
            iterations += 1
            
            var newActivity = activity
            
            for conn in connections {
                guard let fromLevel = activity[conn.fromNeuronID], fromLevel > 0.3 else {
                    connectionActive[conn.id] = false
                    continue
                }
                
                let fromNeuron = neurons.first { $0.id == conn.fromNeuronID }!
                let signal = fromLevel * fromNeuron.outputStrength * conn.weight
                let effectiveSignal = conn.isExcitatory ? signal : -signal
                
                connectionActive[conn.id] = true
                
                let currentTo = newActivity[conn.toNeuronID] ?? 0
                let toNeuron = neurons.first { $0.id == conn.toNeuronID }!
                var newTo = currentTo + effectiveSignal
                newTo = min(1, max(0, newTo))
                if newTo >= toNeuron.activationThreshold {
                    newTo = 1
                } else if newTo < toNeuron.activationThreshold {
                    newTo = max(0, newTo)
                }
                if abs(newTo - currentTo) > 0.01 {
                    changed = true
                }
                newActivity[conn.toNeuronID] = newTo
            }
            
            activity = newActivity
        }
        
        // Build updated neurons with isActive
        let updatedNeurons = neurons.map { n -> Neuron in
            let level = activity[n.id] ?? 0
            var copy = n
            copy.isActive = level >= n.activationThreshold
            return copy
        }
        
        let state = ActivationState(neuronActivity: activity, connectionActive: connectionActive)
        return (updatedNeurons, state)
    }
    
    static func checkSuccess(
        level: Int,
        neurons: [Neuron],
        connections: [Connection],
        sensoryInputs: Set<UUID>,
        condition: LevelConfig.SuccessCondition
    ) -> Bool {
        let (updatedNeurons, _) = propagate(neurons: neurons, connections: connections, sensoryInputs: sensoryInputs)
        
        switch condition {
        case .connectAllToMotor:
            let motorFires = updatedNeurons.first { $0.type == .motor }?.isActive ?? false
            let hasConnection = connections.contains { conn in
                let from = neurons.first { $0.id == conn.fromNeuronID }
                let to = neurons.first { $0.id == conn.toNeuronID }
                return from?.type == .sensory && to?.type == .motor
            }
            return hasConnection && motorFires && !sensoryInputs.isEmpty
            
        case .orGate:
            let motor = updatedNeurons.first { $0.type == .motor }
            guard let m = motor, !sensoryInputs.isEmpty else { return false }
            let hasPath = connections.contains { conn in
                let from = neurons.first { $0.id == conn.fromNeuronID}
                let to = neurons.first { $0.id == conn.toNeuronID }
                return (from?.type == .sensory || from?.type == .intermediate) &&
                       (to?.type == .motor || to?.type == .intermediate)
            }
            return hasPath && m.isActive
            
        case .andGate:
            let sensoryIds = neurons.filter { $0.type == .sensory }.map(\.id)
            guard sensoryIds.count >= 2 else { return false }
            let (r1, _) = propagate(neurons: neurons, connections: connections, sensoryInputs: Set([sensoryIds[0]]))
            let (r2, _) = propagate(neurons: neurons, connections: connections, sensoryInputs: Set([sensoryIds[1]]))
            let (rBoth, _) = propagate(neurons: neurons, connections: connections, sensoryInputs: Set(sensoryIds))
            let motor = updatedNeurons.first { $0.type == .motor }
            guard let m = motor else { return false }
            let bothFire = rBoth.first { $0.type == .motor }?.isActive ?? false
            let only1 = r1.first { $0.type == .motor }?.isActive ?? false
            let only2 = r2.first { $0.type == .motor }?.isActive ?? false
            return bothFire && !only1 && !only2
            
        case .custom(let checker):
            return checker(updatedNeurons, connections, Array(sensoryInputs))
        }
    }
}
