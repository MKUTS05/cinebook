//
//  MovieDetailView.swift
//  Assignment 3 CineBook
//
//  Created by Jovan Sutardi on 9/5/2026.
//

import SwiftUI

struct MovieDetailView: View {
    
    let movie: Movie
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Hero Poster
                // In the wireframe, this spans the full width
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 350)
                    .overlay(
                        Text("HERO POSTER")
                            .foregroundColor(.gray)
                            .font(.headline)
                    )
                    // This modifier pushes the image up under the navigation bar
                    .ignoresSafeArea(edges: .top)
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Title & Metadata
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(movie.title)
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                            
                            HStack {
                                Text(movie.genre)
                                Text("•")
                                Text(movie.duration)
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Rating Badge (e.g., PG13)
                        Text(movie.rating)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().stroke(Color.primary, lineWidth: 1))
                    }
                    
                    Divider()
                    
                    // MARK: - Synopsis
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SYNOPSIS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .tracking(1.5) // Adds cinematic letter spacing
                        
                        Text(movie.synopsis)
                            .font(.body)
                            .lineSpacing(4) // Makes the paragraph easier to read
                    }
                    
                    Divider()
                    
                    // MARK: - Sessions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SESSIONS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .tracking(1.5)
                        
                        // Hardcoding the layout from the wireframe for now.
                        // Person A will eventually feed real CoreData sessions here.
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TODAY MAY 5")
                                .font(.headline)
                            
                            HStack(spacing: 16) {
                                Text("Room 2")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .leading)
                                
                                // This button will eventually navigate to the Seat Picker
                                NavigationLink(destination: Text("Seat Picker for 14:30")) {
                                    Text("14:30")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                // Pulls the text up slightly so the gap between the image and text isn't massive
                .offset(y: -20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    // Wrapping the preview in a NavigationView so we can see the back button behavior
    NavigationView {
        MovieDetailView(movie: MockData.movies[0])
    }
}
