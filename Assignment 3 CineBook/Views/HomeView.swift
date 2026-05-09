//
//  HomeView.swift
//  Assignment 3 CineBook
//
//  Created by Jovan Sutardi on 9/5/2026.
//

import SwiftUI

struct HomeView: View {
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Header
                    HStack {
                        Text("CineBook")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                    }
                    .padding(.horizontal)
                    
                    Text("Now Showing")
                        .font(.title)
                        .fontWeight(.heavy)
                        .padding(.horizontal)
                    
                    // MARK: - Category Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(MockData.categories, id: \.self) { category in
                                Text(category)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Capsule().stroke(Color.gray, lineWidth: 1))
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Movie Grid
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(MockData.movies) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                MovieCardView(movie: movie)
                            }
                            .buttonStyle(PlainButtonStyle()) 
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
    }
}


