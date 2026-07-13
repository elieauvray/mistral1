import AppKit

@main
struct SafePasteApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var keyboardMonitor: KeyboardShortcutMonitor?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "SafePaste")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
        
        // Create popover
        popover = NSPopover()
        popover?.behavior = .transient
        popover?.animates = true
        
        // Load settings and start keyboard monitoring
        let settings = Settings.shared
        keyboardMonitor = KeyboardShortcutMonitor(settings: settings)
        keyboardMonitor?.startMonitoring()
        
        // Show initial popover with settings
        showSettingsPopover()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        keyboardMonitor?.stopMonitoring()
        popover?.close()
        statusItem = nil
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if let popover = popover, popover.isShown {
            popover.close()
        } else {
            showSettingsPopover()
        }
    }
    
    func showSettingsPopover() {
        if popover == nil {
            popover = NSPopover()
            popover?.behavior = .transient
            popover?.animates = true
        }
        
        let settings = Settings.shared
        let settingsView = SettingsView()
        
        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 400, height: 500)
        
        popover?.contentView = hostingView
        popover?.contentSize = NSSize(width: 400, height: 500)
        
        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    func closePopover() {
        popover?.close()
    }
}
