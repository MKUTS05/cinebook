import CoreData
import SwiftUI

struct BookingConfirmView: View {

    let session: Session
    let selectedSeats: [Seat]

    @StateObject private var bookingVM: BookingViewModel
    @EnvironmentObject private var appState: AppState
    @State private var isBooking = false
    @State private var confirmationMessage: String?
    @State private var errorMessage: String?
    @State private var customerName = ""

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    init(session: Session, selectedSeats: [Seat]) {
        self.session = session
        self.selectedSeats = selectedSeats
        guard let ctx = session.managedObjectContext else {
            preconditionFailure("BookingConfirmView requires a session with a managed object context")
        }
        _bookingVM = StateObject(wrappedValue: BookingViewModel(context: ctx))
    }

    private var seatListString: String {
        selectedSeats.map { "\($0.row ?? "")\($0.number)" }.joined(separator: ", ")
    }

    private var trimmedName: String { customerName.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        VStack(spacing: 20) {
            Text("Confirm Booking")
                .font(.title)

            Text("Movie: \(session.movie?.title ?? "")")
            Text("Time: \(session.dateTime.map { Self.timeFormatter.string(from: $0) } ?? "—")")
            Text("Seats: \(seatListString)")
                .multilineTextAlignment(.center)

            TextField("Your name", text: $customerName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            if let msg = confirmationMessage {
                Text(msg)
                    .foregroundColor(.green)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if let msg = errorMessage {
                Text(msg)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            Button(action: confirmBooking) {
                Group {
                    if isBooking && confirmationMessage == nil {
                        ProgressView().tint(.white)
                    } else {
                        Text("Confirm Booking")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background((trimmedName.isEmpty || isBooking) ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(trimmedName.isEmpty || isBooking)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.top)
    }

    private func confirmBooking() {
        guard !isBooking else { return }
        errorMessage = nil
        isBooking = true
        do {
            try bookingVM.createBooking(
                session: session,
                seats: selectedSeats,
                customerName: trimmedName
            )
            confirmationMessage = "Booking confirmed! Taking you to your bookings…"
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                appState.moviesPath = NavigationPath()
                appState.selectedTab = 1
            }
        } catch let e as BookingError {
            errorMessage = e.localizedDescription
            isBooking = false
        } catch {
            errorMessage = error.localizedDescription
            isBooking = false
        }
    }
}
