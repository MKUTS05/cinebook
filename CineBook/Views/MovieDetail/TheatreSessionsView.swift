import CoreData
import SwiftUI

struct TheatreSessionsView: View {

    let theatre: Theatre
    let movie: Movie
    @ObservedObject var sessionVM: SessionViewModel

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        let groups = sessionVM.sessionsByDate(for: theatre)

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Theatre Badge
                HStack(spacing: 12) {
                    Image(systemName: "film.stack")
                        .font(.title2)
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(theatre.displayName)
                            .font(.headline)
                        Text(theatre.typeName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                if groups.isEmpty {
                    ContentUnavailableView(
                        "No Sessions",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("No sessions available for this screen.")
                    )
                    .padding(.top, 40)
                } else {
                    // MARK: - Sessions by Date
                    ForEach(groups, id: \.date) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(group.label)
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(group.sessions, id: \.objectID) { session in
                                        let full = sessionVM.isFull(session)
                                        NavigationLink(destination: SeatPickerView(session: session)) {
                                            sessionButton(session: session, full: full)
                                        }
                                        .disabled(full)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(movie.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func sessionButton(session: Session, full: Bool) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                Text(timeString(session.dateTime))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(String(format: "$%.2f", session.price))
                    .font(.caption)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background((full ? Color.gray : Color.blue).opacity(0.1))
            .foregroundColor(full ? .gray : .blue)
            .cornerRadius(10)

            if full {
                Text("FULL")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.gray)
                    .cornerRadius(3)
                    .offset(x: 4, y: -4)
            }
        }
    }

    private func timeString(_ date: Date?) -> String {
        guard let date else { return "—" }
        return Self.timeFormatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        TheatreSessionsView(
            theatre: Theatre(roomNumber: 1),
            movie: {
                let ctx = PersistenceController.preview.container.viewContext
                return try! ctx.fetch(Movie.fetchRequest()).first!
            }(),
            sessionVM: {
                let ctx = PersistenceController.preview.container.viewContext
                let movie = try! ctx.fetch(Movie.fetchRequest()).first!
                return SessionViewModel(movie: movie)
            }()
        )
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
