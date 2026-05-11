import Combine
import CoreData
import Foundation

@MainActor
final class SeatViewModel: ObservableObject {
    @Published private(set) var seats: [Seat] = []
    @Published private(set) var selectedSeats: Set<NSManagedObjectID> = []
    @Published private(set) var seatGrid: [(rowLabel: String, seats: [Seat])] = []

    private let context: NSManagedObjectContext
    let session: Session
    private var contextObserver: AnyCancellable?

    init(session: Session) {
        self.session = session
        guard let ctx = session.managedObjectContext else {
            preconditionFailure("SeatViewModel requires a session with a managed object context")
        }
        self.context = ctx
        fetch()
        contextObserver = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextObjectsDidChange, object: ctx)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.fetch() }
    }

    private func fetch() {
        let request: NSFetchRequest<Seat> = Seat.fetchRequest()
        request.predicate = NSPredicate(format: "session == %@", session)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Seat.row, ascending: true),
            NSSortDescriptor(keyPath: \Seat.number, ascending: true)
        ]
        seats = (try? context.fetch(request)) ?? []
        buildGrid()
        pruneBookedSelections()
    }

    private func buildGrid() {
        let rows = Array(Set(seats.compactMap(\.row))).sorted()
        seatGrid = rows.map { rowLabel in
            (rowLabel: rowLabel,
             seats: seats.filter { $0.row == rowLabel }.sorted { $0.number < $1.number })
        }
    }

    private func pruneBookedSelections() {
        let bookedIDs = Set(seats.filter(\.isBooked).map(\.objectID))
        selectedSeats.subtract(bookedIDs)
    }

    func toggle(_ seat: Seat) {
        guard !seat.isBooked else { return }
        if selectedSeats.contains(seat.objectID) {
            selectedSeats.remove(seat.objectID)
        } else {
            selectedSeats.insert(seat.objectID)
        }
    }

    func isSelected(_ seat: Seat) -> Bool {
        selectedSeats.contains(seat.objectID)
    }

    var selectedSeatObjects: [Seat] {
        seats.filter { selectedSeats.contains($0.objectID) }
    }

    var totalPrice: Double {
        Double(selectedSeatObjects.count) * session.price
    }

    var selectedSeatString: String {
        let names = selectedSeatObjects.map { "\($0.row ?? "")\($0.number)" }
        return names.isEmpty ? "None" : names.joined(separator: ", ")
    }
}
