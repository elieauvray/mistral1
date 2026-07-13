import SwiftUI

@main
struct SafePasteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings{}
            .commands {
                CommandGroup(replacing: .newItem) {}
            }
    }
}
