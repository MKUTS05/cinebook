import CoreData
import SwiftUI

struct BookingDetailView: View {

    let booking: Booking

    @StateObject private var bookingVM: BookingViewModel
    @State private var showCancelAlert = false
    @State private var cancelError: String?
    @Environment(\.dismiss) private var dismiss

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    init(booking: Booking) {
        self.booking = booking
        guard let ctx = booking.managedObjectContext else {
            preconditionFailure("BookingDetailView requires a booking with a managed object context")
        }
        _bookingVM = StateObject(wrappedValue: BookingViewModel(context: ctx))
    }

    private var isUpcoming: Bool {
        (booking.session?.dateTime ?? .distantPast) > Date()
    }

    private var referenceNumber: String {
        booking.id.map { String($0.uuidString.prefix(8)).uppercased() } ?? "—"
    }

    private var seatList: String {
        guard let seats = booking.seats as? Set<Seat> else { return "—" }
        return seats
            .sorted { "\($0.row ?? "")\($0.number)" < "\($1.row ?? "")\($1.number)" }
            .map { "\($0.row ?? "")\($0.number)" }
            .joined(separator: ", ")
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(booking.session?.movie?.title ?? "")
                .font(.title)

            Text("Time: \(timeString(booking.session?.dateTime))")
            Text("Seats: \(seatList)")

            Text("Ref: \(referenceNumber)")
                .font(.caption)
                .foregroundColor(.secondary)

            if let err = cancelError {
                Text(err)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if isUpcoming {
                Button("Cancel Booking") {
                    showCancelAlert = true
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .alert("Cancel Booking?", isPresented: $showCancelAlert) {
            Button("Cancel Booking", role: .destructive) {
                cancelError = nil
                do {
                    try bookingVM.cancelBooking(booking)
                    dismiss()
                } catch {
                    cancelError = error.localizedDescription
                }
            }
            Button("Keep", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
        .navigationTitle("Booking Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func timeString(_ date: Date?) -> String {
        guard let date else { return "—" }
        return Self.timeFormatter.string(from: date)
    }
}
