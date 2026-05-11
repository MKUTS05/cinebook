import CoreData
import SwiftUI

struct MyBookingsView: View {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Booking.bookingDate, ascending: false)],
        animation: .default
    ) private var bookings: FetchedResults<Booking>

    var body: some View {
        let now = Date()
        let upcoming = bookings.filter { ($0.session?.dateTime ?? .distantPast) > now }
        let past = bookings.filter { ($0.session?.dateTime ?? .distantPast) <= now }

        Group {
            if bookings.isEmpty {
                ContentUnavailableView(
                    "No Bookings",
                    systemImage: "ticket",
                    description: Text("Your bookings will appear here.")
                )
            } else {
                List {
                    if !upcoming.isEmpty {
                        Section("Upcoming") {
                            ForEach(upcoming, id: \.objectID) { booking in
                                NavigationLink(destination: BookingDetailView(booking: booking)) {
                                    BookingRow(booking: booking)
                                }
                            }
                        }
                    }
                    if !past.isEmpty {
                        Section("Past") {
                            ForEach(past, id: \.objectID) { booking in
                                NavigationLink(destination: BookingDetailView(booking: booking)) {
                                    BookingRow(booking: booking)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("My Bookings")
    }
}

private struct BookingRow: View {
    let booking: Booking

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(booking.session?.movie?.title ?? "Unknown")
                .font(.headline)
            Text(sessionTimeString(booking.session?.dateTime))
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Seats: \(booking.seats?.count ?? 0)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func sessionTimeString(_ date: Date?) -> String {
        guard let date else { return "—" }
        return Self.timeFormatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        MyBookingsView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
