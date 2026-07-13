import SwiftUI

struct RuleEditorView: View {
    @Binding var rule: Rule
    var onDismiss: () -> Void
    
    @State private var testText: String = ""
    @State private var testResult: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(rule.id == UUID() ? "Add Rule" : "Edit Rule")
                    .font(.headline)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(height: 40)
            .padding(.horizontal, 16)
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            Form {
                Section {
                    TextField("Rule Name", text: $rule.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Toggle("Enabled", isOn: $rule.isEnabled)
                        .toggleStyle(SwitchToggleStyle())
                    
                    Toggle("Use Regular Expression", isOn: $rule.isRegex)
                        .toggleStyle(SwitchToggleStyle())
                        .help("Enable for complex patterns like email addresses or phone numbers")
                }
                
                Section {
                    TextField("Pattern to Match", text: $rule.pattern)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .help(rule.isRegex ? "Enter a regular expression pattern" : "Enter text to find and replace")
                    
                    TextField("Replacement Text", text: $rule.replacement)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .help("Text to replace matches with (e.g., [EMAIL], [PHONE])")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Test Text", text: $testText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Test Rule") {
                            testRule()
                        }
                        
                        if !testResult.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Result:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(testResult)
                                    .font(.body)
                                    .padding(8)
                                    .background(Color(.controlBackgroundColor))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            .padding(16)
            
            Divider()
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    onDismiss()
                }
                .padding(.trailing, 16)
                
                Button("Save") {
                    onDismiss()
                    Settings.shared.save()
                }
                .keyboardShortcut(".return", modifiers: [])
                .disabled(rule.name.isEmpty || rule.pattern.isEmpty)
                .padding(.trailing, 16)
            }
            .frame(height: 40)
        }
        .frame(width: 400, height: 400)
    }
    
    private func testRule() {
        let sanitizer = TextSanitizer(rules: [rule])
        testResult = sanitizer.sanitize(testText)
    }
}
