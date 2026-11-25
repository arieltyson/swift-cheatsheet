import SwiftUI

struct Recipe: Identifiable, Hashable {
  let id: Int
  let name: String
}

/// Push by VALUE: the link carries data, navigationDestination says
/// which screen shows it. The path array IS the back stack.
struct RecipesScreen: View {
  let recipes: [Recipe]
  @State private var path: [Recipe] = []

  var body: some View {
    NavigationStack(path: $path) {
      List(recipes) { recipe in
        NavigationLink(recipe.name, value: recipe)
      }
      .navigationTitle("Recipes")
      // Once per type, on the stack's content (not inside the List)
      .navigationDestination(for: Recipe.self) { recipe in
        RecipeDetail(recipe: recipe, popToRoot: { path.removeAll() })
      }
      .toolbar {
        // Push from code: append to the path
        Button("Open first") {
          if let first = recipes.first { path.append(first) }
        }
      }
    }
  }
}

struct RecipeDetail: View {
  let recipe: Recipe
  let popToRoot: () -> Void

  var body: some View {
    VStack(spacing: 16) {
      Text(recipe.name).font(.title2)
      Button("Back to all recipes", action: popToRoot)
    }
    .navigationTitle(recipe.name)
    .navigationBarTitleDisplayMode(.inline)
  }
}

/// NavigationPath holds values of DIFFERENT types; [Recipe] can't.
struct MixedRoutesScreen: View {
  @State private var path = NavigationPath()

  var body: some View {
    NavigationStack(path: $path) {
      List {
        NavigationLink("Pasta", value: Recipe(id: 1, name: "Pasta"))
        NavigationLink("Step 2", value: 2)  // an Int route
      }
      .navigationDestination(for: Recipe.self) { Text($0.name) }
      .navigationDestination(for: Int.self) { Text("Step \($0)") }
      .toolbar {
        Button("Back") { if !path.isEmpty { path.removeLast() } }
      }
    }
  }
}

/// Sidebar + detail. Two columns on iPad and Mac; on iPhone it
/// collapses into a stack automatically.
struct RecipeSplitView: View {
  let recipes: [Recipe]
  @State private var selection: Recipe?

  var body: some View {
    NavigationSplitView {
      List(recipes, selection: $selection) { recipe in
        NavigationLink(recipe.name, value: recipe)
      }
      .navigationTitle("Recipes")
    } detail: {
      if let selection {
        RecipeDetail(recipe: selection) { self.selection = nil }
      } else {
        ContentUnavailableView(
          "Pick a recipe", systemImage: "fork.knife")
      }
    }
  }
}
