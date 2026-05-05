//
//  ContentView.swift
//  CineBook
//
//  Placeholder root view that proves the Core Data stack and seeder are wired up
//  by listing every seeded movie. Replace with a proper home view once the
//  feature screens under Views/Home/ are built out.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Movie.title, ascending: true)],
        animation: .default
    )
    private var movies: FetchedResults<Movie>

    var body: some View {
        NavigationStack {
            Group {
                if movies.isEmpty {
                    ContentUnavailableView(
                        "No movies yet",
                        systemImage: "film",
                        description: Text("Seeded data should appear on first launch.")
                    )
                } else {
                    List(movies, id: \.objectID) { movie in
                        MovieRow(movie: movie)
                    }
                }
            }
            .navigationTitle("CineBook")
        }
    }
}

private struct MovieRow: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(movie.title ?? "Untitled")
                .font(.headline)
            HStack(spacing: 6) {
                Text(movie.genre ?? "—")
                Text("·")
                Text("\(movie.duration) min")
                Text("·")
                Text("\(movie.sessions?.count ?? 0) sessions")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
