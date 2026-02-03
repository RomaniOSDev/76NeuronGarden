//
//  ContentView.swift
//  76NeuronGarden
//
//  Start screen - main entry point
//

import SwiftUI

private let hasCompletedOnboardingKey = "hasCompletedOnboarding"

struct ContentView: View {
    @AppStorage(hasCompletedOnboardingKey) private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            MainMenuView()
        } else {
            OnboardingView {
                hasCompletedOnboarding = true
            }
        }
    }
}

#Preview {
    ContentView()
}
