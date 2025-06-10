//
//  StatusMessageModifier.swift
//  CleanSweep
//
//  Created by Sam Oehlert on 6/9/25.
//


import SwiftUI

struct StatusMessageModifier: ViewModifier {
    @ObservedObject var organizer: FileOrganizer

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content

            if let statusMessage = organizer.statusMessage {
                statusMessageOverlay(message: statusMessage)
                    .zIndex(1)
            }
        }
    }

    private func statusMessageOverlay(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: organizer.isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundColor(organizer.isError ? .red : .green)
                .font(.title3)

            Text(message)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.primary)

            Spacer()

            Button("×") {
                withAnimation(.easeOut(duration: 0.2)) {
                    organizer.statusMessage = nil
                }
            }
            .foregroundColor(.secondary)
            .buttonStyle(.borderless)
            .font(.title2)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke((organizer.isError ? Color.red : Color.green).opacity(0.4), lineWidth: 1)
        )
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 220)
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: organizer.statusMessage)
    }
}

extension View {
    func statusMessage(organizer: FileOrganizer) -> some View {
        modifier(StatusMessageModifier(organizer: organizer))
    }
}
