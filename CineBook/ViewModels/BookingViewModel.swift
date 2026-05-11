import Combine
import CoreData
import Foundation

enum BookingError: LocalizedError {
    case seatsAlreadyBooked([String])

    var errorDescription: String? {
        switch self {
        case .seatsAlreadyBooked(let names):
            return "Seats \(names.joined(separator: ", ")) were just taken. Please choose again."
        }
    }
}

// Write coordinator for booking operations.
// Reads are intentionally done via @FetchRequest in views for live SwiftUI integration.
@MainActor
final class BookingViewModel: ObservableObject {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func createBooking(session: Session, seats: [Seat], customerName: String) throws {
        let objectIDs = seats.map { $0.objectID }
        let request: NSFetchRequest<Seat> = Seat.fetchRequest()
        request.predicate = NSPredicate(format: "SELF IN %@", objectIDs)

        var thrownError: Error?
        context.performAndWait {
            do {
                let freshSeats = try context.fetch(request)

                let taken = freshSeats.filter { $0.isBooked }
                if !taken.isEmpty {
                    thrownError = BookingError.seatsAlreadyBooked(taken.map { "\($0.row ?? "")\($0.number)" })
                    return
                }

                let booking = Booking(context: context)
                booking.id = UUID()
                booking.bookingDate = Date()
                booking.customerName = customerName
                booking.totalPrice = Double(freshSeats.count) * session.price
                booking.session = session

                for seat in freshSeats {
                    seat.isBooked = true
                    booking.addToSeats(seat)
                }

                try context.save()
            } catch {
                thrownError = error
            }
        }
        if let error = thrownError { throw error }
    }

    func cancelBooking(_ booking: Booking) throws {
        var thrownError: Error?
        context.performAndWait {
            do {
                if let seats = booking.seats as? Set<Seat> {
                    for seat in seats { seat.isBooked = false }
                }
                context.delete(booking)
                try context.save()
            } catch {
                thrownError = error
            }
        }
        if let error = thrownError { throw error }
    }
}
