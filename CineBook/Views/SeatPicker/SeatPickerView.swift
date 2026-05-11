import CoreData
import SwiftUI

struct SeatPickerView: View {

    @StateObject private var seatVM: SeatViewModel

    init(session: Session) {
        _seatVM = StateObject(wrappedValue: SeatViewModel(session: session))
    }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header Info
            VStack(spacing: 4) {
                Text(seatVM.session.movie?.title ?? "")
                    .font(.title3)
                    .fontWeight(.bold)
                HStack {
                    Text(seatVM.session.movie?.genre ?? "")
                    Text("•")
                    Text("\(seatVM.session.movie?.duration ?? 0) min")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.top)

            ScrollView {
                VStack(spacing: 32) {

                    // MARK: - Screen Graphic
                    VStack(spacing: 8) {
                        GeometryReader { geo in
                            Path { path in
                                path.move(to: CGPoint(x: 20, y: 20))
                                path.addQuadCurve(
                                    to: CGPoint(x: geo.size.width - 60, y: 20),
                                    control: CGPoint(x: geo.size.width / 2 - 20, y: -10)
                                )
                            }
                            .stroke(Color.gray.opacity(0.5), lineWidth: 3)
                        }
                        .frame(height: 20)

                        Text("SCREEN")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .tracking(2)
                    }
                    .padding(.top, 20)

                    // MARK: - Seat Grid
                    VStack(spacing: 12) {
                        ForEach(seatVM.seatGrid, id: \.rowLabel) { row in
                            HStack(spacing: 10) {
                                Text(row.rowLabel)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 20, alignment: .leading)

                                ForEach(row.seats, id: \.objectID) { seat in
                                    Circle()
                                        .fill(seatFill(seat))
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle().stroke(
                                                (!seat.isBooked && !seatVM.isSelected(seat))
                                                    ? Color.gray : Color.clear,
                                                lineWidth: 1.5
                                            )
                                        )
                                        .onTapGesture { seatVM.toggle(seat) }
                                }

                                Text(row.rowLabel)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 20, alignment: .trailing)
                            }
                        }
                    }

                    // MARK: - Legend
                    HStack(spacing: 24) {
                        legendItem(fill: Color.clear, bordered: true,  label: "Free")
                        legendItem(fill: Color.blue,  bordered: false, label: "Selected")
                        legendItem(fill: Color.gray.opacity(0.3), bordered: false, label: "Booked")
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal)
            }

            // MARK: - Bottom Checkout Bar
            VStack {
                Divider()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SEATS: \(seatVM.selectedSeatString)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "$%.2f", seatVM.totalPrice))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    NavigationLink(destination: BookingConfirmView(
                        session: seatVM.session,
                        selectedSeats: seatVM.selectedSeatObjects
                    )) {
                        HStack {
                            Text("Continue").fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(seatVM.selectedSeats.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(seatVM.selectedSeats.isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func seatFill(_ seat: Seat) -> Color {
        if seat.isBooked           { return Color.gray.opacity(0.3) }
        if seatVM.isSelected(seat) { return Color.blue }
        return Color.clear
    }

    @ViewBuilder
    private func legendItem(fill: Color, bordered: Bool, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(fill)
                .frame(width: 16, height: 16)
                .overlay(Circle().stroke(bordered ? Color.gray : Color.clear, lineWidth: 1.5))
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        SeatPickerView(session: {
            let ctx = PersistenceController.preview.container.viewContext
            return try! ctx.fetch(Session.fetchRequest()).first!
        }())
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
