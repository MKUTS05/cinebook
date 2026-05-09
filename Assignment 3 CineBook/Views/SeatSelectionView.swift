//
//  SeatSelectionView.swift
//  Assignment 3 CineBook
//
//  Created by Jovan Sutardi on 9/5/2026.
//

import SwiftUI

// MARK: - Local Models

enum SeatStatus {
    case available, selected, booked
}

struct Seat: Identifiable, Equatable {
    let id = UUID()
    let row: String
    let number: Int
    var status: SeatStatus
}

struct SeatSelectionView: View {
    let movie: Movie
    
    
    @State private var grid: [[Seat]] = []
    
    let rowLabels = ["A", "B", "C", "D", "E", "F", "G", "H"]
    let columns = 6
    let ticketPrice: Double = 14.00
    
    
    var selectedSeats: [Seat] {
        grid.flatMap { $0 }.filter { $0.status == .selected }
    }
    
    var totalPrice: Double {
        Double(selectedSeats.count) * ticketPrice
    }
    
    var selectedSeatString: String {
        let seatNames = selectedSeats.map { "\($0.row)\($0.number)" }
        return seatNames.isEmpty ? "None" : seatNames.joined(separator: ", ")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header Info
            VStack(spacing: 4) {
                Text(movie.title)
                    .font(.title3)
                    .fontWeight(.bold)
                HStack {
                    Text(movie.genre)
                    Text("•")
                    Text(movie.duration)
                    Text("•")
                    Text(movie.rating)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.top)
            
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: - Screen Graphic
                    VStack(spacing: 8) {
                        Path { path in
                            path.move(to: CGPoint(x: 20, y: 20))
                            path.addQuadCurve(to: CGPoint(x: UIScreen.main.bounds.width - 60, y: 20),
                                              control: CGPoint(x: UIScreen.main.bounds.width / 2 - 20, y: -10))
                        }
                        .stroke(Color.gray.opacity(0.5), lineWidth: 3)
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
                        ForEach(0..<grid.count, id: \.self) { rowIndex in
                            HStack(spacing: 12) {
                                
                                Text(rowLabels[rowIndex])
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 20, alignment: .leading)
                                
                                
                                ForEach(0..<grid[rowIndex].count, id: \.self) { colIndex in
                                    let seat = grid[rowIndex][colIndex]
                                    
                                    SeatIcon(status: seat.status)
                                        .onTapGesture {
                                            self.toggleSeat(row: rowIndex, col: colIndex)
                                        }
                                }
                                
                                
                                Text(rowLabels[rowIndex])
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 20, alignment: .trailing)
                            }
                        }
                    }
                    
                    // MARK: - Legend
                    HStack(spacing: 24) {
                        LegendItem(status: .available, text: "Free")
                        LegendItem(status: .selected, text: "Selected")
                        LegendItem(status: .booked, text: "Booked")
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
                        Text("SEATS: \(selectedSeatString)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "$%.2f", totalPrice))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: ConfirmationView(movie: movie, selectedSeats: selectedSeats)) {
                        HStack {
                            Text("Continue")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(selectedSeats.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(selectedSeats.isEmpty)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if grid.isEmpty {
                generateMockSeats()
            }
        }
    }
    
    // MARK: - Interaction Logic
    private func toggleSeat(row: Int, col: Int) {
        var seat = grid[row][col]
        
        
        if seat.status == .booked { return }
        
        
        seat.status = (seat.status == .selected) ? .available : .selected
        
        
        grid[row][col] = seat
    }
    
    // MARK: - Mock Data Generator
    private func generateMockSeats() {
        var newGrid: [[Seat]] = []
        for r in 0..<rowLabels.count {
            var rowArray: [Seat] = []
            for c in 0..<columns {
                
                let isBooked = Int.random(in: 1...10) > 8
                let status: SeatStatus = isBooked ? .booked : .available
                
                let seat = Seat(row: rowLabels[r], number: c + 1, status: status)
                rowArray.append(seat)
            }
            newGrid.append(rowArray)
        }
        grid = newGrid
    }
}


// MARK: - Helper Views
struct SeatIcon: View {
    let status: SeatStatus
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
        
            .fill(status == .selected ? Color.blue : (status == .booked ? Color.gray.opacity(0.3) : Color.clear))
            .frame(width: 35, height: 35)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(status == .available ? Color.gray : Color.clear, lineWidth: 2)
            )
        
            .scaleEffect(status == .selected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: status)
    }
}

struct LegendItem: View {
    let status: SeatStatus
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            
            RoundedRectangle(cornerRadius: 4)
                .fill(status == .selected ? Color.blue : (status == .booked ? Color.gray.opacity(0.3) : Color.clear))
                .frame(width: 16, height: 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(status == .available ? Color.gray : Color.clear, lineWidth: 1.5)
                )
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
#Preview {
    NavigationView {
        SeatSelectionView(movie: MockData.movies[0])
    }
}
