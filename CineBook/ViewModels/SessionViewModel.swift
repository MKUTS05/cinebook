import Combine
import CoreData
import Foundation

@MainActor
final class SessionViewModel: ObservableObject {
    @Published private(set) var sessions: [Session] = []
    @Published private(set) var sessionsByDate: [(date: Date, label: String, sessions: [Session])] = []
    @Published private(set) var theatres: [Theatre] = []

    private let context: NSManagedObjectContext
    private let movie: Movie

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    init(movie: Movie) {
        self.movie = movie
        guard let ctx = movie.managedObjectContext else {
            preconditionFailure("SessionViewModel requires a movie with a managed object context")
        }
        self.context = ctx
        fetch()
        // Note: sessions are not observed for live updates. For live seat-availability
        // changes, use NSFetchedResultsController or .NSManagedObjectContextObjectsDidChange.
    }

    private func fetch() {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "movie == %@", movie)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Session.dateTime, ascending: true)]
        sessions = (try? context.fetch(request)) ?? []
        sessionsByDate = groupByDate(sessions)
        theatres = Array(Set(sessions.map { Theatre(roomNumber: $0.roomNumber) }))
            .sorted { $0.roomNumber < $1.roomNumber }
    }

    /// Sessions for a specific theatre, grouped into date buckets.
    func sessionsByDate(for theatre: Theatre) -> [(date: Date, label: String, sessions: [Session])] {
        groupByDate(sessions.filter { $0.roomNumber == theatre.roomNumber })
    }

    func isFull(_ session: Session) -> Bool {
        guard let seats = session.seats as? Set<Seat>, !seats.isEmpty else { return false }
        return seats.allSatisfy { $0.isBooked }
    }

    // MARK: - Private

    private func groupByDate(_ input: [Session]) -> [(date: Date, label: String, sessions: [Session])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let grouped = Dictionary(grouping: input) { session in
            calendar.startOfDay(for: session.dateTime ?? .distantFuture)
        }

        return grouped.keys.sorted().map { date in
            let label: String
            if calendar.isDate(date, inSameDayAs: today) {
                label = "Today"
            } else if calendar.isDate(date, inSameDayAs: tomorrow) {
                label = "Tomorrow"
            } else {
                label = Self.dateFormatter.string(from: date)
            }
            let sorted = grouped[date]!.sorted {
                ($0.dateTime ?? .distantFuture) < ($1.dateTime ?? .distantFuture)
            }
            return (date: date, label: label, sessions: sorted)
        }
    }
}
