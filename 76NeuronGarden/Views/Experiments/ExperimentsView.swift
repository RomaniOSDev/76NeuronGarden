//
//  ExperimentsView.swift
//  76NeuronGarden
//
//  Discover new mechanics - educational challenges
//

import SwiftUI

struct ExperimentsView: View {
    let onExit: () -> Void
    
    @State private var selectedExperiment: Experiment?
    
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
                    
                    Text("Experiments")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Experiment.all) { exp in
                            ExperimentCard(experiment: exp) {
                                selectedExperiment = exp
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(item: $selectedExperiment) { exp in
            ExperimentDetailView(experiment: exp, onExit: {
                selectedExperiment = nil
            })
        }
    }
}

// MARK: - Experiment Model

struct Experiment: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let content: ExperimentContent
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Experiment, rhs: Experiment) -> Bool {
        lhs.id == rhs.id
    }
}

enum ExperimentContent {
    case article(title: String, sections: [(String, String)])
    case challenge(LevelConfig)
}

extension Experiment {
    static let all: [Experiment] = [
        Experiment(
            id: "neurons",
            title: "Neuron Types",
            subtitle: "Learn the basics",
            icon: "brain.head.profile",
            color: NeuronGardenColors.neuronCore,
            content: .article(
                title: "Types of Neurons",
                sections: [
                    ("Sensory", "Input neurons receive information from the environment. They activate when given input."),
                    ("Motor", "Output neurons produce actions. When they fire, the task is complete."),
                    ("Intermediate", "Hidden layer neurons process information between sensory and motor neurons."),
                    ("Modulator", "Special neurons that change the properties of connections in the network.")
                ]
            )
        ),
        Experiment(
            id: "connections",
            title: "Neural Connections",
            subtitle: "How signals travel",
            icon: "point.3.connected.trianglepath.dotted",
            color: NeuronGardenColors.neuralConnection,
            content: .article(
                title: "Connections",
                sections: [
                    ("Excitatory", "Strengthens the signal. When neuron A fires, it activates neuron B."),
                    ("Inhibitory", "Weakens the signal. Prevents neuron B from firing even when other inputs are active."),
                    ("Weight", "Connection strength. Stronger connections have more influence on the target neuron.")
                ]
            )
        ),
        Experiment(
            id: "logic",
            title: "Logic Gates",
            subtitle: "AND, OR, XOR",
            icon: "function",
            color: Color(hex: "9b59b6"),
            content: .article(
                title: "Logic in Networks",
                sections: [
                    ("AND", "Output fires only when BOTH inputs are active. Requires high threshold or summed weights."),
                    ("OR", "Output fires when ANY input is active. Simple connections from inputs to output."),
                    ("XOR", "Output fires when inputs differ. Needs intermediate neurons to compute.")
                ]
            )
        ),
        Experiment(
            id: "challenge",
            title: "Practice Challenge",
            subtitle: "Try your skills",
            icon: "flask.fill",
            color: NeuronGardenColors.neuralConnection,
            content: .challenge(
                LevelConfig.config(for: 3, fieldSize: CGSize(width: 320, height: 320))
            )
        )
    ]
}

// MARK: - Experiment Card

struct ExperimentCard: View {
    let experiment: Experiment
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Image(systemName: experiment.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(experiment.color)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(experiment.color.opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(experiment.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                    
                    Text(experiment.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(NeuronGardenColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NeuronGardenColors.textSecondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(NeuronGardenColors.glassPanel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(NeuronGardenColors.glassBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Experiment Detail View

struct ExperimentDetailView: View {
    let experiment: Experiment
    let onExit: () -> Void
    
    @State private var showChallenge = false
    
    var body: some View {
        ZStack {
            NeuronGardenColors.labBackground
                .ignoresSafeArea()
            
            switch experiment.content {
            case .article(let title, let sections):
                VStack(spacing: 0) {
                    HStack {
                        Button { onExit() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(NeuronGardenColors.textPrimary)
                                .frame(width: 44, height: 44)
                        }
                        Spacer()
                        Text(experiment.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(NeuronGardenColors.textPrimary)
                        Spacer()
                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            Text(title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(experiment.color)
                            
                            ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(section.0)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(NeuronGardenColors.textPrimary)
                                    
                                    Text(section.1)
                                        .font(.system(size: 15))
                                        .foregroundStyle(NeuronGardenColors.textSecondary)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(NeuronGardenColors.glassPanel)
                                )
                            }
                        }
                        .padding(20)
                    }
                }
                
            case .challenge(let config):
                ExperimentChallengeView(config: config, onExit: onExit)
            }
        }
    }
}

// MARK: - Experiment Challenge View

struct ExperimentChallengeView: View {
    let config: LevelConfig
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
                    Text(config.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                TaskPanelView(config: config)
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
                        Text("Experiment Complete!")
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
        isRunning = true
        let (updated, _) = NetworkSimulator.propagate(
            neurons: neurons,
            connections: connections,
            sensoryInputs: activeInputs
        )
        withAnimation(.easeInOut(duration: 0.3)) { neurons = updated }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if NetworkSimulator.checkSuccess(
                level: 0,
                neurons: neurons,
                connections: connections,
                sensoryInputs: activeInputs,
                condition: config.successCondition
            ) {
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
    ExperimentsView(onExit: {})
}
