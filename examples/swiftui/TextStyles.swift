import SwiftUI

/// Every built-in text style, largest to smallest. Styles scale with
/// the user's text size setting; fixed point sizes don't.
struct TextStyleScale: View {
  private let styles: [(String, Font)] = [
    (".largeTitle", .largeTitle), (".title", .title),
    (".title2", .title2), (".title3", .title3),
    (".headline", .headline), (".subheadline", .subheadline),
    (".body (default)", .body), (".callout", .callout),
    (".footnote", .footnote), (".caption", .caption),
    (".caption2", .caption2),
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(styles, id: \.0) { name, font in
        Text(name).font(font)
      }
    }
    .padding()
  }
}

/// Hierarchical styles fade from the main colour; they follow light
/// and dark mode, so prefer them over fixed greys.
struct ForegroundStyles: View {
  private let styles: [(String, HierarchicalShapeStyle)] = [
    (".primary (default)", .primary), (".secondary", .secondary),
    (".tertiary", .tertiary), (".quaternary", .quaternary),
    (".quinary", .quinary),
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(styles, id: \.0) { name, style in
        Text(name).foregroundStyle(style)
      }
      Text(".tint (the app accent)").foregroundStyle(.tint)
      Text(".red, .blue, ... (fixed colours)").foregroundStyle(.red)
    }
    .font(.title3)
    .padding()
  }
}
