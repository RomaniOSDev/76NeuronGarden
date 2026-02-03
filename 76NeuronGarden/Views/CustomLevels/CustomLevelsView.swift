//
//  CustomLevelsView.swift
//  76NeuronGarden
//
//  Create and manage custom levels
//

import SwiftUI

struct CustomLevelsView: View {
    let onExit: () -> Void
    
    @State private var customLevels: [CustomLevel] = CustomLevelStorage.load()
    @State private var showCreateSheet = false
    @State private var levelToPlay: CustomLevel?
    
    var body: some View {
        ZStack {
            NeuronGardenColors.labBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        onExit()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(NeuronGardenColors.neuronCore)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Custom Levels")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                    
                    Spacer()
                    
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(NeuronGardenColors.neuralConnection)
                    }
                    .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)
                
                if customLevels.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(NeuronGardenColors.textSecondary.opacity(0.5))
                        
                        Text("No custom levels yet")
                            .font(.system(size: 17))
                            .foregroundStyle(NeuronGardenColors.textSecondary)
                        
                        Text("Create your own neural network challenge")
                            .font(.system(size: 14))
                            .foregroundStyle(NeuronGardenColors.textSecondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Button {
                            showCreateSheet = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                Text("Create Level")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(NeuronGardenColors.labBackground)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(NeuronGardenColors.neuralConnection)
                            )
                        }
                        .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(customLevels) { level in
                                CustomLevelRow(
                                    level: level,
                                    onPlay: { levelToPlay = level },
                                    onDelete: {
                                        customLevels.removeAll { $0.id == level.id }
                                        CustomLevelStorage.save(customLevels)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateCustomLevelView(
                onSave: { newLevel in
                    customLevels.append(newLevel)
                    CustomLevelStorage.save(customLevels)
                    showCreateSheet = false
                },
                onCancel: { showCreateSheet = false }
            )
        }
        .fullScreenCover(item: $levelToPlay) { level in
            CustomLevelPlayView(level: level, onExit: {
                levelToPlay = nil
            })
        }
    }
}

// MARK: - Custom Level Model

struct CustomLevel: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var taskDescription: String
    var neurons: [NeuronSetupCodable]
    var successCondition: String
    
    struct NeuronSetupCodable: Codable, Hashable {
        let typeRaw: String
        let x: Double
        let y: Double
        let activationThreshold: Double?
        let outputStrength: Double?
    }
}

// MARK: - Custom Level Storage

struct CustomLevelStorage {
    private static let key = "custom_levels"
    
    static func load() -> [CustomLevel] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([CustomLevel].self, from: data) else {
            return []
        }
        return decoded
    }
    
    static func save(_ levels: [CustomLevel]) {
        if let data = try? JSONEncoder().encode(levels) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

// MARK: - Custom Level Row

struct CustomLevelRow: View {
    let level: CustomLevel
    let onPlay: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 22))
                .foregroundStyle(NeuronGardenColors.neuronCore)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(level.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(NeuronGardenColors.textPrimary)
                
                Text(level.taskDescription)
                    .font(.system(size: 12))
                    .foregroundStyle(NeuronGardenColors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: onPlay) {
                Text("Play")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NeuronGardenColors.neuralConnection)
            }
            .buttonStyle(.plain)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(NeuronGardenColors.textSecondary.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(NeuronGardenColors.glassPanel)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(NeuronGardenColors.glassBorder.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

// MARK: - Create Custom Level View

struct CreateCustomLevelView: View {
    let onSave: (CustomLevel) -> Void
    let onCancel: () -> Void
    
    @State private var title = ""
    @State private var taskDescription = ""
    @State private var neurons: [Neuron] = []
    @State private var connections: [Connection] = []
    @State private var activeInputs: Set<UUID> = []
    @State private var selectedNeuronType: NeuronType?
    private let fieldSize = CGSize(width: 320, height: 320)
    
    var body: some View {
        NavigationStack {
            ZStack {
                NeuronGardenColors.labBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(NeuronGardenColors.neuralConnection)
                            
                            TextField("Level name", text: $title)
                                .textFieldStyle(.plain)
                                .font(.system(size: 16))
                                .foregroundStyle(NeuronGardenColors.textPrimary)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(NeuronGardenColors.glassPanel)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(NeuronGardenColors.neuralConnection)
                            
                            TextField("Describe the goal", text: $taskDescription, axis: .vertical)
                                .textFieldStyle(.plain)
                                .font(.system(size: 16))
                                .foregroundStyle(NeuronGardenColors.textPrimary)
                                .lineLimit(3...6)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(NeuronGardenColors.glassPanel)
                                )
                        }
                        
                        Text("Design your network")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(NeuronGardenColors.neuralConnection)
                        
                        HStack(spacing: 8) {
                            ForEach(NeuronType.allCases, id: \.self) { type in
                                Button {
                                    selectedNeuronType = selectedNeuronType == type ? nil : type
                                } label: {
                                    Text(type.displayName)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(selectedNeuronType == type ? NeuronGardenColors.labBackground : type.color)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedNeuronType == type ? type.color : NeuronGardenColors.glassPanel)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        FreeGrowthPetriDishView(
                            neurons: $neurons,
                            connections: $connections,
                            activeInputs: $activeInputs,
                            placeNeuronType: selectedNeuronType,
                            onPlaceNeuron: { point in
                                guard let type = selectedNeuronType else { return }
                                neurons.append(Neuron(type: type, position: point))
                                selectedNeuronType = nil
                            }
                        )
                        .frame(width: 300, height: 300)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                        .foregroundStyle(NeuronGardenColors.neuronCore)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveLevel()
                    }
                    .foregroundStyle(NeuronGardenColors.neuralConnection)
                    .disabled(title.isEmpty || neurons.isEmpty)
                }
            }
        }
    }
    
    private func saveLevel() {
        let neuronSetups = neurons.map { n in
            CustomLevel.NeuronSetupCodable(
                typeRaw: n.type.rawValue,
                x: Double(n.position.x),
                y: Double(n.position.y),
                activationThreshold: 0.5,
                outputStrength: 1.0
            )
        }
        let level = CustomLevel(
            id: UUID(),
            title: title,
            taskDescription: taskDescription.isEmpty ? "Connect the network" : taskDescription,
            neurons: neuronSetups,
            successCondition: "connectAllToMotor"
        )
        onSave(level)
    }
}

// MARK: - Custom Level Play View

struct CustomLevelPlayView: View {
    let level: CustomLevel
    let onExit: () -> Void
    
    @State private var neurons: [Neuron] = []
    @State private var connections: [Connection] = []
    @State private var activeInputs: Set<UUID> = []
    @State private var isRunning = false
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            NeuronGardenColors.labBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button { onExit() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(NeuronGardenColors.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    Text(level.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Text(level.taskDescription)
                    .font(.system(size: 13))
                    .foregroundStyle(NeuronGardenColors.textSecondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                
                PetriDishView(neurons: $neurons, connections: $connections, activeInputs: $activeInputs)
                    .frame(width: 320, height: 320)
                    .padding(.horizontal, 20)
                
                Text("Tap sensory = input • Long press + tap = connect")
                    .font(.system(size: 11))
                    .foregroundStyle(NeuronGardenColors.textSecondary.opacity(0.7))
                    .padding(.top, 8)
                
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
                        .background(RoundedRectangle(cornerRadius: 14).fill(NeuronGardenColors.neuralConnection))
                    }
                    .buttonStyle(.plain)
                    .disabled(isRunning)
                    
                    Button {
                        setupLevel()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(NeuronGardenColors.textPrimary)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(NeuronGardenColors.glassPanel)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(NeuronGardenColors.glassBorder, lineWidth: 1))
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
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    VStack(spacing: 24) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(NeuronGardenColors.neuralConnection)
                        Text("Level Complete!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        Button("Continue") {
                            showSuccess = false
                            onExit()
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(NeuronGardenColors.labBackground)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(NeuronGardenColors.neuralConnection))
                    }
                    .padding(40)
                }
            }
        }
        .onAppear { setupLevel() }
    }
    
    private func setupLevel() {
        neurons = level.neurons.compactMap { setup in
            guard let type = NeuronType(rawValue: setup.typeRaw) else { return nil }
            return Neuron(
                type: type,
                position: CGPoint(x: setup.x, y: setup.y),
                activationThreshold: setup.activationThreshold ?? 0.5,
                outputStrength: setup.outputStrength ?? 1.0
            )
        }
        connections = []
        activeInputs = []
    }
    
    private func runActivation() {
        isRunning = true
        let (updated, _) = NetworkSimulator.propagate(
            neurons: neurons,
            connections: connections,
            sensoryInputs: activeInputs
        )
        withAnimation(.easeInOut(duration: 0.3)) { neurons = updated }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let motorFires = updated.first { $0.type == .motor }?.isActive ?? false
            let hasConnection = connections.contains { conn in
                let from = neurons.first { $0.id == conn.fromNeuronID }
                let to = neurons.first { $0.id == conn.toNeuronID }
                return from?.type == .sensory && to?.type == .motor
            }
            if hasConnection && motorFires && !activeInputs.isEmpty {
                withAnimation { showSuccess = true }
            }
            withAnimation(.easeOut(duration: 0.5)) {
                neurons = neurons.map { n in
                    var copy = n
                    copy.isActive = false
                    return copy
                }
            }
            isRunning = false
        }
    }
}

#Preview {
    CustomLevelsView(onExit: {})
}
