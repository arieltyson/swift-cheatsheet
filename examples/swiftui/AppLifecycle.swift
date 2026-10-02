import SwiftData
import SwiftUI

// Mark this @main in a real app. It owns the window and the store.
struct NotesApp: App {
  @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      NavigationStack { NotesScreen() }
    }
    .modelContainer(for: Note.self)
    .onChange(of: scenePhase) { _, phase in
      switch phase {
      case .active: break  // refresh stale data, restart timers
      case .inactive: break  // app switcher, alert, incoming call
      case .background: break  // save, pause work; time is short
      @unknown default: break
      }
    }
  }
}
