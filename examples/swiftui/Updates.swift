import SwiftUI

@MainActor
final class Profile: ObservableObject {
  @Published var name = ""
  @Published var visits = 0
}

struct ProfileHeader: View {
  @EnvironmentObject private var profile: Profile
  @State private var greeting = ""

  var body: some View {
    // body only describes the UI; it can run any number of times
    Text(greeting)
      .onAppear { profile.visits += 1 }
      .onChange(of: profile.name, initial: true) { _, name in
        greeting = name.isEmpty ? "Welcome" : "Hi, \(name)"
      }
  }
}
