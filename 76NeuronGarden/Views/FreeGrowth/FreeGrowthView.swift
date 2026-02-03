//
//  FreeGrowthView.swift
//  76NeuronGarden
//
//  Sandbox - create networks without restrictions
//

import SwiftUI

struct FreeGrowthView: View {
    let onExit: () -> Void
    
    @State private var neurons: [Neuron] = []
    @State private var connections: [Connection] = []
    @State private var activeInputs: Set<UUID> = []
    @State private var selectedNeuronType: NeuronType?
    @State private var isRunning = false
    @State private var activationState = ActivationAnimationState()
    
    private let fieldSize = CGSize(width: 320, height: 320)
    
    var body: some View {
        ZStack {
            NeuronGardenColors.labBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        onExit()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(NeuronGardenColors.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Free Growth")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                    
                    Spacer()
                    
                    Button {
                        clearAll()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundStyle(NeuronGardenColors.textSecondary)
                    }
                    .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                // Add neuron toolbar
                HStack(spacing: 12) {
                    Text("Add:")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(NeuronGardenColors.textSecondary)
                    
                    ForEach(NeuronType.allCases, id: \.self) { type in
                        Button {
                            selectedNeuronType = selectedNeuronType == type ? nil : type
                        } label: {
                            Text(type.displayName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(selectedNeuronType == type ? NeuronGardenColors.labBackground : type.color)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedNeuronType == type ? type.color : NeuronGardenColors.glassPanel)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // Petri dish
                FreeGrowthPetriDishView(
                    neurons: $neurons,
                    connections: $connections,
                    activeInputs: $activeInputs,
                    activationState: activationState,
                    placeNeuronType: selectedNeuronType,
                    onPlaceNeuron: { point in
                        addNeuron(at: point)
                        selectedNeuronType = nil
                    }
                )
                .frame(width: 320, height: 320)
                .padding(.horizontal, 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(NeuronGardenColors.neuralConnection, lineWidth: 2)
                        .opacity(isRunning ? 0.7 : 0)
                )
                
                Text("Tap empty area to place • Long press + tap = connect")
                    .font(.system(size: 11))
                    .foregroundStyle(NeuronGardenColors.textSecondary.opacity(0.7))
                    .padding(.top, 8)
                
                // Controls
                HStack(spacing: 20) {
                    Button {
                        runActivation()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Activate")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(NeuronGardenColors.labBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(NeuronGardenColors.neuralConnection)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isRunning || neurons.isEmpty)
                    
                    Button {
                        resetActivation()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(NeuronGardenColors.textPrimary)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(NeuronGardenColors.glassPanel)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(NeuronGardenColors.glassBorder, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 34)
            }
        }
    }
    
    private func addNeuron(at point: CGPoint) {
        guard let type = selectedNeuronType else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            neurons.append(Neuron(type: type, position: point))
        }
    }
    
    private func runActivation() {
        guard !isRunning else { return }
        isRunning = true
        
        let (updated, state) = NetworkSimulator.propagate(
            neurons: neurons,
            connections: connections,
            sensoryInputs: activeInputs
        )
        
        activationState = ActivationAnimationState(
            phase: 0,
            impulseProgress: 0,
            activeConnectionIDs: Set(state.connectionActive.filter { $0.value }.map { $0.key })
        )
        withAnimation(.easeOut(duration: 0.15)) { activationState.phase = 0.3 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeInOut(duration: 0.6)) {
                activationState.phase = 0.7
                activationState.impulseProgress = 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                neurons = updated
                activationState.phase = 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                neurons = neurons.map { n in
                    var copy = n
                    copy.isActive = false
                    return copy
                }
            }
            activationState = ActivationAnimationState()
            isRunning = false
        }
    }
    
    private func resetActivation() {
        withAnimation {
            neurons = neurons.map { n in
                var copy = n
                copy.isActive = false
                return copy
            }
        }
    }
    
    private func clearAll() {
        withAnimation {
            neurons = []
            connections = []
            activeInputs = []
            selectedNeuronType = nil
        }
    }
}

// MARK: - Free Growth Petri Dish (supports placing neurons)

struct FreeGrowthPetriDishView: View {
    @Binding var neurons: [Neuron]
    @Binding var connections: [Connection]
    @Binding var activeInputs: Set<UUID>
    var activationState: ActivationAnimationState = ActivationAnimationState()
    let placeNeuronType: NeuronType?
    let onPlaceNeuron: (CGPoint) -> Void
    
    @State private var connectionFromNeuronID: UUID?
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(NeuronGardenColors.labBackground)
                    .overlay(GridOverlay())
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(NeuronGardenColors.glassBorder, lineWidth: 2)
                    )
                    .overlay(
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        let dist = value.translation.width * value.translation.width +
                                            value.translation.height * value.translation.height
                                        if dist < 100 {
                                            let loc = value.location
                                            let hitNeuron = neurons.contains { n in
                                                let dx = n.position.x - loc.x
                                                let dy = n.position.y - loc.y
                                                return dx * dx + dy * dy < 900
                                            }
                                            if !hitNeuron {
                                                if placeNeuronType != nil {
                                                    onPlaceNeuron(loc)
                                                } else {
                                                    connectionFromNeuronID = nil
                                                }
                                            }
                                        }
                                    }
                            )
                    )
                
                ForEach(connections) { connection in
                    ConnectionView(
                        connection: connection,
                        fromPosition: neuronPosition(for: connection.fromNeuronID, in: size),
                        toPosition: neuronPosition(for: connection.toNeuronID, in: size),
                        isImpulseActive: activationState.activeConnectionIDs.contains(connection.id),
                        impulseProgress: activationState.impulseProgress
                    )
                }
                
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

#Preview {
    FreeGrowthView(onExit: {})
}
