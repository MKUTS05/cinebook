import CoreData
import Foundation

enum DataSeeder {

    // MARK: - Public API

    static func seedIfNeeded(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.fetchLimit = 1
        let existingCount = (try? context.count(for: request)) ?? 0
        guard existingCount == 0 else { return }
        seed(in: context)
    }

    // MARK: - Poster asset names

    private enum PosterAsset: String {
        case interstellarEchoes  = "poster_interstellar_echoes"
        case midnightGarden      = "poster_midnight_garden"
        case velocityRun         = "poster_velocity_run"
        case paperCrowns         = "poster_paper_crowns"
        case lighthouseKeeper    = "poster_lighthouse_keeper"
    }

    private struct SampleMovie {
        let title: String
        let genre: String
        let duration: Int16
        let synopsis: String
        let poster: PosterAsset
    }

    // MARK: - Sample Data

    private static let sampleMovies: [SampleMovie] = [
        SampleMovie(
            title: "Interstellar Echoes",
            genre: "Sci-Fi",
            duration: 165,
            synopsis: "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",
            poster: .interstellarEchoes
        ),
        SampleMovie(
            title: "Midnight Garden",
            genre: "Drama",
            duration: 124,
            synopsis: "A grieving novelist finds unexpected solace in a mysterious greenhouse that only blooms after dark.",
            poster: .midnightGarden
        ),
        SampleMovie(
            title: "Velocity Run",
            genre: "Action",
            duration: 108,
            synopsis: "An ex-getaway driver is pulled back into the underworld for one last impossible heist.",
            poster: .velocityRun
        ),
        SampleMovie(
            title: "Paper Crowns",
            genre: "Comedy",
            duration: 96,
            synopsis: "Two rival office workers fake-marry to inherit a quirky uncle's printer empire.",
            poster: .paperCrowns
        ),
        SampleMovie(
            title: "The Lighthouse Keeper",
            genre: "Mystery",
            duration: 132,
            synopsis: "On a remote island, a new keeper begins to suspect the previous one never actually left.",
            poster: .lighthouseKeeper
        )
    ]

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
            movie.posterImageName = sample.poster.rawValue

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
        let hour = 14 + sessionIndex * 3
        let baseDay = calendar.date(byAdding: .day, value: daysAhead, to: today) ?? today
        session.dateTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: baseDay) ?? baseDay

        session.roomNumber = Int16(((movieIndex + sessionIndex) % 5) + 1)
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
