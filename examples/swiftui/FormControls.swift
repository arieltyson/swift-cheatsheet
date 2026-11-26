import SwiftUI

/// A Form groups input controls into the system's settings-style
/// rows: grouped background, one control per row, labels on the left,
/// values on the right. Sections add a header and footer.
struct FormBasics: View {
  @State private var name = ""
  @State private var notify = true
  @State private var guests = 2
  @State private var size = "M"
  @State private var date = Date.now

  var body: some View {
    Form {
      Section("Details") {
        TextField("Name", text: $name)  // the text is a placeholder
        Toggle("Notify me", isOn: $notify)
        Stepper("Guests: \(guests)", value: $guests, in: 1...10)
      }
      Section {
        Picker("Size", selection: $size) {
          ForEach(["S", "M", "L"], id: \.self) { Text($0).tag($0) }
        }
        DatePicker("Date", selection: $date, displayedComponents: .date)
      } footer: {
        Text("A footer explains the section.")
      }
    }
  }
}

/// The same controls in a plain VStack: no rows, no grouping, so you
/// style and space everything yourself.
struct SameControlsInStack: View {
  @State private var name = ""
  @State private var notify = true

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      TextField("Name", text: $name)
        .textFieldStyle(.roundedBorder)  // outside a Form, add a style
      Toggle("Notify me", isOn: $notify)
    }
    .padding()
  }
}

/// A Picker writes the TAG of the chosen row into its selection.
/// The tag's type must match the selection's type exactly.
struct PickerTags: View {
  enum Mood: String, CaseIterable { case calm, busy, tired }

  @State private var hour = 9
  @State private var mood = Mood.calm

  var body: some View {
    Form {
      // Shows "9 AM" but stores 9: the label and the value differ
      Picker("Hour", selection: $hour) {
        ForEach(0..<24, id: \.self) { h in
          Text(h < 12 ? "\(h) AM" : "\(h) PM").tag(h)
        }
      }
      // .segmented for 2-4 short choices
      Picker("Mood", selection: $mood) {
        ForEach(Mood.allCases, id: \.self) { m in
          Text(m.rawValue.capitalized).tag(m)
        }
      }
      .pickerStyle(.segmented)
      // .wheel scrolls in place; .menu (the default) pops up a list
      Picker("Hour", selection: $hour) {
        ForEach(0..<24, id: \.self) { Text("\($0)").tag($0) }
      }
      .pickerStyle(.wheel)
    }
  }
}

/// TextField variations.
struct TextFieldKinds: View {
  @State private var title = ""
  @State private var notes = ""
  @State private var count = 0

  var body: some View {
    Form {
      TextField("Title", text: $title)
        .textInputAutocapitalization(.words)
      // Grows to 3-6 lines as the user types
      TextField("Notes", text: $notes, axis: .vertical)
        .lineLimit(3...6)
      // Number input: binds an Int through a format
      TextField("Count", value: $count, format: .number)
        .keyboardType(.numberPad)
    }
  }
}

/// TextField styles on iOS: .automatic (the default), .plain and
/// .roundedBorder. Outside a Form, the default draws NO box at all.
struct TextFieldStyles: View {
  @State private var name = "Team Sync"
  @State private var empty = ""

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(".automatic / .plain: no box").font(.caption)
      TextField("Name", text: $name)
      Text(".roundedBorder").font(.caption)
      TextField("Name", text: $name).textFieldStyle(.roundedBorder)
      Text(".roundedBorder, empty: placeholder").font(.caption)
      TextField("Name", text: $empty).textFieldStyle(.roundedBorder)
      Text("Custom: padding + background").font(.caption)
      TextField("Name", text: $name)
        .padding(10)
        .background(.quaternary, in: .rect(cornerRadius: 10))
    }
    .padding()
  }
}

/// Button styles. In a List or Form row, the default style turns the
/// WHOLE row into the tap target; .borderless or .plain limits a
/// button to its own frame. .plain also keeps a custom label's own
/// colours instead of tinting all of it.
struct ButtonStyles: View {
  @State private var taps = 0

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Button(".automatic") { taps += 1 }
      Button(".plain") { taps += 1 }.buttonStyle(.plain)
      Button(".borderless") { taps += 1 }.buttonStyle(.borderless)
      Button(".bordered") { taps += 1 }.buttonStyle(.bordered)
      Button(".borderedProminent") { taps += 1 }
        .buttonStyle(.borderedProminent)
      Button("Large capsule") { taps += 1 }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .buttonBorderShape(.capsule)
        .tint(.green)
      if #available(iOS 26, *) {
        Button(".glassProminent") { taps += 1 }
          .buttonStyle(.glassProminent)
      }
      Text("A custom label").font(.caption).padding(.top)
      HStack {
        Button { taps += 1 } label: { Card() }  // tinted: all blue
        Button { taps += 1 } label: { Card() }.buttonStyle(.plain)
      }
    }
    .padding()
  }
}

private struct Card: View {
  var body: some View {
    VStack(alignment: .leading) {
      Image(systemName: "star.fill").foregroundStyle(.orange)
      Text("Standup").font(.headline)
      Text("9 AM").foregroundStyle(.secondary)
    }
    .padding(10)
    .background(.quaternary, in: .rect(cornerRadius: 10))
  }
}

/// Two buttons in one List row: with the default style, a tap
/// anywhere in the row runs BOTH actions.
struct RowButtons: View {
  @State private var likes = 0
  @State private var shares = 0

  var body: some View {
    List {
      HStack {  // broken: one tap = likes + 1 AND shares + 1
        Button("Like") { likes += 1 }
        Spacer()
        Button("Share") { shares += 1 }
      }
      HStack {  // fixed: each button only answers its own taps
        Button("Like") { likes += 1 }.buttonStyle(.borderless)
        Spacer()
        Button("Share") { shares += 1 }.buttonStyle(.borderless)
      }
      Text("Likes \(likes), shares \(shares)")
    }
  }
}

// Previews: Xcode renders each #Preview in the canvas. Several per
// file are fine; give them names to tell them apart.
#Preview("Form") { FormBasics() }

#Preview("In a sheet") {
  // Wrap in what the real screen has around it
  Text("Behind")
    .sheet(isPresented: .constant(true)) { FormBasics() }
}

#Preview("Bindings") {
  // A #Preview body is a closure, not a View, so it has nowhere to
  // keep @State. @Previewable wraps it in a hidden View that does.
  // Needed only when the view under preview takes a Binding.
  @Previewable @State var on = true
  Toggle("Live", isOn: $on).padding()
}

/// Button roles: meaning first, colour follows. The system styles
/// .destructive red and puts .cancel in the cancel slot of dialogs.
struct ButtonRoles: View {
  @State private var asking = false

  var body: some View {
    Form {
      Section("In a Form or List") {
        Button("No role") {}
        Button("Delete", role: .destructive) {}
        Button("Cancel", role: .cancel) {}
      }
      Section("Bordered styles") {
        HStack {
          Button("Plain") {}.buttonStyle(.bordered)
          Button("Delete", role: .destructive) {}
            .buttonStyle(.bordered)
          Button("Save") {}.buttonStyle(.borderedProminent)
          Button("Delete", role: .destructive) {}
            .buttonStyle(.borderedProminent)
        }
      }
      Button("Show a dialog") { asking = true }
        .confirmationDialog("Delete this note?", isPresented: $asking,
          titleVisibility: .visible) {
          Button("Delete", role: .destructive) {}
          Button("Cancel", role: .cancel) {}  // shown apart, bold
        }
    }
  }
}

/// Sections group rows. Header above (small grey), footer below
/// (small grey): the footer is the natural spot for a validation
/// message. Save stays disabled until the problem is nil.
struct SectionsAndValidation: View {
  @State private var title = ""
  @State private var start = 10
  @State private var end = 9

  private var problem: String? {
    if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return "Add a title."
    }
    return end <= start ? "End must be after start." : nil
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Header text") {  // shorthand: a String header
          TextField("Title", text: $title)
        }
        Section {
          Stepper("Start \(start):00", value: $start, in: 0...23)
          Stepper("End \(end):00", value: $end, in: 1...24)
        } header: {
          Text("Custom header")
        } footer: {
          if let problem {  // shows only when invalid
            Text(problem).foregroundStyle(.red)
          }
        }
        Section {
          Text("A Section with no header")
        }
      }
      .navigationTitle("Sections")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        Button("Save") {}.disabled(problem != nil)
      }
    }
  }
}
