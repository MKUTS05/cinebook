import CoreData
import SwiftUI

struct MovieDetailView: View {

    let movie: Movie
    @StateObject private var sessionVM: SessionViewModel

    init(movie: Movie) {
        self.movie = movie
        _sessionVM = StateObject(wrappedValue: SessionViewModel(movie: movie))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Hero Poster
                Group {
                    if let name = movie.posterImageName, UIImage(named: name) != nil {
                        Image(name)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Text("HERO POSTER")
                                    .foregroundColor(.gray)
                                    .font(.headline)
                            )
                    }
                }
                .frame(height: 350)
                .clipped()

                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Title & Metadata
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(movie.title ?? "")
                                .font(.largeTitle)
                                .fontWeight(.heavy)

                            HStack {
                                Text(movie.genre ?? "")
                                Text("•")
                                Text("\(movie.duration) min")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        Spacer()
                    }

                    Divider()

                    // MARK: - Synopsis
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SYNOPSIS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .tracking(1.5)

                        Text(movie.synopsis ?? "")
                            .font(.body)
                            .lineSpacing(4)
                    }

                    Divider()

                    // MARK: - Theatre Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SELECT THEATRE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .tracking(1.5)

                        if sessionVM.theatres.isEmpty {
                            Text("No sessions available")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        } else {
                            let now = Date()
                            ForEach(sessionVM.theatres) { theatre in
                                let theatreSessions = sessionVM.sessions.filter {
                                    $0.roomNumber == theatre.roomNumber
                                }
                                // soldOut = every session has all seats booked
                                let soldOut = theatreSessions.allSatisfy { sessionVM.isFull($0) }
                                // upcoming = future sessions that still have seats
                                let upcoming = theatreSessions.filter {
                                    ($0.dateTime ?? .distantPast) > now && !sessionVM.isFull($0)
                                }.count
                                let minPrice = theatreSessions.map(\.price).min() ?? 0

                                NavigationLink(destination: TheatreSessionsView(
                                    theatre: theatre,
                                    movie: movie,
                                    sessionVM: sessionVM
                                )) {
                                    TheatreCard(
                                        theatre: theatre,
                                        upcomingCount: upcoming,
                                        soldOut: soldOut,
                                        minPrice: minPrice
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

}

private struct TheatreCard: View {
    let theatre: Theatre
    let upcomingCount: Int
    let soldOut: Bool
    let minPrice: Double

    private var dimmed: Bool { upcomingCount == 0 }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "film.stack")
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(theatre.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(theatre.typeName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                if soldOut {
                    Text("Sold out")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if upcomingCount == 0 {
                    Text("No upcoming")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(upcomingCount) session\(upcomingCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "from $%.2f", minPrice))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .opacity(dimmed ? 0.5 : 1)
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: {
            let ctx = PersistenceController.preview.container.viewContext
            return try! ctx.fetch(Movie.fetchRequest()).first!
        }())
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
