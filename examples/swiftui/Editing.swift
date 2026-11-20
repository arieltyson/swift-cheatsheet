import SwiftUI

struct Booking: Identifiable, Equatable {
  var id = UUID()
  var title: String
  var start: Date
  var end: Date
}

/// Edits a copy, so Cancel discards and Save hands the copy back.
struct BookingEditor: View {
  @State private var draft: Booking
  let isNew: Bool
  let onSave: (Booking) -> Void
  let onDelete: (Booking) -> Void
  @Environment(\.dismiss) private var dismiss

  init(
    booking: Booking, isNew: Bool,
    onSave: @escaping (Booking) -> Void,
    onDelete: @escaping (Booking) -> Void
  ) {
    // Seeds the draft once, when the sheet first appears
    _draft = State(initialValue: booking)
    self.isNew = isNew
    self.onSave = onSave
    self.onDelete = onDelete
  }

  private var isValid: Bool {
    let title = draft.title.trimmingCharacters(in: .whitespaces)
    return !title.isEmpty && draft.end > draft.start
  }

  var body: some View {
    NavigationStack {
      Form {
        TextField("Title", text: $draft.title)
        DatePicker(
          "Starts", selection: $draft.start,
          displayedComponents: .hourAndMinute)
        // A one-sided range stops Ends from going before Starts
        DatePicker(
          "Ends", selection: $draft.end, in: draft.start...,
          displayedComponents: .hourAndMinute)
        if !isNew {
          Button("Delete", role: .destructive) {
            onDelete(draft)
            dismiss()
          }
        }
      }
      .onChange(of: draft.start) {
        if draft.end <= draft.start {
          draft.end = draft.start.addingTimeInterval(3600)
        }
      }
      .navigationTitle(isNew ? "New booking" : "Edit booking")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            onSave(draft)
            dismiss()
          }
          .disabled(!isValid)
        }
      }
    }
  }
}

/// One optional drives the sheet; Save updates by id or appends.
struct BookingsScreen: View {
  @State private var bookings: [Booking] = []
  @State private var editing: Booking?

  var body: some View {
    NavigationStack {
      List {
        ForEach(bookings) { booking in
          Button(booking.title) { editing = booking }
            .swipeActions {
              Button("Delete", role: .destructive) {
                delete(booking)
              }
            }
        }
      }
      .toolbar {
        Button("Add", systemImage: "plus") {
          let now = Date.now
          editing = Booking(
            title: "", start: now, end: now.addingTimeInterval(3600))
        }
      }
      .sheet(item: $editing) { booking in
        BookingEditor(
          booking: booking,
          isNew: !bookings.contains { $0.id == booking.id },
          onSave: save, onDelete: delete)
      }
    }
  }

  private func save(_ booking: Booking) {
    if let index = bookings.firstIndex(where: { $0.id == booking.id }) {
      bookings[index] = booking
    } else {
      bookings.append(booking)
    }
  }

  private func delete(_ booking: Booking) {
    bookings.removeAll { $0.id == booking.id }
  }
}
