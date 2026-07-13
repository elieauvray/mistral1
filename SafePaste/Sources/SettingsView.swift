import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = Settings.shared
    @State private var selectedRule: Rule? = nil
    @State private var showingAddRule = false
    @State private var newRule = Rule(name: "", pattern: "", replacement: "")
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("SafePaste")
                    .font(.headline)
                    .padding(.leading, 16)
                
                Spacer()
                
                Button(action: { NSApp.terminate(nil) }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 8)
            }
            .frame(height: 40)
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Section {
                        Toggle("Enable SafePaste", isOn: $settings.isEnabled)
                            .toggleStyle(SwitchToggleStyle())
                            .onChange(of: settings.isEnabled) { _ in
                                settings.save()
                            }
                        
                        Text("When enabled, SafePaste will intercept your custom paste shortcut and sanitize clipboard content.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Paste Shortcut")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                TextField("Enter shortcut (e.g., Control+Option+Command+V)", text: $settings.pasteShortcut)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: settings.pasteShortcut) { _ in
                                        settings.save()
                                    }
                            }
                            
                            Text("Use Control+Option+Command+V or any combination of Control, Option, Command, and Shift with a key.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    Section {
                        HStack {
                            Text("Sanitization Rules")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Button(action: { showingAddRule = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Text("Rules are applied in order. Enable/disable rules and edit them below.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LazyVStack(spacing: 8) {
                            ForEach($settings.rules) { $rule in
                                RuleRow(rule: $rule, onEdit: { selectedRule = rule })
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(16)
            }
            
            Divider()
            
            HStack {
                Button("Reset to Defaults") {
                    settings.rules = defaultRules
                    settings.save()
                }
                .padding(.leading, 16)
                
                Spacer()
                
                Button("Save & Close") {
                    settings.save()
                    if let appDelegate = NSApp.delegate as? AppDelegate {
                        appDelegate.closePopover()
                    }
                }
                .keyboardShortcut(".return", modifiers: [])
                .padding(.trailing, 16)
            }
            .frame(height: 40)
        }
        .frame(width: 400, height: 500)
        .sheet(item: $selectedRule) { rule in
            RuleEditorView(rule: Binding(
                get: { rule },
                set: { newRule in
                    if let index = settings.rules.firstIndex(where: { $0.id == rule.id }) {
                        settings.rules[index] = newRule
                    }
                }
            ), onDismiss: { selectedRule = nil })
        }
        .sheet(isPresented: $showingAddRule) {
            RuleEditorView(rule: Binding(
                get: { newRule },
                set: { newRule = $0 }
            ), onDismiss: {
                showingAddRule = false
                if !newRule.name.isEmpty && !newRule.pattern.isEmpty {
                    settings.rules.append(newRule)
                    newRule = Rule(name: "", pattern: "", replacement: "")
                }
            })
        }
    }
}

struct RuleRow: View {
    @Binding var rule: Rule
    var onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(rule.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(rule.pattern)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("→")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(rule.replacement)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $rule.isEnabled)
                .toggleStyle(SwitchToggleStyle())
                .onChange(of: rule.isEnabled) { _ in
                    Settings.shared.save()
                }
                .frame(width: 40)
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 30)
        }
        .padding(8)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
}
