import Observation
import SwiftUI

@MainActor @Observable
final class StudySession {
  var topic = "Binary search"
  var completed = false
}

@MainActor
struct SessionScreen: View {
  @State private var session = StudySession()

  var body: some View {
    SessionEditor()
      .environment(session)
  }
}

@MainActor
struct SessionEditor: View {
  @Environment(StudySession.self) private var session

  var body: some View {
    @Bindable var editableSession = session
    Form {
      TextField("Topic", text: $editableSession.topic)
      Toggle("Completed", isOn: $editableSession.completed)
      Text(session.completed ? "Ready to review" : "Keep practicing")
    }
  }
}
