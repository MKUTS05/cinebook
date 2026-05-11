import CoreData
import SwiftUI

struct HomeView: View {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Movie.title, ascending: true)],
        animation: .default
    ) private var movies: FetchedResults<Movie>

    @State private var selectedGenre: String? = nil

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var genres: [String] {
        Array(Set(movies.compactMap(\.genre))).sorted()
    }

    private var filteredMovies: [Movie] {
        guard let genre = selectedGenre else { return Array(movies) }
        return movies.filter { $0.genre == genre }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Header
                Text("CineBook")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                Text("Now Showing")
                    .font(.title)
                    .fontWeight(.heavy)
                    .padding(.horizontal)

                // MARK: - Category Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(genres, id: \.self) { genre in
                            let isSelected = selectedGenre == genre
                            Button {
                                selectedGenre = isSelected ? nil : genre
                            } label: {
                                Text(genre)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(isSelected ? Color.blue.opacity(0.15) : Color.clear)
                                            .overlay(
                                                Capsule().stroke(
                                                    isSelected ? Color.blue : Color.gray,
                                                    lineWidth: 1
                                                )
                                            )
                                    )
                                    .foregroundColor(isSelected ? .blue : .primary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }

                // MARK: - Movie Grid
                if filteredMovies.isEmpty {
                    ContentUnavailableView("No movies", systemImage: "film")
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(filteredMovies, id: \.objectID) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                MovieCardView(movie: movie)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
