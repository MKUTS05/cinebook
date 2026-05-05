//
//  DataSeeder.swift
//  CineBook
//
//  Pre-populates the Core Data store with sample movies, sessions and seats
//  on first launch (or any time the database is empty).
//

import CoreData
import Foundation

enum DataSeeder {

    // MARK: - Public API

    /// Seeds the store only when no movies exist yet. Safe to call on every launch.
    static func seedIfNeeded(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.fetchLimit = 1

        let existingCount = (try? context.count(for: request)) ?? 0
        guard existingCount == 0 else { return }

        seed(in: context)
    }

    // MARK: - Sample Data

    /// Hard-coded sample catalogue. Matches assets we expect under `Resources/`.
    private static let sampleMovies: [SampleMovie] = [
        SampleMovie(
            title: "Interstellar Echoes",
            genre: "Sci-Fi",
            duration: 165,
            synopsis: "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",
            posterImageName: "poster_interstellar_echoes"
        ),
        SampleMovie(
            title: "Midnight Garden",
            genre: "Drama",
            duration: 124,
            synopsis: "A grieving novelist finds unexpected solace in a mysterious greenhouse that only blooms after dark.",
            posterImageName: "poster_midnight_garden"
        ),
        SampleMovie(
            title: "Velocity Run",
            genre: "Action",
            duration: 108,
            synopsis: "An ex-getaway driver is pulled back into the underworld for one last impossible heist.",
            posterImageName: "poster_velocity_run"
        ),
        SampleMovie(
            title: "Paper Crowns",
            genre: "Comedy",
            duration: 96,
            synopsis: "Two rival office workers fake-marry to inherit a quirky uncle's printer empire.",
            posterImageName: "poster_paper_crowns"
        ),
        SampleMovie(
            title: "The Lighthouse Keeper",
            genre: "Mystery",
            duration: 132,
            synopsis: "On a remote island, a new keeper begins to suspect the previous one never actually left.",
            posterImageName: "poster_lighthouse_keeper"
        )
    ]

    /// Rows A–H, seats 1–10 — a standard 80-seat layout per session.
    private static let seatRows: [String] = ["A", "B", "C", "D", "E", "F", "G", "H"]
    private static let seatsPerRow: ClosedRange<Int16> = 1...10

    // MARK: - Seeding

    private static func seed(in context: NSManagedObjectContext) {
        let calendar = Calendar.current
        let today = Date()

        for (movieIndex, sample) in sampleMovies.enumerated() {
            let movie = Movie(context: context)
            movie.id = UUID()
            movie.title = sample.title
            movie.genre = sample.genre
            movie.duration = sample.duration
            movie.synopsis = sample.synopsis
            movie.posterImageName = sample.posterImageName

            // 3 sessions per movie, spread across the next three days at 14:00 / 17:00 / 20:00.
            for sessionIndex in 0..<3 {
                let session = makeSession(
                    for: movie,
                    movieIndex: movieIndex,
                    sessionIndex: sessionIndex,
                    today: today,
                    calendar: calendar,
                    in: context
                )
                attachFullSeatLayout(to: session, in: context)
            }
        }

        do {
            try context.save()
        } catch {
            assertionFailure("DataSeeder failed to save initial content: \(error)")
        }
    }

    private static func makeSession(
        for movie: Movie,
        movieIndex: Int,
        sessionIndex: Int,
        today: Date,
        calendar: Calendar,
        in context: NSManagedObjectContext
    ) -> Session {
        let session = Session(context: context)
        session.id = UUID()
        session.movie = movie

        let daysAhead = sessionIndex + 1
        let hour = 14 + sessionIndex * 3 // 14:00, 17:00, 20:00
        let baseDay = calendar.date(byAdding: .day, value: daysAhead, to: today) ?? today
        session.dateTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: baseDay) ?? baseDay

        // Cycle through 5 cinema rooms.
        session.roomNumber = Int16(((movieIndex + sessionIndex) % 5) + 1)
        // $12.50 base, +$1.50 for each later showtime.
        session.price = 12.50 + Double(sessionIndex) * 1.50

        return session
    }

    private static func attachFullSeatLayout(to session: Session, in context: NSManagedObjectContext) {
        for row in seatRows {
            for number in seatsPerRow {
                let seat = Seat(context: context)
                seat.id = UUID()
                seat.row = row
                seat.number = number
                seat.isBooked = false
                seat.session = session
            }
        }
    }
}

// MARK: - Helpers

private struct SampleMovie {
    let title: String
    let genre: String
    let duration: Int16
    let synopsis: String
    let posterImageName: String
}
