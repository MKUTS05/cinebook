//
//  MovieCardView.swift
//  Assignment 3 CineBook
//
//  Created by Jovan Sutardi on 9/5/2026.
//

import SwiftUI

struct MovieCardView: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder for the poster image
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(2/3, contentMode: .fit)
                .cornerRadius(12)
                .overlay(
                    Text("POSTER")
                        .foregroundColor(.gray)
                        .font(.caption)
                )
            
            Text(movie.title)
                .font(.headline)
                .lineLimit(1)
            
            Text(movie.genre)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    HomeView()
}
