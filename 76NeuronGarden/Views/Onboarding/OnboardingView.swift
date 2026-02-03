//
//  OnboardingView.swift
//  76NeuronGarden
//
//  3-screen onboarding flow
//

import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "brain.head.profile",
            title: "Grow Neural Networks",
            description: "Create living neural networks in a futuristic lab. Place neurons, connect them, and watch signals propagate."
        ),
        OnboardingPage(
            icon: "point.3.connected.trianglepath.dotted",
            title: "Connect & Activate",
            description: "Tap sensory neurons for input. Long press and tap to create connections. Press Activate to run your network."
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Solve Puzzles",
            description: "Complete levels, master logic gates, and discover emergent behaviors. Grow intelligence, cultivate connections."
        )
    ]
    
    var body: some View {
        ZStack {
            NeuronGardenColors.labBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? NeuronGardenColors.neuronCore : NeuronGardenColors.glassBorder)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 32)
                
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        onComplete()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(NeuronGardenColors.labBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(NeuronGardenColors.neuralConnection)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 72))
                .foregroundStyle(NeuronGardenColors.neuronCore)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(NeuronGardenColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 16))
                    .foregroundStyle(NeuronGardenColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
