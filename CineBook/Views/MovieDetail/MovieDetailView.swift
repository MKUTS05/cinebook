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

                    // MARK: - Sessions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SESSIONS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .tracking(1.5)

                        if sessionVM.sessionsByDate.isEmpty {
                            Text("No sessions available")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        } else {
                            ForEach(sessionVM.sessionsByDate, id: \.date) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(group.label)
                                        .font(.headline)

                                    ForEach(group.sessions, id: \.objectID) { session in
                                        let full = sessionVM.isFull(session)
                                        HStack(spacing: 16) {
                                            Text("Room \(session.roomNumber)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .frame(width: 64, alignment: .leading)

                                            NavigationLink(destination: SeatPickerView(session: session)) {
                                                Text(timeString(session.dateTime))
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        (full ? Color.gray : Color.blue).opacity(0.1)
                                                    )
                                                    .foregroundColor(full ? .gray : .blue)
                                                    .cornerRadius(8)
                                            }
                                            .disabled(full)

                                            if full {
                                                Text("Full")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    private func timeString(_ date: Date?) -> String {
        guard let date else { return "—" }
        return Self.timeFormatter.string(from: date)
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
