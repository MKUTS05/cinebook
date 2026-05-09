//
//  Models.swift
//  Assignment 3 CineBook
//
//  Created by Jovan Sutardi on 9/5/2026.
//

import Foundation


struct Movie: Identifiable {
    let id = UUID()
    let title: String
    let genre: String
    let duration: String
    let rating: String
    let synopsis: String
    let imageName: String 
}


struct MockData {
    static let movies = [
        Movie(title: "Neon Drift", genre: "Sci-Fi", duration: "2h 14m", rating: "PG13", synopsis: "In a city stitched from light, a courier discovers a memory she never lived...", imageName: "neon_drift_poster"),
        Movie(title: "Last Letter", genre: "Drama", duration: "1h 58m", rating: "M", synopsis: "A lost letter changes everything...", imageName: "last_letter_poster"),
        Movie(title: "Crimson Hour", genre: "Thriller", duration: "2h 05m", rating: "MA15+", synopsis: "Time is running out.", imageName: "crimson_hour_poster"),
        Movie(title: "Wild Coast", genre: "Adventure", duration: "1h 45m", rating: "PG", synopsis: "Survival is just the beginning.", imageName: "wild_coast_poster")
    ]
    
    static let categories = ["Action", "Drama", "Sci-Fi", "Indie"]
}
