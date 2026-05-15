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

    // Each room's number and the price surcharge over the base price.
    private static let rooms: [(number: Int16, surcharge: Double)] = [
        (number: 1, surcharge: 0.00),   // Standard
        (number: 2, surcharge: 0.00),   // Standard
        (number: 3, surcharge: 5.00),   // IMAX
        (number: 4, surcharge: 3.00),   // Premium
        (number: 5, surcharge: 7.00),   // Gold Class
    ]

    // Time slots seeded per room per day, with a small price increment for later shows.
    private static let timeSlots: [(hour: Int, minute: Int, surcharge: Double)] = [
        (hour: 10, minute: 30, surcharge: 0.00),
        (hour: 13, minute: 00, surcharge: 0.00),
        (hour: 16, minute: 00, surcharge: 1.00),
        (hour: 19, minute: 00, surcharge: 1.50),
        (hour: 21, minute: 30, surcharge: 2.00),
    ]

    private static let daysToSeed = 3
    private static let basePrice  = 12.50

    private static let seatRows: [String] = ["A", "B", "C", "D", "E", "F", "G", "H"]
    private static let seatsPerRow: ClosedRange<Int16> = 1...10

    // MARK: - Seeding

    private static func seed(in context: NSManagedObjectContext) {
        let calendar = Calendar.current
        let today = Date()

        for sample in sampleMovies {
            let movie = Movie(context: context)
            movie.id        = UUID()
            movie.title     = sample.title
            movie.genre     = sample.genre
            movie.duration  = sample.duration
            movie.synopsis  = sample.synopsis
            movie.posterImageName = sample.poster.rawValue

            for room in rooms {
                for daysAhead in 1...daysToSeed {
                    let baseDay = calendar.date(byAdding: .day, value: daysAhead, to: today) ?? today
                    for slot in timeSlots {
                        let session = Session(context: context)
                        session.id         = UUID()
                        session.movie      = movie
                        session.roomNumber = room.number
                        session.price      = basePrice + room.surcharge + slot.surcharge
                        session.dateTime   = calendar.date(
                            bySettingHour: slot.hour,
                            minute: slot.minute,
                            second: 0,
                            of: baseDay
                        ) ?? baseDay
                        attachFullSeatLayout(to: session, in: context)
                    }
                }
            }
        }

        do {
            try context.save()
        } catch {
            assertionFailure("DataSeeder failed to save initial content: \(error)")
        }
    }

    private static func attachFullSeatLayout(to session: Session, in context: NSManagedObjectContext) {
        for row in seatRows {
            for number in seatsPerRow {
                let seat      = Seat(context: context)
                seat.id       = UUID()
                seat.row      = row
                seat.number   = number
                seat.isBooked = false
                seat.session  = session
            }
        }
    }
}
