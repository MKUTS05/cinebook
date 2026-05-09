//
//  ConfirmationView.swift
//  Assignment 3 CineBook
//
//  Created by Jovan Sutardi on 9/5/2026.
//

import SwiftUI

struct ConfirmationView: View {
    let movie: Movie
    let selectedSeats: [Seat]
    
    
    let sessionDate = "Tue May 5"
    let sessionTime = "14:30"
    let roomName = "Room 2"
    let ticketPrice: Double = 14.00
    
    var totalPrice: Double {
        Double(selectedSeats.count) * ticketPrice
    }
    
    var selectedSeatString: String {
        let seatNames = selectedSeats.map { "\($0.row)\($0.number)" }
        return seatNames.joined(separator: ", ")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Almost there.")
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    Text("Review and confirm your booking.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // MARK: - Movie Summary
                HStack(spacing: 16) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 120)
                        .cornerRadius(8)
                        .overlay(
                            Text("POSTER")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOW SHOWING")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .tracking(1.5)
                        
                        Text(movie.title)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("\(movie.genre) • \(movie.duration)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                Divider()
                
                // MARK: - Booking Details Card
                VStack(spacing: 16) {
                    DetailRow(title: "DATE", value: sessionDate)
                    DetailRow(title: "ROOM", value: roomName)
                    DetailRow(title: "TIME", value: sessionTime)
                    DetailRow(title: "SEATS", value: selectedSeatString)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                // MARK: - Payment Details
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Payment Method")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Image(systemName: "applelogo")
                            Text("Apple Pay")
                                .fontWeight(.semibold)
                        }
                    }
                    Spacer()
                    Button("Change") {
                        
                    }
                    .font(.subheadline)
                }
                .padding(.vertical, 8)
                
                Divider()
                
                // MARK: - Total & Checkout
                HStack {
                    Text("Total")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Text(String(format: "$%.2f", totalPrice))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Button(action: {
                    
                    print("Booking Confirmed!")
                }) {
                    Text("Confirm Booking")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
                
                
                Text("Free cancellation up to 2 hours before showtime")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                
            }
            .padding(.horizontal)
        }
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper View for Detail Rows
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .tracking(1.5)
                .frame(width: 60, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        
        ConfirmationView(movie: MockData.movies[0], selectedSeats: [
            Seat(row: "D", number: 4, status: .selected),
            Seat(row: "D", number: 5, status: .selected),
            Seat(row: "D", number: 6, status: .selected)
        ])
    }
}
