//
//  MainMenuView.swift
//  76NeuronGarden
//
//  Main menu with game modes - bio-tech aesthetic
//

import SwiftUI

private struct LevelSelection: Identifiable, Hashable {
    let id: Int
}

struct MainMenuView: View {
    @State private var selectedMode: GameMode?
    @State private var selectedLevel: LevelSelection?
    @State private var showPulse = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Lab background
            NeuronGardenColors.labBackground
                .ignoresSafeArea()
            
            // Subtle grid overlay (petri dish coordinates)
            GeometryReader { geo in
                Path { path in
                    let spacing: CGFloat = 30
                    for i in stride(from: 0, through: geo.size.width + spacing, by: spacing) {
                        path.move(to: CGPoint(x: i, y: 0))
                        path.addLine(to: CGPoint(x: i, y: geo.size.height))
                    }
                    for i in stride(from: 0, through: geo.size.height + spacing, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: i))
                        path.addLine(to: CGPoint(x: geo.size.width, y: i))
                    }
                }
                .stroke(Color.white.opacity(0.04), lineWidth: 1)
            }
            
            // Ambient particles
            FloatingParticlesView()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(NeuronGardenColors.textSecondary)
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 8)
                }
                
                Spacer()
                    .frame(height: 30)
                
                // Logo & Slogan
                VStack(spacing: 12) {
                    Text("NEURON GARDEN")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                        .shadow(color: NeuronGardenColors.neuronCore.opacity(0.5), radius: 20)
                        .scaleEffect(showPulse ? 1.02 : 1.0)
                    
                    Text("Grow intelligence. Cultivate connections.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(NeuronGardenColors.textSecondary)
                        .italic()
                }
                .padding(.bottom, 40)
                
                // Game mode buttons
                VStack(spacing: 16) {
                    ForEach(GameMode.allCases) { mode in
                        GameModeButton(
                            mode: mode,
                            isSelected: selectedMode == mode
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMode = mode
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Footer
                Text("v1.0 • Neuroscience Puzzle")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(NeuronGardenColors.textSecondary.opacity(0.6))
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                showPulse = true
            }
        }
        .fullScreenCover(item: $selectedMode) { mode in
            switch mode {
            case .campaign:
                NavigationStack {
                    CampaignLevelSelectView(
                        onDismiss: { selectedMode = nil },
                        onSelectLevel: { level in
                            selectedLevel = LevelSelection(id: level)
                        }
                    )
                    .navigationDestination(item: $selectedLevel) { level in
                        GameLevelView(levelNumber: level.id, onExit: {
                            selectedLevel = nil
                        })
                    }
                }
            case .freeGrowth:
                FreeGrowthView(onExit: { selectedMode = nil })
            case .dailyTasks:
                DailyTasksView(onExit: { selectedMode = nil })
            case .customLevels:
                CustomLevelsView(onExit: { selectedMode = nil })
            case .experiments:
                ExperimentsView(onExit: { selectedMode = nil })
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(onDismiss: { showSettings = false })
        }
    }
}

// MARK: - Game Mode Button

struct GameModeButton: View {
    let mode: GameMode
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: mode.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(mode.accentColor)
                    .frame(width: 36, alignment: .center)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                    
                    Text(mode.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(NeuronGardenColors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NeuronGardenColors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(NeuronGardenColors.glassPanel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? mode.accentColor.opacity(0.6) : NeuronGardenColors.glassBorder,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(color: mode.accentColor.opacity(isSelected ? 0.3 : 0), radius: 12)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Floating Particles

struct FloatingParticlesView: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                for i in 0..<15 {
                    let x = (size.width * 0.2 + CGFloat(i) * 47 + sin(time + Double(i)) * 20).truncatingRemainder(dividingBy: size.width)
                    let y = (size.height * 0.3 + CGFloat(i * 31) + cos(time * 0.7 + Double(i * 2)) * 15).truncatingRemainder(dividingBy: size.height)
                    let opacity = 0.03 + sin(time + Double(i)) * 0.02
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: 4, height: 4)),
                        with: .color(NeuronGardenColors.neuronCore.opacity(opacity))
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - GameMode Identifiable for fullScreenCover

extension GameMode {
    static func == (lhs: GameMode, rhs: GameMode) -> Bool { lhs.id == rhs.id }
}

extension GameMode: Hashable {}

#Preview {
    MainMenuView()
}
