//
//  PetriDishView.swift
//  76NeuronGarden
//
//  Petri dish game field - neural network canvas
//

import SwiftUI

struct PetriDishView: View {
    @Binding var neurons: [Neuron]
    @Binding var connections: [Connection]
    @Binding var activeInputs: Set<UUID>
    var activationState: ActivationAnimationState = ActivationAnimationState()
    
    @State private var connectionFromNeuronID: UUID?
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                // Background with grid
                RoundedRectangle(cornerRadius: 24)
                    .fill(NeuronGardenColors.labBackground)
                    .overlay(GridOverlay())
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(NeuronGardenColors.glassBorder, lineWidth: 2)
                    )
                    .onTapGesture {
                        connectionFromNeuronID = nil
                    }
                
                // Connections
                ForEach(connections) { connection in
                    ConnectionView(
                        connection: connection,
                        fromPosition: neuronPosition(for: connection.fromNeuronID, in: size),
                        toPosition: neuronPosition(for: connection.toNeuronID, in: size),
                        isImpulseActive: activationState.activeConnectionIDs.contains(connection.id),
                        impulseProgress: activationState.impulseProgress
                    )
                }
                
                // Neurons
                ForEach(neurons) { neuron in
                    NeuronNodeView(
                        neuron: neuron,
                        isSelected: connectionFromNeuronID == neuron.id,
                        hasInput: neuron.type == .sensory && activeInputs.contains(neuron.id),
                        isCharging: activationState.phase > 0 && activationState.phase < 0.5 &&
                            neuron.type == .sensory && activeInputs.contains(neuron.id)
                    )
                    .position(neuron.position)
                    .onTapGesture {
                        handleNeuronTap(neuron, isLongPress: false)
                    }
                    .onLongPressGesture(minimumDuration: 0.5) {
                        handleNeuronTap(neuron, isLongPress: true)
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func handleNeuronTap(_ neuron: Neuron, isLongPress: Bool) {
        if isLongPress {
            connectionFromNeuronID = neuron.id
            return
        }
        if let fromID = connectionFromNeuronID {
            if fromID != neuron.id {
                addConnection(from: fromID, to: neuron.id)
            }
            connectionFromNeuronID = nil
        } else if neuron.type == .sensory {
            withAnimation(.easeInOut(duration: 0.15)) {
                if activeInputs.contains(neuron.id) {
                    activeInputs.remove(neuron.id)
                } else {
                    activeInputs.insert(neuron.id)
                }
            }
        } else {
            connectionFromNeuronID = neuron.id
        }
    }
    
    private func neuronPosition(for id: UUID, in size: CGSize) -> CGPoint {
        neurons.first { $0.id == id }?.position ?? .zero
    }
    
    private func addConnection(from: UUID, to: UUID) {
        guard !connections.contains(where: { $0.fromNeuronID == from && $0.toNeuronID == to }) else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            connections.append(Connection(fromNeuronID: from, toNeuronID: to))
        }
    }
}

// MARK: - Connection View

struct ConnectionView: View {
    let connection: Connection
    let fromPosition: CGPoint
    let toPosition: CGPoint
    var isImpulseActive: Bool = false
    var impulseProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Base connection
            Path { path in
                path.move(to: fromPosition)
                path.addLine(to: toPosition)
            }
            .stroke(
                connection.isExcitatory ? NeuronGardenColors.neuralConnection : NeuronGardenColors.neuronCore.opacity(0.6),
                style: StrokeStyle(
                    lineWidth: CGFloat(2 + connection.weight * 3),
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .opacity(0.6 + connection.weight * 0.4)
            
            // Impulse traveling along connection
            if isImpulseActive && impulseProgress > 0 {
                Path { path in
                    path.move(to: fromPosition)
                    path.addLine(to: toPosition)
                }
                .trim(from: 0, to: impulseProgress)
                .stroke(
                    NeuronGardenColors.neuronCore,
                    style: StrokeStyle(
                        lineWidth: CGFloat(4 + connection.weight * 2),
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .opacity(0.9)
                .shadow(color: NeuronGardenColors.neuronCore.opacity(0.8), radius: 4)
            }
        }
    }
}

// MARK: - Neuron Node View

struct NeuronNodeView: View {
    let neuron: Neuron
    let isSelected: Bool
    let hasInput: Bool
    var isCharging: Bool = false
    
    @State private var pulseScale: CGFloat = 1.0
    
    private var isHighlighted: Bool {
        neuron.isActive || isCharging
    }
    
    var body: some View {
        ZStack {
            // Glow when active or charging
            if isSelected || hasInput || isHighlighted {
                Circle()
                    .fill(neuron.type.color.opacity(isHighlighted ? 0.6 : 0.35))
                    .frame(width: isHighlighted ? 60 : 52, height: isHighlighted ? 60 : 52)
                    .blur(radius: isHighlighted ? 12 : 8)
            }
            
            Circle()
                .stroke(neuron.type.color, lineWidth: isSelected ? 3 : (isHighlighted ? 2.5 : 2))
                .frame(width: 36, height: 36)
            
            Circle()
                .fill(neuron.type.color.opacity(neuron.isActive ? 1 : (hasInput || isCharging ? 0.95 : 0.7)))
                .frame(width: 28, height: 28)
                .scaleEffect(neuron.isActive ? 1.25 : (isCharging ? 1.15 : pulseScale))
            
            Image(systemName: neuron.type.icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(neuron.isActive ? 1 : 0.9))
            
            if hasInput && !neuron.isActive && !isCharging {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.9))
                    .offset(y: -24)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = neuron.isActive ? 1.25 : 1.05
            }
        }
    }
}

// MARK: - Grid Overlay

struct GridOverlay: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let spacing: CGFloat = 20
                for i in stride(from: 0, through: geo.size.width + spacing, by: spacing) {
                    path.move(to: CGPoint(x: i, y: 0))
                    path.addLine(to: CGPoint(x: i, y: geo.size.height))
                }
                for i in stride(from: 0, through: geo.size.height + spacing, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: i))
                    path.addLine(to: CGPoint(x: geo.size.width, y: i))
                }
            }
            .stroke(Color.white.opacity(0.06), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Preview

#Preview {
    let n1 = Neuron(type: .sensory, position: CGPoint(x: 100, y: 100))
    let n2 = Neuron(type: .motor, position: CGPoint(x: 200, y: 200))
    return PetriDishView(
        neurons: .constant([n1, n2]),
        connections: .constant([Connection(fromNeuronID: n1.id, toNeuronID: n2.id, weight: 0.8)]),
        activeInputs: .constant([])
    )
    .frame(width: 350, height: 350)
    .padding()
}
