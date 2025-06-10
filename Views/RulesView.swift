//
//  RulesView.swift
//  CleanSweep
//
//  Created by Sam Oehlert on 6/7/25.
//

import SwiftUI

struct RulesView: View {
    @ObservedObject var organizer: FileOrganizer
    @State private var showingAddRule = false
    @State private var showingEditRule = false
    @State private var editingRuleIndex: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
            rulesSection
            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingAddRule) {
            AddRuleView(organizer: organizer)
        }
    }
    
    // Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "list.bullet.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Organizing Rules")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                Button("Load Defaults") {
                    organizer.loadDefaultRules()
                }
                .buttonStyle(.bordered)
                
                Button("Add Rule") {
                    showingAddRule = true
                }
                .buttonStyle(.borderedProminent)
            }
            
            Text("Define how files should be organized by type")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var rulesSection: some View {
        Group {
            if organizer.rules.isEmpty {
                VStack {
                    Text("No rules yet")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("Add rules to organize files automatically")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(organizer.rules.enumerated()), id: \.element.id) { index, rule in
                            HStack {
                                Text(rule.folderName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Text(rule.fileExtensions.joined(separator: ", "))
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Button("Edit") {
                                    editingRuleIndex = index
                                    showingEditRule = true
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                
                                Button("Delete") {
                                    organizer.removeRule(at: index)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(.regularMaterial)
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditRule) {
            EditRuleView(organizer: organizer, ruleIndex: editingRuleIndex)
        }
    }
}

#Preview {
    RulesView(organizer: FileOrganizer())
        .frame(width: 600, height: 400)
}

