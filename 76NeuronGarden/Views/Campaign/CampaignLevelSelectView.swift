//
//  CampaignLevelSelectView.swift
//  76NeuronGarden
//
//  Campaign level selection - Chapter 1: Binary Classification
//

import SwiftUI

struct CampaignLevelSelectView: View {
    let onDismiss: () -> Void
    let onSelectLevel: (Int) -> Void
    
    @AppStorage(CampaignProgress.highestCompletedKey) private var highestCompletedLevel = 0
    
    private let chapters: [(title: String, range: ClosedRange<Int>)] = [
        ("Binary Classification", 1...20),
        ("Patterns & Sequences", 21...45),
        ("Logic Operations", 46...70),
        ("Adaptive Learning", 71...100),
        ("Complex Architectures", 101...110)
    ]
    
    var body: some View {
        ZStack {
            NeuronGardenColors.labBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(NeuronGardenColors.neuronCore)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Campaign")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(Array(chapters.enumerated()), id: \.offset) { index, chapter in
                            ChapterSection(
                                title: chapter.title,
                                levelRange: chapter.range,
                                highestCompletedLevel: highestCompletedLevel,
                                onSelectLevel: onSelectLevel
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Chapter Section

struct ChapterSection: View {
    let title: String
    let levelRange: ClosedRange<Int>
    let highestCompletedLevel: Int
    let onSelectLevel: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(NeuronGardenColors.neuralConnection)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                ForEach(levelRange, id: \.self) { level in
                    LevelButton(level: level, isUnlocked: level <= highestCompletedLevel + 1) {
                        onSelectLevel(level)
                    }
                }
            }
        }
    }
}

// MARK: - Level Button

struct LevelButton: View {
    let level: Int
    let isUnlocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(NeuronGardenColors.glassPanel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isUnlocked ? NeuronGardenColors.neuralConnection.opacity(0.5) : NeuronGardenColors.glassBorder.opacity(0.5),
                                lineWidth: 1
                            )
                    )
                
                if isUnlocked {
                    Text("\(level)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(NeuronGardenColors.textSecondary.opacity(0.5))
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
}

#Preview {
    CampaignLevelSelectView(onDismiss: {}, onSelectLevel: { _ in })
}
