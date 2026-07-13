import Foundation

struct Rule: Identifiable, Codable {
    var id = UUID()
    var name: String
    var pattern: String
    var replacement: String
    var isRegex: Bool
    var isEnabled: Bool
    
    init(id: UUID = UUID(), name: String, pattern: String, replacement: String, isRegex: Bool = false, isEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.pattern = pattern
        self.replacement = replacement
        self.isRegex = isRegex
        self.isEnabled = isEnabled
    }
    
    func apply(to text: String) -> String {
        guard isEnabled else { return text }
        
        do {
            if isRegex {
                let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
                return regex.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.count), withTemplate: replacement)
            } else {
                return text.replacingOccurrences(of: pattern, with: replacement, options: [.caseInsensitive])
            }
        } catch {
            print("Error applying rule: $error)")
            return text
        }
    }
}

// Default rules for GDPR/confidential information
let defaultRules: [Rule] = [
    // Personal information
    Rule(name: "Email Addresses", pattern: "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b", replacement: "[EMAIL]", isRegex: true),
    Rule(name: "Phone Numbers", pattern: "\\b(\\+?\\d{1,3}[-.\\s]?)?\\(?\\d{3}\\)?[-.\\s]?\\d{3}[-.\\s]?\\d{4}\\b", replacement: "[PHONE]", isRegex: true),
    Rule(name: "Social Security Numbers (US)", pattern: "\\b\\d{3}-\\d{2}-\\d{4}\\b", replacement: "[SSN]", isRegex: true),
    
    // French specific
    Rule(name: "French Phone Numbers", pattern: "\\b0[1-9]\\d{8}\\b", replacement: "[PHONE]", isRegex: true),
    Rule(name: "French SIRET", pattern: "\\b\\d{14}\\b", replacement: "[SIRET]", isRegex: true),
    Rule(name: "French SIREN", pattern: "\\b\\d{9}\\b", replacement: "[SIREN]", isRegex: true),
    
    // Company information
    Rule(name: "Company Names", pattern: "(Inc\\.|LLC|Corp\\.|Corporation|Ltd\\.|Limited|S\\.A\\.|SARL|GmbH)", replacement: "[COMPANY]", isRegex: true),
    
    // Project names (common patterns)
    Rule(name: "Project Prefixes", pattern: "\\b(Project|Projet|Inititative)\\s+[A-Z][a-zA-Z0-9]*\\b", replacement: "[PROJECT]", isRegex: true),
    
    // Addresses
    Rule(name: "Street Addresses", pattern: "\\d+\\s+[A-Za-z\\s]+\\s+(St\\.|Street|Ave\\.|Avenue|Blvd\\.|Boulevard|Rd\\.|Road|Ln\\.|Lane)", replacement: "[ADDRESS]", isRegex: true),
    
    // Dates (keep structure but remove specific info)
    Rule(name: "Specific Dates", pattern: "\\b\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4}\\b", replacement: "[DATE]", isRegex: true),
    
    // URLs
    Rule(name: "Web URLs", pattern: "https?://[^\\s]+|www\\.[^\\s]+", replacement: "[URL]", isRegex: true),
    
    // IP Addresses
    Rule(name: "IP Addresses", pattern: "\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b", replacement: "[IP]", isRegex: true),
    
    // Common names (first and last names)
    Rule(name: "Common First Names", pattern: "\\b(John|Jane|Michael|Emily|David|Sarah|Robert|Jennifer|William|Lisa|James|Mary|Charles|Patricia|Joseph|Susan|Thomas|Jessica|Daniel|Elizabeth)\\b", replacement: "[FIRSTNAME]", isRegex: true),
    Rule(name: "Common Last Names", pattern: "\\b(Smith|Johnson|Williams|Brown|Jones|Garcia|Miller|Davis|Rodriguez|Martinez|Hernandez|Lopez|Gonzalez|Wilson|Anderson|Thomas|Taylor|Moore|Jackson|Martin)\\b", replacement: "[LASTNAME]", isRegex: true),
]
