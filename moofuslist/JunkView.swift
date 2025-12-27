//
//  JunkView.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/24/25.
//

import SwiftUI

@Observable
class NavigationManager {
    var path: [Recipe] = [] {
        didSet {
            save()
        }
    }

    /// The URL for the JSON file that stores the navigation path.
    private static var dataURL: URL {
        .documentsDirectory.appending(path: "NavigationPath.json")
    }

    init() {
        do {
            // Load the data model from the 'NavigationPath' data file found in the Documents directory.
            let path = try load(url: NavigationManager.dataURL)
            self.path = path
        } catch {
            // Handle error.
        }
    }

    func save() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(path)
            try data.write(to: NavigationManager.dataURL)
        } catch {
            // Handle error.
        }
    }

    /// Load the navigation path from a previously saved state.
    func load(url: URL) throws -> [Recipe] {
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        let decoder = JSONDecoder()
        return try decoder.decode([Recipe].self, from: data)
    }
}


struct ContentView2: View {
    @State private var navigationManager = NavigationManager()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            List {
                NavigationLink("Mint", value: Color.mint)
                NavigationLink("Red", value: Color.red)
                NavigationLink("Apple Pie", value: Recipe.applePie)
                NavigationLink("Chocolate Cake", value: Recipe.chocolateCake)
            }
            .navigationDestination(for: Color.self) { color in
                ColorDetail(color: color, text: color.description)
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}


struct RecipeDetailView: View {
    var recipe: Recipe

    var body: some View {
        Text(recipe.description)
    }
}


enum Recipe: Identifiable, Hashable, Codable {
    case applePie
    case chocolateCake

    var id: Self { self }

    var description: String {
        switch self {
        case .applePie:
            return "Apple Pie"
        case .chocolateCake:
            return "Chocolate Cake"
        }
    }
}

struct ColorDetail: View {
    var color: Color
    var text: String


    var body: some View {
        VStack {
            Text(text)
            color
         }
    }
}

struct JunkView: View {
  var body: some View {
    ContentView2()
  }
}

#Preview {
  JunkView()
}
