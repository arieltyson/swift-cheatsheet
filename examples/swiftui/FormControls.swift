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

// Previews: Xcode renders each #Preview in the canvas. Several per
// file are fine; give them names to tell them apart.
#Preview("Form") { FormBasics() }

#Preview("In a sheet") {
  // Wrap in what the real screen has around it
  Text("Behind")
    .sheet(isPresented: .constant(true)) { FormBasics() }
}

#Preview("Bindings") {
  // @Previewable lets a preview own state for a view that takes a
  // Binding (Xcode 16+)
  @Previewable @State var on = true
  Toggle("Live", isOn: $on).padding()
}
