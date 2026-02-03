//
//  CampaignProgress.swift
//  76NeuronGarden
//
//  Campaign level progression storage
//

import Foundation

struct CampaignProgress {
    static let highestCompletedKey = "campaign_highestCompletedLevel"
    
    static var highestCompletedLevel: Int {
        get { UserDefaults.standard.integer(forKey: Self.highestCompletedKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.highestCompletedKey) }
    }
    
    static func isLevelUnlocked(_ level: Int) -> Bool {
        level <= highestCompletedLevel + 1
    }
    
    static func completeLevel(_ level: Int) {
        if level > highestCompletedLevel {
            highestCompletedLevel = level
        }
    }
}
