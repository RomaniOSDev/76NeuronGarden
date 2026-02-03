//
//  DailyTasksView.swift
//  76NeuronGarden
//
//  Random generated daily challenges
//

import SwiftUI

struct DailyTasksView: View {
    let onExit: () -> Void
    
    @State private var selectedTask: DailyTask?
    
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
                    
                    Text("Daily Tasks")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
                
                Text(todayDateString)
                    .font(.system(size: 14))
                    .foregroundStyle(NeuronGardenColors.textSecondary)
                    .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(DailyTaskGenerator.todayTasks()) { task in
                            DailyTaskCard(task: task) {
                                selectedTask = task
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(item: $selectedTask) { task in
            DailyTaskPlayView(task: task, onExit: {
                selectedTask = nil
            })
        }
    }
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }
}

// MARK: - Daily Task Model

struct DailyTask: Identifiable {
    let id: String
    let title: String
    let description: String
    let difficulty: Int
    let levelConfig: LevelConfig
}

// MARK: - Daily Task Generator (seeded by date)

struct DailyTaskGenerator {
    static func todayTasks() -> [DailyTask] {
        let calendar = Calendar.current
        let day = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let fieldSize = CGSize(width: 320, height: 320)
        
        return [
            DailyTask(
                id: "daily-\(day)-1",
                title: "Morning Warm-up",
                description: "Simple connection challenge",
                difficulty: 1,
                levelConfig: LevelConfig.config(for: 1 + (day % 5), fieldSize: fieldSize)
            ),
            DailyTask(
                id: "daily-\(day)-2",
                title: "Midday Challenge",
                description: "Logic puzzle",
                difficulty: 2,
                levelConfig: LevelConfig.config(for: 2 + (day % 4), fieldSize: fieldSize)
            ),
            DailyTask(
                id: "daily-\(day)-3",
                title: "Evening Expert",
                description: "Advanced network",
                difficulty: 3,
                levelConfig: LevelConfig.config(for: 3 + (day % 3), fieldSize: fieldSize)
            )
        ]
    }
}

// MARK: - Daily Task Card

struct DailyTaskCard: View {
    let task: DailyTask
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundStyle(NeuronGardenColors.neuronCore)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                    
                    Text(task.description)
                        .font(.system(size: 13))
                        .foregroundStyle(NeuronGardenColors.textSecondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(0..<3) { i in
                        Image(systemName: i < task.difficulty ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundStyle(NeuronGardenColors.neuronCore)
                    }
                }
                
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

// MARK: - Daily Task Play View (reuses level logic)

struct DailyTaskPlayView: View {
    let task: DailyTask
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
                    Text(task.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                TaskPanelView(config: task.levelConfig)
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
                        Text("Task Complete!")
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
        neurons = task.levelConfig.neurons.map { setup in
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
        let (updated, _) = NetworkSimulator.propagate(neurons: neurons, connections: connections, sensoryInputs: activeInputs)
        withAnimation(.easeInOut(duration: 0.3)) { neurons = updated }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if NetworkSimulator.checkSuccess(
                level: 0,
                neurons: neurons,
                connections: connections,
                sensoryInputs: activeInputs,
                condition: task.levelConfig.successCondition
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

// MARK: - DailyTask Hashable for fullScreenCover

extension DailyTask: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: DailyTask, rhs: DailyTask) -> Bool { lhs.id == rhs.id }
}

#Preview {
    DailyTasksView(onExit: {})
}
