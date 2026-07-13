import AppKit
import Carbon

class KeyboardShortcutMonitor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let settings: Settings
    private var lastPasteTime: Date = Date.distantPast
    
    init(settings: Settings) {
        self.settings = settings
    }
    
    func startMonitoring() {
        // Stop any existing monitoring
        stopMonitoring()
        
        // Create event tap for keyboard events
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        
        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventTypeMask(eventMask),
            callback: eventTapCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("Failed to create event tap")
            return
        }
        
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        
        print("Keyboard monitoring started")
    }
    
    func stopMonitoring() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            eventTap = nil
            runLoopSource = nil
        }
    }
    
    @objc private func handleKeyEvent(_ event: CGEvent) {
        guard settings.isEnabled else { return }
        
        // Check if this is a key down event
        guard event.type == .keyDown else { return }
        
        // Get the keyboard shortcut from settings
        guard let (key, modifiers) = settings.parseShortcut(settings.pasteShortcut) else { return }
        
        // Check if the event matches our shortcut
        let eventModifiers = event.flags
        let requiredModifiers = modifiers
        
        // Check if all required modifiers are present
        if (eventModifiers.rawValue & requiredModifiers.rawValue) != requiredModifiers.rawValue {
            return
        }
        
        // Check if the key matches
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let expectedKeyCode = keyCodeForKey(key)
        
        guard keyCode == expectedKeyCode else { return }
        
        // Check if 'v' key is pressed (for paste)
        // Also check for 'V' (shift+v)
        let isVKey = keyCode == 9 || keyCode == 86 // 9 is 'v', 86 is 'V' with shift
        guard isVKey else { return }
        
        // Debounce: prevent multiple triggers
        let now = Date()
        guard now.timeIntervalSince(lastPasteTime) > 0.5 else { return }
        lastPasteTime = now
        
        // Perform safe paste
        performSafePaste()
    }
    
    private func performSafePaste() {
        // Get current clipboard content
        guard let clipboardString = NSPasteboard.general.string(forType: .string) else {
            NSSound.beep()
            return
        }
        
        // Sanitize the text
        let sanitizer = TextSanitizer(rules: settings.rules)
        let sanitizedText = sanitizer.sanitizeWithContext(clipboardString)
        
        // Put sanitized text back to clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(sanitizedText, forType: .string)
        
        // Simulate paste command
        simulatePaste()
        
        // Restore original clipboard after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            pasteboard.clearContents()
            pasteboard.setString(clipboardString, forType: .string)
        }
    }
    
    private func simulatePaste() {
        // Create a new event tap to inject the paste command
        let eventSource = CGEventSource(stateID: .hidSystemState)
        
        // Create key down event for Command
        if let cmdDown = CGEvent(keyboardEventSource: eventSource, virtualKey: 55, keyDown: true) {
            cmdDown.flags = .command
            cmdDown.post(tap: .cghidEventTap)
        }
        
        // Create key down event for V
        if let vDown = CGEvent(keyboardEventSource: eventSource, virtualKey: 9, keyDown: true) {
            vDown.flags = .command
            vDown.post(tap: .cghidEventTap)
        }
        
        // Create key up event for V
        if let vUp = CGEvent(keyboardEventSource: eventSource, virtualKey: 9, keyDown: false) {
            vUp.flags = .command
            vUp.post(tap: .cghidEventTap)
        }
        
        // Create key up event for Command
        if let cmdUp = CGEvent(keyboardEventSource: eventSource, virtualKey: 55, keyDown: false) {
            cmdUp.flags = .command
            cmdUp.post(tap: .cghidEventTap)
        }
    }
    
    private func keyCodeForKey(_ key: String) -> Int64 {
        switch key.lowercased() {
        case "a": return 0
        case "s": return 1
        case "d": return 2
        case "f": return 3
        case "h": return 4
        case "g": return 5
        case "z": return 6
        case "x": return 7
        case "c": return 8
        case "v": return 9
        case "b": return 11
        case "q": return 12
        case "w": return 13
        case "e": return 14
        case "r": return 15
        case "y": return 16
        case "t": return 17
        case "1": return 18
        case "2": return 19
        case "3": return 20
        case "4": return 21
        case "6": return 22
        case "5": return 23
        case "=": return 24
        case "9": return 25
        case "7": return 26
        case "-": return 27
        case "8": return 28
        case "0": return 29
        case "]": return 30
        case "o": return 31
        case "u": return 32
        case "]": return 33
        case "i": return 34
        case "p": return 35
        case "return": return 36
        case "l": return 37
        case "j": return 38
        case "'": return 39
        case "k": return 40
        case ";": return 41
        case "\\": return 42
        case ",": return 43
        case "/": return 44
        case "n": return 45
        case "m": return 46
        case ".": return 47
        case "tab": return 48
        case "space": return 49
        case "`": return 50
        case "delete": return 51
        case "enter": return 52
        case "escape": return 53
        case "command": return 55
        case "shift": return 56
        case "capslock": return 57
        case "option": return 58
        case "control": return 59
        case "fn": return 63
        case "up": return 126
        case "down": return 125
        case "left": return 123
        case "right": return 124
        default: return -1
        }
    }
}

// Event tap callback
private let eventTapCallback: CGEventTapCallBack = { (proxy, type, event, refcon) in
    guard let refcon = refcon else { return Unmanaged.passRetained(event) }
    
    let monitor = Unmanaged<KeyboardShortcutMonitor>.fromOpaque(refcon).takeUnretainedValue()
    monitor.handleKeyEvent(event)
    
    return Unmanaged.passRetained(event)
}
