//
//  View+.swift
//  VibeCodedComponents
    

import SwiftUI

public extension View {
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style, view: UIView()).impactOccurred()
    }
}
