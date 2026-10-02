import Foundation

/// LocalizedError gives localizedDescription a readable message.
enum TransferError: LocalizedError, Equatable {
  case invalidAmount(String)
  case insufficientFunds(needed: Int)
  case accountLocked

  var errorDescription: String? {
    switch self {
    case .invalidAmount(let text): "\"\(text)\" is not an amount"
    case .insufficientFunds(let needed): "Needs \(needed) more cents"
    case .accountLocked: "This account is locked"
    }
  }
}

/// Parses "12.50" into cents, or throws.
func parseCents(_ text: String) throws(TransferError) -> Int {
  guard let amount = Decimal(string: text), amount > 0 else {
    throw .invalidAmount(text)
  }
  return NSDecimalNumber(decimal: amount * 100).intValue
}

func withdraw(_ text: String, from balance: Int) throws -> Int {
  let cents = try parseCents(text)
  guard cents <= balance else {
    throw TransferError.insufficientFunds(needed: cents - balance)
  }
  return balance - cents
}

func demoDoCatch() {
  var message = ""
  do {
    _ = try withdraw("30.00", from: 1_000)
  } catch TransferError.insufficientFunds(let needed) {
    message = "short by \(needed)"
  } catch let error as TransferError {
    message = error.localizedDescription
  } catch {
    // Every other error; the error constant is implicit
    message = "unexpected: \(error)"
  }
  assert(message == "short by 2000")
  let error = TransferError.invalidAmount("abc")
  assert(error.localizedDescription == "\"abc\" is not an amount")
}

func demoTryVariants() {
  // try? turns any error into nil
  assert((try? withdraw("5", from: 1_000)) == 500)
  assert((try? withdraw("x", from: 1_000)) == nil)
  // try! crashes on error: only when failure is a bug
  let fixed = try! parseCents("1.25")
  assert(fixed == 125)
  // Typed throws: the catch knows the error is a TransferError
  do {
    _ = try parseCents("-1")
  } catch {
    assert(error == .invalidAmount("-1"))
  }
}

func demoDefer() {
  var log: [String] = []
  func process(_ text: String) throws {
    log.append("open")
    // Runs when the scope exits, whether it returns or throws
    defer { log.append("close") }
    _ = try parseCents(text)
    log.append("done")
  }
  try? process("oops")
  assert(log == ["open", "close"])
}

func demoResult() {
  // Result stores success or failure as a value, for later or callbacks
  let results = ["1.00", "abc"].map { text in
    Result { try parseCents(text) }
  }
  let messages = results.map { result in
    switch result {
    case .success(let cents): "\(cents) cents"
    case .failure(let error): error.localizedDescription
    }
  }
  assert(messages == ["100 cents", "\"abc\" is not an amount"])
  assert((try? results[1].get()) == nil)
  let doubled = results[0].map { $0 * 2 }
  assert((try? doubled.get()) == 200)
}
