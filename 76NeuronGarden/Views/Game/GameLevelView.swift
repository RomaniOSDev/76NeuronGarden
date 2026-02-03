//
//  GameLevelView.swift
//  76NeuronGarden
//
//  Game level screen - Petri dish + controls
//

import SwiftUI

struct ActivationAnimationState {
    var phase: Double = 0
    var impulseProgress: Double = 0
    var activeConnectionIDs: Set<UUID> = []
}

struct GameLevelView: View {
    let levelNumber: Int
    let onExit: () -> Void
    
    @State private var neurons: [Neuron] = []
    @State private var connections: [Connection] = []
    @State private var activeInputs: Set<UUID> = []
    @State private var isRunning = false
    @State private var showTaskPanel = true
    @State private var showSuccess = false
    @State private var levelConfig: LevelConfig?
    @State private var activationState = ActivationAnimationState()
    
    private let fieldSize = CGSize(width: 320, height: 320)
    
    var body: some View {
        ZStack {
            NeuronGardenColors.labBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
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
                    
                    Text("Level \(levelNumber)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                    
                    Spacer()
                    
                    Button {
                        withAnimation { showTaskPanel.toggle() }
                    } label: {
                        Image(systemName: showTaskPanel ? "info.circle.fill" : "info.circle")
                            .font(.system(size: 22))
                            .foregroundStyle(NeuronGardenColors.neuronCore)
                    }
                    .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                // Task panel
                if showTaskPanel, let config = levelConfig {
                    TaskPanelView(config: config)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                }
                
                // Petri dish
                PetriDishView(
                    neurons: $neurons,
                    connections: $connections,
                    activeInputs: $activeInputs,
                    activationState: activationState
                )
                .frame(width: 320, height: 320)
                .padding(.horizontal, 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(NeuronGardenColors.neuralConnection, lineWidth: 2)
                        .opacity(isRunning ? 0.7 : 0)
                )
                
                // Hint
                Text("Tap sensory = input • Long press + tap = connect")
                    .font(.system(size: 11))
                    .foregroundStyle(NeuronGardenColors.textSecondary.opacity(0.7))
                    .padding(.top, 8)
                
                // Control bar
                HStack(spacing: 20) {
                    Button {
                        runActivation()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isRunning ? "stop.fill" : "play.fill")
                            Text(isRunning ? "Stop" : "Activate")
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
                    .disabled(isRunning)
                    
                    Button {
                        resetNetwork()
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
        .overlay {
            if showSuccess {
                SuccessOverlay(onDismiss: {
                    showSuccess = false
                    onExit()
                })
            }
        }
        .onAppear {
            setupLevel()
        }
    }
    
    private func setupLevel() {
        let config = LevelConfig.config(for: levelNumber, fieldSize: fieldSize)
        levelConfig = config
        
        neurons = config.neurons.map { setup in
            Neuron(
                type: setup.type,
                position: setup.position,
                activationThreshold: setup.activationThreshold ?? 0.5,
                outputStrength: setup.outputStrength ?? 1.0
            )
        }
        connections = []
        activeInputs = []
    }
    
    private func runActivation() {
        guard !isRunning else { return }
        isRunning = true
        
        let (updated, state) = NetworkSimulator.propagate(
            neurons: neurons,
            connections: connections,
            sensoryInputs: activeInputs
        )
        
        // Phase 1: Sensory charge (0.2s)
        activationState = ActivationAnimationState(
            phase: 0,
            impulseProgress: 0,
            activeConnectionIDs: Set(state.connectionActive.filter { $0.value }.map { $0.key })
        )
        
        withAnimation(.easeOut(duration: 0.15)) {
            activationState.phase = 0.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            // Phase 2: Impulse travels along connections (0.6s)
            withAnimation(.easeInOut(duration: 0.6)) {
                activationState.phase = 0.7
                activationState.impulseProgress = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            // Phase 3: Neurons light up
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                neurons = updated
                activationState.phase = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let config = levelConfig,
               NetworkSimulator.checkSuccess(
                level: levelNumber,
                neurons: neurons,
                connections: connections,
                sensoryInputs: activeInputs,
                condition: config.successCondition
               ) {
                CampaignProgress.completeLevel(levelNumber)
                withAnimation {
                    showSuccess = true
                }
            }
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
    
    private func resetNetwork() {
        setupLevel()
    }
}

// MARK: - Success Overlay

struct SuccessOverlay: View {
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(NeuronGardenColors.neuralConnection)
                
                Text("Level Complete!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Button("Continue") {
                    onDismiss()
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(NeuronGardenColors.labBackground)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(NeuronGardenColors.neuralConnection)
                )
                .padding(.top, 8)
            }
            .padding(40)
        }
    }
}

// MARK: - Task Panel

struct TaskPanelView: View {
    let config: LevelConfig
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(config.title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(NeuronGardenColors.neuralConnection)
            
            Text(config.taskDescription)
                .font(.system(size: 13))
                .foregroundStyle(NeuronGardenColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Hint: \(config.hint)")
                .font(.system(size: 11))
                .foregroundStyle(NeuronGardenColors.textSecondary.opacity(0.8))
                .italic()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(NeuronGardenColors.glassPanel)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(NeuronGardenColors.glassBorder.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

#Preview {
    GameLevelView(levelNumber: 1, onExit: {})
}
