import SwiftUI

struct SignUpForm: View {
  enum Field: Hashable { case email, password }

  @State private var email = ""
  @State private var password = ""
  var onCreate: (String, String) -> Void = { _, _ in }
  @FocusState private var focus: Field?

  private var emailError: String? {
    email.isEmpty || email.contains("@") ? nil : "Enter a valid email"
  }
  private var canSubmit: Bool {
    email.contains("@") && password.count >= 8
  }

  var body: some View {
    Form {
      Section {
        TextField("Email", text: $email)
          .textContentType(.emailAddress)
          .keyboardType(.emailAddress)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .focused($focus, equals: .email)
          .submitLabel(.next)
        if let emailError {
          Text(emailError).foregroundStyle(.red).font(.footnote)
        }
        SecureField("Password, 8+ characters", text: $password)
          .textContentType(.newPassword)
          .focused($focus, equals: .password)
          .submitLabel(.go)
      }
      Button("Create account", action: submit)
        .disabled(!canSubmit)
    }
    // Return moves to the next field, then submits
    .onSubmit {
      if focus == .email { focus = .password } else { submit() }
    }
    .onAppear { focus = .email }
  }

  private func submit() {
    guard canSubmit else { return }
    focus = nil  // hides the keyboard
    onCreate(email, password)
  }
}
