import Foundation

class TextSanitizer {
    private let rules: [Rule]
    
    init(rules: [Rule]) {
        self.rules = rules
    }
    
    func sanitize(_ text: String) -> String {
        var result = text
        
        for rule in rules where rule.isEnabled {
            result = rule.apply(to: result)
        }
        
        return result
    }
    
    func sanitizeWithContext(_ text: String) -> String {
        var result = sanitize(text)
        
        // Replace sequences of digits that might be IDs
        result = replaceNumberSequences(in: result)
        
        // Replace proper nouns
        result = replaceProperNouns(in: result)
        
        return result
    }
    
    private func replaceNumberSequences(in text: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: "\\b\\d{4,}\\b", options: [])
            return regex.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.count), withTemplate: "[ID]")
        } catch {
            return text
        }
    }
    
    private func replaceProperNouns(in text: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: "(?<=\\s)[A-Z][a-zA-Z]+(?=\\s)", options: [])
            return regex.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.count), withTemplate: "[NAME]")
        } catch {
            return text
        }
    }
}
