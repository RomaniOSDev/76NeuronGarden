//
//  SettingsView.swift
//  76NeuronGarden
//
//  Settings with Rate us, Privacy, Terms
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    let onDismiss: () -> Void
    
    private let privacyURL = "https://example.com/privacy-policy"
    private let termsURL = "https://example.com/terms-of-service"
    
    var body: some View {
        ZStack {
            NeuronGardenColors.labBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(NeuronGardenColors.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(NeuronGardenColors.textPrimary)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
                
                VStack(spacing: 0) {
                    SettingsRow(
                        icon: "star.fill",
                        title: "Rate Us",
                        action: { rateApp() }
                    )
                    
                    Divider()
                        .background(NeuronGardenColors.glassBorder)
                        .padding(.leading, 56)
                    
                    SettingsRow(
                        icon: "hand.raised.fill",
                        title: "Privacy Policy",
                        action: { openURL(privacyURL) }
                    )
                    
                    Divider()
                        .background(NeuronGardenColors.glassBorder)
                        .padding(.leading, 56)
                    
                    SettingsRow(
                        icon: "doc.text.fill",
                        title: "Terms of Service",
                        action: { openURL(termsURL) }
                    )
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(NeuronGardenColors.glassPanel)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(NeuronGardenColors.glassBorder, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(NeuronGardenColors.neuronCore)
                    .frame(width: 24, alignment: .center)
                
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(NeuronGardenColors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NeuronGardenColors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView(onDismiss: {})
}
