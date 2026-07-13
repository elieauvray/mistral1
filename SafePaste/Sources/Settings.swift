import Foundation

class Settings: ObservableObject {
    static let shared = Settings()
    
    @Published var pasteShortcut: String = "Control+Option+Command+V"
    @Published var rules: [Rule] = defaultRules
    @Published var isEnabled: Bool = true
    
    private let pasteShortcutKey = "pasteShortcut"
    private let rulesKey = "rules"
    private let isEnabledKey = "isEnabled"
    
    init() {
        load()
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(pasteShortcut, forKey: pasteShortcutKey)
        defaults.set(isEnabled, forKey: isEnabledKey)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(rules)
            defaults.set(data, forKey: rulesKey)
        } catch {
            print("Error saving rules: $error)")
        }
    }
    
    func load() {
        let defaults = UserDefaults.standard
        
        if let shortcut = defaults.string(forKey: pasteShortcutKey) {
            pasteShortcut = shortcut
        }
        
        isEnabled = defaults.bool(forKey: isEnabledKey)
        
        if let data = defaults.data(forKey: rulesKey) {
            do {
                let decoder = JSONDecoder()
                rules = try decoder.decode([Rule].self, from: data)
            } catch {
                print("Error loading rules: $error)")
                // Keep default rules if loading fails
            }
        }
    }
    
    func parseShortcut(_ shortcut: String) -> (key: String, modifiers: NSEvent.ModifierFlags)? {
        let parts = shortcut.components(separatedBy: "+")
        guard parts.count >= 2 else { return nil }
        
        let key = parts.last!.lowercased()
        var modifiers: NSEvent.ModifierFlags = []
        
        for part in parts.dropLast() {
            switch part.lowercased() {
            case "control": modifiers.insert(.control)
            case "option": modifiers.insert(.option)
            case "command": modifiers.insert(.command)
            case "shift": modifiers.insert(.shift)
            default: break
            }
        }
        
        return (key, modifiers)
    }
}
